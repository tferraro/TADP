class Aspects
  def on(*objetos, condicion)
    raise ArgumentError, 'wrong number of arguments (0 for +1)' if objetos.empty?
    "Me pasaste #{objetos.join(', ')} y #{condicion}"
  end
end