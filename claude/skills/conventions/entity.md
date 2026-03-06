# JPA Entity Conventions

> How to structure JPA entities: Lombok annotations, relationships, equals/hashCode, and audit fields.

## Rules

- Use `@Getter @Setter` on the class. Never use `@Data` on entities.
- Always add `@Builder`, `@NoArgsConstructor`, `@AllArgsConstructor`.
- Add `@ToString(exclude = {...})` listing all bidirectional relationship fields to prevent infinite recursion.
- Use `@Builder.Default` on collection fields and initialize them to `new HashSet<>()`.
- Primary keys: `@Id @GeneratedValue(strategy = GenerationType.IDENTITY)` with `Long` type.
- Enums: `@Enumerated(EnumType.STRING)` — never store as ordinals.
- All `@ManyToOne` and `@OneToMany` relationships use `FetchType.LAZY`.
- `@ManyToOne` side: always include `@JoinColumn(name = "..._id", nullable = false)` with an explicit column name. The column name should be the relationship name suffixed with `_id` (e.g., `creator_id`, `party_id`).
- Owning `@OneToMany` side uses `cascade = CascadeType.ALL, orphanRemoval = true`.
- Always include audit timestamps: `@CreationTimestamp` on `createdAt` (updatable = false) and `@UpdateTimestamp` on `updatedAt`.
- Column constraints: always declare `nullable` and `unique` explicitly. Use `length` on `VARCHAR` columns.
- Custom `equals()`: compare only by `id` with null guard — two entities are equal only if both have non-null IDs that match.
- Custom `hashCode()`: return `getClass().hashCode()` (constant per entity type). This is safe with Hibernate proxies and prevents issues when entities are added to Sets before being persisted.

## Example

```java
package com.example.app.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Entity
@Table(name = "users")
@Getter
@Setter
@ToString(exclude = {"ownedItems", "memberships"})
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Role role;

    @Column(nullable = false)
    @Builder.Default
    private boolean enabled = true;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "creator", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<Item> ownedItems = new HashSet<>();

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<Membership> memberships = new HashSet<>();

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return id != null && Objects.equals(id, user.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
```
