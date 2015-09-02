class Aspects
  def on(*objetos, &condicion)
    origenes = validar_argumentos(objetos, condicion)
    "Me pasaste #{origenes.join(', ')} y #{condicion.call}"
  end

  def validar_argumentos(objetos, condicion)
    raise ArgumentError, 'wrong number of arguments (0 for +1)' if condicion.nil?
    raise ArgumentError, 'origen vacio' if objetos.empty?
    convertir_a_origenes_validos(objetos)
  end

  def convertir_a_origenes_validos(objetos)
    regexs = objetos.select { |origen| origen.is_a? Regexp }
    origenes_regex = Module.get_origin_by_multiple_regex(regexs)
    raise ArgumentError, 'origen vacio' if !regexs.empty? && origenes_regex.empty?
    objetos - regexs + origenes_regex
  end

  def origen_exists?(regex)
    Module.constants.any? do |constante|
      !regex.match(constante).nil?
    end
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