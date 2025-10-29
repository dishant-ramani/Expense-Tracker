# Project Blueprint

## Overview

This document outlines the structure and implementation of the Flutter budget tracking application. It serves as a single source of truth for the project's features, design, and implementation details.

## Implemented Features

### Core Features

*   **Transaction Management:** Add, edit, and delete income and expense transactions.
*   **Budgeting:** Create and manage budgets for different spending categories.
*   **Insights:** Visualize spending habits with a pie chart showing income vs. expenses and category-wise breakdowns.
*   **Settings:** Toggle between light and dark themes.

### App Structure

The application is structured using the Provider package for state management, with a clear separation of concerns between UI, providers, and models.

*   **`main.dart`:** The entry point of the application, responsible for initializing providers and setting up the main theme.
*   **`models/`:** Contains the data models for `Transaction`, `Category`, and `Budget`.
*   **`providers/`:** Contains the `TransactionProvider`, `CategoryProvider`, `BudgetProvider`, and `ThemeProvider` for managing the application's state.
*   **`screens/`:** Contains the UI for each screen of the application:
    *   `add_budget_screen.dart`
    *   `add_transaction_screen.dart`
    *   `budget_screen.dart`
    *   `edit_transaction_screen.dart`
    *   `home_screen.dart`
    *   `insights_screen.dart`
    *   `main_screen.dart`
    *   `settings_screen.dart`

### Design and Theming

*   **Material Design:** The application uses the Material Design library, with a custom theme defined in `main.dart`.
*   **Light and Dark Themes:** The application supports both light and dark themes, with the ability to toggle between them in the settings screen.
*   **Custom Fonts:** The `google_fonts` package is used to apply custom fonts throughout the application.
*   **Theme-Aware Colors:** All hardcoded colors have been replaced with theme-aware colors to ensure consistency across both light and dark themes.
*   **Bottom Navigation Bar:** The bottom navigation bar is now theme-aware and will adapt to the selected theme.

## Current Task: Bottom Navigation Bar Theme

**Goal:** Make the bottom navigation bar adapt to the selected theme.

**Plan:**

1.  **Update `main_screen.dart`:** The `BottomNavyBar` in `main_screen.dart` was updated to use colors from the `ThemeData`.
2.  **Update `main.dart`:** The `ThemeData` in `main.dart` was updated to include a `bottomAppBarTheme` for both the light and dark themes.
3.  **Wrap `BottomNavyBar` in a `Consumer`:** The `BottomNavyBar` in `main_screen.dart` was wrapped in a `Consumer` of the `ThemeProvider` to ensure it rebuilds when the theme changes.
