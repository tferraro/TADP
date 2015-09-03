class Aspects
  def Aspects.on(*objetos, &condicion)
    origenes = validar_argumentos(objetos, condicion)
    condicion.call origenes
    condicion.inspect
    # Para chequear con los tests
    "Me pasaste #{origenes.join(', ')} y #{condicion.call origenes}"
  end

  def self.validar_argumentos(objetos, condicion)
    raise ArgumentError, 'wrong number of arguments (0 for +1)' if condicion.nil?
    raise ArgumentError, 'origen vacio' if objetos.empty?
    convertir_a_origenes_validos(objetos)
  end

  def self.convertir_a_origenes_validos(objetos)
    regexs = objetos.select { |origen| origen.is_a? Regexp }
    origenes_regex = Module.get_origin_by_multiple_regex(regexs)
    raise ArgumentError, 'origen vacio' if !regexs.empty? && origenes_regex.empty?
    objetos - regexs + origenes_regex
  end

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

class Module
  def _get_symbol_by_regex(regex)
    self.constants.select { |c| regex.match(c) }
  end

  def get_origin_by_regex(regex)
    self._get_symbol_by_regex(regex).map { |symbol| self.const_get(symbol) }
  end

  def get_origin_by_multiple_regex(regex)
    regex.map { |r| Module.get_origin_by_regex(r) }.flatten(1).uniq
  end

end

# TODO: Cambiar a chequeo de condiciones
class Object
  def where(*condiciones)
    regex_nombres = condiciones.select { |c| c.is_a?(Regexp) }
    metodo = condiciones.select { |c| c.is_a?(Symbol) }.first
    todos_los_metodos = condiciones.last.last.methods
    todos_los_metodos.select { |m| regex_nombres.first.match(m) }
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