package model

import model.Movimientos._
import model.Especies._

object GuerrerosZ {

  case class Guerrero(
      nombre: String,
      especie: Especie,
      energia: Int,
      energiaMaxima: Int,
      estado: EstadoGuerrero = Tranca,
      movimientos: List[Movimiento] = List(),
      items: List[Item] = List()) {

    require(energiaMaxima >= energia, "La energia no puede ser mayor a la máxima")

    var kiExterno: Int = 0
    def recuperarEnergiaMaxima = {
      val guerreroRecuperado = copy(energia = energiaMaxima)
      guerreroRecuperado.estado match {
        case KO => guerreroRecuperado.cambiarEstado(Tranca)
        case _  => guerreroRecuperado
      }
    }

    def perderCola = especie match {
      case Saiyan(_) => actualizarEspecie(Saiyan(false))
      case _         => this
    }

    def aumentarEnergia(cuanto: Int) = {
      val energiaPosta = energia + cuanto
      if (energiaPosta > energiaMaxima)
        copy(energia = energiaMaxima)
      else
        copy(energia = energiaPosta)
    }
    def disminuirEnergia(cuanto: Int): Guerrero = {
      val energiaPosta = energia - cuanto
      val guerreroDescargado = {
        if (energiaPosta > 0)
          copy(energia = energiaPosta)
        else
          copy(energia = 0) //Nunca tengo energia negativa.
      }
      guerreroDescargado.energia match {
        case 0 => guerreroDescargado.cambiarEstado(DEAD)
        case _ => guerreroDescargado
      }

    }
    def actualizarEspecie(especie: Especie) = copy(especie = especie)
    def cambiarEstado(nuevo: EstadoGuerrero) = {
      (especie match {
        case Fusion(original) if (nuevo == KO || nuevo == DEAD) => original
        case _ => this
      }).copy(estado = nuevo)
    }

    def estaMorido: Boolean = estado.equals(DEAD)

    def aumentarEMaxTantasVeces(veces: Int) = copy(energiaMaxima = energiaMaxima * veces)
    def aumentarEMax(cuantas: Int) = copy(energiaMaxima = energiaMaxima + cuantas)
    def cargaKiExterno: Guerrero = {
      val nuevo = copy()
      nuevo.kiExterno = kiExterno + 1
      return nuevo
    }
    def pasar = copy()
    def agregarMovimiento(moves: Movimiento*) = copy(movimientos = movimientos ++ moves)
    def agregarMovimiento(moves: List[Movimiento]) = copy(movimientos = movimientos ++ moves)
    def agregarItems(item: Item*) = copy(items = items ++ item)
    def agregarItems(item: List[Item]) = copy(items = items ++ item)
    def removerItem(item: Item) = copy(items = items diff List(item))
    def tieneItem(item: Item): Boolean = items.contains(item)

    def usarMovimiento(mov: Movimiento)(enemigo: Guerrero) = {
      estado match {
        case DEAD => (this, enemigo)
        case KO => mov match {
          case UsarItem(item) if (item.equals(SemillaDelHermitaño)) => mov(this, enemigo)
          case _ => (this, enemigo)
        }
        case _ => mov(this, enemigo)
      }
    }
    def movimientoMasEfectivoContra(oponente: Guerrero)(criterio: Criterio): Movimiento = {
      val mejorMovimiento = movimientos.maxBy(movimiento => criterio.evaluar(movimiento, this, oponente))
      if (criterio.evaluar(mejorMovimiento, this, oponente) > 0)
        mejorMovimiento
      else
        PasarTurno
    }

    def pelearUnRound(movimiento: Movimiento)(oponente: Guerrero) = {
      val (atacador, atacado) = this.usarMovimiento(movimiento)(oponente)
      atacado.contraAtacarA(atacador).swap
    }

    def contraAtacarA(agresor: Guerrero): (Guerrero, Guerrero) = {
      this.usarMovimiento(movimientoMasEfectivoContra(agresor)(VentajaDeKi))(agresor: Guerrero)
    }

    def planDeAtaqueContra(oponente: Guerrero, rounds: Int)(criterio: Criterio): PlanDeAtaque = {
      var planDeAtaque: PlanDeAtaque = List()
      List.range(0, rounds).foldLeft(planDeAtaque, (this, oponente))((semilla, _) => {
        var (plan, (atacante, defensor)) = semilla
        var movimientoAUsar = atacante.movimientoMasEfectivoContra(defensor)(criterio)
        (plan :+ movimientoAUsar, atacante.pelearUnRound(movimientoAUsar)(defensor))
      })
        ._1
    }

    def pelearContra(oponente: Guerrero)(planDeAtaque: PlanDeAtaque): ResultadoPelea = {
      var resultadoPelea: ResultadoPelea = SiguenPeleando(this, oponente)
      planDeAtaque.foldLeft(resultadoPelea) { (resultadoAnterior, movimiento) =>
        resultadoAnterior.map(movimiento)
      }
    }
  }

