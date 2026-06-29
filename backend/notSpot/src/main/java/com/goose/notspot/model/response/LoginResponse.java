package com.goose.notspot.model.response;

import com.goose.notspot.model.user.DTO.UserDTO;

public record LoginResponse(
        UserDTO user,
        String accessToken,
        String refreshToken
) {
}
