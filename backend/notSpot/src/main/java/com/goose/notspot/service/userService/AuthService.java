package com.goose.notspot.service.userService;

import com.goose.notspot.model.requestDTO.auth.CreateUserRequest;
import com.goose.notspot.model.response.LoginResponse;
import com.goose.notspot.model.user.DTO.UserDTO;
import com.goose.notspot.model.user.RefreshToken;
import com.goose.notspot.model.user.User;
import com.goose.notspot.repository.RefreshTokenRepository;
import com.goose.notspot.repository.UserRepository;
import com.goose.notspot.service.JwtService.JwtService;
import com.goose.notspot.service.JwtService.RefreshTokenService;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserCreationService userCreationService;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final RefreshTokenRepository refreshTokenRepository;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, UserCreationService userCreationService, JwtService jwtService, RefreshTokenService refreshTokenService, RefreshTokenRepository refreshTokenRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.userCreationService = userCreationService;
        this.jwtService = jwtService;
        this.refreshTokenService = refreshTokenService;
        this.refreshTokenRepository = refreshTokenRepository;
    }

    public LoginResponse register(CreateUserRequest request) {
        UserDTO userDto = userCreationService.createUser(
                request.username(),
                request.password(),
                request.email()
        );
        String accessToken = jwtService.generateAuthToken(userDto.username());
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(userDto.username());

        return new LoginResponse(userDto, accessToken, refreshToken.getToken());
    }

    public LoginResponse login(String username, String password) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));

        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new BadCredentialsException("Invalid credentials");
        }
        UserDTO userDto = new UserDTO(user.getId(), user.getUsername(), user.getEmail());
        String accessToken = jwtService.generateAuthToken(user.getUsername());
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user.getUsername());
        return new LoginResponse(userDto, accessToken, refreshToken.getToken());
    }

    public LoginResponse refreshSession(String requestToken) {
        return refreshTokenRepository.findByToken(requestToken)
                .map(refreshTokenService::verifyExpiration) // Verifies it hasn't expired
                .map(RefreshToken::getUser) // Gets the associated User
                .map(user -> {
                    String newAccessToken = jwtService.generateAuthToken(user.getUsername());
                    UserDTO userDto = new UserDTO(user.getId(), user.getUsername(), user.getEmail());

                    return new LoginResponse(userDto, newAccessToken, requestToken);
                })
                .orElseThrow(() -> new RuntimeException("Refresh token is not in database!"));
    }

    public void logout(String username) {
        refreshTokenService.deleteByUsername(username);
    }
}
