# Cuentas — Microservicio de riesgo cuentas

Microservicio correspondiente al **caso caso04 — NovaBank** (Banca digital / fintech) de la Evaluación Parcial N°1.

| | |
|---|---|
| Asignatura | JVY0101 — Java: Diseño y Construcción de Soluciones Nativas en Nube |
| Stack | Spring Boot 3.3 · Java 21 · Maven · Spring Data JPA · H2 · springdoc-openapi |
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

## Cómo ejecutar localmente

```bash
mvn spring-boot:run
```

## Cómo ejecutar con Docker

```bash
docker compose up --build
# http://localhost:8080
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

### Reflexiones

Fernando Valenzuela: Esta evaluación me resulto util para entender el porque es necesario crear ramas en lugar de subir todo directo a main, hasta ahora siento que voy bien y no hay algo especifico que me cueste y la parte de que tengamos que aprobar los pull request del otro me parece que es algo que vamos a ver mucho al momento de trabajar en un proyecto real.

Dacier Tapia: Esta evaluación me permitió comprender como funciona el desarrollo a través de las prácticas de devops, y algunas acciones utilizadas en las herramientas que utilizamos en la entrega, como lo son Git, Github y Visual Studio Code. Me pareció muy divertido e intrigante el uso de PRs con reviews asignadas a mi compañero, ya qué nos ayudaba a que ambos estuvieramos al tanto de los cambios realizados en el proyecto y a que nos pudieramos dar feedback y así poder ir mejorando nuestro trabajo de forma continua, ordenada y colaborativa.
Y para cerrar, si bien siento que al ser una evaluación tenemos más presión, al desarrollar un proyecto o tarea en específico, se aprende más rápido y también con más ganas.