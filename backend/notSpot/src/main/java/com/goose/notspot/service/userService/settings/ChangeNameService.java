package com.goose.notspot.service.userService.settings;

import com.goose.notspot.model.user.DTO.UserDTO;
import com.goose.notspot.model.user.User;
import com.goose.notspot.repository.UserRepository;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class ChangeNameService {
    private final UserRepository userRepository;


    public ChangeNameService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserDTO changeUsername(Long userId, String username) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if(user.getUsername().equals(username)) {
            return new UserDTO(user.getId(), user.getUsername(), user.getEmail());

        }

        if (userRepository.existsByUsername(username)) {
            throw new UsernameNotFoundException("Username " + username + " already exists");
        }
        user.setUsername(username);

        User savedUser = userRepository.save(user);

        return new UserDTO(savedUser.getId(), savedUser.getUsername(), savedUser.getEmail());
    }
}
