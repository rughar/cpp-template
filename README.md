# C++ Project Template

A lightweight template for modern C++ projects based on CMake.

The template provides:

-   a predefined project structure,
-   a modern CMake build system,
-   a lightweight unit testing framework,
-   GitHub Actions CI,
-   optional developer tools for project maintenance.

The goal is to provide a clean starting point while keeping the required
tooling minimal.

------------------------------------------------------------------------

## Contents

-   [Project Structure](#project-structure)
-   [Quick Start](#quick-start)
-   [Project Generator](#project-generator)
-   [Unit Testing](#unit-testing)
-   [Continuous Integration](#continuous-integration)
-   [Conventions](#conventions)
-   [FAQ](#faq)

------------------------------------------------------------------------

# Project Structure

``` text
.
├── apps/
├── libs/
├── tests/
├── tools/
├── cmake/
├── .github/
├── CMakeLists.txt
├── .editorconfig
└── README.md
```

  Directory    Purpose
  ------------ ------------------------------
  `apps/`      Executable applications
  `libs/`      Reusable libraries
  `tests/`     Unit tests (mirrors `libs/`)
  `tools/`     Optional developer tools
  `cmake/`     Shared CMake modules
  `.github/`   GitHub Actions workflows

Each library has one corresponding test project:

``` text
libs/statistics
        │
        ▼
tests/statistics
```

------------------------------------------------------------------------

# Quick Start

Configure

``` bash
cmake -S . -B build
```

Build

``` bash
cmake --build build
```

Run tests

``` bash
ctest --test-dir build --output-on-failure
```

------------------------------------------------------------------------

# Project Generator

The template includes an optional developer tool:

``` text
tools/project.cmake
```

The generator automates repetitive maintenance tasks but is **not**
required to configure, build or test the project.

## Command Syntax

``` text
cmake -P tools/project.cmake <action> <type> <name> [dependencies...]
```

## Supported Commands

### `create lib`

Creates a new library together with its corresponding unit test project.

### `create app`

Creates a new application.

### `remove lib`

Removes a library together with its corresponding unit test project.

### `remove app`

Removes an application.

## Create a Library

``` bash
cmake -P tools/project.cmake create lib statistics
```

Creates:

``` text
libs/statistics/
tests/statistics/
```

Generates:

-   source file
-   header
-   `CMakeLists.txt`
-   unit test

Registers both projects automatically.

## Library Dependencies

``` bash
cmake -P tools/project.cmake create lib solver matrix algebra
```

The generated library links against:

-   `matrix`
-   `algebra`

The generated test project links against:

-   `unit_test`
-   `solver`
-   `matrix`
-   `algebra`

All dependency libraries must already exist.

## Create an Application

``` bash
cmake -P tools/project.cmake create app demo solver
```

Applications do not receive automatically generated test projects.

------------------------------------------------------------------------

# Unit Testing

Each library owns one unit test project.

Typical structure:

``` cpp
unit_test::Runner runner;

runner.run(testFoo, "testFoo");
runner.run(testBar, "testBar");

runner.printSummary();

return runner.getExitCode();
```

Assertions:

``` cpp
unit_test::require(condition);
unit_test::require(condition, "Message");
```

------------------------------------------------------------------------

# Continuous Integration

GitHub Actions automatically:

-   configure the project,
-   build the project,
-   execute all tests.

------------------------------------------------------------------------

# Conventions

-   Reusable code belongs in `libs/`.
-   Applications belong in `apps/`.
-   Every library owns one test project.
-   The `tests/` directory mirrors `libs/`.
-   `tools/` contains optional developer utilities, not build
    infrastructure.

------------------------------------------------------------------------

# FAQ

### Why is every library paired with a test project?

To keep the project structure predictable and make missing tests
immediately visible.

### Is `tools/project.cmake` required?

No. It is a convenience utility. Everything it generates can also be
created manually.

### Can I use GoogleTest?

Yes. The included framework is intentionally lightweight and can be
replaced.

### Can I use Conan or vcpkg?

Yes. The template does not depend on any package manager.

### Is a `.clang-format` file included?

No. Formatting is left to the project. The template only provides a
minimal `.editorconfig`.


| Directory | Purpose |
| --------- | ------- |
| `apps/` | Executable applications |
| `libs/` | Reusable libraries |
| `tests/` | Unit tests (mirrors `libs/`) |
| `tools/` | Optional developer tools |
| `cmake/` | Shared CMake modules |
| `.github/` | GitHub Actions workflows |
