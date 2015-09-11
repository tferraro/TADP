require_relative '../src/aspects_method'

class Aspect_Converter
  attr_accessor :origins

  # Condiciones

  def where(*condiciones)
    _intersect_methods(condiciones)
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
    origins.map { |o| _get_origin_methods(o, cant, tipo, regex) }.flatten_lvl_one_unique
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

  # Transformaciones <- Todavia no hace nada D:

  def transform(metodos, &transf)
    @source = metodos
    instance_eval &transf
  end

  def inject(condition)
    @source.each do |m|
      s2 = m.metodo
      s2 = s2.bind(m.owner.new) if s2.is_a? UnboundMethod
      parameters = s2.parameters.map { |_, p| p }
      parameters2 = parameters.map { |p| (condition.has_key? p) ? condition[p] : p }
      #Receptor=owner; Mensaje=s2 ArgAnt = ??
      define_metodo = (m.owner.is_a? Class) ? :define_method : :define_singleton_method
      m.owner.send define_metodo, s2.name.to_s do |*args|
        parameters2 = parameters2.map do |p|
          if p.is_a? Proc
            p.call(m.owner, s2.name.to_s, args[parameters.index (parameters - parameters2).first])
          else
            p
          end
        end
        s2.call *(parameters2.map { |sym| (sym.is_a? Symbol) ? args[parameters2.index sym] : sym })
      end
    end
  end

  def redirect_to(new_origin)
    get = (new_origin.is_a? Class) ? :instance_method : :method
    @source.each do |m|
      define_metodo = (m.owner.is_a? Class) ? :define_method : :define_singleton_method
      s2 = new_origin.send get, m.symbol
      s2 = s2.bind(new_origin.new) if s2.is_a? UnboundMethod
      m.owner.send define_metodo, s2.name.to_s do
      |*param|
        s2.call *param
      end
    end
  end

  def before(&block)
    # TODO: Duplicated code....BLAH, ESTO ES BASURA
    @source.each do |m|
      define_metodo = (m.owner.is_a? Class) ? :define_method : :define_singleton_method
      s2 = m.metodo
      s2 = s2.bind(m.owner.new) if s2.is_a? UnboundMethod
      m.owner.send define_metodo, s2.name.to_s do
      |*param|
        s2 = s2.unbind.bind(self)
        cont = proc { |_, _, *args| s2.call *args }
        self.instance_exec self, cont, *param, &block
      end
    end
  end

  def after(&block)
    # TODO: Duplicated code....BLAH, ESTO ES BASURA
    @source.each do |m|
      define_metodo = (m.owner.is_a? Class) ? :define_method : :define_singleton_method
      s2 = m.metodo
      s2 = s2.bind(m.owner.new) if s2.is_a? UnboundMethod
      m.owner.send define_metodo, s2.name.to_s do
      |*param|
        previous = s2.unbind.bind(self).call *param
        self.instance_exec self, previous, &block
      end
    end
  end

  def instead_of(&block)
    # TODO: Duplicated code....BLAH, ESTO ES BASURA
    @source.each do |m|
      define_metodo = (m.owner.is_a? Class) ? :define_method : :define_singleton_method
      s2 = m.metodo
      s2 = s2.bind(m.owner.new) if s2.is_a? UnboundMethod
      m.owner.send define_metodo, s2.name.to_s do
      |*param|
        s2 = s2.unbind.bind(self)
        self.instance_exec self, *param, &block
      end
    end
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
        o.send(sym_visibilidad.first).map { |s| Method_Aspect.new o, o.instance_method(s) }
      rescue
        o.send(sym_visibilidad.last).map { |s| Method_Aspect.new o, o.method(s) }
      end
    end
        .flatten_lvl_one_unique
  end

  def _all_methods(origin, type = true)
    (origin.private_instance_methods(type) + origin.public_instance_methods(type)).map { |s| Method_Aspect.new origin, origin.instance_method(s) }
  rescue
    (origin.private_methods(type) + origin.public_methods(type)).map { |s| Method_Aspect.new origin, origin.method(s) }
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
          e2.is_same? elem
        end
      end
        unless resultado.any? do |r|
          r.is_same? elem
        end
          resultado << elem
        end
      end
    end
    resultado
  end

  def _remove_aspect_methods(original, duplicados)
    original.select do |o|
      !duplicados.any? {|d| d.is_same? o}
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
