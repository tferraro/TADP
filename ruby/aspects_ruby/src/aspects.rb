class Aspects
  def on(*objetos, &condicion)
    validar_argumentos(objetos, condicion)
    "Me pasaste #{objetos.join(', ')} y #{condicion.call}"
  end

  def validar_argumentos(objetos, condicion)
    raise ArgumentError, 'wrong number of arguments (0 for +1)' if condicion.nil?
    raise ArgumentError, 'origen vacio' if objetos.empty?
    #objetos.select{ |origen| origen.is_a? Regexp}.matches()
  end

end

class Class
  def descendants
    result = []
    ObjectSpace.each_object(::Class) { |clase| result << clase if clase < self }
    result
  end
end

class Module
  def descendants
    result = []
    ObjectSpace.each_object(::Module) { |clase| result << clase if clase < self }
    result
  end
end

class Object
  def descendants
    result = []
    ObjectSpace.each_object(::Object) { |clase| result << clase if clase < self }
    result
  end
end