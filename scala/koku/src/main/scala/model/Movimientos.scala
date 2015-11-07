package model

import model.GuerrerosZ._
import model.Especies._

object Movimientos {

  type Movimiento = Function2[Guerrero, Guerrero, (Guerrero, Guerrero)]

  case object DejarseFajar extends Movimiento {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      (user.cargaKiExterno, enemigo.pasar)
    }
  }

  case object CargarKi extends Movimiento {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      val cant = user.estado match {
        case SuperSaiyan(nivel) => 150 * nivel
        case _                  => user.especie.aumentoDeKi
      }
      (user.aumentarEnergia(cant), enemigo.pasar)
    }
  }

  case object TransformarSuperSaiyan extends Movimiento {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      val guerreroActualizado = (user.especie, user.energia, user.energiaMaxima) match {
        case (Saiyan(_), e, eMax) if e >= (eMax / 2) => {
          user.estado match {
            case MonoGigante     => user.pasar
            case ss: SuperSaiyan => user.cambiarEstado(ss.subirNivel).aumentarEMaxTantasVeces(5 * ss.nivel)
            case _               => user.cambiarEstado(SuperSaiyan()).aumentarEMaxTantasVeces(5)
          }
        }
        case _ => user.pasar
      }
      (guerreroActualizado, enemigo.pasar)
    }
  }

  case class UsarItem(item: Item) extends Movimiento {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      if (user.items.contains(item))
        item match {
          case Arma(tipo) => tipo match {
            case ArmaFuego  if user.tieneItem(Municion)       => (user.removerItem(Municion), tipo.infligirDaño(enemigo))
            case ArmaRoma                                     => (user.pasar, tipo.infligirDaño(enemigo))
            case ArmaFilosa if !user.especie.equals(Androide) => (user.pasar, tipo.infligirDaño(enemigo, Some(user.energia)))
            case _                                            => (user.pasar, enemigo.pasar)
          }
          case SemillaDelHermitaño if !user.especie.equals(Androide)  => (user.recuperarEnergiaMaxima.removerItem(item), enemigo.pasar)
          case _                   => (user.pasar, enemigo.pasar)
        }
      else
        (user.pasar, enemigo.pasar)
    }
  }

  case class FusionCon(amigo: Guerrero) extends Movimiento {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      val fusionado = user.especie match {
        case Humano | Namekusein | Saiyan(_) =>
          user
            .copy(nombre = user.nombre + "+" + amigo.nombre, especie = Fusion(user))
            .aumentarEMax(amigo.energiaMaxima)
            .aumentarEnergia(amigo.energia)
            .agregarMovimiento(amigo.movimientos)
        case _ => user.pasar
      }
      (fusionado, enemigo.pasar)
    }
  }

  case object TransformarMono extends Movimiento {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      val mono = user.especie match {
        case Saiyan(cola) if cola &&
          user.items.contains(FotoLuna) =>
          user.estado match {
            case SuperSaiyan(_) => user.pasar
            case _ => {
              var userEMaxAumentado = user.aumentarEMaxTantasVeces(3)
              userEMaxAumentado.aumentarEnergia(userEMaxAumentado.energiaMaxima).cambiarEstado(MonoGigante)
            }
          }
        case _ => user.pasar
      }
      (mono, enemigo.pasar)
    }
  }

  case object ComerOponente extends Movimiento {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      user.especie match {
        case Monstruo(formaComer) if (user.energia > enemigo.energia) &&
          formaComer.puedeComerA(enemigo) =>
          (formaComer.digerir(user, enemigo), enemigo.cambiarEstado(DEAD))
        case _ => (user.pasar, enemigo.pasar)
      }
    }
  }

  case class Magia(magia: HabilidadMagica) extends Movimiento {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      user.especie match {
        case Namekusein | Monstruo(_)                      => magia(user, enemigo)
        case _ if user.items.contains(EsferasDelDragon(7)) => magia(user.removerItem(EsferasDelDragon(7)), enemigo)
      }
    }
  }

  type HabilidadMagica = Function2[Guerrero, Guerrero, (Guerrero, Guerrero)]
  case object RevivirOponente extends HabilidadMagica {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      val revivido = enemigo.estado match {
        case KO | DEAD => enemigo.cambiarEstado(Tranca)
        case _         => enemigo.pasar
      }
      (user.pasar, revivido)
    }
  }

  trait AtaqueFisico extends Movimiento {
    def recibirExplosion(guerrero: Guerrero, cuanta: Int) = {
      guerrero.especie match {
        case Androide => guerrero.disminuirEnergia(cuanta * 3)
        case _        => guerrero.disminuirEnergia(cuanta * 2)
      }
    }
  }
  case object MuchosGolpesNinja extends AtaqueFisico {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      (user.especie, enemigo.especie) match {
        case (Humano, Androide)                        => (user.disminuirEnergia(10), enemigo.pasar)
        case (_, _) if user.energia > enemigo.energia  => (user.pasar, enemigo.disminuirEnergia(20))
        case (_, _) if user.energia < enemigo.energia  => (user.disminuirEnergia(20), enemigo.pasar)
        //Si ambos tienen el mismo ki, ambos pierden 20
        case (_, _) if user.energia == enemigo.energia => (user.disminuirEnergia(20), enemigo.disminuirEnergia(20))
      }
    }
  }
  case object Explotar extends AtaqueFisico {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      user.especie match {
        case Androide | Monstruo(_) => {
          val explosion = user.energia
          enemigo.especie match {
            case Namekusein if enemigo.energia < explosion =>
              (user.disminuirEnergia(explosion), enemigo.disminuirEnergia(enemigo.energia - 1))
            case _ => (user.disminuirEnergia(explosion), recibirExplosion(enemigo, explosion))
          }
        }
        case _ => (user.pasar, enemigo.pasar)
      }
    }
  }

  trait AtaqueEnergia extends Movimiento {
    
    def recibirEnergia(guerrero: Guerrero, energia: Int): Guerrero = {
      guerrero.especie match {
        case Androide     => guerrero.aumentarEnergia(energia)
        case Monstruo (_) => guerrero.disminuirEnergia(energia /2)
        case _            => guerrero.disminuirEnergia(energia*2)
      }
    }
  }
  
  case class Onda(energia: Int) extends AtaqueEnergia {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      if (user.energia >= energia)
        (user.disminuirEnergia(energia), recibirEnergia(enemigo, energia))
      else
        (user.pasar, enemigo.pasar)
    }
  }
  case object Genkidama extends AtaqueEnergia {
    def apply(user: Guerrero, enemigo: Guerrero) = {
      (user, recibirEnergia(enemigo, Math.pow(10.toDouble, user.kiExterno.toDouble).toInt))
    }
  }
  
  trait Criterio {
    def evaluar(movimiento: Movimiento, atacante: Guerrero, defensor: Guerrero):Int
  }
  
  object MayorDaño extends Criterio {
    def evaluar(movimiento: Movimiento, atacante: Guerrero, defensor: Guerrero) = {
      val defensorDañado = movimiento(atacante,defensor)._2
      if (defensorDañado.energia < defensor.energia)
        defensor.energia - defensorDañado.energia
      else
        0  //Si lanzo Ondas a un androide, le subo la bateria.
    }
  }
  
  object DerribarEnemigo extends Criterio {
     def evaluar(movimiento: Movimiento, atacante: Guerrero, defensor: Guerrero) = {
       val defensorDañado = movimiento(atacante,defensor)._2
       defensorDañado.estado match {
         case DEAD => 2
         case KO   => 1
         case _    => 0  //Si esta Tranca, bien. Si no hubo cambios, no cumplo el Criterio.
       }
     }
  }
  
  object SacarPocoKi extends Criterio {
    def evaluar(movimiento: Movimiento, atacante: Guerrero, defensor: Guerrero) = {
      val defensorDañado = movimiento(atacante,defensor)._2
      if (defensorDañado.energia < defensor.energia)
        defensorDañado.energia  //A lo sumo es 0, si lo matas.
      else
        0 //Si uso movimientos que no sacan ki, no tiene chiste, no cumplo el Criterio.
    }
  }
  
  object MovimientoTacaño extends Criterio {
    def evaluar(movimiento: Movimiento, atacante: Guerrero, defensor: Guerrero) = {
      val atacanteAfectado = movimiento(atacante,defensor)._1
      if (atacanteAfectado.items.size < atacante.items.size)
        atacanteAfectado.items.size
      else
        0 //No perder items es como usar un movimiento que hace otra cosa menos usar items, no cumplo el Criterio.
    }
  }
  
  object NoMorir extends Criterio {
    def evaluar(movimiento: Movimiento, atacante: Guerrero, defensor: Guerrero) = {
      val atacanteAfectado = movimiento(atacante,defensor)._1
      atacanteAfectado.estado match {
        case DEAD => 0  //No es la idea morir.
        case KO   => 1
        case _    => 3
      }
    }
  }
    
  object VentajaDeKi extends Criterio {
      def evaluar(movimiento: Movimiento, atacante: Guerrero, defensor: Guerrero) = {
        val (atacado,defendido) = movimiento(atacante,defensor)
        (defensor.energia - atacante.energia) match {
          case desventaja if desventaja < 0 => atacado.energia - defendido.energia
          case desventaja if desventaja > 0 => (defendido.energia - atacado.energia) match {
                                                  case diferencia if diferencia > 0 => desventaja - diferencia
                                                  case diferencia if diferencia < 0 => diferencia.*(-1)
                                                }
       }
     }
   }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
   
}