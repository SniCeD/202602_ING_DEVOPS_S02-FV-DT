# Cuentas — Microservicio de riesgo cuentas

Microservicio correspondiente al **caso caso04 — NovaBank** (Banca digital / fintech), desarrollado inicialmente en la Evaluación Parcial N°1 y extendido para la Evaluación Parcial N°2.

| | |
|---|---|
| Asignatura | DOY0101 — Ingeniería DevOps |
| Stack | Spring Boot 4.1.3 · Java 21 · Maven · Spring Data JPA · H2 · springdoc-openapi |
| Calidad | JaCoCo cobertura LINE 100% · Cucumber (BDD) alineado a endpoints REST |
| Entrega | Docker / Docker Compose |

## Responsabilidad (SRP)

administra los datos y la lógica del dominio de Cuentas del caso caso04 (NovaBank). Su base de datos es una **H2 en memoria** (un solo microservicio por base), cumpliendo aislamiento de datos por dominio.

## Página de presentación

Al ejecutar el servicio, `http://localhost:8080/` muestra la página de presentación del microservicio con documentación y enlaces a:

- **Swagger UI**: `/swagger-ui/index.html`
- **OpenAPI (yaml)**: `/v3/api-docs.yaml`
- **ReDoc**: `/redoc.html`
- **H2 Console**: `/h2-console`

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/cuentas` | Lista todos los recursos |
| GET | `/api/cuentas/{id}` | Obtiene un recurso por id |
| POST | `/api/cuentas` | Crea un recurso |
| PUT | `/api/cuentas/{id}` | Actualiza un recurso |
| DELETE | `/api/cuentas/{id}` | Elimina un recurso |

## Documentación del proyecto

La documentación completa está en la carpeta [`docs/`](docs/):

- [`docs/00_Resumen.md`](docs/00_Resumen.md) — propósito, responsabilidad y tecnologías
- [`docs/01_Arquitectura.md`](docs/01_Arquitectura.md) — componentes, arquitectura y patrones
- [`docs/02_API.md`](docs/02_API.md) — contrato REST y ejemplos curl
- [`docs/03_Pruebas.md`](docs/03_Pruebas.md) — tests unitarios, cobertura y Cucumber
- [`docs/04_Despliegue.md`](docs/04_Despliegue.md)
- [`docs/05_Justificacion.md`](docs/05_Justificacion.md) — justificación del servicio: RF/RNF/seguridad cubiertos, stack y por qué cada tecnología AWS
- [`docs/diagramas/`](docs/diagramas/) — C4 (contexto, contenedores, componentes), secuencia e infraestructura AWS — Docker, Docker Compose e integración

## Contenedorización del microservicio (IE1)

El microservicio se contiene mediante Docker utilizando un `Dockerfile` multi-stage, con el objetivo de separar el proceso de construcción de la aplicación de su entorno de ejecución y reducir el tamaño de la imagen final.

### Construcción de la imagen

El `Dockerfile` utiliza dos etapas:

- **Etapa de construcción:** utiliza `maven:3.9-eclipse-temurin-21` para descargar las dependencias y generar el archivo JAR de la aplicación.
- **Etapa de ejecución:** utiliza `eclipse-temurin:21-jre-alpine`, una imagen más ligera que incluye el entorno de ejecución de Java sin incorporar Maven ni todas las herramientas utilizadas durante la construcción.

El artefacto JAR generado se copia desde la primera etapa a la imagen final, que expone el puerto `8080`.

### Seguridad y optimización

La imagen final incorpora las siguientes medidas:

- Ejecución como usuario no privilegiado mediante la creación del usuario `appuser` y la instrucción `USER appuser`.
- Uso de una imagen basada en Alpine con Java Runtime Environment (JRE), reduciendo los componentes incluidos en el entorno de ejecución.
- Definición de un `HEALTHCHECK` HTTP que comprueba la disponibilidad del servicio mediante la ruta `/`.

### Integración con el pipeline

El workflow de GitHub Actions construye la imagen mediante el comando:

```bash
docker build --pull --tag "duoc/jv0101-caso04-cuentas:${GITHUB_SHA}" .
```

La construcción de la imagen depende de la aprobación previa de las pruebas automatizadas, el análisis de dependencias y el análisis estático de código. Posteriormente, el pipeline verifica que la imagen se haya generado correctamente mediante `docker image inspect` y la exporta como artefacto para utilizarla en el despliegue simulado.

Archivos relacionados:

- [`Dockerfile`](Dockerfile)
- [`pipeline.yml`](.github/workflows/pipeline.yml)
- [`docker-compose.yml`](docker-compose.yml)

## Pruebas automatizadas y cobertura (IE2)

El proyecto incorpora pruebas automatizadas para validar el comportamiento del microservicio de Cuentas, incluyendo la lógica de negocio, las respuestas HTTP y el funcionamiento de los endpoints REST.

### Pruebas unitarias

Las pruebas unitarias se organizan de la siguiente manera:

- `CuentaServiceTest`: utiliza Mockito para comprobar las operaciones de listar, consultar, crear, actualizar y eliminar cuentas, incluyendo los casos en que el recurso existe o no existe.
- `CuentaControllerTest`: utiliza MockMvc para verificar el comportamiento HTTP del controlador, incluyendo respuestas exitosas, errores de validación y recursos no encontrados.
- `OpenApiConfigTest`: verifica la metadata de la configuración OpenAPI.

### Pruebas de integración con Cucumber (BDD)

El proyecto incorpora escenarios BDD con Cucumber que ejercitan los endpoints del microservicio mediante solicitudes HTTP.

Los escenarios contemplan:

1. Verificar que el listado de cuentas responda con código HTTP `200`.
2. Ejecutar el ciclo de vida de una cuenta: creación (`201`), consulta (`200`), actualización (`200`), eliminación (`204`) y comprobación posterior de que el recurso eliminado responda con `404`.

### Cobertura de código con JaCoCo

El proyecto utiliza JaCoCo para medir la cobertura de líneas de código. La configuración documentada establece un objetivo del `100%` de cobertura de líneas y verifica este requisito durante la fase `verify` de Maven.

### Integración con el pipeline

El job de pruebas de GitHub Actions utiliza Java 21 y ejecuta el siguiente comando:

```bash
mvn --batch-mode --no-transfer-progress clean verify
```

El pipeline genera y publica el reporte de cobertura JaCoCo como artefacto de GitHub Actions con el nombre `reporte-cobertura-jacoco`.

La construcción de la imagen Docker depende de que el job de pruebas termine correctamente. De esta manera, si las pruebas o la verificación de cobertura fallan, la construcción de la imagen no continúa.

Archivos relacionados:

- [`docs/03_Pruebas.md`](docs/03_Pruebas.md)
- [`pom.xml`](pom.xml)
- [`pipeline.yml`](.github/workflows/pipeline.yml)
- [Ejecuciones de GitHub Actions](https://github.com/SniCeD/202602_ING_DEVOPS_S02-FV-DT/actions)

## Seguridad del pipeline (IE3)

## Dependabot
Dependabot revisa semanalmente las dependencias Maven y las
acciones de GitHub Actions, según la configuración de
`.github/dependabot.yml`.

### Análisis con Snyk
El pipeline realiza dos análisis automáticos:
- **Dependencias:** `snyk test --severity-threshold=high`
- **Código:** `snyk code test --severity-threshold=high`

El token de autenticación se almacena en el secreto
`SNYK_TOKEN` de GitHub Actions.

## Política de bloqueo
El trabajo de construcción de Docker depende de las pruebas,
el análisis de dependencias y el análisis estático de código.
Si alguna de estas comprobaciones falla, la construcción de
la imagen no se ejecuta y la ejecución del pipeline falla.

## Excepción temporal de seguridad
El archivo `.snyk` contiene una excepción temporal para
`SNYK-JAVA-ORGGLASSFISHJAXB-20883142`, correspondiente a una
vulnerabilidad XXE de JAXB que Snyk reporta sin una corrección
disponible.

La excepción tiene vencimiento el 25 de noviembre de 2026.
No elimina ni corrige la vulnerabilidad. Se debe revisar
antes de su vencimiento y retirar la excepción cuando sea
posible resolver el problema de forma segura.

## Límites de recursos y escalabilidad (IE3)

Docker Compose define límites para controlar el consumo de
recursos del microservicio:

- CPU máxima: 1 núcleo equivalente.
- Memoria máxima: 512 MiB.
- Reserva flexible de memoria: 128 MiB.
- Máximo de procesos e hilos: 200.

Estos parámetros ayudan a evitar que el contenedor consuma
recursos de forma ilimitada. Los valores son iniciales y deben
validarse con pruebas de carga antes de usarse en producción.


## Documentación de decisiones (IE4)

En esta sección se documentan las decisiones tomadas para seleccionar las herramientas utilizadas en el proyecto, considerando su función dentro del pipeline y la observabilidad del microservicio.

La documentación detallada se encuentra en [Decisiones sobre las herramientas](docs/evidencias/ep3/ie4/decisiones-herramientas.md).

El diagrama general se encuentra en [Pipeline CI/CD — EP2 y EP3](docs/diagramas/pipeline-ep3.md).
## Cumplimiento de controles de seguridad (IE5)

El cumplimiento de esta parte se aborda mediante tres vías: el Quality Gate de SonarQube, la protección de la rama principal y las auditorías de seguridad realizadas al repositorio y a la imagen Docker.

### 1. Quality Gate de SonarQube

SonarQube permite comprobar la calidad del código mediante un Quality Gate. El paso está configurado para ejecutarse en los push a `main` y en los Pull Requests cuya rama de destino sea `main`.

Si el Quality Gate no se aprueba, el job de pruebas falla y los trabajos que dependen de él no pueden continuar.

### 2. Protección de la rama main

Se configuró el ruleset `EP3 - proteger main`, aplicado a la rama `main`. Este exige integrar los cambios mediante Pull Request y tener aprobados los controles de estado obligatorios.

Los controles configurados son:

- Pruebas, cobertura y SonarQube Quality Gate.
- Snyk - análisis de dependencias.
- Snyk - análisis de código.
- Auditoría de secretos (Gitleaks).
- Construcción de imagen Docker.
- Auditoría de imagen Docker (Trivy).
- Despliegue simulado con Docker Compose.

De esta manera, los cambios no pueden integrarse a `main` mientras falte alguno de los controles obligatorios.

### 3. Auditorías propias de seguridad

Se incorporaron herramientas para revisar distintos riesgos del proyecto:

- **Snyk:** revisa las dependencias Maven y el código para detectar posibles vulnerabilidades.
- **Gitleaks:** revisa el historial y el directorio de trabajo para detectar secretos que puedan quedar expuestos.
- **Trivy:** analiza la imagen Docker y utiliza las vulnerabilidades `CRITICAL` como condición de bloqueo.

En las comprobaciones locales realizadas, Gitleaks no encontró secretos y Trivy no detectó vulnerabilidades críticas en la imagen analizada. Esto demuestra el resultado de esas ejecuciones, pero no reemplaza la prueba controlada de fallo descrita en IE6.

Resultados de las auditorías:

- [Validación de Gitleaks](docs/evidencias/ep3/ie6/04-gitleaks-validation.json).
- [Análisis de imagen con Trivy](docs/evidencias/ep3/ie6/05-trivy-image.json).
- [Validación de Trivy](docs/evidencias/ep3/ie6/06-trivy-validation.json).

## Demostración del bloqueo del pipeline (IE6)

El pipeline utiliza dependencias entre trabajos para evitar que una etapa posterior continúe cuando una validación anterior falla.

El flujo comienza con las pruebas y los análisis de seguridad. Cuando estas comprobaciones terminan correctamente, se permite construir la imagen Docker. Después, Trivy analiza la imagen antes de permitir su publicación o despliegue.

La publicación en GHCR depende de las validaciones anteriores y se realiza solamente en los eventos `push` configurados. El despliegue en EKS también requiere la publicación de la imagen y utiliza el entorno `ep3-eks`, que tiene revisores requeridos.

### Evidencias disponibles

Se conservan resultados de las pruebas automatizadas, Gitleaks y Trivy en [docs/evidencias/ep3/ie6/](docs/evidencias/ep3/ie6/). Estas evidencias corresponden a ejecuciones en las que los controles finalizaron correctamente.

### Prueba controlada de bloqueo

**Prueba controlada realizada:** el 23 de noviembre de 2026 se ejecutó una prueba en la rama `feature/demo-ie6-gitleaks-block`, utilizando un secreto completamente ficticio.

En la [ejecución #54 de GitHub Actions](https://github.com/SniCeD/202602_ING_DEVOPS_S02-FV-DT/actions/runs/45238972146), Gitleaks detectó un hallazgo mediante la regla `aws-access-token` y terminó con `failure`.

Como resultado, la construcción de la imagen Docker, el análisis Trivy, la publicación en GHCR y los despliegues de Docker Compose y EKS quedaron en estado `skipped`, debido a las dependencias configuradas en el workflow.

La evidencia detallada se encuentra en [07-demostracion-bloqueo-gitleaks.md](docs/evidencias/ep3/ie6/07-demostracion-bloqueo-gitleaks.md). También se publicó el artefacto `gitleaks-results.sarif` con el reporte de detección.

La prueba se realizó en una rama separada, sin crear un Pull Request ni integrar el archivo ficticio en `main`.
## Despliegue simulado con Docker Compose

Docker Compose se utiliza para administrar la ejecución del microservicio en el entorno simulado.

El servicio se configura con dos réplicas:

deploy:
  replicas: 2

Cada réplica utiliza la misma imagen del microservicio y Docker asigna dinámicamente los puertos del host para evitar conflictos entre las instancias.

La configuración también incluye:

- Reinicio automático mediante restart: unless-stopped.
- CPU máxima de 1 núcleo equivalente.
- Memoria máxima de 512 MiB.
- Reserva de memoria de 128 MiB.
- Máximo de 200 procesos o hilos.
- Healthcheck HTTP definido en el Dockerfile.

El estado de las réplicas puede verificarse mediante:

docker compose ps

Para obtener el puerto asignado a cada réplica:

docker compose port --index=1 cuentas-svc 8080
docker compose port --index=2 cuentas-svc 8080


## Pipeline CI/CD

El workflow principal del proyecto se encuentra en:

.github/workflows/pipeline.yml

El pipeline contiene las siguientes etapas:

- Ejecución de pruebas y verificación de cobertura.
- Análisis de dependencias mediante Snyk.
- Análisis estático de código mediante Snyk Code.
- Construcción de la imagen Docker.
- Exportación de la imagen como artefacto.
- Despliegue automático mediante Docker Compose.
- Verificación del estado de las réplicas.
- Verificación HTTP posterior al despliegue.
- Limpieza del entorno utilizado durante la ejecución.

Los trabajos posteriores dependen del resultado correcto de las etapas anteriores. Si las pruebas o los análisis de seguridad fallan, la construcción y el despliegue no continúan.


## Evaluación Parcial 3 — Observabilidad y entornos reales

La Evaluación Parcial N°3 extiende el pipeline y el microservicio implementados en las evaluaciones anteriores incorporando monitoreo, logging y observabilidad.

### EP3 — IE1: Monitoreo y observabilidad

El microservicio `cuentas-svc` incorpora una capa de observabilidad compuesta por **Spring Boot Actuator, Micrometer, Prometheus, Grafana Alloy, Loki y Grafana**.

#### Métricas del microservicio

Spring Boot Actuator y Micrometer exponen información de operación mediante los endpoints:

```text
/actuator/health
/actuator/metrics
/actuator/prometheus
```

Prometheus consulta automáticamente `/actuator/prometheus` cada 15 segundos y almacena las series temporales generadas por el microservicio.

Entre las métricas verificadas se encuentran:

- Uso de CPU del proceso Java.
- Uso de memoria de la JVM.
- Cantidad y duración de solicitudes HTTP.
- Estados HTTP registrados.
- Disponibilidad del microservicio.

La disponibilidad también puede verificarse mediante la consulta PromQL:

```promql
up{job="cuentas-svc"}
```

Un valor `1` indica que Prometheus puede consultar correctamente el microservicio.

#### Logging centralizado

La aplicación genera sus logs en:

```text
logs/cuentas-svc.log
```

Grafana Alloy monitorea este archivo y envía los registros a Loki.

Los logs almacenados en Loki pueden consultarse desde Grafana mediante LogQL, por ejemplo:

```logql
{job="cuentas-svc"}
```

Para filtrar errores:

```logql
{job="cuentas-svc"} |= "ERROR"
```

Y para filtrar advertencias:

```logql
{job="cuentas-svc"} |= "WARN"
```

Los archivos `.log` generados durante la ejecución están excluidos de Git mediante `.gitignore`.

#### Validación de errores HTTP 5xx

Se incorporó el endpoint técnico:

```text
GET /api/cuentas/observability/test-500
```

Este endpoint genera de forma controlada una respuesta:

```text
HTTP 500 Internal Server Error
```

Su objetivo es permitir verificar que los errores del servidor sean registrados por Micrometer y posteriormente recolectados por Prometheus.

Los errores pueden consultarse mediante:

```promql
http_server_requests_seconds_count{status=~"5.."}
```

El endpoint cuenta además con una prueba automatizada en `CuentaControllerTest`.

#### Stack de observabilidad

La configuración está versionada en:

```text
monitoring/
├── alloy/
│   └── config.alloy
├── grafana/
│   └── provisioning/
│       └── datasources/
│           └── datasources.yml
├── loki/
│   └── loki-config.yml
└── prometheus/
    └── prometheus.yml
