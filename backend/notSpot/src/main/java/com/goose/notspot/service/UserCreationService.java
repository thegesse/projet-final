package com.goose.notspot.service;

import com.goose.notspot.model.user.DTO.UserDTO;
import com.goose.notspot.model.user.User;
import com.goose.notspot.repository.UserRepository;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserCreationService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;


    public UserCreationService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public UserDTO createUser(String username, String password, String email) {
        if (userRepository.existsByUsername(username)) {
            throw new UsernameNotFoundException("Username " + username + " already exists");
        }
        if (userRepository.existsByEmail(email)) {
            throw new UsernameNotFoundException("Email " + email + " already in use");
        }

        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));

        User savedUser = userRepository.save(user);

        return new UserDTO(savedUser.getId(), savedUser.getUsername(), savedUser.getEmail());
    }
}
