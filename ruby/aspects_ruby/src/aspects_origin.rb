require_relative '../src/aspects_mutage'

class Aspects_Origin_Converter

  def self.convert_to_origins(sources)
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