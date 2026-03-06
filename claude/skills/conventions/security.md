# Spring Security Conventions

> How to set up authentication and authorization: roles, user details service, security config, and auth flow.

## Rules

- `Role` enum defines available roles. Always includes `ADMIN` plus one or more domain roles.
- `User` entity is the auth source — must have: username, password, email, role, enabled.
- `CustomUserDetailsService` implements `UserDetailsService`:
  - Looks up user by username (converted to lowercase).
  - Maps the `Role` enum to a Spring Security authority: `"ROLE_" + user.getRole().name()`.
  - Sets `disabled`, `accountExpired`, `accountLocked`, `credentialsExpired` flags.
- `SecurityConfig`:
  - `@Configuration @EnableWebSecurity`.
  - `SecurityFilterChain` bean with `HttpSecurity`:
    - Public routes: `/`, `/home`, `/register`, `/css/**`, `/js/**`, `/img/**`, `/.well-known/**`.
    - Role-restricted routes: `/admin/**` requires ADMIN, `/<role>/**` requires that role.
    - Form login: login page at `/home`, processing URL `/login`, default success URL `/dashboard`.
    - Logout: success URL `/home?logout`.
  - `DaoAuthenticationProvider` bean wiring the custom user details service + password encoder.
  - `BCryptPasswordEncoder` bean.
- `DashboardController` at `/dashboard` checks the user's role and redirects to the appropriate role-specific dashboard (e.g., `/admin/dashboard` or `/user/dashboard`).
- `AuthController` handles:
  - `GET /` and `GET /home` — home page.
  - `GET /register` — registration form.
  - `POST /register` — create user, redirect to `/login?registered` on success.
  - `GET /login` — login page.
- `UserRegistrationDto` uses `@Data` (DTOs are the exception to the `@Getter/@Setter` rule). Fields: username, email, password, confirmPassword.
- Registration validation happens in the service layer, not the controller. Controller catches `IllegalArgumentException` and redirects with error flash attributes.
- Seed users: one admin and one domain-role user, both with BCrypt-encoded password "password".

## Example

### Role enum

```java
public enum Role {
    ADMIN,
    USER
}
```

### CustomUserDetailsService

```java
@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username.toLowerCase())
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUsername())
                .password(user.getPassword())
                .authorities(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()))
                .disabled(!user.isEnabled())
                .accountExpired(false)
                .accountLocked(false)
                .credentialsExpired(false)
                .build();
    }
}
```

### SecurityConfig

```java
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final CustomUserDetailsService userDetailsService;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authorize -> authorize
                .requestMatchers("/", "/home", "/register",
                        "/css/**", "/js/**", "/img/**", "/.well-known/**"
                ).permitAll()
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .requestMatchers("/user/**").hasRole("USER")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/home")
                .loginProcessingUrl("/login")
                .defaultSuccessUrl("/dashboard")
                .permitAll()
            )
            .logout(logout -> logout
                .logoutSuccessUrl("/home?logout")
                .permitAll()
            );

        return http.build();
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

### AuthController

```java
@Controller
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final UserService userService;

    @GetMapping({"/", "/home"})
    public String home() {
        return "home";
    }

    @GetMapping("/login")
    public String showLoginForm() {
        return "common/auth/login";
    }

    @GetMapping("/register")
    public String showRegistrationForm(Model model) {
        if (!model.containsAttribute("user")) {
            model.addAttribute("user", new UserRegistrationDto());
        }
        return "common/auth/register";
    }

    @PostMapping("/register")
    public String registerUser(@ModelAttribute("user") UserRegistrationDto registrationDto,
                               RedirectAttributes redirectAttributes) {
        try {
            if (userService.isUsernameTaken(registrationDto.getUsername())) {
                redirectAttributes.addAttribute("error", "Username is already taken");
                redirectAttributes.addFlashAttribute("user", registrationDto);
                return "redirect:/register";
            }

            if (userService.isEmailRegistered(registrationDto.getEmail())) {
                redirectAttributes.addAttribute("error", "Email is already registered");
                redirectAttributes.addFlashAttribute("user", registrationDto);
                return "redirect:/register";
            }

            userService.createUser(registrationDto);
            return "redirect:/login?registered";
        } catch (IllegalArgumentException e) {
            log.atError().log("Registration failed for user: {}. Reason: {}",
                    registrationDto.getUsername(), e.getMessage());
            redirectAttributes.addAttribute("error", e.getMessage());
            redirectAttributes.addFlashAttribute("user", registrationDto);
            return "redirect:/register";
        } catch (Exception e) {
            log.atError().log("Registration failed for user: {}. Error: {}",
                    registrationDto.getUsername(), e.getMessage());
            redirectAttributes.addAttribute("error", "An unexpected error occurred. Please try again.");
            redirectAttributes.addFlashAttribute("user", registrationDto);
            return "redirect:/register";
        }
    }
}
```

### DashboardController (role-based redirect)

```java
@Controller("commonDashboardController")
@RequestMapping("/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    @GetMapping
    public String dashboard(Authentication authentication) {
        if (authentication.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_ADMIN"))) {
            return "redirect:/admin/dashboard";
        }
        if (authentication.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_USER"))) {
            return "redirect:/user/dashboard";
        }
        return "redirect:/";
    }
}
```
