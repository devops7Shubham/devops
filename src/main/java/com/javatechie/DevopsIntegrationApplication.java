package com.javatechie;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
//adding underneath code so that timestamp error is avoided when docker image is built and ran
@RequestMapping("/api")
public class DevopsIntegrationApplication {

	@GetMapping
	public String message(){
		return "welcome to Young Minds";
	}

	public static void main(String[] args) {
		SpringApplication.run(DevopsIntegrationApplication.class, args);
	}

}
