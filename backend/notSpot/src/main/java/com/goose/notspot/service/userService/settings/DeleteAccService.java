package com.goose.notspot.service.userService.settings;

import com.goose.notspot.model.requestDTO.DeleteAccountRequest;
import com.goose.notspot.model.user.User;
import com.goose.notspot.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class DeleteAccService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public DeleteAccService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public void deleteAccount(Long userId, DeleteAccountRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if(!passwordEncoder.matches(request.password(),  user.getPassword())) {
            throw new RuntimeException("Wrong password");
        }

        userRepository.deleteById(userId);
    }
}
