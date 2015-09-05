class Aspects
  def Aspects.on(*objetos, &condicion)
    validar_argumentos(objetos, condicion)
    @origenes = convertir_a_origenes_validos(objetos)
    metodos = self.instance_eval &condicion
    "Me pasaste #{@origenes.join(', ')} y #{metodos}"
  end

  def self.validar_argumentos(objetos, condicion)
    raise ArgumentError, 'wrong number of arguments (0 for +1)' if condicion.nil?
    raise ArgumentError, 'origen vacio' if objetos.empty?
  end

  def self.convertir_a_origenes_validos(objetos)
    origenes_regex = Module.get_origin_by_multiple_regex(objetos.get_regexp)
    raise ArgumentError, 'origen vacio' if !objetos.get_regexp.empty? && origenes_regex.empty?
    objetos.get_neg_regexp + origenes_regex
  end


  def self.where(*condiciones)
    metodo = condiciones.get_symbols.select { |s| [is_private, is_public].include? s }.first
    regex_matching = condiciones.select { |s| s.is_a? (Array)}.flatten
    #El primero que llega se lo queda ;)
    todos_los_metodos = @origenes.map { |o| o.send(metodo.nil? ? :methods : metodo) }.flatten_lvl_one_unique
    metodos_filtrados = todos_los_metodos.select {|m| regex_matching.include? m}
    !metodos_filtrados.empty? ? metodos_filtrados : todos_los_metodos
  end

  def self.name(regex)
    Symbol.all_symbols.select { |s| regex.match(s) }
  end

  def self.is_private
    :private_methods
  end

  def self.is_public
    :public_methods
  end

end

class Module
  def _get_class_symbol_by_regex(regex)
    self.constants.select { |c| regex.match(c) }
  end

  def get_origin_by_regex(regex)
    self._get_class_symbol_by_regex(regex).map { |symbol| self.const_get(symbol) }
  end

  def get_origin_by_multiple_regex(regex)
    regex.map { |r| Module.get_origin_by_regex(r) }.flatten_lvl_one_unique
  end
end

class Array
  def get_regexp
    self.select { |o| o.is_a? (Regexp) }
  end

  def get_symbols
    self.select { |o| o.is_a? (Symbol) }
  end

  def get_neg_regexp
    self - get_regexp
  end


  def flatten_lvl_one_unique
    self.flatten(1).uniq
  end
end
