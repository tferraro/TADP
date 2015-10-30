package model

trait Raza {

  def aumentoKi(cant: Int): Int = {
    cant
  }
}

class Humano extends Raza {
}

class Saiyajin extends Raza {
  override def aumentoKi(cant: Int) = cant
  
}


class Androide extends Raza {
  override def aumentoKi(cant: Int)= 0
  
}


class Namekusein extends Raza {
  
}


class Monstruo extends Raza {
  
}