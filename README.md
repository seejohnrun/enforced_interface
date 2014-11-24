# EnforcedInterace

## Introduction

Sometimes people use mixin modules to get interface-like behavior.  While it
works well for type checking, this method doesn't support any way to ensure
the interface is obeyed.

This proof-of-concept gem adds `EnforcedInterface` to cover this case:

``` ruby
# Our interface
module AreaInterface
  def area
  end
end

# Proper Usage
class Square
  def area
    width * height
  end

  include EnforcedInterface[AreaInterface]
end

# Checking
class Person
  include EnforcedInterface[AreaInterface] # EnforcedInterface::NotImplementedError
end

```

The interfaces will match and verify:

* Access (public, private, protected)
* Arity (the number of arguments the method takes)

---

## Disclaimer

This is just a proof-of-concept!  I don't support using this code.
