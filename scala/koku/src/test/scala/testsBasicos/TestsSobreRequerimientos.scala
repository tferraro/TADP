package testsBasicos

import org.junit.Assert.assertEquals
import org.junit.Test
import model.Movimientos._
import model._
import model.GuerrerosZ._

class TestsSobreRequerimientos {

  @Test
  def proofOfConceptMejorMovimiento() {
    val ataque1 = Onda(15)
    val ataque2 = Onda(10)
    val ataque3 = Onda(5)
    val ataque4 = CargarKi
    val cuchi = ArmaFilosa
    val mp5 = ArmaFuego
    val ataque5 = UsarItem(cuchi)
    val ataque6 = UsarItem(mp5)
    val ataque7 = Explotar

    val koku: Guerrero = Guerrero("koku", Saiyan(), 30, 150).agregarItems(cuchi, mp5, Municion, Municion)
      .agregarMovimiento(ataque1, ataque2, ataque3, ataque4, ataque5, ataque6, ataque7)
    val yamcha: Guerrero = Guerrero("yamcha", Humano, 30, 150)
    val n18: Guerrero = Guerrero("n18", Androide, 30, 150)

    assertEquals(ataque1, koku.movimientoMasEfectivoContra(yamcha)(MayorDaño).get)
    assertEquals(ataque1, koku.movimientoMasEfectivoContra(yamcha)(DerribarEnemigo).get)
    assertEquals(ataque3, koku.movimientoMasEfectivoContra(yamcha)(SacarPocoKi).get)
    assertEquals(None, koku.movimientoMasEfectivoContra(n18)(MayorDaño))
    assertEquals(None, koku.movimientoMasEfectivoContra(n18)(SacarPocoKi))
    assertEquals(ataque6, koku.movimientoMasEfectivoContra(yamcha)(MovimientoTacaño).get)

    val cell: Guerrero = Guerrero("Cell v2", Monstruo(ComerALaCell), 40, 150).agregarMovimiento(ataque7)
    val gohan: Guerrero = Guerrero("Son Gohan", Saiyan(), 80, 150)
    assertEquals(PasarTurno, cell.movimientoMasEfectivoContra(gohan)(NoMorir).getOrElse(PasarTurno))

    val vegetaM: Guerrero = Guerrero("Majin Vegeta", Monstruo(ComerALaBuu), 40, 150).agregarMovimiento(ataque1, ataque7)
    val majinBuu: Guerrero = Guerrero("Majin Buu", Monstruo(ComerALaBuu), 80, 150)
    assertEquals(ataque1, vegetaM.movimientoMasEfectivoContra(majinBuu)(NoMorir).getOrElse(PasarTurno))
  }

