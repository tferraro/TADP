class Aspects_Origin_Converter

  def self.create_origins(sources)
    sources.map { |s| convert_base(s) }.inject([]) { |x, y| x + y }.uniq
  end

  def self.convert_base(base)
    return [base] unless base.is_a? Regexp
    Module.constants.select { |c| base.match(c) }.map { |symbol| self.const_get(symbol) }
  end
end

class Aspect_Origin
  attr_accessor :base

  def initialize(base)
    @base = base
  end

  def self.create_origin(source)
    return Aspect_Origin_Instance.new(source) unless source.is_a? Module
    Aspect_Origin_Class.new(source)
  end

  def sym_all_metodos(type= true)
    sym_privados(type) + sym_publicos(type)
  end

  def sym_privados(type= true)
    @base.send sym_private, type
  end

  def sym_publicos(type= true)
    @base.send sym_public, type
  end

  def meth_all_metodos(type= true)
    meth_privados(type) + meth_publicos(type)
  end

  def meth_publicos(type= true)
    __methods_obtain__(sym_publicos(type))
  end

  def meth_privados(type= true)
    __methods_obtain__(sym_privados(type))
  end

  def definir_metodo(sym, &behaviour)
    @base.send sym_definir, sym, &behaviour
  end

  def meth_obtain(sym)
    method_check __get_meth__ sym
  end

  def __get_meth__(sym)
    @base.send sym_method, sym
  end

  def __methods_obtain__(collection)
    collection.map { |sym| meth_obtain sym }
  end

  def bind_me_to(method)
    method.bind(bind_instancia)
  end

end

class Aspect_Origin_Class < Aspect_Origin

  def method_check(method)
    method
  end

  def sym_method
    :instance_method
  end

  def sym_definir
    :define_method
  end

  def sym_public
    :public_instance_methods
  end

  def sym_private
    :private_instance_methods
  end

  def conoce?(sym, visibility= false)
    @base.new.respond_to? sym, visibility
  end

  def bind_instancia
    @base.new
  end
end

class Aspect_Origin_Instance < Aspect_Origin

  def method_check(method)
    method.unbind
  end

  def sym_method
    :method
  end

  def sym_definir
    :define_singleton_method
  end

  def sym_public
    :public_methods
  end

  def sym_private
    :private_methods
  end

  def conoce?(sym, visibility= false)
    @base.respond_to? sym, visibility
  end

  def bind_instancia
    @base
  end
end


class Aspect_Parameter_Matcher

  attr_accessor :type

  def initialize(type)
    @type = type
  end

  def self.get_by(tipo)
    return Aspect_Parameter_Matcher_Regex.new(tipo) if tipo.is_a? Regexp
    Aspect_Parameter_Matcher_Type.new(tipo)
  end
end

class Aspect_Parameter_Matcher_Type < Aspect_Parameter_Matcher

  def match(param)
    type == param.first
  end
end

class Aspect_Parameter_Matcher_Regex < Aspect_Parameter_Matcher

  def match(param)
    type.match(param.last)
  end
end

# TODO: Ir reemplazando los siguientes Refactors

class Aspects_Mutagen
  attr_reader :owner, :metodo

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

  def binded_method
    @owner.bind_me_to(@metodo)
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
  end

  def redirect_to(new_origin)
    nuevo = Aspect_Origin.create_origin(new_origin)
    nuevo_mutageno = Aspects_Mutagen.new(nuevo, nuevo.meth_obtain(self.symbol))
    redefine_method nuevo_mutageno.symbol do |*param|
      nuevo_mutageno.binded_method.call *param
    end
  end

  def before(&block)
  end

  def after(&block)
  end

  def instead_of(&block)
  end
end


class Aspects_Getter
  attr_accessor :origins

  # Condiciones

  def where(*condiciones)
    origins.map do |origen|
      origen.meth_all_metodos
          .map { |metodo| Aspects_Mutagen.new origen, metodo }
          .select { |mutagen| condiciones.all? { |cond| cond.call mutagen } }
    end.flatten(1)
  end

  def transform(mutagens, &transf)
    mutagens.each { |m| m.instance_eval &transf }
  end

  def name(regex)
    proc { |mutagen| mutagen.method_match(regex) }
  end

  def is_private
    proc { |mutagen| !mutagen.owner.conoce?(mutagen.symbol) and mutagen.owner.conoce?(mutagen.symbol, true) }
  end

  def is_public
    proc { |mutagen| mutagen.owner.conoce? mutagen.symbol }
  end

  def has_parameters(cant, tipo = /.*/)
    proc do |mutagen|
      mutagen.metodo
          .parameters
          .select { |param| Aspect_Parameter_Matcher.get_by(tipo).match(param) }
          .count == cant
    end
  end

  def mandatory
    :req
  end

  def optional
    :opt
  end

  def neg(block)
    proc { |mutagen| !block.call mutagen }
  end
end

class Aspects

  @converter = Aspects_Getter.new

  def Aspects.on(*objetos, &condicion)
    _validar_argumentos(objetos, condicion)
    @converter.origins = _convertir_a_origenes_validos(objetos)
    @converter.instance_eval &condicion
  end

  #Internal Methods

  def self._validar_argumentos(objetos, condicion)
    raise ArgumentError, 'wrong number of arguments (0 for +1)' if condicion.nil? || objetos.empty?
  end

  def self._convertir_a_origenes_validos(objetos)
    origins = Aspects_Origin_Converter
                  .create_origins(objetos)
                  .map { |s| Aspect_Origin.create_origin(s) }
    raise ArgumentError, 'origen vacio' if origins.empty?
    origins
  end

  private_class_method :_validar_argumentos
  private_class_method :_convertir_a_origenes_validos
end

