class Aspects

  def Aspects.on(*objetos, &condicion)
    _validar_argumentos(objetos, condicion)
    @origenes = _convertir_a_origenes_validos(objetos)
    metodos = self.instance_eval &condicion
    "Me pasaste #{@origenes.join(', ')} y #{metodos}"
  end

  def self.where(*condiciones)
    condiciones.map { |_, m| m }.intersect_arrays
  end

  def self.name(regex)
    [:name, @origenes
                .map { |o| o.all_methods }
                .flatten_lvl_one_unique
                .select { |s| regex.match(s) }]
  end

  def self.is_private
    [:is_private, _get_methods_by_visibility(:private_methods)]
  end

  def self.is_public
    [:is_public, _get_methods_by_visibility(:public_methods)]
  end

  def self.has_parameters(cant, tipo = /.*/)
    regex = /.*/
    if tipo.is_a? (Regexp)
      regex = tipo
      tipo = nil
    end
    [:has_parameters, @origenes.map { |o| o.get_origin_methods(cant, tipo, regex) }.flatten_lvl_one_unique]
  end

  def self.requerido
    :req
  end

  def self.opcional
    :opt
  end

  def self.neg(dupla_metodos_condicion)
      
  end

  #Internal Methods

  def self._get_methods_call_from(condition_array)
    condition_array
        .get_symbols
        .select { |s| [is_private, is_public].include? s }
        .first
  end

  def self._get_methods_by_visibility(sym_visibilidad)
    @origenes
        .map { |o| o.send(sym_visibilidad.nil? ? :all_methods : sym_visibilidad) }
        .flatten_lvl_one_unique
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

  private_class_method :_validar_argumentos
  private_class_method :_convertir_a_origenes_validos
  private_class_method :_get_methods_call_from
end

class Module

  def all_methods(type = true)
    self.private_methods(type) + self.public_methods(type)
  end

  def _get_class_symbol_by_regex(regex)
    self.constants.select { |c| regex.match(c) }
  end

  def get_origin_by_regex(regex)
    self._get_class_symbol_by_regex(regex).map { |symbol| self.const_get(symbol) }
  end

  def get_origin_by_multiple_regex(regex)
    regex.map { |r| Module.get_origin_by_regex(r) }.flatten_lvl_one_unique
  end

  def get_origin_methods(cant, tipo, regex)
    all_methods.select do |s|
      parametros = method(s).parameters
      unless tipo.nil?
        parametros = parametros.select { |t, _| t == tipo }
      end
      parametros = parametros.select { |_, n| regex.match(n) }
      parametros.map { |t, _| t }.count.equal? cant
    end
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

  def intersect_arrays
    every_element = self.flatten_lvl_one_unique
    self.each { |a| every_element = every_element & a }
    every_element
  end
end