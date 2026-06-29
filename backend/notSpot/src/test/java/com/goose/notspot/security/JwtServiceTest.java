package com.goose.notspot.security;

import com.goose.notspot.model.user.Role;
import com.goose.notspot.model.user.User;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class JwtServiceTest {

    private final JwtService jwtService = new JwtService();

    @Test
    void generatedTokenContainsUsernameAndValidSignature() {
        User user = new User();
        user.setUsername("alice");
        user.setRole(Role.USER);

        String token = jwtService.generateToken(user);

        assertThat(jwtService.extractUsername(token)).isEqualTo("alice");
        assertThat(jwtService.isValid(token, "alice")).isTrue();
        assertThat(jwtService.isValid(token, "bob")).isFalse();
    }

    @Test
    void malformedTokenIsRejected() {
        assertThat(jwtService.extractUsername("not-a-token")).isNull();
        assertThat(jwtService.isValid("not-a-token", "alice")).isFalse();
    }
}
