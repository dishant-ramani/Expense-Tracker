# Project Blueprint

## Overview

This document outlines the architecture, features, and design of the personal finance management application. The app allows users to track their income and expenses, manage categories, set budgets, and view their financial activity.

## Style and Design

- **Theme:** The app uses a modern, clean design with support for both light and dark modes. The theme is based on Material Design 3, with a color scheme generated from a seed color.
- **Typography:** The app uses the Google Fonts package to provide a consistent and readable typography.
- **Animations:** The app incorporates animations to enhance the user experience, such as staggered list animations for the transaction list.

## Features

### Financial Summary

- **Income, Expenses, and Balance:** The home screen displays a summary of the user's total income, expenses, and the remaining balance, providing a quick overview of their financial situation.

### Transaction Management

- **Add, Edit, and Delete Transactions:** Users can add new transactions and edit or delete existing ones directly from the transaction list on the home screen. Each transaction includes an amount, category, date, and an optional note.
- **Search Transactions:** Users can search for transactions by keyword in the transaction note or category.

### Category Management

- **Separate Categories for Income and Expense:** The application now enforces separate category lists for income and expense transactions. When adding or editing a transaction, the category dropdown menu dynamically updates to show only the relevant categories based on the selected transaction type (income or expense).

### Budget Management

- **Set and Track Budgets:** Users can set monthly budgets for different categories.
- **Add Budget Screen:** The "Add Budget" screen now includes fields for selecting the amount, category, type (income or expense), and period (daily, weekly, or monthly).
- **Budget List Screen:** This screen displays a list of all budgets, allowing users to view, edit, and delete them.
- **Edit Budget Screen:** This screen allows users to edit an existing budget.

### Settings

- **Settings Screen:** This screen provides app-related settings.
- **Theme Toggle:** Users can switch between light and dark mode.

## Architecture

### Navigation

- **Main Screen:** The app uses a `MainScreen` that contains a `BottomNavigationBar` and a `PageView` to switch between the main screens (Home and Budgets), and a `MainDrawer` for navigation.
- **Main Drawer:** A `MainDrawer` provides navigation to Home and Budgets.

### State Management

- **Provider:** The app uses the `provider` package for state management, with individual providers for transactions, categories, and budgets.

### Services

- **DatabaseService:** This service is responsible for initializing the Hive database.
- **TransactionService:** This service encapsulates all database operations for transactions, separating the database logic from the UI and state management layers.
- **BudgetService:** This service encapsulates all database operations for budgets, separating the database logic from the UI and state management layers.
- **CategoryService:** This service encapsulates all database operations for categories, separating the database logic from the UI and state management layers.

### Data Persistence

- **Hive:** The app uses the `hive` package for local data storage, ensuring that all data is saved on the device.
- **shared_preferences:** The app uses the `shared_preferences` package to save and retrieve the user's theme preference.

## Final Touches

- **Code Formatting:** The entire codebase has been formatted using `dart format .` to ensure consistency and readability.
