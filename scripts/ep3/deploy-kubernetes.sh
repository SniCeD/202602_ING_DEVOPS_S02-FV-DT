#!/usr/bin/env bash
set -euo pipefail

jacoco_report=${1:?Ruta a jacoco.xml}
evidence=${2:?Directorio de evidencias}
sha=${IMAGE_TAG:?SHA publicado}
[[ "$sha" =~ ^[0-9a-f]{40}$ ]]
image="ghcr.io/sniced/202602_ing_devops_s02-fv-dt:$sha"
k=(kubectl -n ep3)
mkdir -p "$evidence"
work=$(mktemp -d)
forward_pid=

stop_forward() {
  if [[ -n "$forward_pid" ]]; then
    kill "$forward_pid" 2>/dev/null || true
    wait "$forward_pid" 2>/dev/null || true
    forward_pid=
  fi
}
trap 'stop_forward; rm -f "$work/forward.log"; rmdir "$work"' EXIT

start_forward() {
  local resource=$1 port=$2 remote=$3 path=$4
  stop_forward
  "${k[@]}" port-forward --address 127.0.0.1 "$resource" "$port:$remote" >"$work/forward.log" 2>&1 &
  forward_pid=$!
  if ! curl --silent --show-error --fail --retry 15 --retry-delay 1 --retry-all-errors \
      --max-time 5 "http://127.0.0.1:$port$path" >/dev/null; then
    cat "$work/forward.log" >&2
    return 1
  fi
}

# Comprobar el reporte antes de modificar el clúster.
python3 scripts/ep3/ci-metrics.py "$jacoco_report" 0 >/dev/null
printf 'SHA de GitHub: %s\nImagen: %s\n' "$sha" "$image"
kubectl create namespace ep3 --dry-run=client -o yaml | kubectl apply -f -
deployed_from=$SECONDS
"${k[@]}" apply -f k8s/service.yaml
kubectl set image --local -f k8s/deployment.yaml "cuentas-svc=$image" -o yaml | "${k[@]}" apply -f -
"${k[@]}" rollout status deployment/cuentas-svc --timeout=300s
"${k[@]}" get deployment cuentas-svc -o json | jq -e --arg image "$image" '
  .spec.replicas == 2 and .status.readyReplicas == 2 and .status.availableReplicas == 2
  and .status.updatedReplicas == 2 and .spec.template.spec.containers[0].image == $image' >/dev/null
"${k[@]}" get service cuentas-svc -o json | jq -e '
  .spec.type == "ClusterIP" and .spec.selector.app == "cuentas-svc"
  and any(.spec.ports[]; .port == 80 and .targetPort == 8080)' >/dev/null
pods_json=$("${k[@]}" get pods -l app=cuentas-svc -o json)
pods=$(jq -ce --arg image "$image" '
  [.items[] | select(.metadata.deletionTimestamp == null) |
   .metadata.name as $name | .status.containerStatuses[]? |
   select(.name == "cuentas-svc" and .ready and .image == $image and (.imageID | length > 0)) |
   {name: $name, image, imageID}] | select(length == 2)' <<<"$pods_json")
printf '%s\n' "$pods" | jq . | tee "$evidence/replicas.json"
for attempt in {1..10}; do
  "${k[@]}" get endpointslices -l kubernetes.io/service-name=cuentas-svc -o json >"$evidence/endpoints.json"
  if jq -e --argjson pods "$pods" '
    ([.items[].endpoints[] | select(.conditions.ready == true) | .targetRef.name] | unique)
    == ($pods | map(.name) | sort)' "$evidence/endpoints.json" >/dev/null; then
    break
  fi
  if ((attempt == 10)); then
    echo "El Service no apunta a las dos réplicas listas." >&2
    exit 1
  fi
  sleep 2
done
start_forward svc/cuentas-svc 18080 80 /
pod_names=$(jq -r '.[].name' <<<"$pods")
while IFS= read -r pod; do
  start_forward "pod/$pod" 18080 8080 /actuator/health/readiness
  for probe in liveness readiness; do
    curl -fsS --max-time 5 "http://127.0.0.1:18080/actuator/health/$probe" | jq -e '.status == "UP"' >/dev/null
    printf '%s %s=UP\n' "$pod" "$probe"
  done
done <<<"$pod_names"
deployment_seconds=$((SECONDS - deployed_from))
stop_forward
python3 scripts/ep3/ci-metrics.py "$jacoco_report" "$deployment_seconds" | tee "$evidence/ci-metrics.prom"

"${k[@]}" apply -k monitoring/k8s
for component in prometheus grafana pushgateway; do
  "${k[@]}" rollout status "deployment/$component" --timeout=300s
done

start_forward svc/pushgateway 19091 9091 /-/ready
push_since=$(date +%s)
curl -fsS --max-time 15 --request PUT --header 'Content-Type: text/plain; version=0.0.4' \
  --data-binary "@$evidence/ci-metrics.prom" http://127.0.0.1:19091/metrics/job/novabank-ci

start_forward svc/grafana 13000 3000 /api/health
grafana=http://127.0.0.1:13000
curl -fsS --retry 5 --retry-delay 2 --retry-all-errors --max-time 10 \
  "$grafana/api/dashboards/uid/novabank-cuentas" >"$evidence/grafana-dashboard.json"
prometheus="$grafana/api/datasources/proxy/uid/prometheus/api/v1/query"
query() {
  curl -fsS --max-time 10 --get --data-urlencode "query=$1" "$prometheus"
}

# Esperar un scrape que incluya esta publicación y las dos réplicas.
checks="vector(1) and on() (count(up{job=\"cuentas-svc\"} == 1) == 2)
  and on() (push_time_seconds{job=\"novabank-ci\"} >= $push_since)
  and on() (count(process_cpu_usage{job=\"cuentas-svc\"}) == 2)
  and on() (count(logback_events_total{job=\"cuentas-svc\",level=\"error\"}) == 2)
  and on() (count(jvm_memory_used_bytes{job=\"cuentas-svc\"}) > 0)"
for attempt in {1..15}; do
  query "$checks" >"$evidence/prometheus-checks.json"
  if jq -e '.status == "success" and (.data.result | length == 1)' "$evidence/prometheus-checks.json" >/dev/null; then
    break
  fi
  if ((attempt == 15)); then
    echo "Prometheus no confirmó la publicación y las métricas de las réplicas." >&2
    exit 1
  fi
  sleep 5
done
while read -r metric expected; do
  [[ "$metric" != '#' ]] || continue
  query "$metric{job=\"novabank-ci\"}" >"$evidence/$metric.json"
  jq -e --argjson expected "$expected" '
    (.data.result | length == 1) and (.data.result[0].value[1] | tonumber == $expected)
  ' "$evidence/$metric.json" >/dev/null
done <"$evidence/ci-metrics.prom"
"${k[@]}" get deployments,pods,services
printf 'Despliegue verificado: %s (%s segundos)\n' "$sha" "$deployment_seconds"
