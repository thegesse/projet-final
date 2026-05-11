package com.goose.notspot.controller;

import com.goose.notspot.model.requestDTO.CreateUserRequest;
import com.goose.notspot.model.requestDTO.LoginRequest;
import com.goose.notspot.model.user.DTO.UserDTO;
import com.goose.notspot.service.userService.AuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public UserDTO register(@Valid @RequestBody CreateUserRequest request) {
        return authService.register(request);
    }
    @PostMapping("/login")
    public UserDTO login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request.username(), request.password());
    }
}
