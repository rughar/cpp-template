#pragma once

#include <stdexcept>

namespace unit_test
{

inline void require(bool condition)
{
  if (!condition)
  {
    throw std::runtime_error("Unit test requirement failed.");
  }
}

}