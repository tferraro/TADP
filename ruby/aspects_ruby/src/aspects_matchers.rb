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

class Aspect_Parameter_Injecter

  def self.get_injecter(value, mutagen)
    return Aspect_Parameter_Injecter.new if value.nil?
    return Aspect_Parameter_Injecter_Proc.new(value, mutagen) if value.is_a? Proc
    Aspect_Parameter_Injecter_Value.new(value)
  end

  def set_original(value)
    @value = value
  end

  def get_value
    @value
  end

end

class Aspect_Parameter_Injecter_Value < Aspect_Parameter_Injecter

  def initialize(value)
    @value = value
  end

  def set_original(value)

  end
end

class Aspect_Parameter_Injecter_Proc < Aspect_Parameter_Injecter

  def initialize(value, mutagen)
    @value = value
    @mutagen = mutagen
  end

  def set_original(value)
    @previous = value
  end

  def get_value
    @value.call(@mutagen.owner, @mutagen.symbol, @previous)
  end
end
