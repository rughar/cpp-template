#include "UnitTest.hpp"

#include <stdexcept>

namespace
{

void testRequireAcceptsTrueCondition()
{
  unit_test::require(true, "require(true) should not throw.");
}

void testRequireThrowsForFalseCondition()
{
  try
  {
    unit_test::require(false);
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
  unit_test::Runner runner;

  runner.run(testRequireAcceptsTrueCondition, "testRequireAcceptsTrueCondition");
  runner.run(testRequireThrowsForFalseCondition, "testRequireThrowsForFalseCondition");

  runner.printSummary();
  return runner.getExitCode();
}