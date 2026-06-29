package com.goose.notspot.model.requestDTO.auth;

public record LoginResponse(
        Long userId,
        String username,
        String email,
        String role,
        String token
) {}
