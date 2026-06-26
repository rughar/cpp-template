#include "UnitTest.hpp"

#include <stdexcept>

namespace
{

void testRequireAcceptsTrueCondition()
{
  unit_test::require(true);
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

  throw std::runtime_error("unit_test::require(false) did not throw.");
}

}

int main()
{
  testRequireAcceptsTrueCondition();
  testRequireThrowsForFalseCondition();

  return 0;
}