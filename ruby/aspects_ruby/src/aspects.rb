class Aspects
  def on(*objetos, &condicion)
    raise ArgumentError, 'wrong number of arguments (0 for +1)' if condicion.nil?
    "Me pasaste #{objetos.join(', ')} y #{condicion.call}"
  end
end