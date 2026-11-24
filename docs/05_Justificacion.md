# ms-cuentas — Justificación del servicio y cobertura de requisitos

**Caso caso04 — NovaBank** (Banca digital / fintech) · Asignatura de Ingeniería DevOps

## Alcance y criterio de lectura

Este documento justifica la separación del dominio de Cuentas y relaciona los requisitos del caso NovaBank con las decisiones técnicas del proyecto.

Para evitar confundir el diseño con el resultado implementado, se distinguen tres niveles:

- **Implementado:** funcionalidades y tecnologías que forman parte del repositorio y tienen código o configuración verificable.
- **Validado históricamente:** funcionalidades que cuentan con evidencias de una ejecución anterior, aunque no necesariamente continúen operativas.
- **Arquitectura objetivo o propuesta:** servicios y patrones considerados en el diseño general de NovaBank, pero que no están desplegados ni implementados en este microservicio.

La presencia de una tecnología en un diagrama o en una justificación arquitectónica no constituye, por sí sola, evidencia de que esté desplegada.

## 1. Misión y responsabilidad del servicio

El microservicio `cuentas-svc` concentra las operaciones del dominio de Cuentas del caso NovaBank. Expone una API REST para crear, consultar, actualizar y eliminar recursos del dominio.

Su responsabilidad se mantiene separada de otros posibles dominios de la plataforma, como autenticación, transferencias, préstamos y notificaciones.

En el repositorio actual, el servicio utiliza una base de datos H2 en memoria. Esto permite ejecutar y probar la aplicación de manera independiente, pero no equivale a una solución de persistencia productiva ni garantiza la conservación de datos al detener el servicio.

La API implementada constituye una base funcional y técnica sobre la cual se podría evolucionar hacia una arquitectura de mayor escala.

## 2. Requisitos funcionales relacionados

| RF | Requisito del caso | Relación con la implementación | Alcance |
|---|---|---|---|
| **RF-02** | Apertura y gestión de cuentas corrientes y consulta de saldos | La API permite crear, listar, consultar, actualizar y eliminar recursos de Cuentas. El modelo contempla atributos como titular y saldo. | Implementación CRUD del microservicio; no representa por sí sola un core bancario transaccional completo. |

Los endpoints implementados se encuentran bajo `/api/cuentas`:

| Método | Ruta | Operación |
|---|---|---|
| GET | `/api/cuentas` | Listar cuentas |
| GET | `/api/cuentas/{id}` | Consultar una cuenta |
| POST | `/api/cuentas` | Crear una cuenta |
| PUT | `/api/cuentas/{id}` | Actualizar una cuenta |
| DELETE | `/api/cuentas/{id}` | Eliminar una cuenta |

La definición de estos endpoints y sus respuestas HTTP se encuentra documentada en `docs/02_API.md`.

## 3. Arquitectura y tecnologías implementadas

La siguiente tabla resume las tecnologías que sí forman parte del repositorio:

| Componente | Tecnología | Uso en el proyecto |
|---|---|---|
| Lenguaje | Java 21 | Desarrollo del microservicio |
| Framework | Spring Boot 4.1.3 | Aplicación y API REST |
| Construcción | Maven | Gestión de dependencias y compilación |
| Persistencia | Spring Data JPA + H2 | Acceso y almacenamiento de datos en memoria |
| Validación | Bean Validation | Validación de datos de entrada |
| Documentación API | springdoc-openapi | Swagger UI, OpenAPI y ReDoc |
| Pruebas | JUnit, Mockito y MockMvc | Pruebas unitarias y del controlador |
| Pruebas BDD | Cucumber | Escenarios de comportamiento sobre endpoints REST |
| Cobertura | JaCoCo | Medición y umbral configurado de cobertura de líneas |
| Contenedores | Docker | Construcción de imágenes del servicio |
| Orquestación local/simulada | Docker Compose | Ejecución de dos réplicas y comprobaciones de salud |
| CI/CD | GitHub Actions | Automatización de validaciones, construcción y despliegue |
| Seguridad | Snyk, Gitleaks, Trivy y SonarQube Cloud | Análisis de dependencias, código, secretos e imagen |
| Registro de imágenes | GitHub Container Registry (GHCR) | Publicación de imágenes validadas |
| Métricas | Spring Boot Actuator, Micrometer y Prometheus | Exposición y recolección de métricas |
| Visualización | Grafana | Consulta y visualización de métricas y logs |
| Logging | Grafana Alloy y Loki | Recolección y almacenamiento centralizado de logs |
| Orquestación Kubernetes | Manifiestos Kubernetes y Kustomize | Configuración versionada de la aplicación y componentes de monitoreo |

La configuración de Docker Compose y del pipeline permite validar dos réplicas del microservicio en un entorno automatizado. Esto es distinto de disponer de una infraestructura productiva con alta disponibilidad garantizada.

