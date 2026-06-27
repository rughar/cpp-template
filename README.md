# C++ Project Template

A lightweight template for modern C++ projects based on CMake.

The template provides:

- a predefined project structure,
- a modern CMake build system,
- a lightweight unit testing framework,
- GitHub Actions CI,
- optional developer tools for project maintenance.

---

## Contents

- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Project Generator](#project-generator)
- [Unit Testing](#unit-testing)
- [Continuous Integration](#continuous-integration)

---

# Project Structure

```text
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

| Directory | Purpose |
|:----------|:--------|
| `apps/` | Executable applications |
| `libs/` | Reusable libraries |
| `tests/` | Unit tests (mirrors `libs/`) |
| `tools/` | Optional developer tools |
| `cmake/` | Shared CMake modules |
| `.github/` | GitHub Actions workflows |

Each library has one corresponding test project:

```text
libs/sample_library
        │
        ▼
tests/sample_library
```

---

# Quick Start

Configure

```bash
cmake -S . -B build
```

Build

```bash
cmake --build build
```

Run tests

```bash
ctest --test-dir build --output-on-failure
```

---

# Project Generator

The template includes an optional developer tool:

```text
tools/project.cmake
```

The generator is **not** required to configure, build or test the project.

## Command Syntax

```text
cmake -P tools/project.cmake <action> <type> <name> [dependencies...]
```

## Create a Library

```bash
cmake -P tools/project.cmake create lib sample_library
```

Creates:

```text
libs/sample_library/
tests/sample_library/
```

Generates:

- `sample_library.hpp`
- `sample_library.cpp`
- `CMakeLists.txt`
- unit test project

Registers both projects automatically.

## Create an Application

```bash
cmake -P tools/project.cmake create app sample_application
```

Creates an executable application.

## Library Dependencies

Additional library dependencies of an `app` or `lib` can be specified after the component name:

```bash
cmake -P tools/project.cmake create lib my_library sample_library another_sample_library
```

or

```bash
cmake -P tools/project.cmake create lib my_app sample_library another_sample_library
```

All dependency libraries must already exist.

---

## Remove a Library or an Application 

```bash
cmake -P tools/project.cmake remove lib sample_library
```

Removes library `sample_library`.

```bash
cmake -P tools/project.cmake remove app sample_application
```

Removes executable application `sample_application`.

# Unit Testing

Each library owns one unit test project.

```cpp
unit_test::Runner runner;

runner.run(testFoo, "testFoo");

runner.printSummary();

return runner.getExitCode();
```

Assertions:

```cpp
unit_test::require(condition);
unit_test::require(condition, "Message");
```

---

# Continuous Integration

GitHub Actions automatically:

- configure the project,
- build the project,
- execute all tests.
