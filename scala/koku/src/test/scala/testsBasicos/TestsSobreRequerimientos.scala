package testsBasicos

import org.junit.Assert.assertEquals
import org.junit.Test
import model.GuerrerosZ._
import model.Movimientos._
import model.Especies._

class TestsSobreRequerimientos {
  
  @Test
  def proofOfConceptMejorMovimiento() {
    val ataque1 = Onda(15)
    val ataque2 = Onda(10)
    val ataque3 = Onda(5)
    val ataque4 = CargarKi
    val arma = Arma(ArmaFilosa)
    val ataque5 = UsarItem(arma)
    
    var koku: Guerrero = Guerrero("koku", Saiyan(), 30, 150).agregarItems(arma)
                                                             .agregarMovimiento(ataque1,ataque2,ataque3,ataque4,ataque5)
    var yamcha: Guerrero = Guerrero("yamcha", Humano, 30, 150)
    var n18: Guerrero = Guerrero("n18",Androide, 30, 150)
    
    assertEquals(ataque1, koku.movimientoMasEfectivoContra(yamcha, MayorDaño))
    assertEquals(ataque3, koku.movimientoMasEfectivoContra(yamcha, SacarPocoKi))
    assertEquals(null, koku.movimientoMasEfectivoContra(n18, MayorDaño))
    assertEquals(null, koku.movimientoMasEfectivoContra(n18, SacarPocoKi))
  }
  
}