## 4. Requisitos no funcionales y arquitectura objetivo

Los requisitos no funcionales orientan las decisiones futuras de infraestructura. Es importante separar las capacidades verificadas en este repositorio de las metas que necesitarían una infraestructura productiva.

| RNF | Objetivo del caso | Implementado o validado | Arquitectura objetivo |
|---|---|---|---|
| **RNF-01 — Disponibilidad** | Mantener disponibles los servicios críticos. | Se verifican salud, disponibilidad y réplicas en los entornos de prueba. No se ha demostrado un SLA productivo de 99,99 %. | Despliegue multi-AZ, balanceo y recuperación ante fallos. |
| **RNF-04 — Escalabilidad** | Soportar variaciones de carga sin afectar otros dominios. | Docker Compose ejecuta dos réplicas en el despliegue simulado. Existen manifiestos Kubernetes y evidencias históricas de EKS. | Escalado independiente mediante servicios administrados como ECS Fargate o Kubernetes, según la arquitectura definitiva. |
| **Observabilidad** | Detectar problemas de disponibilidad, rendimiento y errores. | Actuator, Micrometer, Prometheus, Grafana Alloy, Loki y Grafana cuentan con configuraciones y evidencias en el proyecto. | Evolución hacia monitoreo persistente, alertas y operación productiva. |
| **Seguridad** | Reducir riesgos en el ciclo de desarrollo y operación. | Se incorporaron controles automatizados de análisis de código, dependencias, secretos e imágenes. | Completar controles de identidad, autorización, cifrado y protección perimetral en una infraestructura productiva. |

### Consideración especial sobre Amazon EKS

El repositorio contiene manifiestos y automatización para desplegar la aplicación y los componentes de observabilidad en EKS.

También existe una validación histórica exitosa documentada en la ejecución de GitHub Actions `45086754091`, que registró dos réplicas saludables, 66 segundos de despliegue y 100 % de cobertura de líneas JaCoCo.

Posteriormente se diagnosticaron restricciones del entorno AWS Academy: una política SCP denegaba `ec2:DescribeInstances` y también se identificaron restricciones IAM que impedían completar la inicialización de los nodos.

La ejecución posterior `45197178472` terminó con `deployment "cuentas-svc" exceeded its progress deadline`. Por este motivo, la validación histórica no debe interpretarse como evidencia de que EKS continúa operativo.

El diagnóstico está documentado en `docs/evidencias/ep3/ie2/limitacion-eks-aws-academy.md`. En la última ejecución de `main`, el trabajo EKS quedó omitido por las condiciones de configuración del workflow.

## 5. Seguridad: relación con STRIDE

STRIDE permite identificar amenazas y relacionarlas con controles adecuados. En la siguiente tabla se distingue entre controles presentes en el proyecto y medidas que corresponden a una arquitectura objetivo.

| Amenaza | Riesgo | Control o decisión | Estado en este proyecto |
|---|---|---|---|
| **Spoofing** | Suplantación de identidad de un consumidor. | Autenticación mediante JWT y validación centralizada en API Gateway. | Propuesta para la arquitectura objetivo; no se debe afirmar que existe un API Gateway o autenticación JWT implementada en este microservicio. |
| **Tampering** | Modificación de datos mediante solicitudes inválidas o no autorizadas. | Bean Validation y controles de autorización por rol. | Bean Validation está implementada. La autorización centralizada por roles es una medida propuesta, no acreditada por la implementación actual. |
| **Repudiation** | Dificultad para atribuir una operación. | Auditoría de eventos y registro de operaciones relevantes. | Existe logging de aplicación y observabilidad; no se debe confundir con una auditoría transaccional completa. |
| **Information Disclosure** | Exposición de información que debería estar protegida. | Cifrado con KMS y aislamiento de datos por tenant. | Son controles propuestos para una infraestructura productiva; no están acreditados como implementados en esta aplicación. |
| **Denial of Service** | Consumo excesivo de recursos o solicitudes abusivas. | Throttling en API Gateway y caché mediante Redis. | No están implementados en este microservicio. Sí existen límites de recursos en Docker Compose y controles de salud. |
| **Elevation of Privilege** | Acceso a operaciones sin autorización suficiente. | Validación de roles, políticas IAM y reglas de red. | Son medidas de la arquitectura objetivo. El pipeline sí incorpora controles automatizados de seguridad del software y de la imagen. |

### Controles de seguridad efectivamente incorporados

El pipeline incluye controles específicos para el ciclo de desarrollo:

- **Snyk:** análisis de dependencias y código, con umbral de severidad configurado.
- **Gitleaks:** detección de secretos en el repositorio y su historial.
- **Trivy:** análisis de vulnerabilidades de la imagen Docker, con bloqueo configurado para hallazgos críticos.
- **SonarQube Cloud:** análisis estático y evaluación del Quality Gate.
- **GitHub:** integración mediante Pull Requests y controles de protección de la rama principal.

