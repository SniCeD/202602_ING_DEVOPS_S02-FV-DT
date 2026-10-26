package cl.duoc.jv0101.caso04.cuentas.cucumber;

import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import io.cucumber.spring.CucumberContextConfiguration;
import org.springframework.boot.test.context.SpringBootTest;

@CucumberContextConfiguration
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureTestRestTemplate
public class CucumberSpringConfiguration {
}