```

Los componentes de observabilidad se levantan mediante:

```bash
docker compose -f docker-compose.observability.yml up -d
```

Servicios locales:

| Componente | Dirección |
|---|---|
| `cuentas-svc` | `http://localhost:8080` |
| Prometheus | `http://localhost:9090` |
| Grafana | `http://localhost:3000` |
| Loki | `http://localhost:3100` |
| Alloy | `http://localhost:12345` |

Para ejecutar el microservicio localmente:

```bash
mvn spring-boot:run
```

#### Señales verificadas

| Señal | Implementación | Estado |
|---|---|---|
| Uso | CPU, memoria JVM y solicitudes HTTP mediante Micrometer/Prometheus | ✅ |
| Disponibilidad | Actuator Health y métrica `up` de Prometheus | ✅ |
| Errores | Métricas HTTP 5xx recolectadas por Prometheus | ✅ |
| Logs | Archivo de aplicación → Alloy → Loki → Grafana | ✅ |

#### Evidencias

Las evidencias de la implementación se encuentran en:

[`docs/evidencias/ep3/ie1/`](docs/evidencias/ep3/ie1/)

Incluyen la validación del target `cuentas-svc` en Prometheus, métricas de uso, consulta de logs mediante Loki, registro de errores HTTP 500 y ejecución exitosa de las pruebas con JaCoCo.