  type PlanDeAtaque = List[Movimiento]

  trait ResultadoPelea {
    def map(f: ((Guerrero, Guerrero) => (Guerrero, Guerrero))): ResultadoPelea
    def checkType(r: ResultadoPelea): Boolean
  }

  case class HabemusGanador(peleadores: (Guerrero, Guerrero)) extends ResultadoPelea {
    def map(f: ((Guerrero, Guerrero) => (Guerrero, Guerrero))): ResultadoPelea = this
    def checkType(r: ResultadoPelea): Boolean = this.copy(null).equals(r)
  }

  case class SiguenPeleando(peleadores: (Guerrero, Guerrero)) extends ResultadoPelea {
    def map(f: ((Guerrero, Guerrero) => (Guerrero, Guerrero))): ResultadoPelea = {
      var resultado = f(peleadores._1, peleadores._2)
      if (resultado._1.estaMorido || resultado._2.estaMorido)
        HabemusGanador(resultado)
      else
        SiguenPeleando(resultado)
    }
    def checkType(r: ResultadoPelea): Boolean = this.copy(null).equals(r)
  }

  trait EstadoGuerrero
  case object Tranca extends EstadoGuerrero
  case object KO extends EstadoGuerrero
  case object DEAD extends EstadoGuerrero
  case class SuperSaiyan(nivel: Int = 1) extends EstadoGuerrero {
    def subirNivel = copy(nivel = nivel + 1)
  }
  case object MonoGigante extends EstadoGuerrero

  trait Item
  case object FotoLuna extends Item
  case class EsferasDelDragon(cuantas: Int) extends Item
  case object SemillaDelHermitaño extends Item
  case class Arma(tipo: TipoArma) extends Item
  case object Municion extends Item

  trait TipoArma {
    def infligirDaño(guerrero: Guerrero, kiAtacante: Option[Int] = None): Guerrero
  }
  case object ArmaRoma extends TipoArma {
    def infligirDaño(guerrero: Guerrero, kiAtacante: Option[Int] = None) = {
      if (!guerrero.especie.equals(Androide) && guerrero.energia < 300)
        guerrero.cambiarEstado(KO)
      else
        guerrero
    }
  }
  case object ArmaFilosa extends TipoArma {
    def infligirDaño(guerrero: Guerrero, kiAtacante: Option[Int]) = {
      guerrero.especie match {
        case Saiyan(cola) if cola => guerrero.estado match {
          case MonoGigante => guerrero.perderCola.disminuirEnergia(guerrero.energia - 1).cambiarEstado(KO)
          case _           => guerrero.perderCola.disminuirEnergia(guerrero.energia - 1)
        }
        case _ => guerrero.disminuirEnergia(kiAtacante.get / 100)
      }
    }
  }
  case object ArmaFuego extends TipoArma {
    def infligirDaño(guerrero: Guerrero, kiAtacante: Option[Int] = None) = {
      guerrero.especie match {
        case Humano                                   => guerrero.disminuirEnergia(20)
        case Namekusein if guerrero.estado.equals(KO) => guerrero.disminuirEnergia(10)
        case _                                        => guerrero
      }
    }
  }
}