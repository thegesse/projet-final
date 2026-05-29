package com.goose.notspot.repository;

import com.goose.notspot.model.user.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {
    Optional<RefreshToken> findByToken(String token);
    //for loging out
    void deleteByUserUsername(String username);
}
