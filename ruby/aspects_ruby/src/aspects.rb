class Aspects
  def Aspects.on(*objetos, &condicion)
    _validar_argumentos(objetos, condicion)
    @origenes = _convertir_a_origenes_validos(objetos)
    metodos = self.instance_eval &condicion
    "Me pasaste #{@origenes.join(', ')} y #{metodos}"
  end

  def self._validar_argumentos(objetos, condicion)
    raise ArgumentError, 'wrong number of arguments (0 for +1)' if condicion.nil?
    raise ArgumentError, 'origen vacio' if objetos.empty?
  end

  def self._convertir_a_origenes_validos(objetos)
    origenes_regex = Module.get_origin_by_multiple_regex(objetos.get_regexp)
    raise ArgumentError, 'origen vacio' if !objetos.get_regexp.empty? && origenes_regex.empty?
    objetos.get_neg_regexp + origenes_regex
  end


  def self.where(*condiciones)
    metodo = condiciones.get_symbols.select { |s| [is_private, is_public].include? s }.first
    regex_matching = condiciones.select { |s| s.is_a? (Array) }.flatten
    #El primero que llega se lo queda ;)
    todos_los_metodos = @origenes.map { |o| o.send(metodo.nil? ? :methods : metodo) }.flatten_lvl_one_unique
    metodos_filtrados = todos_los_metodos.select { |m| regex_matching.include? m }
    metodos_simples = !metodos_filtrados.empty? ? metodos_filtrados : todos_los_metodos

    #Joya.new.method(:holis).parameters.select { |d| d.include?(:req)}.flatten.select {|d| d != :req}.count == 1
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

  def self.has_parameters(cant, tipo = nil)
    [cant, tipo]
  end

  def self.requerido
    :req
  end

  def self.opcional
    :opt
  end

  def self._get_origin_methods_by_parameters(origin, cant, tipo = nil)
    origin.methods.select do |s|
      parametros = origin.method(s).parameters
      parametros = parametros.select { |d| d.include?(tipo) }.flatten.select { |d| d != tipo } unless tipo.nil?
      parametros.count.equal? cant
    end
  end

  private_class_method :_validar_argumentos
  private_class_method :_convertir_a_origenes_validos
  private_class_method :_get_origin_methods_by_parameters
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
