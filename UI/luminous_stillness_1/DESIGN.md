# Design System: Editorial Serenity

## 1. Overview & Creative North Star: "The Digital Sanctuary"
This design system moves away from the aggressive, high-contrast layouts of standard SaaS platforms, embracing instead the philosophy of **The Digital Sanctuary**. Our North Star is an editorial-inspired experience that prioritizes cognitive ease, breathability, and "Luminous Stillness." 

We break the "template" look through **Tonal Architecture**. By utilizing sophisticated layering and intentional asymmetry, we create a UI that feels curated rather than constructed. Expect high-contrast typography scales where massive data points sit alongside delicate, airy secondary text, creating a rhythmic cadence that guides the eye with quiet authority.

---

## 2. Colors & Surface Philosophy
The palette is rooted in muted cool tones and atmospheric neutrals, designed to reduce ocular strain and convey premium stability.

### The Palette (Material Design Tokens)
*   **Primary (`#426372`):** The grounding force. Used for key actions and authoritative text.
*   **Primary Container (`#A5C7D9`):** Our signature "Luminous" glow. Use this for soft highlights and progress fills.
*   **Background (`#F8FAFB`):** A bright, airy canvas with a hint of coolness to prevent "stark white" fatigue.
*   **Surface Tiers:** 
    *   `surface-container-lowest`: `#FFFFFF` (Floating cards/Active states)
    *   `surface-container-low`: `#F2F4F5` (Subtle sectioning)
    *   `surface-container-high`: `#E6E8E9` (Distinct UI elements)

### The "No-Line" Rule
**Explicit Instruction:** Do not use 1px solid borders for sectioning. Boundaries must be defined solely through background color shifts or subtle tonal transitions. A `surface-container-low` section sitting on a `surface` background is all the definition the user needs.

### Glass & Gradient Soul
To avoid a flat, "out-of-the-box" feel, primary CTAs and Progress Indicators should utilize a linear gradient from `primary` to `primary-container`. For floating overlays, use **Glassmorphism**: semi-transparent `surface` colors with a 12px backdrop-blur to allow the content beneath to "bleed" through, creating an integrated, atmospheric depth.

---

## 3. Typography Hierarchy
We use a dual-font strategy to balance editorial sophistication (Manrope) with functional clarity (Inter).

*   **Data as Art (Display LG/MD):** `manrope`, Bold. Large numbers (e.g., "72%") should be treated as hero elements.
*   **Narrative Headlines (Headline SM/MD):** `manrope`, Medium. Use for section titles to provide a human, editorial touch.
*   **Functional Labels (Label MD/SM):** `inter`, Regular. Used for metadata.
*   **Secondary Text:** Use `on-surface-variant` with `body-sm` to create a "light" feel that recedes visually, allowing data and titles to lead.

---

## 4. Elevation & Depth: The Layering Principle
We reject traditional drop shadows in favor of **Ambient Tonal Layering**.

*   **Nesting:** Depth is achieved by "stacking" tiers. Place a `surface-container-lowest` card on a `surface-container-low` background to create a soft, natural lift.
*   **Ambient Shadows:** If an element must "float" (e.g., a Modal or FAB), use an extra-diffused shadow: `box-shadow: 0 12px 32px rgba(66, 99, 114, 0.06);`. The shadow color is a tinted version of our Primary, mimicking natural light.
*   **The Ghost Border Fallback:** If accessibility requires a stroke, use `outline-variant` at 15% opacity. Never use 100% opaque borders.

---

## 5. Components

### Buttons & Interaction
*   **Primary (Solid):** `primary` background or Gradient. `ROUND_FULL`. Subtle scale-down (0.98) on press.
*   **Secondary (Soft):** `secondary-container` background with `on-secondary-container` text. `ROUND_FULL`.
*   **Tertiary (Text):** No background. `primary` text. Use for low-emphasis actions like "Cancel" or "Learn More."

### Progress Indicators
Our progress bars are "living" elements. Use a gradient fill (`primary` to `primary-container`) with a smooth, rounded stroke edge. Add a `1px` inner glow (white at 20% opacity) on the top edge of the fill to give it a 3D, luminous quality.

### Cards & Lists
*   **Rule:** Forbid divider lines. 
*   **Separation:** Use the Spacing Scale (24px or 32px) or a subtle shift from `surface` to `surface-container-lowest`. 
*   **Radius:** All cards must use `DEFAULT` (0.5rem / 8px).

### Input Fields
*   **Style:** Minimalist. No bottom line or full border. Use a `surface-container-high` background with a `ROUND_EIGHT` radius. On focus, transition the background to `surface-container-lowest` and add a subtle `primary` ghost border (20% opacity).

---

## 6. Micro-interactions: The "500ms Ease"
Movement should feel intentional and liquid, not "snappy."

*   **Timing:** All state transitions must be **500ms ease-out**.
*   **The Ripple:** For logging or submission actions, use a subtle radial ripple in `primary-fixed-dim` to provide tactile feedback.
*   **Scaling:** Buttons and interactive cards should scale down by 2% on `active` states to mimic physical depression.

---

## 7. Do's and Don'ts

### Do:
*   **Embrace Negative Space:** If you think a section needs a border, try adding 16px of extra padding instead.
*   **Use Asymmetry:** Place large display numbers offset to the left of their descriptive headlines to break the "grid" feel.
*   **Color-Tint Shadows:** Always ensure shadows have a hint of the `primary` or `secondary` hue.

### Don't:
*   **Don't use 100% Black:** Even for text, use `on-surface` (`#191C1D`).
*   **Don't use Divider Lines:** Use the `8px/16px/24px/32px` spacing scale to define content blocks.
*   **Don't Snap:** Avoid 100ms or 200ms "instant" transitions; they feel jarring in a sanctuary environment.