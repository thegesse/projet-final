package com.goose.notspot.repository;

import com.goose.notspot.model.user.user;
import org.springframework.data.jpa.repository.JpaRepository;

public interface userRepository extends JpaRepository<user,Long> {
}
