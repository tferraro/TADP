class Aspect_Converter
  attr_accessor :origins

  # Condiciones

  def where(*condiciones)
    condiciones.intersect_multi_arrays
  end

  def name(regex)
    _get_origins_methods.select { |s| regex.match(s.name) }
  end

  def is_private
    _get_methods_by_visibility([:private_instance_methods, :private_methods])
  end

  def is_public
    _get_methods_by_visibility([:public_instance_methods, :public_methods])
  end

  def has_parameters(cant, tipo = /.*/)
    regex = /.*/
    if tipo.is_a? (Regexp)
      regex = tipo
      tipo = nil
    end
    origins.map { |o| _get_origin_methods(o, cant, tipo, regex) }.flatten_lvl_one_unique
  end

  def requerido
    :req
  end

  def opcional
    :opt
  end

  def neg(metodos_condicion)
    _get_origins_methods - metodos_condicion
  end

  # Transformaciones

  def transform(metodos, &transf)
    self.instance_eval &transf
    metodos
  end

  def inject(condition)
    condition
  end


  #Internal Methods
  private

  def _get_origins_methods
    origins.map { |o| _all_methods(o) }.flatten_lvl_one_unique
  end

  def _get_methods_call_from(condition_array)
    condition_array
        .get_symbols
        .select { |s| [is_private, is_public].include? s }
        .first
  end

  def _get_methods_by_visibility(sym_visibilidad)
    origins
        .map do |o|
      begin
        o.send(sym_visibilidad.first).map { |s| o.instance_method(s) }
      rescue
        o.send(sym_visibilidad.last).map { |s| o.method(s) }
      end
    end
        .flatten_lvl_one_unique
  end

  def _all_methods(origin, type = true)
    (origin.private_instance_methods(type) + origin.public_instance_methods(type)).map { |s| origin.instance_method(s) }
  rescue
    (origin.private_methods(type) + origin.public_methods(type)).map { |s| origin.method(s) }
  end

  def _get_origin_methods(origin, cant, tipo, regex)
    _all_methods(origin).select do |s|
      parametros = s.parameters
      unless tipo.nil?
        parametros = parametros.select { |t, _| t == tipo }
      end
      parametros = parametros.select { |_, n| regex.match(n) }
      parametros.map { |t, _| t }.count.equal? cant
    end
  end

end


# TODO: Sacar todas las definiciones en Module y Object posibles.

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

  def intersect_multi_arrays
    every_element = self.flatten_lvl_one_unique
    self.each { |a| every_element = every_element & a }
    every_element
  end
end