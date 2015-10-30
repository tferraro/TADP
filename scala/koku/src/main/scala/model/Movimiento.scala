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

class SuperSaiyan extends Movimiento {
  def usarSobre(guerreros: (Guerrero, Guerrero)): (Guerrero, Guerrero) = guerreros._1.raza match {
    case raza:Saiyajin => {
      var saiyan = guerreros._1
      if(saiyan.ki >= saiyan.kiMaximo) {
        var superSaiyan = saiyan.copy(saiyan.nombre,raza.transfSS(raza))
        superSaiyan.kiMaximo = saiyan.kiMaximo * 5 * raza.transfSS(raza).nivelSS
        return (superSaiyan, guerreros._2)        
      }
      guerreros
    }
    case _ => guerreros
  }
}