  @Test
  def proofOfConceptPelearUnRound() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 190, 650)
    var vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 200, 800).agregarMovimiento(Onda(80), CargarKi, Onda(10))

    assertEquals(350, vegeta.usarMovimiento(CargarKi)(koku)._1.energia)
    assertEquals(30, vegeta.usarMovimiento(Onda(80))(koku)._2.energia)
    assertEquals(CargarKi, vegeta.movimientoMasEfectivoContra(koku)(VentajaDeKi).getOrElse(PasarTurno))
    assertEquals(140, koku.pelearUnRound(Onda(50))(vegeta)._1.energia)
    assertEquals(250, koku.pelearUnRound(Onda(50))(vegeta)._2.energia)
  }

  @Test
  def proofOfConceptPlanDeAtaque() {
    var yajirobe: Guerrero = Guerrero("yajirobe", Humano, 400, 400).agregarItems(ArmaFilosa, SemillaDelHermitaño)
      .agregarMovimiento(UsarItem(ArmaFilosa), UsarItem(SemillaDelHermitaño))
    var vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 200, 800).agregarItems(ArmaFuego, Municion)
      .agregarMovimiento(Onda(30), UsarItem(ArmaFuego))

    assertEquals(1, yajirobe.usarMovimiento(UsarItem(ArmaFilosa))(vegeta)._2.energia)
    assertEquals(1, yajirobe.usarMovimiento(yajirobe.movimientoMasEfectivoContra(vegeta)(VentajaDeKi).getOrElse(PasarTurno))(vegeta)._2.energia)
    assertEquals(340, vegeta.usarMovimiento(vegeta.movimientoMasEfectivoContra(yajirobe)(VentajaDeKi).getOrElse(PasarTurno))(yajirobe)._2.energia)
    assertEquals(400, vegeta.usarMovimiento(vegeta.movimientoMasEfectivoContra(yajirobe)(VentajaDeKi).getOrElse(PasarTurno))(yajirobe)
      ._2.usarMovimiento(UsarItem(SemillaDelHermitaño))(vegeta)._1.energia)

    assertEquals(1, yajirobe.usarMovimiento(yajirobe.movimientoMasEfectivoContra(vegeta)(VentajaDeKi).getOrElse(PasarTurno))(vegeta)._2.energia)
    assertEquals(380, yajirobe.pelearUnRound(yajirobe.movimientoMasEfectivoContra(vegeta)(VentajaDeKi).getOrElse(PasarTurno))(vegeta)._1.energia)

    assertEquals(List(UsarItem(ArmaFilosa), UsarItem(SemillaDelHermitaño)), yajirobe.planDeAtaqueContra(vegeta, 2)(VentajaDeKi))
  }

  @Test
  def proofOfConceptAPelearHuboGanador() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 600, 600).agregarItems(SemillaDelHermitaño, SemillaDelHermitaño)
      .agregarMovimiento(UsarItem(SemillaDelHermitaño), Onda(30), Onda(100), CargarKi, Genkidama, DejarseFajar, MuchosGolpesNinja)
    val piccolo: Guerrero = Guerrero("Piccolo", Namekusein, 1, 500).agregarItems(EsferasDelDragon(7), SemillaDelHermitaño)
      .agregarMovimiento(UsarItem(SemillaDelHermitaño), Onda(40), Onda(70), CargarKi, MuchosGolpesNinja, Explotar)
    val elPlanDeGoku = koku.planDeAtaqueContra(piccolo, 10)(MayorDaño)

    val resultado = koku.pelearContra(piccolo)(elPlanDeGoku)
    val kokuFinal = Guerrero("koku", Saiyan(), 570, 600, Tranca).agregarItems(SemillaDelHermitaño, SemillaDelHermitaño)
      .agregarMovimiento(UsarItem(SemillaDelHermitaño), Onda(30), Onda(100), CargarKi, Genkidama, DejarseFajar, MuchosGolpesNinja)
    assertEquals(HabemusGanador(kokuFinal), resultado)
  }

  @Test
  def proofOfConceptAPelearSiguenPeleando() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 600, 600).agregarItems(SemillaDelHermitaño, SemillaDelHermitaño)
      .agregarMovimiento(UsarItem(SemillaDelHermitaño), Onda(30), Onda(100), CargarKi, Genkidama, DejarseFajar, MuchosGolpesNinja)
    var piccolo: Guerrero = Guerrero("Piccolo", Namekusein, 500, 500).agregarItems(EsferasDelDragon(7), SemillaDelHermitaño)
      .agregarMovimiento(UsarItem(SemillaDelHermitaño), Onda(40), Onda(70), CargarKi, MuchosGolpesNinja, Explotar)
    var elPlanDeGoku = koku.planDeAtaqueContra(piccolo, 1)(MayorDaño)

    var resultado = koku.pelearContra(piccolo)(elPlanDeGoku)

    val kokuFinal = Guerrero("koku", Saiyan(), 500, 600, Tranca).agregarItems(SemillaDelHermitaño, SemillaDelHermitaño)
      .agregarMovimiento(UsarItem(SemillaDelHermitaño), Onda(30), Onda(100), CargarKi, Genkidama, DejarseFajar, MuchosGolpesNinja)
    val picoloFinal = Guerrero("Piccolo", Namekusein, 300, 500, Tranca).agregarItems(EsferasDelDragon(7), SemillaDelHermitaño)
      .agregarMovimiento(UsarItem(SemillaDelHermitaño), Onda(40), Onda(70), CargarKi, MuchosGolpesNinja, Explotar)
    assertEquals(SiguenPeleando(kokuFinal, picoloFinal), resultado)
  }
}