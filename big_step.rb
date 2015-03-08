module PrityPrint
  def inspect
    "<<#{self}>>"
  end
end

class Number < Struct.new(:value)
  include PrityPrint

  def to_s
    value.to_s
  end

  def evaluate(environment)
    self
  end
end

class Boolean < Struct.new(:value)
  include PrityPrint

  def to_s
    value.to_s
  end

  def evaluate(environment)
    self
  end
end

class Variable < Struct.new(:name)
  include PrityPrint

  def to_s
    name.to_s
  end

  def evaluate(environment)
    environment[name]
  end
end

class Add < Struct.new(:left, :right)
  include PrityPrint

  def to_s
    "#{left} + #{right}"
  end

  def evaluate(environment)
    Number.new(
      left.evaluate(environment).value +
      right.evaluate(environment).value
    )
  end
end

class Multiply < Struct.new(:left, :right)
  include PrityPrint

  def to_s
    "#{left} * #{right}"
  end

  def evaluate(environment)
    Number.new(
      left.evaluate(environment).value *
      right.evaluate(environment).value
    )
  end
end

class LessThan < Struct.new(:left, :right)
  include PrityPrint

  def to_s
    "#{left} < #{right}"
  end

  def evaluate(environment)
    Boolean.new(
      left.evaluate(environment).value <
      right.evaluate(environment).value
    )
  end
end

class Assign < Struct.new(:name, :expression)
  include PrityPrint

  def to_s
    "#{name} = #{expression}"
  end

  def evaluate(environment)
    environment.merge( name => expression.evaluate(environment) )
  end
end

class DoNothing
  include PrityPrint

  def to_s
    'do-nothing'
  end

  def evaluate(environment)
    environment
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  include PrityPrint

  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      consequence.evaluate(environment)
    when Boolean.new(false)
      alternative.evaluate(environment)
    end
  end
end

class Sequence < Struct.new(:first, :second)
  include PrityPrint

  def to_s
    "#{first}; #{second}"
  end

  def evaluate(environment)
    second.evaluate(first.evaluate(environment))
  end
end

class While < Struct.new(:condition, :body)
  include PrityPrint

  def to_s
    "while (#{condition}) { #{body} }"
  end

  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      evaluate(body.evaluate(environment))
    when Boolean.new(false)
      environment
    end
  end
end

p Number.new(23).evaluate({})
p Variable.new(:x).evaluate(x: Number.new(23))
p LessThan.new(
  Add.new(Variable.new(:x), Number.new(2)),
  Variable.new(:y)
).evaluate(x: Number.new(2), y: Number.new(5))

p statement =
  Sequence.new(
    Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
    Assign.new(:y, Add.new(Variable.new(:x), Number.new(3)))
)
p statement.evaluate({})

p statement =
  While.new(
    LessThan.new(Variable.new(:x), Number.new(5)),
    Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
)

p statement.evaluate(x: Number.new(1))
