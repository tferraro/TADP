class Aspect_Parameter_Matcher

  attr_accessor :type

  def initialize(type)
    @type = type
  end

  def self.get_by(tipo)
    return Aspect_Parameter_Matcher_Regex.new(tipo) if tipo.is_a? Regexp
    Aspect_Parameter_Matcher_Type.new(tipo)
  end
end

class Aspect_Parameter_Matcher_Type < Aspect_Parameter_Matcher

  def match(param)
    type == param.first
  end
end

class Aspect_Parameter_Matcher_Regex < Aspect_Parameter_Matcher

  def match(param)
    type.match(param.last)
  end
end
