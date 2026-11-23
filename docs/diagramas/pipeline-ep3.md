# IE4 — Documentar decisiones

## Mapa del pipeline

El siguiente diagrama representa las etapas de validación y despliegue del proyecto, integrando el pipeline de las evaluaciones anteriores con los componentes incorporados en EP3.

[Ver diagrama del pipeline CI/CD](../../../diagramas/pipeline-ep3.md).

## Mapa de observabilidad de EP3

El flujo de observabilidad implementado permite recopilar métricas y registros de la aplicación y consultarlos desde Grafana.

```mermaid
flowchart TD
    APP["Microservicio cuentas-svc"]

    APP -->|"Métricas Actuator / Micrometer"| PROM["Prometheus"]
    PROM --> GRAF["Grafana"]

    APP -->|"Archivo de logs"| ALLOY["Grafana Alloy"]
    ALLOY --> LOKI["Loki"]
    LOKI --> GRAF

    CI["GitHub Actions"] -->|"Métricas del despliegue y cobertura"| PUSH["Pushgateway"]
    PUSH --> PROM
