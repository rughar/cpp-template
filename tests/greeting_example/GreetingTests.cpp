#include "Greeting.hpp"
#include "UnitTest.hpp"

#include <stdexcept>
#include <string>

namespace
{

void testCreateGreeting()
{
  unit_test::require(greeting_example::createGreeting("World") == "Hello, World!", "Greeting has unexpected format.");
}

}

int main()
{
  unit_test::Runner runner;

  runner.run(testCreateGreeting, "testCreateGreeting");

  runner.printSummary();
  return runner.getExitCode();
}