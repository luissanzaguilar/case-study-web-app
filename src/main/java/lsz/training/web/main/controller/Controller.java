package lsz.training.web.main.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.atomic.AtomicLong;

@RestController
public class Controller {


    @Value("${app.welcome.message:Welcome default message.}")
    private String appMessage;
    private static final String template = "Main application, %s!";
    private final AtomicLong counter = new AtomicLong();

    @GetMapping("/")
    public Main main(@RequestParam(defaultValue = "You can start") String name) {
        return new Main(counter.incrementAndGet(), String.format(appMessage + template, name));
    }
}