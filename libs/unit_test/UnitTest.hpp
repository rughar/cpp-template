#pragma once

#include <exception>
#include <iostream>

namespace unit_test
{

using TestFunction = void (*)();

namespace color
{
  inline constexpr const char* reset = "\033[0m";
  inline constexpr const char* blue = "\033[34m";
  inline constexpr const char* green = "\033[32m";
  inline constexpr const char* red = "\033[31m";
  inline constexpr const char* yellow = "\033[33m";
}

class Runner
{
public:

  void writeCategory(const char* categoryName) const
  {
    std::cout << color::blue << categoryName << color::reset << '\n';
  }

  void run(TestFunction testFunction, const char* testName)
  {
    this->totalTests++;

    try
    {
      testFunction();

      this->passedTests++;

      std::cout << color::green << "PASSED" << color::reset << ": " << testName << '\n';
    }
    catch (const std::exception& error)
    {
      this->failedTests++;

      std::cout << color::red << "FAILED" << color::reset << ": " << testName << '\n' << error.what() << '\n';
    }
    catch (...)
    {
      this->failedTests++;

      std::cout << color::red << "FAILED" << color::reset << ": " << testName << '\n' << "Unknown error" << '\n';
    }
  }

  void printSummary() const
  {
    std::cout 
      << color::yellow << "Test summary" << color::reset << ": " << this->passedTests << " passed, "
      << this->failedTests << " failed, out of " << this->totalTests << " tests." << '\n';
  }

  int getExitCode() const
  {
    if (this->failedTests > 0)
    {
      return 1;
    }

    return 0;
  }

private:

  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;
};

}