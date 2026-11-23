# GitHub Actions y publicación en GHCR

La [ejecución 45077752245](https://github.com/SniCeD/202602_ING_DEVOPS_S02-FV-DT/actions/runs/45077752245), disparada por un push del SHA `7ad26ce436f0623d133db5f2a7938e5b201c9ed2`, finalizó correctamente. La API de GitHub devolvió `success` para pruebas y cobertura, ambos análisis de Snyk, construcción de imagen y despliegue simulado con Docker Compose.

La consulta anónima a GHCR devolvió HTTP 200 para ese SHA. El índice tiene digest `sha256:95e814a9bc410e00dc4a1f6f0869711f5922c99ee537073ab6edec55435d852c` e incluye un manifiesto para `linux/amd64`.

La ejecución corresponde al despliegue simulado. En Learner Lab, `iam:ListOpenIDConnectProviders` devolvió una lista vacía y `iam:SimulatePrincipalPolicy` para el rol `voclabs` devolvió `implicitDeny` en `iam:CreateOpenIDConnectProvider` e `iam:CreateRole`. Esta comprobación se hizo en modo de solo lectura.
