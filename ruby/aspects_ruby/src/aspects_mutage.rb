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

  def conoce_metodo?(type= false)
    @owner.conoce?(symbol, type)
  end

  def es_local?
    @owner.sym_all_metodos(false).include? symbol
  end

  def binded_method(owner = @owner)
    Aspect_Origin.create_origin(owner).bind_me_to(@metodo)
  end

  def redefine_method(sym, &behavour)
    @owner.definir_metodo sym, &behavour
  end

  def method_parameters
    @metodo.parameters
  end

  # Transformaciones

  def inject(condition)
    mutagen = self
    injections = binded_method.parameters.map { |_, p| Aspect_Parameter_Injecter.get_injecter(condition[p], self) }
    redefine_method self.symbol do |*param|
      (0..((param.count)-1)).each { |i| injections[i].set_original(param[i])}
      mutagen.binded_method(self).call *(injections.map { |i| i.get_value })
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
      cont = proc { |_, _, *args| mutagen.binded_method(self).call *args }
      instance_exec self, cont, *param, &block
    end
  end

  def after(&block)
    mutagen = self
    redefine_method mutagen.symbol do |*param|
      previous = mutagen.binded_method(self).call *param
      instance_exec self, previous, &block
    end
  end

  def instead_of(&block)
    mutagen = self
    redefine_method mutagen.symbol do |*param|
      instance_exec self, *param, &block
    end
  end
end