### EP3 — IE2 e IE3 en Amazon EKS

La validación histórica inicial se realizó en EKS 1.36, en `us-east-1`, con un grupo administrado de un nodo `t3.medium`. Esta información corresponde a una ejecución anterior y no describe el estado actual del clúster. Cuentas tiene dos réplicas y sondas de Actuator. Prometheus descubre cada réplica mediante el Service headless `cuentas-metrics`. Grafana provisiona **NovaBank · Cuentas** desde el repositorio.

#### Despliegue desde GitHub Actions

`deploy-kubernetes` se ejecuta en un push a la rama configurada tras las pruebas, los dos análisis de Snyk y la publicación de la imagen del mismo SHA. GitHub usa las variables de repositorio `EKS_DEPLOY_BRANCH` (`rama configurada en GitHub`) y `EKS_CLUSTER_NAME` (`novabank-ep3`). La ejecución de prueba usó los secretos de repositorio `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` y `AWS_REGION` (`us-east-1`). Renueva los tres valores de la sesión de AWS Academy cuando caduquen. La sesión debe poder describir el clúster y su principal IAM debe tener acceso Kubernetes para desplegar y verificar en `ep3`, crear ese namespace y usar `port-forward`. El runner debe alcanzar la API de EKS.

El job valida las dos réplicas del SHA, el Service, sus endpoints y las sondas de cada pod. Después aplica Prometheus, Grafana y Pushgateway. Publica los datos a través de un `kubectl port-forward` a Pushgateway, un Service interno. El artefacto `ep3-eks-<sha>-<intento>` guarda el registro, las imágenes y digests de las réplicas, los endpoints, las métricas enviadas y las respuestas consultadas a través de Grafana. Encontrarás la cobertura en `ci-metrics.prom` y la duración medida junto a ella.

