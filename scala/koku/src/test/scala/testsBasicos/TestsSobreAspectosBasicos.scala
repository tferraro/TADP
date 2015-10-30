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
    var krillin: Guerrero = new Guerrero("krillin",new Humano(), 30)
    var resultado = new DejarseFajar().usarSobre(koku,krillin)
    assertEquals(30, resultado._1.ki)        
  }
  
  @Test
  def usarCargarKiYVerCambioDeEstado() {
    var koku: Guerrero = new Guerrero("koku",new Saiyajin(), 30)
    var krillin: Guerrero = new Guerrero("krillin",new Humano(), 30)
    var resultado = new CargarKi().usarSobre((koku,krillin))
    assertEquals(130, resultado._1.ki)        
    assertEquals(30, resultado._2.ki)        
  }
  @Test
  def usarCargarKiUnAndroideYVerQueNoHayCambioDeEstado() {
    var androide18: Guerrero = new Guerrero("androide 18",new Androide())
    var krillin: Guerrero = new Guerrero("krillin",new Humano(), 30)
    var resultado = new CargarKi().usarSobre((androide18,krillin))
    assertEquals(0, androide18.ki)        
    assertEquals(androide18.ki, resultado._1.ki)        
    assertEquals(30, resultado._2.ki)        
  }  
  
  
}