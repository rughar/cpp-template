#pragma once

#include <exception>
#include <iostream>

namespace unit_test
{

using TestFunction = void (*)();

class Runner
{
public:

  void run(TestFunction testFunction, const char* testName)
  {
    this->totalTests++;

    try
    {
      testFunction();
      this->passedTests++;
    }
    catch (const std::exception& error)
    {
      this->failedTests++;

      std::cout << "FAILED: " << testName << '\n';
      printIndented(error.what());
    }
    catch (...)
    {
      this->failedTests++;

      std::cout << "FAILED: " << testName << '\n';
      printIndented("Unknown error");
    }
  }

  void printSummary() const
  {
    if (this->failedTests == 0)
    {
      return;
    }

    std::cout << "Test summary: " << this->passedTests << " passed, "
              << this->failedTests << " failed, out of "
              << this->totalTests << " tests.";
  }

  int getExitCode() const
  {
    return this->failedTests == 0 ? 0 : 1;
  }

private:

  void printIndented(const char* text) const
  {
    std::cout << "    ";

    while (*text != '\0')
    {
      std::cout << *text;
      if (*text == '\n' && *(text + 1) != '\0')
      {
        std::cout << "    ";
      }
      text++;
    }

    std::cout << '\n';
  }

  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;
};

}