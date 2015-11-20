package model

import model.GuerrerosZ._

// Los traits y clases pueden definirse como elemento de primer nivel (no necesitan estar incluidos dentro de un object)
trait Especie {
  def aumentoDeKi = 100
}

case object Androide extends Especie {
  override def aumentoDeKi = 0
}

case class Saiyan(cola: Boolean = true) extends Especie {
  override def aumentoDeKi = 150
}

case object Namekusein extends Especie
case object Humano extends Especie
case class Monstruo(formaComer: FormaComer) extends Especie
case class Fusion(original: Guerrero) extends Especie

// bien por la jerarquía de formas de comer
trait FormaComer {
  def puedeComerA(enemigo: Guerrero): Boolean = true
  def digerir(user: Guerrero, enemigo: Guerrero): Guerrero
}

case object ComerALaCell extends FormaComer {
  override def puedeComerA(enemigo: Guerrero) = {
    enemigo.especie.equals(Androide)
  }
  def digerir(user: Guerrero, enemigo: Guerrero) = {
    user.agregarMovimiento(enemigo.movimientos)
  }
}

case object ComerALaBuu extends FormaComer {
  def digerir(user: Guerrero, enemigo: Guerrero) = {
    user.copy(movimientos = enemigo.movimientos)
  }
}
