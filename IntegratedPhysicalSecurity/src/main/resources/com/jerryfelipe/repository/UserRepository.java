package com.jerryfelipe.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.example.model.UserEntity;

public interface UserRepository extends JpaRepository<UserEntity, String> {
    // This interface will be used by Spring Data JPA for database operations.
    // No need to implement any methods - Spring will do it automatically.
}
