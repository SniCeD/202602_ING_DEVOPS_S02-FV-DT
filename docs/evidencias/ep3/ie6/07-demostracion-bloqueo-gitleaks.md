# IE6 — Demostración controlada del bloqueo

## Datos de la ejecución

- Fecha: 23 de noviembre de 2026.
- Workflow: CI - Cuentas Service.
- Ejecución: [GitHub Actions #54](https://github.com/SniCeD/202602_ING_DEVOPS_S02-FV-DT/actions/runs/45238972146).
- Rama de demostración: `feature/demo-ie6-gitleaks-block`.
- Commit: `8e6b026e85629025ec9ecd67ffaeb885d30d7387`.
- Evento: `push`.
- Resultado general: `failure`, esperado para esta prueba negativa.

## Resultado de los controles

| Trabajo | Resultado |
|---|---|
| Pruebas, cobertura y SonarQube Quality Gate | `success` (paso SonarQube omitido por condición de rama) |
| Snyk - análisis de dependencias | `success` |
| Snyk - análisis de código | `success` |
| Auditoría de secretos (Gitleaks) | `failure` |
| Construcción de imagen Docker | `skipped` |
| Auditoría de imagen Docker (Trivy) | `skipped` |
| Publicar imagen validada en GHCR | `skipped` |
| Despliegue simulado con Docker Compose | `skipped` |
| Despliegue y observabilidad en EKS | `skipped` |

## Detección realizada

Gitleaks detectó un hallazgo mediante la regla `aws-access-token`, en la línea 3 del archivo de demostración `docs/evidencias/ep3/ie6-demo/secreto-ficticio.txt`.

El valor utilizado era completamente ficticio y no correspondía a credenciales reales. Los registros de GitHub Actions ocultaron el contenido detectado mediante redacción.

El trabajo de Gitleaks terminó con `failure` y registró `leaks found: 1`.

## Comprobación del bloqueo

La construcción Docker depende de las pruebas, Snyk y Gitleaks. Al fallar Gitleaks, la construcción quedó omitida. Como consecuencia, Trivy no recibió una imagen para analizar y también quedó omitido. La publicación GHCR y el despliegue Compose tampoco continuaron.

El trabajo EKS también quedó omitido. La rama de demostración no correspondía a la rama configurada para el despliegue EKS y, además, sus dependencias no se completaron.

## Artefacto generado

GitHub Actions publicó el artefacto `gitleaks-results.sarif`, que contiene el reporte SARIF de la detección.

## Conclusión

La prueba controlada demuestra que Gitleaks detecta un secreto ficticio y que el pipeline impide continuar con la construcción de la imagen y las etapas de despliegue dependientes. La rama se mantuvo separada de `main` y no se creó un Pull Request.
