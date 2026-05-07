package com.goose.notspot.service;

import com.goose.notspot.model.requestDTO.CreateUserRequest;
import com.goose.notspot.model.user.DTO.UserDTO;
import com.goose.notspot.model.user.User;
import com.goose.notspot.repository.UserRepository;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserCreationService userCreationService;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, UserCreationService userCreationService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.userCreationService = userCreationService;
    }

    public UserDTO register(CreateUserRequest request) {
        return userCreationService.createUser(
                request.username(),
                request.password(),
                request.email()
        );
    }

    public UserDTO login(String username, String password) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));

        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new BadCredentialsException("Invalid credentials");
        }

        return new UserDTO(user.getId(), user.getUsername(), user.getEmail());
    }


}
