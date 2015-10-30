package model


case class Guerrero(nombre: String, 
                    raza : Raza, 
                    var kiMaximo : Int = 0, 
                    movimientos : List[Movimiento] = Nil, 
                    items : List[Item] = Nil) {
  var ki : Int = kiMaximo
    
  def aprenderMovimiento(movimiento : Movimiento) = copy(movimientos = movimiento::movimientos)
  
  def conseguirItem(item : Item) = copy(items = item::items)
  
  def actualizarRaza(raza : Raza) = copy(this.nombre, raza)

  def aumentarKi(cant: Int) = {
      var guerrero = copy()
      guerrero.ki += raza.aumentoKi(cant)
      guerrero
  }
}
