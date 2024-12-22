package com.jerryfelipe.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class UserController {

    // Custom login page
    @GetMapping("/login")
    public String login() {
        return "login";  // Return view name "login" (you will need to create the login.html page)
    }

    // Registration page (optional)
    @GetMapping("/register")
    public String register() {
        return "register";  // Return view name "register" (create the register.html page)
    }
}
