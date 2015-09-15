require_relative '../src/aspects_mutage'
require_relative '../src/aspects_matchers'

class Aspects_Converter
  attr_accessor :origins

  # Condiciones

  def where(*condiciones)
    origins.map do |origen|
      origen.sym_all_metodos
          .map { |sym| Aspects_Mutagen.new origen, origen.meth_obtain(sym) }
          .select { |mutagen| condiciones.all? { |cond| cond.call mutagen } }
    end.flatten(1)
  end

  def transform(mutagens, &transf)
    mutagens.each { |m| m.instance_eval &transf }
  end

  def name(regex)
    proc { |mutagen| mutagen.method_match(regex) }
  end

  def is_private
    proc { |mutagen| !mutagen.conoce_metodo? and mutagen.conoce_metodo?(true) }
  end

  def is_public
    proc { |mutagen| mutagen.conoce_metodo? }
  end

  def has_parameters(cant, tipo = /.*/)
    proc do |mutagen|
      mutagen.metodo
          .parameters
          .select { |param| Aspect_Parameter_Matcher.get_by(tipo).match(param) }
          .count == cant
    end
  end

  def mandatory
    :req
  end

  def optional
    :opt
  end

  def neg(block)
    proc { |mutagen| !block.call mutagen }
  end

  def local
    proc { |mutagen| mutagen.es_local? }
  end
end
