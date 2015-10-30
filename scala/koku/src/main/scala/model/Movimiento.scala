package model

trait Movimiento {
  def usarSobre(guerreros :(Guerrero,Guerrero)) : (Guerrero,Guerrero)
}

class DejarseFajar extends Movimiento {

  def usarSobre(guerreros :(Guerrero,Guerrero)) = {
    guerreros
  }
}

class CargarKi extends Movimiento {

  def usarSobre(guerreros :(Guerrero,Guerrero)) = {
    (guerreros._1.aumentarKi(100), guerreros._2)
  }
}