require_relative '../src/aspects_mutage'

class Aspects_Getter
  attr_accessor :origins

  # Condiciones

  def where(*condiciones)
    _intersect_methods(condiciones)
  end

  def transform(metodos, &transf)
    @source = metodos
    metodos.each { |m| m.instance_eval &transf }
  end

  def name(regex)
    _get_origins_methods.select { |m| m.method_match(regex) }
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
    origins.map { |o| _get_origin_methods(o, cant, tipo, regex) }.flatten(1)
  end

  def mandatory
    :req
  end

  def optional
    :opt
  end

  def neg(metodos_condicion)
    _remove_aspect_methods(_get_origins_methods, metodos_condicion)
  end

  private #Internal Methods

  def _redefine_aspect(aspect, symbol, &behaviour)
    aspect.send_owner symbol, &behaviour
  end

  def _get_origins_methods
    origins.map { |o| _all_methods(o) }.flatten(1)
  end

  def _get_methods_call_from(condition_array)
    condition_array
        .f.select { |o| o.is_a? (Symbol) }
        .select { |s| [is_private, is_public].include? s }
        .first
  end

  def _get_methods_by_visibility(sym_visibilidad)
    origins
        .map do |o|
      begin
        o.send(sym_visibilidad.first).map { |s| Aspects_Mutagen.new o, o.instance_method(s) }
      rescue
        o.send(sym_visibilidad.last).map { |s| Aspects_Mutagen.new o, o.method(s) }
      end
    end
        .flatten(1)
  end

  def _all_methods(origin, type = true)
    (origin.private_instance_methods(type) + origin.public_instance_methods(type)).map { |s| Aspects_Mutagen.new origin, origin.instance_method(s) }
  rescue
    (origin.private_methods(type) + origin.public_methods(type)).map { |s| Aspects_Mutagen.new origin, origin.method(s) }
  end

  def _get_origin_methods(origin, cant, tipo, regex)
    _all_methods(origin).select do |m|
      parametros = m.metodo.parameters
      unless tipo.nil?
        parametros = parametros.select { |t, _| t == tipo }
      end
      parametros = parametros.select { |_, n| regex.match(n) }
      parametros.map { |t, _| t }.count.equal? cant
    end
  end

  def _intersect_methods(aspects_methods)
    resultado = []
    aplastado = aspects_methods.flatten(1) # Aplano todos los method-origin
    aplastado.each do |elem|
      if aspects_methods.all? do |array|
        array.any? do |e2|
          e2.same_atributes? elem
        end
      end
        unless resultado.any? do |r|
          r.same_atributes? elem
        end
          resultado << elem
        end
      end
    end
    resultado
  end

  def _remove_aspect_methods(original, duplicados)
    original.select do |o|
      !duplicados.any? { |d| d.same_atributes? o }
    end
  end
end
