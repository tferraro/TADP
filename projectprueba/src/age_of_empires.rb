module Atacante

  attr_accessor :poder_ofensivo

  def atacar(un_defensor)
    un_defensor.sufri_danio(self.poder_ofensivo)
  end
end

module Defensor

  attr_accessor :poder_defensivo
  attr_accessor :energia

  def sufri_danio(poder_ofensivo)
    if (poder_ofensivo >= self.poder_defensivo)
      self.energia -= poder_ofensivo - self.poder_defensivo
    end
  end

end


class Guerrero
  include Atacante
  include Defensor

  def initialize(un_poder_ofensivo, un_poder_defensivo)
    self.energia = 1000
    self.poder_defensivo = un_poder_defensivo
    self.poder_ofensivo = un_poder_ofensivo
  end
end

class Misil
  include Atacante

  def initialize
    self.poder_ofensivo = 600
  end

end

class Muralla
  include Defensor

  def initialize
    self.poder_defensivo = 800
    self.energia = 1000
  end

end

class Espadachin < Guerrero

  attr_accessor :espada

  def atacar(otro_guerrero)
    otro_guerrero.sufri_danio(self.poder_ofensivo + espada.danio)
  end
end

class Espada

  attr_accessor :danio

  def initialize(danio)
    self.danio = danio
  end
end

