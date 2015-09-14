require_relative '../src/aspects_getter'
require_relative '../src/aspects_origin'
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
