package testsBasicos

import org.junit.Assert.assertEquals
import org.junit.Test
import model.GuerrerosZ._
import model.Movimientos._
import model.Especies._

class TestsSobreRequerimientos {
  
  @Test
  def crearUnGuerreroCualquiera() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 50, 150)
    var androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)

    assertEquals(Saiyan(), koku.especie)
    assertEquals(Androide, androide17.especie)
    assertEquals(50, koku.energia)
    assertEquals(30, androide17.energia)
  }
  
}