Estos controles reducen riesgos en el proceso de construcción y entrega, pero no reemplazan mecanismos de autenticación, autorización ni cifrado de datos de la aplicación.

## 6. Servicios AWS considerados en la arquitectura objetivo

Los siguientes servicios se documentan como alternativas de diseño para una evolución de NovaBank. No deben presentarse como recursos desplegados por el microservicio actual.

| Servicio AWS | Responsabilidad propuesta | Justificación arquitectónica |
|---|---|---|
| **Amazon Aurora Serverless** | Persistencia relacional administrada. | Permitiría disponer de almacenamiento persistente y capacidad de adaptación a la demanda. |
| **Amazon ElastiCache (Redis)** | Caché de consultas frecuentes. | Reduciría la presión de lectura sobre la base de datos. |
| **Amazon CloudFront** | Distribución de contenido. | Permitiría acercar contenido cacheable a los consumidores. |
| **Amazon API Gateway** | Entrada centralizada a las API. | Permitiría aplicar autenticación, autorización y límites de solicitudes. |
| **AWS KMS** | Gestión de claves de cifrado. | Permitiría proteger información almacenada y otros recursos compatibles. |
| **Amazon CloudWatch + AWS X-Ray** | Métricas, registros y trazabilidad distribuida. | Facilitarían el monitoreo integrado de una infraestructura AWS productiva. |
| **Amazon ECS Fargate** | Ejecución administrada de contenedores. | Sería una alternativa para escalar el microservicio sin administrar servidores. |

En la implementación actual, la base de datos es H2 en memoria y la ejecución de contenedores se valida con Docker y Docker Compose. La experiencia de EKS se documenta por separado, incluyendo sus evidencias históricas y las limitaciones del laboratorio.

## 7. Patrones y principios de diseño

### Aplicados en el repositorio

| Principio o patrón | Aplicación |
|---|---|
| Responsabilidad Única (SRP) | El servicio se enfoca en el dominio de Cuentas. |
| Arquitectura por capas | Se separan Controller, Service y Repository. |
| API REST | Se exponen operaciones HTTP sobre recursos del dominio. |
| Contenedorización | Docker empaqueta la aplicación en una imagen reproducible. |
| Trazabilidad | La imagen utiliza el SHA del commit que originó la ejecución. |

### Considerados en la arquitectura objetivo

| Patrón o mecanismo | Propósito |
|---|---|
| API Gateway | Centralizar el acceso y aplicar controles a las API. |
| Service Registry | Facilitar el descubrimiento de instancias. |
| Circuit Breaker | Aislar fallos de servicios dependientes. |
| Cache-Aside | Reducir consultas repetitivas a la persistencia. |
| CDN | Distribuir contenido cacheable. |
| Comunicación asíncrona mediante SQS/EventBridge | Desacoplar procesos y eventos entre dominios. |

La inclusión de estos patrones en el diseño no implica que todos estén implementados en el código actual.

## 8. Delimitación de responsabilidades entre dominios

El diseño general de NovaBank contempla distintos servicios de negocio. La separación propuesta permite asignar responsabilidades específicas:

| Dominio | Responsabilidad prevista |
|---|---|
| Cuentas | Gestión de cuentas y consulta de información asociada. |
| Autenticación | Identidad, inicio de sesión y emisión o validación de credenciales. |
| Transferencias | Operaciones y coordinación de transferencias. |
| Préstamos | Operaciones relacionadas con productos de crédito. |
| Antifraude | Evaluación y detección de operaciones sospechosas. |
| Notificaciones | Entrega de comunicaciones a los usuarios. |

Esta delimitación representa el modelo de dominios del caso. El alcance implementado en este repositorio corresponde al microservicio de Cuentas, no a la construcción completa de todos los servicios enumerados.

## 9. Documentación y evidencias relacionadas

La implementación y sus decisiones pueden revisarse en los siguientes recursos del repositorio:

- `README.md`: resumen del proyecto, tecnologías, pipeline y procedimientos de ejecución.
- `docs/00_Resumen.md`: propósito y stack tecnológico.
- `docs/01_Arquitectura.md`: componentes y separación entre arquitectura implementada y de referencia.
- `docs/02_API.md`: contrato de la API REST.
- `docs/03_Pruebas.md`: estrategia de pruebas y cobertura.
- `docs/04_Despliegue.md`: instrucciones de ejecución y despliegue local.
- `docs/diagramas/`: diagramas de contexto, contenedores, componentes, secuencia e infraestructura.
- `docs/evidencias/ep3/`: evidencias de observabilidad, Kubernetes, seguridad y decisiones técnicas.
- `.github/workflows/pipeline.yml`: definición del pipeline de integración, validación y despliegue.

La documentación debe leerse considerando siempre la diferencia entre la arquitectura objetivo del caso, las funcionalidades implementadas y las validaciones históricas del entorno académico.
