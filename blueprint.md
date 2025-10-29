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

## Current Task: Theme Implementation

**Goal:** Implement a theme toggle feature and ensure all screens adhere to the selected theme.

**Plan:**

1.  **Create a `ThemeProvider`:** A `ThemeProvider` class was created to manage the application's theme state.
2.  **Update `main.dart`:** The `main.dart` file was updated to use the `ThemeProvider` and define both a light and dark theme.
3.  **Refactor Screens:** All screen files (`add_budget_screen.dart`, `add_transaction_screen.dart`, `budget_screen.dart`, `edit_transaction_screen.dart`, `home_screen.dart`, `insights_screen.dart`, `main_screen.dart`, `settings_screen.dart`) were refactored to use theme-aware colors instead of hardcoded colors.
4.  **Fix `SettingsScreen`:** The `SettingsScreen` was updated to correctly call the `toggleTheme` function in the `ThemeProvider` to ensure the theme toggle switch works as expected.
