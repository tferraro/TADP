class Aspects_Mutagen
  attr_accessor :owner, :metodo

  def initialize(owner, method)
    @owner = owner
    @metodo = method
  end

  def method_match(regexp)
    regexp.match(symbol)
  end

  def symbol
    @metodo.name
  end

  def binded_method(owner = @owner)
    owner.bind_me_to(@metodo)
  end

  def redefine_method(sym, &behavour)
    @owner.definir_metodo sym, &behavour
  end

  #Not used yet

  def same_atributes?(another_method_aspect)
    (another_method_aspect.metodo == @metodo) &&
        (another_method_aspect.owner == @owner)
  end

  # Transformaciones

  def inject(condition)
    mutagen = self
    parameters = binded_method.parameters.map { |_, p| p }
    parameters2 = parameters.map { |p| (condition.has_key? p) ? condition[p] : p }
    #Receptor=owner; Mensaje=s2 ArgAnt = ??
    redefine_method mutagen.symbol do |*args|
      parameters2 = parameters2.map do |p|
        if p.is_a? Proc
          p.call(mutagen.owner, mutagen.symbol, args[parameters.index (parameters - parameters2).first])
        else
          p
        end
      end
      mutagen.binded_method.call *(parameters2.map { |sym| (sym.is_a? Symbol) ? args[parameters2.index sym] : sym })
    end
  end

  def redirect_to(new_origin)
    nuevo = Aspect_Origin.create_origin(new_origin)
    nuevo_mutageno = Aspects_Mutagen.new(nuevo, nuevo.meth_obtain(self.symbol))
    redefine_method nuevo_mutageno.symbol do |*param|
      nuevo_mutageno.binded_method.call *param
    end
  end

  def before(&block)
    mutagen = self
    redefine_method mutagen.symbol do |*param|
      cont = proc { |_, _, *args| mutagen.binded_method(Aspect_Origin.create_origin(self)).call *args }
      self.instance_exec self, cont, *param, &block
    end
  end

  def after(&block)
    mutagen = self
    redefine_method mutagen.symbol do |*param|
      previous = mutagen.binded_method(Aspect_Origin.create_origin(self)).call *param
      self.instance_exec self, previous, &block
    end
  end

  def instead_of(&block)
    mutagen = self
    redefine_method mutagen.symbol do |*param|
      self.instance_exec self, *param, &block
    end
  end
end