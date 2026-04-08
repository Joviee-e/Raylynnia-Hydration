# Design System Strategy: The Fluid Sanctuary

### 1. Overview & Creative North Star
**Creative North Star: The Fluid Sanctuary**
This design system rejects the "utility-first" clutter of traditional tracking apps. Instead, it embraces a "High-End Editorial" approach to digital wellness. We are building a space that feels like a premium spa or a high-end architectural publication—quiet, intentional, and restorative.

The interface moves away from rigid, boxy grids in favor of **Atmospheric Depth**. By utilizing wide margins, intentional asymmetry, and overlapping tonal layers, we create a sense of movement and flow. The experience should feel like a rhythmic ritual rather than a chore.

---

### 2. Colors & Surface Philosophy
The palette is a curated spectrum of atmospheric blues and mineral greys. It is designed to lower the user's heart rate, not demand their attention.

*   **The "No-Line" Rule:** Under no circumstances should 1px solid borders be used to define sections or containers. Visual boundaries are created exclusively through background shifts. For example, a `surface-container-low` (#f0f4f7) block should sit flush against a `surface` (#f7f9fb) background to imply structure.
*   **Surface Hierarchy & Nesting:** Treat the UI as a physical stack of fine paper. 
    *   **Level 0 (The Floor):** `surface` (#f7f9fb) or `surface-container-low`.
    *   **Level 1 (Primary Content):** `surface-container-lowest` (#ffffff) for primary cards or modules.
    *   **Level 2 (Active Elements):** `primary-container` (#c5e8f8) for highlighted or active states.
*   **The "Glass & Gradient" Rule:** To evoke the feeling of water, floating navigation or top-level modals must use Glassmorphism. Use the `surface` token at 70% opacity with a `24px` backdrop blur. 
*   **Signature Textures:** Use subtle linear gradients for primary CTAs, transitioning from `primary` (#436471) to `primary_dim` (#375765). This adds a "soul" to the component that flat hex codes cannot replicate.

---

### 3. Typography
We use a dual-font system to balance editorial elegance with clinical precision.

*   **Display & Headlines (Manrope):** This font provides the "Quiet Luxury" aesthetic. Use `display-lg` and `headline-md` for high-impact moments—like your daily percentage or a morning greeting. The geometric nature of Manrope feels modern yet grounded.
*   **Body & Labels (Inter):** Inter is utilized for maximum legibility in data-heavy areas. Its neutral character ensures that the functional aspects of the app (milliliters, time stamps, settings) remain invisible until they are needed.
*   **Editorial Spacing:** Headlines should often be "broken" or offset to the left or right to create an asymmetrical, magazine-style layout, rather than being strictly center-aligned.

---

### 4. Elevation & Depth
In this system, depth is a whisper, not a shout. We replace traditional drop shadows with **Tonal Layering**.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` background to create a "Natural Lift." The contrast between #FFFFFF and #f0f4f7 is enough to define the object without visual noise.
*   **Ambient Shadows:** If an element must float (like a FAB or a floating nav), use a shadow that mimics ambient gallery lighting.
    *   *Specs:* `X: 0, Y: 12, Blur: 32, Spread: 0, Color: on-surface (#2c3437) @ 4% opacity`. 
*   **The "Ghost Border" Fallback:** If accessibility requirements demand a border, use the `outline-variant` (#acb3b7) at **15% opacity**. It should be felt, not seen.
*   **Glassmorphism:** Use `surface_bright` with a 20% transparency for overlays to allow the gentle blue tones of the hydration data to bleed through, softening the edges of the UI.

---

### 5. Components

*   **Action Buttons**: 
    *   *Primary:* Pill-shaped (`full` roundedness), using a soft gradient of `primary` to `primary_dim`. High padding (16px top/bottom, 32px sides).
    *   *Secondary:* `secondary_container` (#d7e5ec) with `on_secondary_container` (#46545a) text. No border.
*   **The "Fluid Wave" Progress:** 
    *   Instead of a standard progress bar, use an organic, large-scale shape that fills vertically using the `tertiary_fixed_dim` (#acbbe6) token. It should feel like water filling a vessel.
*   **Interactive Chips:**
    *   Use `surface_container_high` (#e3e9ed) for unselected states and `primary_fixed` (#c5e8f8) for selected states. Apply `md` (0.75rem) roundedness.
*   **Input Fields:**
    *   Never use a box. Use a simple `surface_container_highest` (#dce4e8) background with a `sm` (0.25rem) bottom-only radius to create a "well" for the text.
*   **Cards & Lists:**
    *   **Forbid Dividers.** Use vertical white space (32px - 48px) to separate list items. If items are high-density, use alternating backgrounds of `surface` and `surface_container_low`.

---

### 6. Do’s and Don’ts

**Do:**
*   **Embrace Negative Space:** If a screen feels "empty," you are likely doing it right. Let the content breathe.
*   **Use Asymmetry:** Offset your headlines. Let a card bleed off the edge of the screen slightly if it suggests horizontal scrolling.
*   **Tonal Overlays:** Use `tertiary_container` at very low opacities (5-10%) as a background wash for specific "wellness achievement" screens.

**Don't:**
*   **Don't use pure black:** Use `on_surface` (#2c3437) for all primary text to maintain the soft, low-contrast "Quiet Luxury" vibe.
*   **Don't use 1px lines:** No dividers, no button borders, no input boxes. Use color transitions only.
*   **Don't use "Haptic" Red:** For errors, use the `error` token (#a83836) but keep the container `error_container` (#fa746f) at a low saturation to avoid jarring the user out of their calm state.

---

### 7. Signature Interaction Pattern: The Gentle Bloom
All transitions (button presses, page changes, modals) should use a custom "ease-out" curve with a slightly longer duration (400ms-500ms). Elements should not "pop" into existence; they should "bloom" through a combination of subtle scale-up (98% to 100%) and a soft fade-in. This reinforces the "Digital Wellness" commitment of the system.