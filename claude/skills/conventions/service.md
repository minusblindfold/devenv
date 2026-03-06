# Service Layer Conventions

> How to structure business logic: interface + implementation, transactions, validation, and exception handling.

## Rules

- Every service has an interface and a separate implementation class.
- Interface lives in the `service` package. Impl lives in the same package, suffixed with `Impl`.
- Interface methods have JavaDoc with `@param` and `@return` tags.
- Impl is annotated `@Service @RequiredArgsConstructor`. Dependencies are `private final` fields injected via constructor (Lombok generates it).
- Mutating methods: `@Transactional`.
- Read-only methods: `@Transactional(readOnly = true)`.
- Input validation lives in private `validate*()` methods inside the impl — never in controllers.
- Missing entity lookups throw `EntityNotFoundException` with a descriptive message.
- Validation failures throw `IllegalArgumentException` with a user-facing message.
- Use `@Slf4j` (Lombok) for logging. Use `log.atInfo().log(...)` or `log.info(...)` style.
- Entity creation uses the Builder pattern.
- Usernames and emails are normalized to lowercase before storing.

## Example

```java
// --- Interface ---
package com.example.app.service;

import com.example.app.dto.UserRegistrationDto;
import com.example.app.model.User;

import java.util.Optional;

/**
 * Service interface for user-related operations.
 */
public interface UserService {

    /**
     * Create a new user from registration data.
     *
     * @param registrationDto the registration data
     * @return the created user
     */
    User createUser(UserRegistrationDto registrationDto);

    /**
     * Find a user by username.
     *
     * @param username the username
     * @return the user if found, null otherwise
     */
    User findByUsername(String username);

    /**
     * Check if a username is already taken (case-insensitive).
     *
     * @param username the username to check
     * @return true if taken
     */
    boolean isUsernameTaken(String username);
}

// --- Implementation ---
package com.example.app.service;

import com.example.app.dto.UserRegistrationDto;
import com.example.app.model.Role;
import com.example.app.model.User;
import com.example.app.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public User createUser(UserRegistrationDto dto) {
        validateRegistrationInput(dto);

        User user = User.builder()
                .username(dto.getUsername().trim().toLowerCase())
                .email(dto.getEmail().trim().toLowerCase())
                .password(passwordEncoder.encode(dto.getPassword()))
                .role(Role.USER)
                .enabled(true)
                .build();

        log.atInfo().log("Creating user: {}", user.getUsername());
        return userRepository.save(user);
    }

    @Override
    @Transactional(readOnly = true)
    public User findByUsername(String username) {
        return userRepository.findByUsername(username.toLowerCase()).orElse(null);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isUsernameTaken(String username) {
        return userRepository.existsByUsernameIgnoreCase(username);
    }

    private void validateRegistrationInput(UserRegistrationDto dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Registration data cannot be null");
        }
        if (dto.getUsername() == null || dto.getUsername().trim().isEmpty()) {
            throw new IllegalArgumentException("Username is required");
        }
        if (dto.getUsername().trim().length() < 3 || dto.getUsername().trim().length() > 20) {
            throw new IllegalArgumentException("Username must be between 3 and 20 characters");
        }
        if (!dto.getUsername().trim().matches("^[a-zA-Z0-9_-]+$")) {
            throw new IllegalArgumentException("Username can only contain letters, numbers, underscores, and hyphens");
        }
        if (isUsernameTaken(dto.getUsername().trim())) {
            throw new IllegalArgumentException("Username is already taken");
        }

        // Validate email
        if (dto.getEmail() == null || dto.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email is required");
        }
        if (!dto.getEmail().trim().matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            throw new IllegalArgumentException("Please provide a valid email address");
        }

        // Validate password
        if (dto.getPassword() == null || dto.getPassword().isEmpty()) {
            throw new IllegalArgumentException("Password is required");
        }
        if (dto.getPassword().length() < 8) {
            throw new IllegalArgumentException("Password must be at least 8 characters long");
        }

        // Validate password confirmation
        if (dto.getConfirmPassword() == null || !dto.getPassword().equals(dto.getConfirmPassword())) {
            throw new IllegalArgumentException("Passwords do not match");
        }
    }
}
```
