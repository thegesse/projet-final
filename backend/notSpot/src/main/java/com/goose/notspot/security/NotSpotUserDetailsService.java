package com.goose.notspot.security;

import com.goose.notspot.model.user.Role;
import com.goose.notspot.model.user.User;
import com.goose.notspot.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class NotSpotUserDetailsService implements UserDetailsService {
    private final UserRepository userRepository;

    public NotSpotUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
        Role role = user.getRole() == null ? Role.USER : user.getRole();

        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword())
                .roles(role.name())
                .build();
    }
}
