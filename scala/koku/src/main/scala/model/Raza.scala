package model

trait Raza {

  def aumentoKi(cant: Int): Int = {
    cant
  }
}

case class Humano() extends Raza {
}

case class Saiyajin(var nivelSS:Int = 0) extends Raza {   
  override def aumentoKi(cant: Int) = cant

  def transfSS(raza: Saiyajin) = copy(raza.nivelSS +1)
}


case class Androide() extends Raza {
  override def aumentoKi(cant: Int)= 0
  
}


case class Namekusein() extends Raza {
  
}


case class Monstruo() extends Raza {
  
}