# Controller Conventions

> How to structure Spring MVC controllers: package layout, authorization guards, redirect patterns, and flash messages.

## Rules

- Controller packages mirror roles: `controller/admin/`, `controller/<domain-role>/`, `controller/common/`, `controller/common/auth/`, `controller/common/error/`.
- Use `@RequiredArgsConstructor` for dependency injection — no `@Autowired` on fields.
- Get the current user via `@AuthenticationPrincipal UserDetails userDetails`, then look up the full User entity from the service.
- Every handler that operates on an owned or member-restricted resource starts with:
  1. Look up the entity (return redirect if not found).
  2. Check the current user has access (membership, ownership, or role).
  3. Redirect with an error flash attribute if access denied.
- **Never perform mutations (save, delete, update) before completing access checks.** All guards must pass before any state-changing work happens. This applies to both GET and POST handlers.
- Use `RedirectAttributes` for flash messages — `addFlashAttribute("successMessage", ...)` and `addFlashAttribute("errorMessage", ...)`.
- Redirect URLs are built inline: `"redirect:/player/things/" + thingId`.
- AJAX endpoints use `@ResponseBody` and return simple strings ("success", "error", "max-reached").
- When a controller bean name would conflict across packages (e.g., multiple `DashboardController`), use `@Controller("specificName")`.
- Use `@Slf4j` for logging. Log errors with context: `log.atError().log("Action failed for user: {}. Reason: {}", username, e.getMessage())`.

## Example

```java
package com.example.app.controller.user;

import com.example.app.model.*;
import com.example.app.service.ItemService;
import com.example.app.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Optional;

@Controller
@RequestMapping("/user/items")
@RequiredArgsConstructor
public class ItemController {

    private final ItemService itemService;
    private final UserService userService;

    @GetMapping("/{itemId}")
    public String viewItem(@PathVariable Long itemId,
                           @AuthenticationPrincipal UserDetails userDetails,
                           RedirectAttributes redirectAttributes,
                           Model model) {
        // 1. Look up entity
        Optional<Item> itemOpt = itemService.getItemById(itemId);
        if (itemOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "Item not found.");
            return "redirect:/user/dashboard";
        }

        // 2. Check access
        Item item = itemOpt.get();
        User user = userService.findByUsername(userDetails.getUsername());
        if (!item.getOwner().equals(user)) {
            redirectAttributes.addFlashAttribute("errorMessage", "You don't have access to this item.");
            return "redirect:/user/dashboard";
        }

        // 3. Render
        model.addAttribute("item", item);
        return "user/items/view";
    }

    @PostMapping("/{itemId}/delete")
    public String deleteItem(@PathVariable Long itemId,
                             @AuthenticationPrincipal UserDetails userDetails,
                             RedirectAttributes redirectAttributes) {
        // 1. Look up entity
        Optional<Item> itemOpt = itemService.getItemById(itemId);
        if (itemOpt.isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "Item not found.");
            return "redirect:/user/dashboard";
        }

        // 2. Check access BEFORE any mutation
        Item item = itemOpt.get();
        User user = userService.findByUsername(userDetails.getUsername());
        if (!item.getOwner().equals(user)) {
            redirectAttributes.addFlashAttribute("errorMessage", "You don't have access to this item.");
            return "redirect:/user/dashboard";
        }

        // 3. Now safe to mutate
        itemService.deleteItem(item);
        redirectAttributes.addFlashAttribute("successMessage", "Item deleted.");
        return "redirect:/user/items";
    }
}
```
