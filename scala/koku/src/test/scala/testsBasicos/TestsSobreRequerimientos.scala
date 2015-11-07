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
    val cuchi   = Arma(ArmaFilosa)
    val mp5     = Arma(ArmaFuego)
    val ataque5 = UsarItem(cuchi)
    val ataque6 = UsarItem(mp5)
    val ataque7 = Explotar
    
    var koku: Guerrero = Guerrero("koku", Saiyan(), 30, 150).agregarItems(cuchi,mp5,Municion,Municion)
                                                             .agregarMovimiento(ataque1,ataque2,ataque3,ataque4,ataque5,ataque6,ataque7)
    var yamcha: Guerrero = Guerrero("yamcha", Humano, 30, 150)
    var n18: Guerrero = Guerrero("n18",Androide, 30, 150)
    
    assertEquals(ataque1, koku.movimientoMasEfectivoContra(yamcha, MayorDaño))
    assertEquals(ataque1, koku.movimientoMasEfectivoContra(yamcha,DerribarEnemigo))
    assertEquals(ataque3, koku.movimientoMasEfectivoContra(yamcha, SacarPocoKi))
    assertEquals(null, koku.movimientoMasEfectivoContra(n18, MayorDaño))
    assertEquals(null, koku.movimientoMasEfectivoContra(n18, SacarPocoKi))
    assertEquals(ataque6, koku.movimientoMasEfectivoContra(yamcha, MovimientoTacaño))
    
    var cell: Guerrero = Guerrero("Cell v2", Monstruo(ComerALaCell), 40, 150).agregarMovimiento(ataque7)
    var gohan: Guerrero = Guerrero("Son Gohan", Saiyan(),80,150)
    assertEquals(null, cell.movimientoMasEfectivoContra(gohan, NoMorir))
    
    var vegetaM: Guerrero = Guerrero("Majin Vegeta", Monstruo(ComerALaBuu), 40, 150).agregarMovimiento(ataque1,ataque7)
    var majinBuu: Guerrero = Guerrero("Majin Buu", Monstruo(ComerALaBuu),80,150)
    assertEquals(ataque1, vegetaM.movimientoMasEfectivoContra(majinBuu, NoMorir))
  }
  
  
  
}