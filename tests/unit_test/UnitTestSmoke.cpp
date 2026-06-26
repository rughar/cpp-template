#include "UnitTest.hpp"

#include <stdexcept>

namespace
{

void require(bool condition)
{
  if (!condition)
  {
    throw std::runtime_error("Test requirement failed.");
  }
}

void testRequireAcceptsTrueCondition()
{
  require(true);
}

void testRequireThrowsForFalseCondition()
{
  try
  {
    require(false);
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
  runner.writeCategory("unit_test");

  runner.run(testRequireAcceptsTrueCondition, "testRequireAcceptsTrueCondition");
  runner.run(testRequireThrowsForFalseCondition, "testRequireThrowsForFalseCondition");

  runner.printSummary();
  return runner.getExitCode();
}