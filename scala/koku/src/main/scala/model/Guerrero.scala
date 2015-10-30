package model


case class Guerrero(val nombre: String, 
                    val raza : Raza, 
                    kiMaximo : Int = 0, 
                    movimientos : List[Movimiento] = Nil, 
                    items : List[Item] = Nil) {
  var ki : Int = kiMaximo
    
  def aprenderMovimiento(movimiento : Movimiento) = copy(movimientos = movimiento::movimientos)
  
  def conseguirItem(item : Item) = copy(items = item::items)

  def aumentarKi(cant: Int) = {
      var guerrero = copy()
      guerrero.ki += raza.aumentoKi(cant)
      guerrero
  }
}
