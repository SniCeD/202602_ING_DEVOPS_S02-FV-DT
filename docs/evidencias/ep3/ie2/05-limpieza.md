# Limpieza del entorno EKS

Verificación final en `us-east-1` el 2026-11-22 23:26:07 UTC.

| Recurso | Resultado observado |
| --- | --- |
| Namespace `ep3` | `kubectl delete namespace ep3 --wait=true` terminó correctamente. |
| Grupo administrado `cuentas-ep3` | EKS devolvió una lista de grupos vacía antes de eliminar el clúster. |
| Grupo de Auto Scaling de `cuentas-ep3` | La consulta por nombre devolvió cero grupos. |
| Instancia EC2 `i-0e3f7cae46962836a` | EC2 devolvió estado `terminated`. |
| Volumen EBS `vol-0f90252c5775c5ee1` | La consulta filtrada por ID devolvió cero volúmenes. |
| Clúster `novabank-ep3` | EKS devolvió `ResourceNotFoundException` al consultar el clúster. |
