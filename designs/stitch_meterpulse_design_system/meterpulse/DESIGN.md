---
name: MeterPulse
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daea'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eefe'
  surface-container-high: '#e2e8f8'
  surface-container-highest: '#dce2f3'
  on-surface: '#151c27'
  on-surface-variant: '#424754'
  inverse-surface: '#2a313d'
  inverse-on-surface: '#ebf1ff'
  outline: '#727785'
  outline-variant: '#c2c6d6'
  surface-tint: '#005ac2'
  primary: '#0058be'
  on-primary: '#ffffff'
  primary-container: '#2170e4'
  on-primary-container: '#fefcff'
  inverse-primary: '#adc6ff'
  secondary: '#00687a'
  on-secondary: '#ffffff'
  secondary-container: '#57dffe'
  on-secondary-container: '#006172'
  tertiary: '#6b38d4'
  on-tertiary: '#ffffff'
  tertiary-container: '#8455ef'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#acedff'
  secondary-fixed-dim: '#4cd7f6'
  on-secondary-fixed: '#001f26'
  on-secondary-fixed-variant: '#004e5c'
  tertiary-fixed: '#e9ddff'
  tertiary-fixed-dim: '#d0bcff'
  on-tertiary-fixed: '#23005c'
  on-tertiary-fixed-variant: '#5516be'
  background: '#f9f9ff'
  on-background: '#151c27'
  surface-variant: '#dce2f3'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-md:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-sm:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: 0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 34px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 20px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style
The design system for this product is built on a **Corporate / Modern** foundation with a distinct focus on utility and clarity. It targets homeowners and property managers who need to monitor resource consumption with precision and ease. 

The aesthetic is an evolved interpretation of Material 3, characterized by:
- **Clarity over Ornament:** High-contrast layouts that prioritize data readability.
- **Modern Utility:** A balance of soft geometry and professional structure to evoke a sense of reliability and control.
- **Contextual Awareness:** A color-coded logic system that immediately informs the user of their consumption status without requiring deep analysis.
- **Tactile Depth:** Using subtle elevations and generous corner radii to make the interface feel approachable yet organized.

## Colors
The palette is divided into functional zones to support rapid identification of utility types and budget status.

- **Utility Accents:** Used for iconography, specific card headers, and progress bar fills. Each utility has a dedicated hue to ensure the user can distinguish between Electricity and Water at a glance.
- **Status Zones:** These colors are strictly reserved for consumption pacing.
    - **Safe (<= 80%):** Emerald Green, signaling healthy usage.
    - **Warning (80-100%):** Amber, suggesting a need for caution.
    - **Critical (> 100%):** Red, indicating budget overages.
- **Neutrals:** A scale of cool grays provides the structural framework, ensuring that the vibrant semantic colors remain the primary focus of the UI.

## Typography
This design system utilizes **Inter** for all levels of the hierarchy. Its neutral, highly legible glyphs are ideal for data-heavy applications.

- **Headlines:** Use semi-bold weights with tighter letter-spacing for a modern, punchy feel in dashboard summaries.
- **Numbers/Data:** Numerical displays should utilize `tabular-nums` where possible to ensure that fluctuating meter readings do not cause layout shifts.
- **Labels:** Small caps or all-caps with increased letter-spacing are used for category tags and chart axes to differentiate them from body copy.

## Layout & Spacing
The layout follows a **Fluid Grid** model with a distinct 4px baseline rhythm. 

- **Grid:** A 12-column grid is used for desktop, collapsing to 4 columns for mobile. 
- **Gutter Logic:** A generous 20px gutter is maintained between cards to prevent the high-density information from feeling cluttered.
- **Padding:** Consistent 16px or 24px internal padding is applied to containers to maintain the "breathable" feel requested for the core aesthetic.
- **Mobile Reflow:** On mobile devices, cards stack vertically, and horizontal scrolling is utilized specifically for historical charts to preserve data granularity.

## Elevation & Depth
Depth is communicated through **Tonal Layers** supplemented by soft, ambient shadows.

- **Level 0 (Background):** Solid neutral gray at 50 or 100 weight.
- **Level 1 (Cards):** Surface color with a very subtle 2px blur shadow (5% opacity).
- **Level 2 (Floating Action Buttons):** Higher elevation with an 8px blur shadow (10% opacity) to signify primary interaction.
- **Glassmorphism:** Reserved for top navigation bars or modal overlays, using a 12px backdrop blur and 80% opacity fill to maintain context of the underlying dashboard.

## Shapes
The shape language is defined by **Rounded** geometry (8px/16px/24px) to soften the technical nature of the utility data.

- **Standard Elements (Inputs/Buttons):** 0.5rem (8px) for a professional yet modern feel.
- **Containers (Cards):** 1rem (16px) for the primary dashboard cards.
- **Featured Elements (Hero Cards):** 1.5rem (24px) to create a soft, inviting focal point.
- **Pill Shapes:** Used exclusively for status chips and floating action buttons to differentiate them from static containers.

## Components
- **Elevated Cards:** These are the primary unit of the UI. Each card features a 16px corner radius, a subtle 1px border (#E5E7EB), and internal progress bars. The progress bar track should be a 10% opacity version of the status color.
- **Status Chips:** Use a pill-shaped geometry with a 15% opacity background of the semantic color and a 100% opacity text color for maximum readability.
- **Floating Action Buttons (FAB):** Large, circular buttons using the Primary Indigo color to denote the "Add Reading" or "New Meter" actions.
- **Tonal Buttons:** Secondary actions use a light-gray tonal background that shifts to a slightly darker tint on hover, avoiding heavy shadows to keep the UI flat and clean.
- **Input Fields:** Outlined Material 3 style with 8px rounded corners. The label should float to the top border on focus.
- **Charts:**
    - **Bar Graphs:** Use rounded caps on the top of bars.
    - **Line Graphs:** Use a 3px stroke width with a subtle gradient fill underneath the line, transitioning from the status color to transparent.