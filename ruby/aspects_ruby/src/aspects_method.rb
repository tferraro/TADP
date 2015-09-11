class Method_Aspect
  attr_reader :owner, :metodo

  def initialize(owner, method)
    @owner = owner
    @metodo = method
  end

  def method_match(regexp)
    regexp.match(@metodo.name)
  end

  def symbol
    @metodo.name
  end

  def is_same?(another_method_aspect)
    (another_method_aspect.metodo == @metodo) &&
    (another_method_aspect.owner. == @owner)
  end
end