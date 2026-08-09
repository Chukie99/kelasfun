# NavigationRail Redesign Design

## Overview
Restyle the NavigationRail in `home_screen.dart` to use theme-aware tokens from `AppTheme`, ensuring proper adaptation for both dark and light themes.

## Requirements
- Use `Theme.of(context).brightness` to select appropriate tokens
- Maintain visual consistency with the new Soft & Calm palette
- No changes to business logic or state management

## Styling Specifications

### Dimensions
- Width: 72px
- Right border: 1px

### Dark Theme Tokens
- Background: `AppTheme.surface`
- Active indicator: `AppTheme.accentSoft` (background)
- Active icon/text: `AppTheme.accent`
- Inactive icon/text: `AppTheme.textSecondary`
- Right border: `AppTheme.divider`

### Light Theme Tokens
- Background: `AppTheme.lightSurface`
- Active indicator: `AppTheme.lightAccentSoft` (background)
- Active icon/text: `AppTheme.lightAccent`
- Inactive icon/text: `AppTheme.lightTextSecondary`
- Right border: `AppTheme.lightDivider`

### Typography
- Font family: Inter
- Size: 11px
- Weight: 500 (medium)

## Implementation Approach
1. Add brightness detection in `build()` method
2. Conditionally select colors based on brightness
3. Apply styling to NavigationRail properties:
   - `backgroundColor`
   - `indicatorColor`
   - `selectedIconTheme`
   - `selectedLabelTextStyle`
   - `unselectedIconTheme`
   - `unselectedLabelTextStyle`
4. Add right border using `VerticalDivider` with theme-aware color

## Files to Modify
- `lib/features/home/home_screen.dart`

## Success Criteria
- NavigationRail adapts to theme changes
- All colors come from AppTheme tokens
- No hardcoded color values
- Visual appearance matches design specs