# IE4 — Documentar decisiones

## Mapa del pipeline

El siguiente diagrama representa las etapas de validación y despliegue del proyecto.

[Ver diagrama del pipeline CI/CD](../../../diagramas/pipeline-ep3.md).

## Decisiones sobre las herramientas de observabilidad

| Herramienta | Motivo de elección |
|---|---|
| Prometheus | Lo elegimos porque nos permite revisar las métricas del microservicio y comprobar si las réplicas están funcionando. |
| Grafana | Lo usamos para visualizar las métricas y los registros en paneles, lo que facilita revisar el estado del servicio. |
| Grafana Alloy | Lo usamos para recopilar los logs que genera la aplicación y enviarlos a Loki. |
| Loki | Lo elegimos para centralizar los logs y poder revisar los errores sin tener que buscarlos directamente en cada contenedor. |

## Decisiones sobre las herramientas de seguridad

| Herramienta | Motivo de elección |
|---|---|
| Snyk (dependencias) | Lo usamos para revisar las dependencias Maven y detectar vulnerabilidades antes de construir la imagen. |
| Snyk Code | Lo usamos para analizar el código y detectar posibles problemas de seguridad. |
| Gitleaks | Lo usamos para comprobar que no se suban claves, tokens u otros secretos al repositorio. |
| Trivy | Lo usamos para revisar la imagen Docker y detectar vulnerabilidades críticas antes de permitir el despliegue. |
| SonarQube | Lo usamos para comprobar la calidad del código mediante un Quality Gate antes de integrar los cambios a `main`. |

## Ejemplos de decisiones a partir de los paneles

| Qué revisamos | Qué decidimos | Qué hacemos |
|---|---|---|
| Disponibilidad de las réplicas | Comprobar que ambas estén funcionando. | Revisar la réplica que aparezca como `DOWN`. |
| Latencia HTTP | Revisar si las solicitudes están tardando demasiado. | Investigar el endpoint y revisar sus registros. |
| Errores en Loki | Identificar si se están produciendo errores. | Buscar qué los está provocando y revisar los logs. |

Estos ejemplos muestran cómo se pueden utilizar las métricas y los registros para revisar el estado del servicio y decidir qué acciones tomar cuando se detecta un problema.
