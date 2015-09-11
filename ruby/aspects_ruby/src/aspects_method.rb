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

  def same_atributes?(another_method_aspect)
    (another_method_aspect.metodo == @metodo) &&
    (another_method_aspect.owner == @owner)
  end

  def binded_method
     (@metodo.is_a? UnboundMethod)? @metodo.bind(@owner.new) : @metodo
  end

  def rebind_method (new_owner)
    self.binded_method.unbind.bind(new_owner)
  end

  def send_owner(symbol, &behaviour)
    @owner.send define_metodo, symbol, &behaviour
  end

  private
  def define_metodo
    (@owner.is_a? Class) ? :define_method : :define_singleton_method
  end
end