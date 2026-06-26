#include "Greeting.hpp"

namespace greeting_example
{

std::string createGreeting(const std::string& name)
{
  return "Hello, " + name + "!";
}

}