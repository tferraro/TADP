require_relative '../src/aspects_getter'

class Aspects

  @converter = Aspects_Getter.new

  def Aspects.on(*objetos, &condicion)
    _validar_argumentos(objetos, condicion)
    @converter.origins = _convertir_a_origenes_validos(objetos)
    metodos = @converter.instance_eval &condicion

    # Para chequear que devuelve
    metodos = metodos.map { |m| m.nil? ? nil : m.symbol } unless metodos.nil?
    "Me pasaste #{_convertir_a_origenes_validos(objetos).join(', ')} y #{metodos}"
  end

  #Internal Methods

  def self._validar_argumentos(objetos, condicion)
    raise ArgumentError, 'wrong number of arguments (0 for +1)' if condicion.nil? || objetos.empty?
  end

  def self._convertir_a_origenes_validos(objetos)
    obj_regex = objetos.select { |o| o.is_a? (Regexp) }
    obj_not_regex = objetos - obj_regex
    origenes_regex = _get_origin_by_multiple_regex(obj_regex)
    raise ArgumentError, 'origen vacio' if obj_not_regex.empty? && origenes_regex.empty?
    obj_not_regex + origenes_regex
  end

  def self._get_class_symbol_by_regex(regex)
    Module.constants.select { |c| regex.match(c) }
  end

  def self._get_origin_by_regex(regex)
    _get_class_symbol_by_regex(regex).map { |symbol| self.const_get(symbol) }
  end

  def self._get_origin_by_multiple_regex(regex)
    regex.map { |r| _get_origin_by_regex(r) }.flatten(1).uniq
  end

  private_class_method :_validar_argumentos
  private_class_method :_convertir_a_origenes_validos
  private_class_method :_get_class_symbol_by_regex
  private_class_method :_get_origin_by_regex
  private_class_method :_get_origin_by_multiple_regex
end