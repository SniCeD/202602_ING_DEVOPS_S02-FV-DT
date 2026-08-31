package cl.duoc.jv0101.caso04.cuentas.service;

import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;
import cl.duoc.jv0101.caso04.cuentas.model.Cuenta;
import cl.duoc.jv0101.caso04.cuentas.repository.CuentaRepository;

@Service
public class CuentaService {

    private final CuentaRepository repository;

    public CuentaService(CuentaRepository repository) {
        this.repository = repository;
    }

    public List<Cuenta> findAll() {
        return repository.findAll();
    }

    public Optional<Cuenta> findById(Long id) {
        return repository.findById(id);
    }

    public Cuenta create(Cuenta recurso) {
        return repository.save(recurso);
    }

    public Optional<Cuenta> update(Long id, Cuenta datos) {
        return repository.findById(id).map(existente -> {
            existente.setNombre(datos.getNombre());
            existente.setTitular(datos.getTitular());
            existente.setSaldo(datos.getSaldo());
            return repository.save(existente);
        });
    }

    public boolean delete(Long id) {
        return repository.findById(id).map(existente -> {
            repository.delete(existente);
            return true;
        }).orElse(false);
    }
}
