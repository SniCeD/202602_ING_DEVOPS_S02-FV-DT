# Limitación de despliegue en Amazon EKS — AWS Academy

Fecha de diagnóstico: 23 de noviembre de 2026.

## Entorno revisado

- Clúster: `novabank-ep3`.
- Región: `us-east-1`.
- Kubernetes: `1.37`.
- Managed Node Group: `novabank-workers`.
- Capacidad deseada, mínima y máxima: 2 instancias `t3.medium`.

## Problema identificado

El grupo administrado aparece en estado `ACTIVE` y las instancias EC2 se crean. Sin embargo, los workers no completan su incorporación al clúster ni aparecen como nodos Kubernetes `Ready`.

La revisión de los registros de arranque permitió identificar que `nodeadm` intenta ejecutar `ec2:DescribeInstances`, operación que recibe `AccessDenied` debido a una denegación explícita de una política SCP de AWS Organizations (`p-9tg9ki2y`).

Como consecuencia, `nodeadm-config.service` no completa su inicialización y los workers no logran registrarse correctamente.

## Restricciones adicionales

La simulación de permisos IAM también identificó denegaciones para operaciones necesarias para crear roles y asociar políticas, entre ellas `iam:CreateRole` y `iam:AttachRolePolicy`.

Por ello, no fue posible completar la alternativa de configuración de nodos que requería un rol IAM diferente y sus asociaciones correspondientes.

## Evidencia de GitHub Actions

La ejecución [45197178472](https://github.com/SniCeD/202602_ING_DEVOPS_S02-FV-DT/actions/runs/45197178472), intento 4, terminó con el despliegue Compose correcto y el trabajo EKS fallido.

El job `Despliegue y observabilidad en EKS` terminó durante el rollout con:

`deployment "cuentas-svc" exceeded its progress deadline`

El workflow publicó el artefacto `ep3-eks-5ebce63cd84b1c709f06eb475348573bac2be678-4`.

Como antecedente, la ejecución [45086754091](https://github.com/SniCeD/202602_ING_DEVOPS_S02-FV-DT/actions/runs/45086754091) había terminado correctamente. Se conserva como evidencia histórica y no demuestra que el entorno actual continúe operativo.

## Diferencia entre el bloqueo AWS y las credenciales locales

Durante una comprobación posterior desde PowerShell, AWS CLI informó `NoCredentials`. Ese mensaje corresponde a la ausencia de una sesión AWS local configurada en el equipo. No es la causa raíz del problema de inicialización de los workers, que fue identificada previamente en los registros EC2 como una denegación SCP.

## Conclusión y alcance

El bloqueo actual depende de las restricciones de AWS Academy y de políticas administradas por AWS Organizations. No se resuelve modificando la aplicación ni repitiendo el despliegue.

Para completar la incorporación de los workers se requiere intervención del administrador de la cuenta o utilizar una cuenta con permisos compatibles.

Se conserva el entorno de prueba y se documenta el resultado sin afirmar que el despliegue EKS actual está operativo.

No se incluyen credenciales, tokens ni valores de sesión AWS en este documento.

## Cortes históricos anteriores

Las evidencias anteriores muestran que el entorno EKS estuvo operativo en un corte previo. Se conservan como antecedentes y no se modifican.

### 22 de noviembre de 2026 — EKS 1.36

Los archivos `01-eks-nodos.txt` y `02-rollout-cuentas.txt` registran:

- Clúster `novabank-ep3`, versión 1.36.
- Node group `cuentas-ep3`, capacidad de una instancia `t3.medium`.
- Un nodo Kubernetes en estado `Ready`.
- Deployment `cuentas-svc` con 2/2 réplicas disponibles.
- Dos pods Cuentas en estado `Running`.
- Prometheus, Grafana y Pushgateway desplegados y disponibles.
- Service Cuentas con HTTP 200 y dos endpoints listos.

La imagen desplegada fue `ghcr.io/sniced/202602_ing_devops_s02-fv-dt:7ad26ce436f0623d133db5f2a7938e5b201c9ed2`, con digest `sha256:95e814a9bc410e00dc4a1f6f0869711f5922c99ee537073ab6edec55435d852c`.

El archivo `06-eks-recreado-validacion-manual.txt` conserva otra validación manual del mismo periodo, también con nodo `Ready` y los deployments disponibles.

### 23 de noviembre de 2026 — diagnóstico posterior

La revisión posterior registra Kubernetes 1.37 y el node group `novabank-workers`, con capacidad deseada de dos instancias `t3.medium`. En este corte, los workers no completaron su incorporación al clúster debido a la denegación SCP descrita anteriormente.

No se dispone en estos archivos de una secuencia completa que permita atribuir con certeza cuándo o por qué se cambió la versión y el node group. Por ello, se presentan los registros como cortes temporales diferenciados, sin inferir una causa de reconfiguración.

La ejecución posterior de GitHub Actions `45197178472` también documenta el fallo del rollout de Cuentas.