#### Reproducción manual

Con acceso al clúster, ejecuta desde la raíz del repositorio en Bash con AWS CLI, `kubectl`, `curl`, `jq` y Python 3. Usa un SHA publicado y el reporte JaCoCo correspondiente a ese mismo commit. El script mide el despliegue que ejecuta y conserva el resultado en el directorio de evidencia.

```bash
aws eks update-kubeconfig --region us-east-1 --name novabank-ep3
kubectl get nodes
IMAGE_TAG='<sha-publicado>' bash scripts/ep3/deploy-kubernetes.sh /ruta/a/jacoco.xml /ruta/a/evidencia
```

Abre tres terminales para reenviar los puertos al equipo local.

```bash
kubectl -n ep3 port-forward svc/cuentas-svc 18080:80
kubectl -n ep3 port-forward svc/prometheus 19090:9090
kubectl -n ep3 port-forward svc/grafana 13000:3000
```

Comprueba `/actuator/health/liveness` y `/actuator/health/readiness` en el puerto 18080. Para poblar ambas réplicas, reenvía por separado el puerto 8080 de cada pod y envía solicitudes a `/` y, en intervalos controlados, a `/api/cuentas/observability/test-500`. Comprueba que `/actuator/prometheus` emita `http_server_requests_seconds_bucket` después de las solicitudes. Verifica los dos targets en `http://localhost:19090/targets` y abre `http://localhost:13000/d/novabank-cuentas`.

