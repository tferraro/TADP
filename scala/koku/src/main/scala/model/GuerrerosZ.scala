package model

import model.Movimientos._

object GuerrerosZ {

  case class Guerrero(
      nombre: String,
      especie: Especie,
      energia: Int,
      energiaMaxima: Int,
      estado: EstadoGuerrero = Tranca,
      movimientos: List[Movimiento] = List(),
      items: List[Item] = List(),
      kiExterno: Int = 0) {

    require(energiaMaxima >= energia, "La energia no puede ser mayor a la máxima")

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

    def aumentoDeKi = {
      val cant = estado match {
        case SuperSaiyan(nivel) => 150 * nivel
        case _                  => especie.aumentoDeKi
      }
      aumentarEnergia(cant)
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
        // bien por el pattern
        case Fusion(original) if (nuevo == KO || nuevo == DEAD) => original
        case _ => this
      }).copy(estado = nuevo)
    }

    // el equals de scala es el "==" (es igualdad y no identidad :)
    def estaMorido = estado == DEAD

    def aumentarEMaxTantasVeces(veces: Int) = copy(energiaMaxima = energiaMaxima * veces)
    def aumentarEMax(cuantas: Int) = copy(energiaMaxima = energiaMaxima + cuantas)

    def cargaKiExterno: Guerrero = copy(kiExterno = kiExterno + 1)
    def resetKiExterno: Guerrero = copy(kiExterno = 0)
    def agregarMovimiento(moves: Movimiento*) = copy(movimientos = movimientos ++ moves)
    def agregarMovimiento(moves: List[Movimiento]) = copy(movimientos = movimientos ++ moves)
    def agregarItems(item: Item*) = copy(items = items ++ item)
    def agregarItems(item: List[Item]) = copy(items = items ++ item)
    def removerItem(item: Item) = copy(items = items diff List(item))
    def tieneItem(item: Item): Boolean = items.contains(item)

    def usarMovimiento(mov: Movimiento)(enemigo: Guerrero) = {
      (estado, mov) match {
        case (DEAD, _)                           => (this, enemigo)
        case (KO, UsarItem(SemillaDelHermitaño)) => mov(this, enemigo)
        case (KO, _)                             => (this, enemigo)
        case (_, DejarseFajar | Genkidama)       => mov(this, enemigo)
        case (_, _)                              => mov(this.resetKiExterno, enemigo)
      }
    }

    // El retorno debería ser un Option (el significado sería: encontrá el movimiento más efectivo, si hay alguno)
    def movimientoMasEfectivoContra(oponente: Guerrero)(criterio: Criterio): Movimiento = {
      criterio
        .ordenarMovimientos(movimientos, this, oponente)
        .headOption.getOrElse(PasarTurno)
    }

    def pelearUnRound(movimiento: Movimiento)(oponente: Guerrero) = {
      // buen detalle usando paternmatching en el val
      val (atacador, atacado) = usarMovimiento(movimiento)(oponente)
      atacado.contraAtacarA(atacador).swap
    }

    def contraAtacarA(agresor: Guerrero): (Guerrero, Guerrero) = {
      this.usarMovimiento(movimientoMasEfectivoContra(agresor)(VentajaDeKi))(agresor: Guerrero)
    }

    def planDeAtaqueContra(oponente: Guerrero, rounds: Int)(criterio: Criterio): PlanDeAtaque = {
      // buena combinacion de funciones, queda un poquito complejo pero no mucho más que el propio problema
      val planDeAtaque: PlanDeAtaque = List()
      List.range(0, rounds).foldLeft(planDeAtaque, (this, oponente))((semilla, _) => {
        val (plan, (atacante, defensor)) = semilla
        val movimientoAUsar = atacante.movimientoMasEfectivoContra(defensor)(criterio)
        (plan :+ movimientoAUsar, atacante.pelearUnRound(movimientoAUsar)(defensor))
      })
        ._1
    }

    def pelearContra(oponente: Guerrero)(planDeAtaque: PlanDeAtaque): ResultadoPelea = {
      val resultadoPelea: ResultadoPelea = SiguenPeleando(this, oponente)
      // bien por el fold
      planDeAtaque.foldLeft(resultadoPelea) { (resultadoAnterior, movimiento) =>
        resultadoAnterior.map(movimiento)
      }
    }
  }

  type PlanDeAtaque = List[Movimiento]

  trait ResultadoPelea {
    def map(f: Movimiento): ResultadoPelea
    def checkType(r: ResultadoPelea): Boolean
  }

  // si ganó no necesita a los dos, puede solo quedarse con el ganador
  case class HabemusGanador(peleadores: (Guerrero, Guerrero)) extends ResultadoPelea {
    def map(f: Movimiento): ResultadoPelea = this
    // TODO: no entiendo el "copy(null)", eviten esto!
    def checkType(r: ResultadoPelea): Boolean = this.copy(null).equals(r)
  }

  case class SiguenPeleando(peleadores: (Guerrero, Guerrero)) extends ResultadoPelea {
    def map(f: Movimiento): ResultadoPelea = {
      val resultado = f(peleadores._1, peleadores._2)
      if (resultado._1.estaMorido || resultado._2.estaMorido)
        // aca contruyan el resultado ganador con el guerrero que ganó y el otro lo descartan
        HabemusGanador(resultado)
      else
        SiguenPeleando(resultado)
    }
    // el checktype que usan para los tests ya no es necesario
    def checkType(r: ResultadoPelea): Boolean = this.copy(null).equals(r)
  }

  // No es necesario que lo cambien, pero pueden pensar que pasaría si el estado es una monada que wrapea al guerrero
  //  entonces el cambio del estado es un map o un flatMap sobre el estado (que adentro tiene al guerrero)
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
    // bien por la delegación en el arma, pero podrían haber heredado directamente el 
    //   tipo "Arma" sin hacer esta composición (Arma no hace nada más que contenerlos y siempre es una relación 1 a 1)
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
        // TODO: usar option.get es desaconsejado en la mayoría de los casos, sería mejor pasarle los dos guerreros y que éste método decida
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