#include "Greeting.hpp"
#include "UnitTest.hpp"

#include <stdexcept>
#include <string>

namespace
{

void require(bool condition)
{
  if (!condition)
  {
    throw std::runtime_error("Test requirement failed.");
  }
}

void testCreateGreeting()
{
  const std::string greeting =
    greeting_example::createGreeting("World");

  require(greeting == "Hello, World!");
}

}

int main()
{
  unit_test::Runner runner;

  runner.run(testCreateGreeting,"testCreateGreeting");
  
  runner.printSummary();
  return runner.getExitCode();
}