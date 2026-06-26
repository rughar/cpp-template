# C++ Project Template

> A lightweight C++ project template focused on simplicity,
> maintainability, scientific software development and clean project
> organization.

> **Status:** Work in progress

## Features

-   Modern CMake
-   Cross-platform (Windows, Linux, macOS)
-   GitHub Actions CI
-   VS Code support
-   Lightweight custom unit test framework
-   Automatic project component generation
-   Minimal external dependencies

------------------------------------------------------------------------

# Philosophy

This template intentionally focuses on **simplicity over features**.

The goal is to provide a template for project that is understandable by a
new developer.

The template is suitable for:

-   scientific software
-   numerical methods
-   simulation software
-   reusable libraries
-   command-line applications

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
└── README.md
```

## libs/

Reusable libraries.

Every library has **exactly one corresponding unit test** project.

## apps/

Executable applications.

Applications typically combine multiple libraries.

## tests/

Unit tests.

The directory layout mirrors `libs/`.

## tools/

Contains project maintenance utilities.

Currently the template provides:

``` text
project.cmake
```

which creates and removes project components automatically.

------------------------------------------------------------------------

# Building

Configure:

``` bash
cmake -S . -B build
```

Build:

``` bash
cmake --build build
```

Run tests:

``` bash
ctest --test-dir build --output-on-failure
```

------------------------------------------------------------------------

# Creating Components

## Library

``` bash
cmake -P tools/project.cmake create lib statistics
```

Creates

``` text
libs/statistics/
tests/statistics/
```

The following are generated automatically:

-   source files
-   headers
-   CMakeLists.txt
-   unit test project

No manual CMake modifications are necessary.

------------------------------------------------------------------------

## Library with Dependencies

``` bash
cmake -P tools/project.cmake create lib solver matrix algebra
```

The generated library links

-   matrix
-   algebra

The generated unit tests automatically link

-   unit_test
-   solver
-   matrix
-   algebra

The generator validates that every dependency already exists.

------------------------------------------------------------------------

## Application

``` bash
cmake -P tools/project.cmake create app simulator solver
```

Applications are **not** automatically accompanied by tests.

------------------------------------------------------------------------

## Remove

``` bash
cmake -P tools/project.cmake remove lib statistics
cmake -P tools/project.cmake remove app simulator
```

Removing a library also removes its associated test project.

------------------------------------------------------------------------

# Unit Testing

The template intentionally ships with a very small custom testing
framework.

Typical usage:

``` cpp
unit_test::Runner runner;

runner.run(testMean, "testMean");
runner.run(testVariance, "testVariance");

runner.printSummary();

return runner.getExitCode();
```

Assertions:

``` cpp
unit_test::require(value == expected);

unit_test::require(
    value == expected,
    "Unexpected value.");
```

Successful tests stay quiet.

Failed tests produce readable diagnostics.

------------------------------------------------------------------------

# Continuous Integration

GitHub Actions automatically builds and tests

-   Windows
-   Linux
-   macOS

Release configuration is used for CI.

------------------------------------------------------------------------

# VS Code

Recommended extensions:

-   C/C++
-   CMake Tools
-   CMake

------------------------------------------------------------------------

# Why no clang-format?

Formatting preferences differ between teams.

This template intentionally avoids enforcing a formatting style.

Only `.editorconfig` is included to enforce universally useful
conventions.

------------------------------------------------------------------------

# Roadmap

Planned improvements:

-   rename component
-   doctor command
-   dependency graph
-   coverage
-   benchmarks
-   documentation generation

------------------------------------------------------------------------

# Contributing

Prefer:

-   readability
-   simplicity
-   minimal dependencies
-   cross-platform compatibility

over additional complexity.
