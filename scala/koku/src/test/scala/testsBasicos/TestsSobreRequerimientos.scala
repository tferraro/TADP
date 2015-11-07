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
    
    assertEquals(ataque1, koku.movimientoMasEfectivoContra(yamcha)(MayorDaño))
    assertEquals(ataque1, koku.movimientoMasEfectivoContra(yamcha)(DerribarEnemigo))
    assertEquals(ataque3, koku.movimientoMasEfectivoContra(yamcha)(SacarPocoKi))
    assertEquals(PasarTurno, koku.movimientoMasEfectivoContra(n18)(MayorDaño))
    assertEquals(PasarTurno, koku.movimientoMasEfectivoContra(n18)(SacarPocoKi))
    assertEquals(ataque6, koku.movimientoMasEfectivoContra(yamcha)(MovimientoTacaño))
    
    var cell: Guerrero = Guerrero("Cell v2", Monstruo(ComerALaCell), 40, 150).agregarMovimiento(ataque7)
    var gohan: Guerrero = Guerrero("Son Gohan", Saiyan(),80,150)
    assertEquals(PasarTurno, cell.movimientoMasEfectivoContra(gohan)(NoMorir))
    
    var vegetaM: Guerrero = Guerrero("Majin Vegeta", Monstruo(ComerALaBuu), 40, 150).agregarMovimiento(ataque1,ataque7)
    var majinBuu: Guerrero = Guerrero("Majin Buu", Monstruo(ComerALaBuu),80,150)
    assertEquals(ataque1, vegetaM.movimientoMasEfectivoContra(majinBuu)(NoMorir))
  }
  
  @Test
  def proofOfConceptPelearUnRound() {
  var koku: Guerrero = Guerrero("koku", Saiyan(), 190, 650)
  var vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 200,800).agregarMovimiento(Onda(80),CargarKi,Onda(10))
  
  assertEquals(350, vegeta.usarMovimiento(CargarKi)(koku)._1.energia)
  assertEquals(30, vegeta.usarMovimiento(Onda(80))(koku)._2.energia)
  assertEquals(CargarKi, vegeta.movimientoMasEfectivoContra(koku)(VentajaDeKi))
  assertEquals(140, koku.pelearUnRound(Onda(50))(vegeta)._1.energia)
  assertEquals(250, koku.pelearUnRound(Onda(50))(vegeta)._2.energia)
  }
  
  @Test
  def proofOfConceptPlanDeAtaque() {
  var yajirobe: Guerrero = Guerrero("yajirobe", Humano, 400, 400)  .agregarItems(Arma(ArmaFilosa),SemillaDelHermitaño)
                                                                   .agregarMovimiento(UsarItem(Arma(ArmaFilosa)),UsarItem(SemillaDelHermitaño))
  var vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 200,800).agregarItems(Arma(ArmaFuego),Municion)
                                                            .agregarMovimiento(Onda(30),UsarItem(Arma(ArmaFuego)))
  
  assertEquals(1, yajirobe.usarMovimiento(UsarItem(Arma(ArmaFilosa)))(vegeta)._2.energia)  
  assertEquals(1, yajirobe.usarMovimiento(yajirobe.movimientoMasEfectivoContra(vegeta)(VentajaDeKi))(vegeta)._2.energia)                                                 
  assertEquals(340, vegeta.usarMovimiento(vegeta.movimientoMasEfectivoContra(yajirobe)(VentajaDeKi))(yajirobe)._2.energia)
  assertEquals(400, vegeta.usarMovimiento(vegeta.movimientoMasEfectivoContra(yajirobe)(VentajaDeKi))(yajirobe)
      ._2.usarMovimiento(UsarItem(SemillaDelHermitaño))(vegeta)._1.energia)
                                                         
  assertEquals(1, yajirobe.usarMovimiento(yajirobe.movimientoMasEfectivoContra(vegeta)(VentajaDeKi))(vegeta)._2.energia)
  assertEquals(380, yajirobe.pelearUnRound(yajirobe.movimientoMasEfectivoContra(vegeta)(VentajaDeKi))(vegeta)._1.energia)
  
  assertEquals(List(UsarItem(Arma(ArmaFilosa)),UsarItem(SemillaDelHermitaño)), yajirobe.planDeAtaqueContra(vegeta, 2)(VentajaDeKi))
  }
  
  @Test
  def proofOfConceptAPelear() {
  var koku: Guerrero = Guerrero("koku",Saiyan(),600,600).agregarItems(SemillaDelHermitaño,SemillaDelHermitaño)
                                                        .agregarMovimiento(UsarItem(SemillaDelHermitaño),Onda(30),Onda(100),CargarKi,Genkidama,DejarseFajar,MuchosGolpesNinja)
  var piccolo: Guerrero = Guerrero("Piccolo", Namekusein,500,500).agregarItems(EsferasDelDragon(7),SemillaDelHermitaño)
                                                                 .agregarMovimiento(UsarItem(SemillaDelHermitaño),Onda(40),Onda(70),CargarKi,MuchosGolpesNinja,Explotar)
  var elPlanDeGoku = koku.planDeAtaqueContra(piccolo,10)(MayorDaño)
  
  var resultado: ResultadoPelea = koku.pelearContra(piccolo)(elPlanDeGoku)
  
  }
  
  
  
  
  
  
}