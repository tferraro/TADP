package testsBasicos

import org.junit.Assert.assertEquals
import org.junit.Test
import model.GuerrerosZ._
import model.Movimientos._
import model.Especies._

class TestsSobreRequerimientos {
  
  @Test
  def proofOfConceptMejorMovimiento() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150)
    var n18: Guerrero = Guerrero("n18", Androide, 30, 150)
    assertEquals(DEAD, koku.usarMovimiento(Onda(15))(n18)._2.estado)
    assertEquals(10, koku.usarMovimiento(Onda(10))(n18)._2.energia)
  }
  
}