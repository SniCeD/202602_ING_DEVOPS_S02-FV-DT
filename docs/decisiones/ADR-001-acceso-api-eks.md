# ADR-001: Configuración de acceso al endpoint de Kubernetes en EKS

- **Estado:** Aceptada para el laboratorio académico
- **Fecha:** 23 de noviembre de 2026
- **Proyecto:** NovaBank - EP3
- **Entorno:** AWS Academy / Amazon EKS
- **Región:** us-east-1

## 1. Contexto

El proyecto utiliza GitHub Actions con ejecutores alojados por GitHub
(`ubuntu-latest`) para automatizar el despliegue de la aplicación y de
los componentes de observabilidad en Amazon EKS.

Estos ejecutores utilizan direcciones IP dinámicas y compartidas.
Por lo tanto, restringir el endpoint público a una única dirección IP
fija podría impedir que el pipeline se conecte correctamente.

También necesitamos permitir que los nodos del clúster se comuniquen
con el plano de control de Kubernetes.

## 2. Decisión

Se utilizará la siguiente configuración para el endpoint del API
de Kubernetes:

| Parámetro | Configuración |
|---|---|
| endpointPublicAccess | true |
| endpointPrivateAccess | true |
| publicAccessCidrs | 0.0.0.0/0 |
| Autenticación | AWS IAM |
| Autorización | EKS Access Entries y Kubernetes RBAC |

La configuración se utilizará exclusivamente en el laboratorio
académico y no se considera una configuración de producción.

## 3. Justificación

Se habilita el acceso público para permitir que GitHub Actions
pueda ejecutar kubectl desde sus ejecutores alojados en GitHub,
sin depender de una dirección IP estática.

Se mantiene habilitado el acceso privado para que las comunicaciones
originadas dentro de la VPC puedan utilizar el endpoint privado.

Se elige esta alternativa porque permite mantener la automatización
CI/CD existente sin incorporar inicialmente un bastion host,
una VPN o un ejecutor autogestionado dentro de la VPC.

## 4. Consideraciones de seguridad

La disponibilidad pública del endpoint no elimina los controles
de autenticación y autorización.

Se establecen las siguientes medidas:

1. Las operaciones del API de Kubernetes requieren autenticación
   mediante AWS IAM.
2. Los permisos de Kubernetes se asignarán mediante EKS Access Entries
   y RBAC, limitando las identidades autorizadas.
3. No se deshabilitará la validación de certificados TLS.
4. Las credenciales de AWS se mantendrán en GitHub Actions Secrets
   y no se almacenarán en el repositorio.
5. Las credenciales temporales de AWS Academy deberán mantenerse
   actualizadas para las ejecuciones del pipeline.
6. La exposición del endpoint público no implica exponer directamente
   los servicios de la aplicación ni el dashboard de Grafana.

## 5. Riesgos aceptados

El uso de 0.0.0.0/0 permite que cualquier dirección IPv4 alcance
el endpoint público a nivel de red.

Esto aumenta la superficie de exposición del API de Kubernetes
y exige mantener correctamente los controles de autenticación,
autorización y seguridad.

La decisión se acepta temporalmente por las características
del laboratorio académico y la necesidad de utilizar GitHub-hosted
runners con direcciones IP dinámicas.

## 6. Alternativas evaluadas

### A. Endpoint exclusivamente privado

Requeriría que GitHub Actions se conectara desde una red con acceso
a la VPC, mediante un ejecutor autogestionado, VPN o infraestructura
de conexión equivalente.

Se descarta inicialmente por la complejidad y los recursos adicionales
que supone en el laboratorio.

### B. Endpoint público con CIDR restringido

Permitiría reducir la exposición a direcciones IP conocidas.

Sin embargo, los ejecutores alojados por GitHub utilizan direcciones
dinámicas, lo que dificulta mantener una lista estable de direcciones
permitidas.

Se podrá reconsiderar esta alternativa si se dispone de una salida
de red estática.

### C. Endpoint público y privado con acceso IPv4 abierto

Se selecciona para el laboratorio porque facilita la conexión
desde GitHub Actions y mantiene disponible el acceso privado
desde la VPC.

## 7. Condiciones para revisar esta decisión

La configuración deberá revisarse cuando:

- Se disponga de un ejecutor con dirección IP estática.
- Se incorpore un ejecutor autogestionado dentro de la VPC.
- Se traslade el proyecto a un entorno de producción.
- Se modifique la arquitectura de acceso al clúster.

En esos casos se evaluará restringir `publicAccessCidrs`
a direcciones conocidas o deshabilitar el acceso público.

## 8. Verificación de la implementación

Después de crear el clúster, se comprobará la configuración
mediante:

- AWS CLI: `aws eks describe-cluster`.
- Revisión de `resourcesVpcConfig`.
- Comprobación de las identidades autorizadas mediante
  `aws eks list-access-entries`.
- Pruebas de autenticación y autorización con `kubectl`.
- Ejecución del despliegue desde GitHub Actions.

## 9. Referencias

- AWS EKS - Configuración del endpoint:
  https://docs.aws.amazon.com/eks/latest/userguide/config-cluster-endpoint.html

- AWS EKS - Buenas prácticas de identidad y acceso:
  https://docs.aws.amazon.com/eks/latest/best-practices/identity-and-access-management.html

- GitHub - Direcciones IP:
  https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-githubs-ip-addresses
