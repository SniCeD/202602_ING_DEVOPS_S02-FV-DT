# Cuentas — Arquitectura del microservicio

## Alcance de este documento

Este documento distingue entre la arquitectura implementada en este repositorio y la arquitectura de referencia del caso NovaBank.

**Implementado en este repositorio:** microservicio REST de Cuentas con Spring Boot, organizado en capas, persistencia H2 en memoria, pruebas automatizadas, contenedorización Docker y configuraciones de observabilidad y despliegue.

**Arquitectura de referencia del caso:** componentes y patrones descritos en el diseño general de NovaBank, como API Gateway, Service Registry, Circuit Breaker, SQS y Lambda. Se presentan como decisiones o alternativas de arquitectura objetivo; no significa que todos estén desplegados o implementados en este microservicio.

## Componentes implementados

| Componente | Rol |
|---|---|
| `CuentaApplication` | Punto de entrada de Spring Boot |
| `controller/CuentaController.java` | API REST expuesta en `/api/cuentas` |
| `service/CuentaService.java` | Lógica de negocio y operaciones del servicio |
| `repository/CuentaRepository.java` | Acceso a datos mediante Spring Data JPA |
| `model/Cuenta.java` | Entidad del dominio persistida en H2 |
| `config/OpenApiConfig.java` | Metadata de documentación OpenAPI |
| `static/index.html` | Página de presentación en `/` |
| `static/redoc.html` | Referencia ReDoc de la API |

La base de datos utilizada por la aplicación es H2 en memoria. En consecuencia, no debe confundirse con una base de datos administrada o persistente de AWS.

## Principios aplicados

- **Responsabilidad Única (SRP):** el servicio concentra las operaciones del dominio de Cuentas.
- **Separación de responsabilidades:** Controller, Service y Repository mantienen diferenciadas la interfaz HTTP, la lógica de negocio y el acceso a datos.
- **Bajo acoplamiento:** el servicio mantiene su propia API y persistencia, sin compartir tablas con otros dominios.
- **Mantenibilidad y verificabilidad:** el código, las pruebas y el proceso de construcción se organizan para poder validarse de forma independiente.

## Arquitectura de referencia del caso NovaBank (EP01)

En el diseño general del caso se consideran los siguientes componentes y patrones:

- **API Gateway:** punto de entrada centralizado para las API de los distintos servicios.
- **Service Registry:** mecanismo de descubrimiento de instancias.
- **Circuit Breaker:** patrón para aislar fallos de dependencias externas.
- **Colas AWS SQS:** alternativa de comunicación asíncrona entre servicios.
- **AWS Lambda:** alternativa para procesamiento eventual, como notificaciones, reportes o analítica.

Estos elementos pertenecen al diseño de referencia del caso. No se deben presentar como componentes desplegados por esta aplicación, salvo que exista evidencia específica de su implementación.

## Flujo de la aplicación implementada

El recorrido de una petición en este repositorio es:

`Cliente HTTP → CuentaController → CuentaService → CuentaRepository → H2`

El cliente consume directamente la API REST del microservicio. La aplicación no requiere un API Gateway para ejecutar este flujo localmente.

## Flujo conceptual de la arquitectura de referencia

En el diseño general de NovaBank, el acceso a los microservicios puede representarse de la siguiente manera:

`Cliente/Sistema → API Gateway → Microservicio de Cuentas → lógica de negocio → persistencia`

El API Gateway de este diagrama corresponde a la arquitectura objetivo del caso, no a un componente incluido en el flujo local implementado en este repositorio.
