package testsBasicos

import org.junit.Assert.assertEquals
import org.junit.Test
import model.GuerrerosZ._
import model.Movimientos._
import model.Especies._

class TestsSobreAspectosBasicos {

  @Test
  def crearUnGuerreroCualquiera() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 50, 150)
    var androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)

    assertEquals(Saiyan(), koku.especie)
    assertEquals(Androide, androide17.especie)
    assertEquals(50, koku.energia)
    assertEquals(30, androide17.energia)
  }

  @Test
  def proofOfConceptoDeDejarseFajar() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 50, 150)
    var androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)
    assertEquals(50, DejarseFajar(koku, androide17)._1.energia)
    assertEquals(30, DejarseFajar(koku, androide17)._2.energia)
  }

  @Test
  def proofOfConceptoDeCargarKi() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 50, 150)
    var androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)

    assertEquals(150, CargarKi(koku, androide17)._1.energia)
    assertEquals(30, CargarKi(androide17, koku)._1.energia)
  }

  @Test
  def proofOfConceptDeConvertirseEnSuperSaiyan() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 50, 150)
    var vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 150, 150)
    var androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)

    assertEquals(150, TransformarSuperSaiyan(koku, vegeta)._1.energiaMaxima)
    assertEquals(150, TransformarSuperSaiyan(androide17, vegeta)._1.energiaMaxima)
    assertEquals(150, TransformarSuperSaiyan(vegeta, koku)._1.energia)
    assertEquals(750, TransformarSuperSaiyan(vegeta, koku)._1.energiaMaxima)
    assertEquals(SuperSaiyan(1), TransformarSuperSaiyan(vegeta, koku)._1.estado)

    val volverseSS2 =
      TransformarSuperSaiyan(
        CargarKi(
          CargarKi(
            TransformarSuperSaiyan(vegeta, koku)._1, koku)._1, koku)._1, koku)
    assertEquals(450, volverseSS2._1.energia)
    assertEquals(SuperSaiyan(2), volverseSS2._1.estado)
  }

  @Test
  def proofOfConceptUsarMovimiento() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 50, 150)
    var vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 150, 150)
    assertEquals(50, koku.cambiarEstado(KO).usarMovimiento(CargarKi)(vegeta)._1.energia)
    assertEquals(50, koku.cambiarEstado(DEAD).usarMovimiento(CargarKi)(vegeta)._1.energia)
    assertEquals(150, koku.usarMovimiento(CargarKi)(vegeta)._1.energia)
  }

  @Test
  def proofOfConceptAgregarMovimiento() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 50, 150)
    assertEquals(true, koku.agregarMovimiento(DejarseFajar, CargarKi).movimientos.contains(DejarseFajar))
    assertEquals(true, koku.agregarMovimiento(DejarseFajar, CargarKi).movimientos.contains(CargarKi))
  }

  @Test
  def proofOfConceptUsarFusion() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 50, 150).agregarMovimiento(CargarKi, TransformarSuperSaiyan)
    var vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 150, 150).agregarMovimiento(DejarseFajar)
    var androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)

    val gogeta = koku.usarMovimiento(FusionCon(vegeta))(androide17)._1

    assertEquals("koku+vegeta", gogeta.nombre)
    assertEquals(200, gogeta.energia)
    assertEquals(300, gogeta.energiaMaxima)
    assertEquals(3, gogeta.movimientos.size)
  }

  @Test
  def proofOfConceptUsarFusionDesFusionandosePorDeadOKO() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 50, 150).agregarMovimiento(CargarKi, TransformarSuperSaiyan)
    var vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 150, 150).agregarMovimiento(DejarseFajar)
    var androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)

    val gogeta = koku.usarMovimiento(FusionCon(vegeta))(androide17)._1

    assertEquals("koku+vegeta", gogeta.nombre)
    assertEquals("koku", gogeta.cambiarEstado(KO).nombre)
    assertEquals("koku", gogeta.cambiarEstado(DEAD).nombre)
  }

  @Test
  def proofOfConceptConvertirseEnMono() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 50, 150).agregarItems(FotoLuna)
    var androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)
    val mono = koku.usarMovimiento(TransformarMono)(androide17)._1
    assertEquals(450, mono.energia)
    assertEquals(450, mono.energiaMaxima)
    assertEquals(MonoGigante, mono.estado)
  }

  @Test
  def proofOfConceptConvertirseEnMonoMalPorSerSuperSaiyan() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150).agregarItems(FotoLuna)
    var androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)
    assertEquals(SuperSaiyan(1), koku
      .usarMovimiento(TransformarSuperSaiyan)(androide17)._1
      .usarMovimiento(TransformarMono)(androide17)
      ._1.estado)
  }

  @Test
  def proofOfConceptConvertirseEnMonoMalPorNoTenerFotoLuna() {
    var koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150)
    var androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)
    assertEquals(Tranca, koku
      .usarMovimiento(TransformarMono)(androide17)
      ._1.estado)
  }

  @Test
  def proofOfConceptConvertirseEnMonoMalPorNoTenerCola() {
    var koku: Guerrero = Guerrero("koku", Saiyan(false), 150, 150)
    var androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)
    assertEquals(Tranca, koku
      .usarMovimiento(TransformarMono)(androide17)
      ._1.estado)
  }

  @Test
  def proofOfConceptMagia() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150).agregarItems(EsferasDelDragon(7))
    val picolo: Guerrero = Guerrero("picolo", Namekusein, 30, 150).cambiarEstado(DEAD)
    val vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 150, 150).cambiarEstado(KO)

    assertEquals(true, koku.items.contains(EsferasDelDragon(7)))
    assertEquals(false, koku.usarMovimiento(Magia(RevivirOponente))(picolo)._1.items.contains(EsferasDelDragon(7)))
    assertEquals(Tranca, koku.usarMovimiento(Magia(RevivirOponente))(picolo)._2.estado)
    assertEquals(false, picolo.items.contains(EsferasDelDragon(7)))
    assertEquals(Tranca, picolo.cambiarEstado(Tranca).usarMovimiento(Magia(RevivirOponente))(vegeta)._2.estado)
  }

  @Test
  def proofOfConceptComerComoCell() {
    val cell: Guerrero = Guerrero("unperfect cell", Monstruo(ComerALaCell), 130, 150).agregarMovimiento(ComerOponente)
    val androide17: Guerrero = Guerrero("lapis", Androide, 30, 150).agregarMovimiento(DejarseFajar)

    assertEquals(DEAD, cell.usarMovimiento(ComerOponente)(androide17)._2.estado)
    assertEquals(2, cell.usarMovimiento(ComerOponente)(androide17)._1.movimientos.size)
    assertEquals(true, cell.usarMovimiento(ComerOponente)(androide17)._1.movimientos.contains(DejarseFajar))
  }

  @Test
  def proofOfConceptComerComoCellPeroNoPuedePorqueNoEsAndroide() {
    val cell: Guerrero = Guerrero("unperfect cell", Monstruo(ComerALaCell), 130, 150).agregarMovimiento(ComerOponente)
    val vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 1, 150).agregarMovimiento(DejarseFajar)

    assertEquals(Tranca, cell.usarMovimiento(ComerOponente)(vegeta)._2.estado)
    assertEquals(1, cell.usarMovimiento(ComerOponente)(vegeta)._1.movimientos.size)
    assertEquals(false, cell.usarMovimiento(ComerOponente)(vegeta)._1.movimientos.contains(DejarseFajar))
  }

  @Test
  def proofOfConceptComerComoMajinBuu() {
    val majinBuu: Guerrero = Guerrero("majinBuu", Monstruo(ComerALaBuu), 130, 150).agregarMovimiento(ComerOponente)
    val vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 2, 150).agregarMovimiento(DejarseFajar)

    assertEquals(DEAD, majinBuu.usarMovimiento(ComerOponente)(vegeta)._2.estado)
    assertEquals(1, majinBuu.usarMovimiento(ComerOponente)(vegeta)._1.movimientos.size)
    assertEquals(true, majinBuu.usarMovimiento(ComerOponente)(vegeta)._1.movimientos.contains(DejarseFajar))
  }

  @Test
  def proofOfConceptNoPoderComerPorFaltaDeKi() {
    val majinBuu: Guerrero = Guerrero("majinBuu", Monstruo(ComerALaBuu), 130, 150).agregarMovimiento(ComerOponente)
    val vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 150, 150).agregarMovimiento(DejarseFajar)

    assertEquals(Tranca, majinBuu.usarMovimiento(ComerOponente)(vegeta)._2.estado)
    assertEquals(1, majinBuu.usarMovimiento(ComerOponente)(vegeta)._1.movimientos.size)
    assertEquals(false, majinBuu.usarMovimiento(ComerOponente)(vegeta)._1.movimientos.contains(DejarseFajar))
  }

  @Test
  def pruebaDeCambioDeKiConEstado() {
    //NOTE: Se presupone que no se va a inicializar un guerrero con 0 de ki.
    //NOTE: Cuando el Ki se vuelve 0, no sirve aumentando el ki, se sigue morido (?)
    val vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 50, 150)
    assertEquals(Tranca, vegeta.estado)
    assertEquals(DEAD, vegeta.disminuirEnergia(501).estado)
    assertEquals(KO, vegeta.cambiarEstado(KO).aumentarEnergia(50).estado)
  }

  @Test
  def proofOfConceptUsarItem() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150).agregarItems(Arma(ArmaRoma))
    val vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 50, 150)
    assertEquals(KO, koku.usarMovimiento(UsarItem(Arma(ArmaRoma)))(vegeta)._2.estado)
  }

  @Test
  def proofOfConceptNoSeUsoItemPorNoTenerlo() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150)
    val vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 50, 150)
    assertEquals(Tranca, koku.usarMovimiento(UsarItem(Arma(ArmaRoma)))(vegeta)._2.estado)
  }

  @Test
  def proofOfConceptArmaRomaNoHacePorAndroide() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150).agregarItems(Arma(ArmaRoma))
    val androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)
    assertEquals(Tranca, koku.usarMovimiento(UsarItem(Arma(ArmaRoma)))(androide17)._2.estado)
  }

  @Test
  def proofOfConceptArmaRomaNoHacePorFaltaDeKi() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150).agregarItems(Arma(ArmaRoma))
    val vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 380, 450)
    assertEquals(Tranca, koku.usarMovimiento(UsarItem(Arma(ArmaRoma)))(vegeta)._2.estado)
  }
  
  @Test
  def proofOfConceptArmaFilosaNoAtacaAndroide() {
    val arale: Guerrero = Guerrero("arale", Androide, 30, 150).agregarItems(Arma(ArmaFilosa))
    val vegeta: Guerrero = Guerrero("vegeta", Saiyan(true), 380, 450)
    assertEquals(380, arale.usarMovimiento(UsarItem(Arma(ArmaFilosa)))(vegeta)._2.energia)
  }

  @Test
  def proofOfConceptArmaFilosaASaiyanTranca() {
    val trunks: Guerrero = Guerrero("trunks", Saiyan(), 380, 450).agregarItems(Arma(ArmaFilosa))
    val koku: Guerrero = Guerrero("vegeta", Saiyan(), 380, 450)
    assertEquals(1, trunks.usarMovimiento(UsarItem(Arma(ArmaFilosa)))(koku)._2.energia)
    assertEquals(Saiyan(false), trunks.usarMovimiento(UsarItem(Arma(ArmaFilosa)))(koku)._2.especie)
    assertEquals(Tranca, trunks.usarMovimiento(UsarItem(Arma(ArmaFilosa)))(koku)._2.estado)
  }
   
   @Test
  def proofOfConceptArmaFilosaAGuerrero() {
    val trunks: Guerrero = Guerrero("trunks", Saiyan(), 380, 450).agregarItems(Arma(ArmaFilosa))
    val kaioshin: Guerrero = Guerrero("Kaioshin", Namekusein, 380, 450)
    assertEquals(377, trunks.usarMovimiento(UsarItem(Arma(ArmaFilosa)))(kaioshin)._2.energia)
  }
  
  @Test
  def proofOfConceptArmaFilosaAMonoGigante() {
    val yayirobe: Guerrero = Guerrero("Yayirobe", Humano, 380, 450).agregarItems(Arma(ArmaFilosa))
    val vegeta: Guerrero = Guerrero("vegeta", Saiyan(true), 380, 450).agregarItems(FotoLuna)
    val mono = vegeta.usarMovimiento(TransformarMono)(yayirobe)._1
    assertEquals(1, yayirobe.usarMovimiento(UsarItem(Arma(ArmaFilosa)))(mono)._2.energia)
    assertEquals(Saiyan(false), yayirobe.usarMovimiento(UsarItem(Arma(ArmaFilosa)))(mono)._2.especie)
    assertEquals(KO, yayirobe.usarMovimiento(UsarItem(Arma(ArmaFilosa)))(mono)._2.estado)
  }

  @Test
  def proofOfConceptArmaFuegoAHumanoSinMuniciones() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150).agregarItems(Arma(ArmaFuego))
    val mrSatan: Guerrero = Guerrero("Mr. Satan", Humano, 380, 450)
    assertEquals(380, koku.usarMovimiento(UsarItem(Arma(ArmaFuego)))(mrSatan)._2.energia)
  }

  @Test
  def proofOfConceptArmaFuegoAHumano() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150).agregarItems(Arma(ArmaFuego)).agregarItems(Municion, Municion)
    val mrSatan: Guerrero = Guerrero("Mr. Satan", Humano, 380, 450)
    assertEquals(360, koku
      .usarMovimiento(UsarItem(Arma(ArmaFuego)))(mrSatan)
      ._2.energia)
    assertEquals(340, koku.usarMovimiento(UsarItem(Arma(ArmaFuego)))(koku.usarMovimiento(UsarItem(Arma(ArmaFuego)))(mrSatan)._2)
      ._2.energia)
    val resultado = koku.usarMovimiento(UsarItem(Arma(ArmaFuego)))(mrSatan)
    assertEquals(false, resultado._1.usarMovimiento(UsarItem(Arma(ArmaFuego)))(resultado._2)
      ._1.items.contains(Municion))
  }

  @Test
  def proofOfConceptArmaFuegoANamekMedioBoludo() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150).agregarItems(Arma(ArmaFuego)).agregarItems(Municion, Municion)
    val kaioshin: Guerrero = Guerrero("Kaioshin", Namekusein, 380, 450)
    assertEquals(380, koku.usarMovimiento(UsarItem(Arma(ArmaFuego)))(kaioshin)._2.energia)
    assertEquals(2, koku.usarMovimiento(UsarItem(Arma(ArmaFuego)))(kaioshin)._1.items.size)
    assertEquals(370, koku.usarMovimiento(UsarItem(Arma(ArmaFuego)))(kaioshin.cambiarEstado(KO))._2.energia)
  }

  @Test
  def proofOfConceptSemillaDelHermitañoGuerrero() {
    val kaioshin: Guerrero = Guerrero("Kaioshin", Namekusein, 380, 450).agregarItems(SemillaDelHermitaño)
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150)
    assertEquals(450, kaioshin.usarMovimiento(UsarItem(SemillaDelHermitaño))(koku)._1.energia)
  }
  
  @Test
  def proofOfConceptSemillaDelHermitañoGuerreroKO() {
    val kaioshin: Guerrero = Guerrero("Kaioshin", Namekusein, 0, 450,KO).agregarItems(SemillaDelHermitaño)
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150)
    assertEquals(Tranca, kaioshin.usarMovimiento(UsarItem(SemillaDelHermitaño))(koku)._1.estado)
    assertEquals(450, kaioshin.usarMovimiento(UsarItem(SemillaDelHermitaño))(koku)._1.energia)
  }
  
  @Test
  def proofOfConceptSemillaDelHermitañoGuerreroDEAD() {
    val kaioshin: Guerrero = Guerrero("Kaioshin", Namekusein, 0, 450,DEAD).agregarItems(SemillaDelHermitaño)
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150)
    assertEquals(DEAD, kaioshin.usarMovimiento(UsarItem(SemillaDelHermitaño))(koku)._1.estado)
    assertEquals(0, kaioshin.usarMovimiento(UsarItem(SemillaDelHermitaño))(koku)._1.energia)
  }
  
  @Test
  def proofOfConceptSemillaDelHermitañoSuperSaiyan() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150).agregarItems(SemillaDelHermitaño)
    val kaioshin: Guerrero = Guerrero("Kaioshin", Namekusein, 380, 450)
    val kokuss = TransformarSuperSaiyan(koku, kaioshin)._1
    assertEquals(750, kokuss.usarMovimiento(UsarItem(SemillaDelHermitaño))(kaioshin)._1.energia)
    assertEquals(SuperSaiyan(1), kokuss.usarMovimiento(UsarItem(SemillaDelHermitaño))(kaioshin)._1.estado)
  }
  
  @Test
  def proofOfConceptGolpesNinja() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150)
    val vegeta: Guerrero = Guerrero("vegeta", Saiyan(), 150, 150)
    val kaioshin: Guerrero = Guerrero("Kaioshin", Namekusein, 380, 450)
    val mrSatan: Guerrero = Guerrero("Mr. Satan", Humano, 380, 450)
    val androide17: Guerrero = Guerrero("lapis", Androide, 30, 150)

    assertEquals(130, koku.usarMovimiento(MuchosGolpesNinja)(vegeta)._1.energia)
    assertEquals(130, koku.usarMovimiento(MuchosGolpesNinja)(vegeta)._2.energia)
    assertEquals(130, koku.usarMovimiento(MuchosGolpesNinja)(kaioshin)._1.energia)
    assertEquals(380, koku.usarMovimiento(MuchosGolpesNinja)(kaioshin)._2.energia)
    assertEquals(380, mrSatan.usarMovimiento(MuchosGolpesNinja)(koku)._1.energia)
    assertEquals(130, mrSatan.usarMovimiento(MuchosGolpesNinja)(koku)._2.energia)
    assertEquals(370, mrSatan.usarMovimiento(MuchosGolpesNinja)(androide17)._1.energia)
    assertEquals(30, mrSatan.usarMovimiento(MuchosGolpesNinja)(androide17)._2.energia)
  }

  @Test
  def proofOfConceptExplotar() {
    val androide17: Guerrero = Guerrero("lapis", Androide, 500, 500)
    val vegetaM: Guerrero = Guerrero("vegeta Majin", Monstruo(ComerALaBuu), 130, 150)
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150)
    val kaioshin: Guerrero = Guerrero("Kaioshin", Namekusein, 380, 450)

    assertEquals(150, koku.usarMovimiento(Explotar)(vegetaM)._1.energia)
    assertEquals(130, koku.usarMovimiento(Explotar)(vegetaM)._2.energia)
    assertEquals(0, vegetaM.usarMovimiento(Explotar)(koku)._1.energia)
    assertEquals(DEAD, vegetaM.usarMovimiento(Explotar)(koku)._1.estado)
    assertEquals(0, vegetaM.usarMovimiento(Explotar)(koku)._2.energia)
    assertEquals(DEAD, vegetaM.usarMovimiento(Explotar)(koku)._2.estado)
    assertEquals(120, vegetaM.usarMovimiento(Explotar)(kaioshin)._2.energia)
    assertEquals(DEAD, androide17.usarMovimiento(Explotar)(kaioshin)._1.estado)
    assertEquals(1, androide17.usarMovimiento(Explotar)(kaioshin)._2.energia)
  }

  @Test
  def proofOfConceptOnda() {
    val androide17: Guerrero = Guerrero("lapis", Androide, 500, 500)
    val vegetaM: Guerrero = Guerrero("vegeta Majin", Monstruo(ComerALaBuu), 130, 150)
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150)
    assertEquals(50, koku.usarMovimiento(Onda(100))(vegetaM)._1.energia)
    assertEquals(80, koku.usarMovimiento(Onda(100))(vegetaM)._2.energia)
    assertEquals(300, koku.usarMovimiento(Onda(100))(androide17)._2.energia)
    assertEquals(150, koku.usarMovimiento(Onda(600))(vegetaM)._1.energia)
    assertEquals(130, koku.usarMovimiento(Onda(600))(vegetaM)._2.energia)
  }

  @Test
  def proofOfConceptGenkidama() {
    val koku: Guerrero = Guerrero("koku", Saiyan(), 150, 150)
    val frieza: Guerrero = Guerrero("frieza", Monstruo(null), 500, 500)
    assertEquals(0, koku.kiExterno)
    assertEquals(1, koku.usarMovimiento(DejarseFajar)(frieza)._1.kiExterno)
    assertEquals(2, koku.usarMovimiento(DejarseFajar)(frieza)._1
      .usarMovimiento(DejarseFajar)(frieza)._1.kiExterno)
    assertEquals(0, koku.usarMovimiento(DejarseFajar)(frieza)._1
      .usarMovimiento(CargarKi)(frieza)._1.kiExterno)
    assertEquals(495, koku.usarMovimiento(DejarseFajar)(frieza)._1
      .usarMovimiento(Genkidama)(frieza)._2.energia)
    val kokuReFajado = koku
      .usarMovimiento(DejarseFajar)(frieza)._1
      .usarMovimiento(DejarseFajar)(frieza)._1
      .usarMovimiento(DejarseFajar)(frieza)._1
      .usarMovimiento(DejarseFajar)(frieza)._1
    assertEquals(0, kokuReFajado.usarMovimiento(Genkidama)(frieza)._2.energia)
    assertEquals(DEAD, kokuReFajado.usarMovimiento(Genkidama)(frieza)._2.estado)

  }
}