#### Métricas de la pauta

La duración se mide en segundos desde la primera aplicación de los manifiestos de Cuentas hasta validar el rollout, el Service y las sondas. La cobertura usa el contador global de líneas de `jacoco.xml` de la misma ejecución, con la fórmula `100 × cubiertas / (cubiertas + omitidas)`. Cada despliegue validado reemplaza la última pareja de valores en Pushgateway. Prometheus conserva las muestras de la sesión de prueba. El almacenamiento en este laboratorio es efímero.

| Panel | PromQL |
|---|---|
| Tiempo de despliegue en EKS | `novabank_ci_deploy_duration_seconds{job="novabank-ci"}` |
| Cobertura de pruebas JaCoCo | `novabank_ci_line_coverage_percent{job="novabank-ci"}` |
| CPU media del microservicio | `avg(process_cpu_usage{job="cuentas-svc"})` |
| Memoria JVM total en bytes | `sum(jvm_memory_used_bytes{job="cuentas-svc"})` |
| Errores registrados por segundo | `sum(rate(logback_events_total{job="cuentas-svc",level="error"}[2m]))` |
| Respuestas HTTP 5xx por segundo | `sum(rate(http_server_requests_seconds_count{job="cuentas-svc",uri!~"/actuator.*",status=~"5.."}[2m]))` |
| Solicitudes por segundo | `sum(rate(http_server_requests_seconds_count{job="cuentas-svc",uri!~"/actuator.*"}[2m]))` |
| Latencia p95 en segundos | `histogram_quantile(0.95, sum by (le) (rate(http_server_requests_seconds_bucket{job="cuentas-svc",uri!~"/actuator.*"}[2m])))` |

