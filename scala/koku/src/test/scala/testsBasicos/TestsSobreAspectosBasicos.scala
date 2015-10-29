package testsBasicos

import org.junit.Assert.assertEquals
import org.junit.Test
import model._

class TestsSobreAspectosBasicos {

  @Test
  def crearUnGuerreroCualquiera() {
    val dejateFajar = new DejarseFajar()
    var koku = new Guerrero("koku", null, 30)
    koku = koku.aprenderMovimiento(dejateFajar)

    assertEquals(30, koku.kiMaximo)
    assertEquals(dejateFajar, koku.movimientos.head)
  }

  @Test
  def crearUnGuerreroCualquieraYChequearItems() {
    val semillaDelHermitanio = new Item()
    var koku = new Guerrero("koku", null, 30)
    koku = koku.conseguirItem(semillaDelHermitanio)

    assertEquals(30, koku.kiMaximo)
    assertEquals(semillaDelHermitanio, koku.items.head)
  }

  @Test
  def crearUnGuerreroDeUnaEspecie() {
    var koku: Guerrero = new Guerrero("koku",new Saiyajin(), 30)

    assertEquals(30, koku.kiMaximo)
    assertEquals(new Saiyajin().getClass, koku.raza.getClass)
  }
  
  @Test
  def usarDejarseFajarYVerQueNoHayCambios() {
    var koku: Guerrero = new Guerrero("koku",new Saiyajin(), 30)
    var kokuSinCambios = new DejarseFajar().sobre(koku)
    assertEquals(30, koku.ki)        
  }
  
}