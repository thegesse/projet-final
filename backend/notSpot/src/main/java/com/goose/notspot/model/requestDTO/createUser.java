package com.goose.notspot.model.requestDTO;

public record createUser(
        String username,
        String email,
        String password
) {}
