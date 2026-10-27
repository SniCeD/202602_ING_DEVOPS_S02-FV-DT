# Cuentas — Microservicio de riesgo cuentas

Microservicio correspondiente al **caso caso04 — NovaBank** (Banca digital / fintech), desarrollado inicialmente en la Evaluación Parcial N°1 y extendido para la Evaluación Parcial N°2.

| | |
|---|---|
| Asignatura | JVY0101 — Java: Diseño y Construcción de Soluciones Nativas en Nube |
| Stack | Spring Boot 4.1.2 · Java 21 · Maven · Spring Data JPA · H2 · springdoc-openapi |
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


## Despliegue automático y trazabilidad (IE4)

El pipeline de GitHub Actions incorpora un despliegue automático en un entorno simulado utilizando Docker Compose.

El trabajo de despliegue depende de la ejecución correcta de:

- Pruebas automatizadas y cobertura.
- Análisis de dependencias con Snyk.
- Análisis estático de código con Snyk Code.
- Construcción de la imagen Docker.

La imagen Docker se identifica utilizando el SHA del commit que originó la ejecución del pipeline.

El formato utilizado es:

duoc/jv0101-caso04-cuentas:<GITHUB_SHA>

La imagen construida se exporta como artefacto dentro de GitHub Actions y posteriormente es recuperada por el trabajo de despliegue.

Después de levantar el entorno se realizan verificaciones automáticas sobre:

- Cantidad de réplicas levantadas.
- Estado de salud de los contenedores.
- Respuesta HTTP de las instancias.
- Imagen Docker correspondiente al SHA del commit ejecutado.

Al finalizar la validación, el entorno utilizado por el pipeline se elimina mediante Docker Compose.


## Orquestación con Docker Compose (IE5)

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

## Conclusiones

### Reflexiones (EP2)

Fernando Valenzuela: Aprendí como configurar Snyk con actions para analizar vulnerabilidades, tuve que pelear con las vulnerabilidades que detecto el Snyk para mitigarlas pero al final se logró, aplicaría esto para el proyecto de portafolio de titulo que estamos haciendo, así nos va a quedar un proyecto mucho más profesional.

Dacier Tapia: Esta evaluación me permitió entender como funciona el despliegue CI/CD, con pruebas, seguridad, la construcción y el despliegue, dependiendo unas de otras. Además del uso de réplicas y healthchecks.
Tuve problemas con el tema de los puertos ya que se sobreponían al ser estáticos, pero al no especificarlos, se volvieron dinámicos y funcionó todo bien.