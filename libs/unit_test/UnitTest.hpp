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
    try
    {
      testFunction();
      this->passedTests++;
    }
    catch (const std::exception& error)
    {
      this->failedTests++;
      std::cerr << "[FAIL] " << testName << ": " << error.what() << '\n'
    }
    catch (...)
    {
      this->failedTests++;
      std::cerr << "[FAIL] " << testName << ": unknown error" << '\n';
    }
  }

  void printSummary() const
  {
    std::cout << "Passed: " << this->passedTests << '\n';
    std::cout << "Failed: " << this->failedTests << '\n';
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

  int passedTests = 0;
  int failedTests = 0;
};

}