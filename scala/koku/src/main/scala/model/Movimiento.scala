package model

trait Movimiento {
  def sobre(guerrero : Guerrero) : Guerrero
}

class DejarseFajar extends Movimiento {
  def sobre(guerrero: Guerrero): Guerrero = {
    guerrero
  }
}