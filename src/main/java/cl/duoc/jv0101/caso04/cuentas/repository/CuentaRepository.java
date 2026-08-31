package cl.duoc.jv0101.caso04.cuentas.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import cl.duoc.jv0101.caso04.cuentas.model.Cuenta;

public interface CuentaRepository extends JpaRepository<Cuenta, Long> {
}
