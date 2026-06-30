#include "utest.hpp"

#include <stdexcept>

namespace
{

void testRequireAcceptsTrueCondition()
{
  utest::require(true, "require(true) should not throw.");
}

void testRequireThrowsForFalseCondition()
{
  try
  {
    utest::require(false);
  }
  catch (const std::runtime_error&)
  {
    return;
  }

  throw std::runtime_error("require(false) did not throw.");
}

}

int main()
{
  utest::Runner runner;

  runner.run(testRequireAcceptsTrueCondition, "testRequireAcceptsTrueCondition");
  runner.run(testRequireThrowsForFalseCondition, "testRequireThrowsForFalseCondition");

  runner.printSummary();
  return runner.getExitCode();
}