La [ejecución 45086754091](https://github.com/SniCeD/202602_ING_DEVOPS_S02-FV-DT/actions/runs/45086754091) verificó el despliegue automático del SHA `bf6afb16ed9bbc4645d0ee42792ed8be5b7d194d`. Sus artefactos registraron **66 segundos** de despliegue y **100%** de cobertura JaCoCo de líneas (46 cubiertas y 0 omitidas). Las [evidencias de IE2](docs/evidencias/ep3/ie2/) y [evidencias de IE3](docs/evidencias/ep3/ie3/) incluyen las comprobaciones en EKS y conservan la validación manual anterior. El despliegue simulado de Compose sigue disponible.

**Estado posterior (23 de noviembre de 2026):** el diagnóstico posterior encontró el clúster en Kubernetes 1.37, con el grupo administrado `novabank-workers` configurado para dos instancias `t3.medium`. Aunque las instancias EC2 se creaban, no conseguían registrarse como nodos Kubernetes `Ready`.

Los registros de arranque identificaron una denegación explícita de la política SCP de AWS Organizations sobre `ec2:DescribeInstances`, que impide completar la inicialización de los workers. También se detectaron restricciones IAM para crear roles y asociar políticas.

La ejecución posterior [45197178472](https://github.com/SniCeD/202602_ING_DEVOPS_S02-FV-DT/actions/runs/45197178472) terminó con el error `deployment "cuentas-svc" exceeded its progress deadline`. Por este motivo, no se debe considerar que el entorno EKS continúa operativo. La ejecución exitosa anterior se conserva exclusivamente como evidencia histórica.

El diagnóstico y las restricciones identificadas están documentados en [Limitación de despliegue en Amazon EKS — AWS Academy](docs/evidencias/ep3/ie2/limitacion-eks-aws-academy.md).



## Cómo ejecutar con Docker

Para construir y levantar el servicio:

docker compose up -d --build

Para comprobar el estado de las réplicas:

docker compose ps

Docker Compose utiliza puertos dinámicos para las dos instancias.

Para obtener los puertos asignados:

docker compose port --index=1 cuentas-svc 8080
docker compose port --index=2 cuentas-svc 8080

Para detener y eliminar el entorno:

docker compose down




## Cómo ejecutar localmente

```bash
mvn spring-boot:run
```

## Cómo ejecutar las pruebas

```bash
mvn test      # unit tests + Cucumber
mvn verify    # + verificación de cobertura JaCoCo (100% LINE, falla si baja)
```

## Ramificación

| Modelo      | Funcionamiento                                                                                           |
| GitFlow     | Utiliza `main`, `develop`, `feature/` y `hotfix/`, separando el código estable del código en desarrollo. |
| GitHub Flow | Utiliza principalmente `main` y ramas de trabajo que se integran mediante Pull Request.                  |
| Trunk-based | El trabajo se concentra en una rama principal, utilizando ramas de muy corta duración.                   |

Elegimos GitFlow porque nos proporciona un mayor control sobre el código que pasa a producción. Además, este modelo se adapta de forma nativa a la estructura de ramas que solicita este proyecto (main, develop, feature, hotfix).



## Convenciones y buenas prácticas

### Convención de commits

Los mensajes de commit siguen el formato:

`tipo(alcance): descripcion-corta`

Tipos utilizados:

- `feat`: nueva funcionalidad.
- `fix`: corrección de errores.
- `docs`: cambios de documentación.
- `chore`: tareas de mantenimiento o integración continua.

Ejemplos:

- `feat(ui): agregar pie de pagina`
- `fix(ui): corregir titulo de la pagina principal`
- `docs: agregar changelog`
- `chore(ci): agregar workflow hola mundo`

### Naming de ramas

Las ramas utilizan nombres descriptivos en minúsculas y separados por guiones:

- `feature/descripcion-corta`
- `hotfix/descripcion-corta`

Ejemplos:

- `feature/pagina-presentacion`
- `feature/changelog`
- `hotfix/titulo-pagina`

### Flujo de merge

Los cambios realizados en ramas `feature/` y `hotfix/` se integran mediante Pull Request.

Las features se crean desde `develop` y se fusionan nuevamente hacia `develop`.

Los hotfix se crean desde `main`, se fusionan hacia `main` y posteriormente se sincronizan con `develop`.

### Estrategia de revisión

Cada Pull Request debe ser revisado por el otro integrante del equipo antes de realizar el merge.

El revisor debe comprobar los cambios realizados en la pestaña `Files changed` y puede aprobar, comentar o solicitar modificaciones antes de la integración.

## Declaración de IA
Se utilizó ChatGPT como apoyo para consultas técnicas, resolución de errores y organización de la documentación. Todo el contenido antes de ser lanzado fue revisado y validado por nosotros.

## Conclusiones

### Reflexiones (EP2)

Fernando Valenzuela: Aprendí como configurar Snyk con actions para analizar vulnerabilidades, tuve que pelear con las vulnerabilidades que detecto el Snyk para mitigarlas pero al final se logró, aplicaría esto para el proyecto de portafolio de titulo que estamos haciendo, así nos va a quedar un proyecto mucho más profesional.

Dacier Tapia: Esta evaluación me permitió entender como funciona el despliegue CI/CD, con pruebas, seguridad, la construcción y el despliegue, dependiendo unas de otras. Además del uso de réplicas y healthchecks.
Tuve problemas con el tema de los puertos ya que se sobreponían al ser estáticos, pero al no especificarlos, se volvieron dinámicos y funcionó todo bien.
