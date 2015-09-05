class Aspects
  def Aspects.on(*objetos, &condicion)
    origenes = validar_argumentos(objetos, condicion)
    condicion.call origenes
    # Para chequear con los tests
    "Me pasaste #{origenes.join(', ')} y #{condicion.call origenes}"
  end

  def self.validar_argumentos(objetos, condicion)
    raise ArgumentError, 'wrong number of arguments (0 for +1)' if condicion.nil?
    raise ArgumentError, 'origen vacio' if objetos.empty?
    convertir_a_origenes_validos(objetos)
  end

  def self.convertir_a_origenes_validos(objetos)
    origenes_regex = Module.get_origin_by_multiple_regex(objetos.get_regexp)
    raise ArgumentError, 'origen vacio' if !objetos.get_regexp.empty? && origenes_regex.empty?
    objetos.remove_regexp + origenes_regex
  end
end

class Module
  def _get_symbol_by_regex(regex)
    self.constants.select { |c| regex.match(c) }
  end

  def get_origin_by_regex(regex)
    self._get_symbol_by_regex(regex).map { |symbol| self.const_get(symbol) }
  end

  def get_origin_by_multiple_regex(regex)
    regex.map { |r| Module.get_origin_by_regex(r) }.flatten_lvl_one_unique
  end
end

class Object
  def where(*condiciones)
    # TODO: Cambiar a chequeo de condiciones
    metodo = condiciones.get_symbols.first #El primero que llega se lo queda ;)
    #Por ahora la ultima condicion es nuestra lista de origenes
    todos_los_metodos = condiciones.last.map { |c| c.send(metodo.nil? ? :methods : metodo) }.flatten_lvl_one_unique
    metodos_filtrados = condiciones.get_regexp.map { |r| todos_los_metodos.select { |m| r.match(m) } }.flatten_lvl_one_unique
    !metodos_filtrados.empty? ? metodos_filtrados : todos_los_metodos
  end

  def name(regex)
    regex
  end

  def is_private
    :private_methods
  end

  def is_public
    :public_methods
  end

end

class Array
  def get_regexp
    self.select { |o| o.is_a? (Regexp) }
  end

  def get_symbols
    self.select { |o| o.is_a? (Symbol) }
  end

  def remove_regexp
    self - get_regexp
  end

  def flatten_lvl_one_unique
    self.flatten(1).uniq
  end
end


class Aspects

  #Prueba de define_method, no tiene importancia
  [Class, Module, Object].each do |origen|
    define_method("#{origen}_exists?".downcase) do |nombre|
      begin
        Module.const_get(nombre).is_a?(origen)
      rescue NameError
        false
      end
    end
  end
end