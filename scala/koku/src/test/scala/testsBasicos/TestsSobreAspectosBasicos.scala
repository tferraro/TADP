package testsBasicos

import org.junit.Assert.assertEquals
import org.junit.Test
import model.Guerrero
import model.Movimiento
import model.Item

class TestsSobreAspectosBasicos {
  
  @Test
  def crearUnGuerreroCualquiera() {
    val kaioken = new Movimiento()
    var koku = new Guerrero("koku", 30)
    koku = koku.aprenderMovimiento(kaioken)
    
    assertEquals(30, koku.ki)
    assertEquals(30, koku.kiMaximo)
    assertEquals(kaioken, koku.movimientos.head)
  }
  
  @Test  
  def crearUnGuerreroCualquieraYChequearItems() {
    val semillaDelHermitanio = new Item()
    var koku = new Guerrero("koku", 30)
    koku = koku.conseguirItem(semillaDelHermitanio)
    
    assertEquals(30, koku.ki)
    assertEquals(30, koku.kiMaximo)
    assertEquals(semillaDelHermitanio, koku.items.head)
  }
}