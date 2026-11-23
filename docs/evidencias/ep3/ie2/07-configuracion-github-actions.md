# Configuración del despliegue automático

El job `deploy-kubernetes` está implementado en la copia local. Actionlint validó el workflow y Bash validó la sintaxis del script. Se crearon en GitHub las variables de repositorio `EKS_DEPLOY_BRANCH` con `feature/ep3-ie1-ie3-observability` y `EKS_CLUSTER_NAME` con `novabank-ep3` (HTTP 201).

La sesión de GitHub tiene permiso de escritura en la rama. La creación del entorno `ep3-eks` mediante la API devolvió HTTP 403. El despliegue desde Actions queda pendiente de configurar los secretos de la sesión temporal y ejecutar el workflow actualizado. No se registraron valores de credenciales en las evidencias.

Con autorización se configuraron los cuatro secretos a nivel de repositorio. La [ejecución 45086754091](https://github.com/SniCeD/202602_ING_DEVOPS_S02-FV-DT/actions/runs/45086754091) completó `deploy-kubernetes` y guardó el artefacto del despliegue. La verificación está en [08-github-actions-eks](08-github-actions-eks/).
