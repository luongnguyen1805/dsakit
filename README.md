
# DSA Kit

A small Swift-base macOS utility app that generates **pre-configured local workspaces** for practicing **Data Structures & Algorithms (DSA)**.

The app automates repetitive setup (boilerplate, inputs, templates) and opens a ready-to-run challenge directly in **VS Code**, allowing you to focus on solving problems rather than preparing environments.

---

## Overview

Practicing DSA often involves:

* Copying problem descriptions
* Rewriting the same input/output scaffolding
* Switching constantly between browser and editor

This app removes that friction by generating a **standardized, local-first challenge workspace** for each problem, designed specifically for **home training and interview preparation**.

---

## Requirements

* **macOS 13+**
* **Xcode 15+**
* **Visual Studio Code**
* **Gemini API Key**

  * Used for problem parsing, classification, and workspace generation
  * Provided by the user and stored locally

---

## Features

* Generate a **self-contained DSA challenge workspace**
* Automatically prepares:

  * Problem ID, title, and source
  * Parsed problem description and constraints
  * Starter code templates
  * Default input/output test cases
* Detects problem category (array, string, graph, DP, tree, etc.)
* Opens the generated workspace directly in **VS Code**
* Designed for **offline-first**, local development

---

## Workspace Location

This is an **unsandboxed macOS app**.

All generated challenges are saved to:

```text
~/Documents/{problem}/
```

Each problem gets its own folder, making it easy to:

* Revisit past solutions
* Organize practice history
* Use version control if desired

> Because the app is unsandboxed, it has direct access to the Documents directory without file picker prompts.

---

## Supported Problem Sources

* LeetCode
* Codeforces
* HackerRank
  *(Designed to be extensible)*

---

## Build from Source (Xcode)

### Prerequisites

* Xcode installed
* VS Code installed
* Gemini API key ready

### Steps

1. Clone the repository:

   ```bash
   git clone <repository-url>
   ```
2. Open the project in Xcode:

   ```text
   Open the .xcodeproj (or .xcworkspace)
   ```
3. Select the **macOS** target
4. Build & Run:

   ```text
   ⌘R
   ```

---

## Gemini API Key Setup

* The Gemini API key is required for problem understanding and workspace generation
* The key is provided by the user
* Configuration happens on first launch or via app settings
* No user source code is uploaded beyond Gemini API requests

---

## Intended Use

* Daily DSA practice
* Interview preparation
* Offline training
* Building a personal archive of solved problems

