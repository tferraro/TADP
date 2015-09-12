class Aspects_Mutagen
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
    (@metodo.is_a? UnboundMethod) ? @metodo.bind(@owner.new) : @metodo
  end

  def rebind_method (new_owner)
    self.binded_method.unbind.bind(new_owner)
  end

  def send_owner(symbol, &behaviour)
    @owner.send _define_metodo, symbol, &behaviour
  end

  # Transformaciones

  def inject(condition)
    mutagen = self
    parameters = binded_method.parameters.map { |_, p| p }
    parameters2 = parameters.map { |p| (condition.has_key? p) ? condition[p] : p }
    #Receptor=owner; Mensaje=s2 ArgAnt = ??
    _redefine_aspect mutagen.binded_method.name.to_s do |*args|
      parameters2 = parameters2.map do |p|
        if p.is_a? Proc
          p.call(mutagen.owner, mutagen.binded_method.name.to_s, args[parameters.index (parameters - parameters2).first])
        else
          p
        end
      end
      mutagen.binded_method.call *(parameters2.map { |sym| (sym.is_a? Symbol) ? args[parameters2.index sym] : sym })
    end
  end

  def redirect_to(new_origin)
    get = (new_origin.is_a? Class) ? :instance_method : :method
    s2 = new_origin.send get, self.symbol
    s2 = s2.bind(new_origin.new) if s2.is_a? UnboundMethod
    _redefine_aspect s2.name.to_s do |*param|
      s2.call *param
    end
  end

  def before(&block)
    mutagen = self
    _redefine_aspect mutagen.binded_method.name.to_s do |*param|
      cont = proc { |_, _, *args| mutagen.rebind_method(self).call *args }
      self.instance_exec self, cont, *param, &block
    end
  end

  def after(&block)
    mutagen = self
    _redefine_aspect mutagen.binded_method.name.to_s do |*param|
      previous = mutagen.rebind_method(self).call *param
      self.instance_exec self, previous, &block
    end
  end

  def instead_of(&block)
    mutagen = self
    _redefine_aspect mutagen.binded_method.name.to_s do |*param|
      self.instance_exec self, *param, &block
    end
  end

  private

  def _define_metodo
    (@owner.is_a? Class) ? :define_method : :define_singleton_method
  end

  def _redefine_aspect(symbol, &behaviour)
    self.send_owner symbol, &behaviour
  end
end