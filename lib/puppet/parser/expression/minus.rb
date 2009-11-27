require 'puppet'
require 'puppet/parser/expression/branch'

# An object that returns a boolean which is the boolean not
# of the given value.
class Puppet::Parser::Expression
  class Minus < Expression::Branch
    attr_accessor :value

    def each
      yield @value
    end

    def evaluate(scope)
      val = @value.safeevaluate(scope)
      val = Puppet::Parser::Scope.number?(val)
      if val == nil
        raise ArgumentError, "minus operand #{val} is not a number"
      end
      return -val
    end
  end
end