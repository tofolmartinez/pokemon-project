#-------------------------------------------------------------------------------
# These are used to define what the Follower will say when spoken to in general
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# All dialogues with the Music Note animation
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :music_generic, proc { |pkmn, random_val|
  if random_val == 0
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_MUSIC)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} parece querer jugar con {2}"),
      _INTL("{1} está cantando y tarareando."),
      _INTL("{1} está mirando a {2} con expresión feliz."),
      _INTL("{1} se balancea y baila a su antojo."),
      _INTL("¡{1} está saltando despreocupadamente!"),
      _INTL("¡{1} está mostrando su agilidad!"),
      _INTL("¡{1} se mueve alegremente!"),
      _INTL("¡Vaya, de repente {1} se ha puesto a bailar de felicidad!"),
      _INTL("¡{1} sigue el ritmo de {2}!"),
      _INTL("{1} está feliz saltando."),
      _INTL("{1} está jugando mordisqueando el suelo."),
      _INTL("{1} está mordisqueando juguetonamente los pies de {2}"),
      _INTL("¡{1} está siguiendo a {2} muy de cerca!"),
      _INTL("{1} se da la vuelta y mira a {2}."),
      _INTL("¡{1} está trabajando duro para mostrar su poderoso poder!"),
      _INTL("¡Parece que {1} quiere correr!"),
      _INTL("{1} se pasea disfrutando del paisaje."),
      _INTL("¡{1} parece estar disfrutando un poco de esto!"),
      _INTL("¡{1} está alegre!"),
      _INTL("{1} parece estar cantando algo..."),
      _INTL("¡{1} está bailando alegremente!"),
      _INTL("¡{1} se divierte bailando una alegre giga!"),
      _INTL("{1} está tan contento, ¡que se ha puesto a cantar!"),
      _INTL("¡{1} miró hacia arriba y aulló!"),
      _INTL("{1} parece sentirse optimista."),
      _INTL("¡Parece que {1} tiene ganas de bailar!"),
      _INTL("{1} ¡de repente empezó a cantar! Parece que se siente genial."),
      _INTL("¡Parece que {1} quiere bailar con {2}!")
    ]
    value = rand(messages.length)
    case value
    # Special move route to go along with some of the dialogue
    when 3, 9
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 80])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0
      ])
    when 4, 5
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 40])
      FollowingPkmn.move_route([
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    when 6, 17
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 40])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp
      ])
    when 7, 28
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 60])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    when 21, 22
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 50])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# All dialogues with the Angry animation
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :angry_generic, proc { |pkmn, random_val|
  if random_val == 1
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("¡{1} suelta un rugido!"),
      _INTL("¡{1} pone cara de estar enfadado!"),
      _INTL("{1} parece estar enfadado por alguna razón."),
      _INTL("{1} mordisqueó los pies de {2}."),
      _INTL("{1} se giró hacia el otro lado, mostrando una expresión desafiante."),
      _INTL("{1} está intentando intimidar a los enemigos de {2}"),
      _INTL("¡{1} quiere iniciar una pelea!"),
      _INTL("¡{1} está listo para pelear!"),
      _INTL("¡Parece que {1} luchará contra cualquiera ahora mismo!"),
      _INTL("{1} está gruñendo de una forma que suena casi como el habla...")
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when 6, 7, 8
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 25])
      FollowingPkmn.move_route([
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# All dialogues with the Neutral Animation
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :ellipses_generic, proc { |pkmn, random_val|
  if random_val == 2
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} está mirando fijamente hacia abajo."),
      _INTL("{1} está olfateando."),
      _INTL("{1} se concentra profundamente."),
      _INTL("{1} mira a {2} y asiente."),
      _INTL("{1} está mirando fijamente a los ojos de {2}."),
      _INTL("{1} está inspeccionando el área."),
      _INTL("¡{1} está enfocado con una mirada aguda!"),
      _INTL("{1} mira distraídamente a su alrededor."),
      _INTL("¡{1} bostezó muy fuerte!"),
      _INTL("{1} se está relajando cómodamente."),
      _INTL("{1} está centrando su atención en {2}."),
      _INTL("{1} está mirando fijamente a la nada."),
      _INTL("{1} se está concentrando."),
      _INTL("{1} mira a {2} y asiente con la cabeza."),
      _INTL("{1} está mirando las huellas de {2}."),
      _INTL("{1} parece querer jugar y está mirando a {2} expectante."),
      _INTL("{1} parece estar pensando profundamente en algo"),
      _INTL("{1} no está prestando atención a {2}...Parece que está pensando en otra cosa."),
      _INTL("{1} parece que se siente serio."),
      _INTL("{1} parece desinteresado."),
      _INTL("La mente de {1} parece estar en otra parte."),
      _INTL("{1} parece estar observando el entorno en vez de mirar a {2}."),
      _INTL("{1} parece un poco aburrido."),
      _INTL("{1} tiene una mirada intensa."),
      _INTL("{1} está mirando a lo lejos."),
      _INTL("{1} parece estar examinando cuidadosamente la cara de {2}."),
      _INTL("{1} parece intentar comunicarse con sus ojos."),
      _INTL("... {1} ¡parece haber estornudado!"),
      _INTL("... {1} se ha dado cuenta de que los zapatos de {2} están un poco sucios."),
      _INTL("Parece que {1} comió algo extraño, está poniendo una cara rara... "),
      _INTL("Parece que {1} está oliendo algo bueno."),
      _INTL("{1} notó que la bolsa de {2} tiene un poco de suciedad..."),
      _INTL("...... ...... ...... ...... ...... ...... ...... ...... ...... ...... ...... ...... {1} ¡asintió en silencio!")
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when 1, 5, 7, 20, 21
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 35])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnDown
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# All dialogues with the Happy animation
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :happy_generic, proc { |pkmn, random_val|
  if random_val == 3
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} empezó a pinchar a {2}."),
      _INTL("{1} parece muy feliz."),
      _INTL("{1} se abrazó felizmente a {2}."),
      _INTL("{1} está tan feliz que no puede estarse quieto."),
      _INTL("{1} parece que quiere liderar!"),
      _INTL("{1} está avanzando felizmente."),
      _INTL("¡Parece que {1} se siente bien caminando con {2}!"),
      _INTL("{1} está radiante de salud."),
      _INTL("{1} parece muy feliz."),
      _INTL("¡{1} hizo un esfuerzo extra sólo por {2}!"),
      _INTL("{1} está oliendo los aromas del aire circundante."),
      _INTL("¡{1} está saltando de alegría!"),
      _INTL("¡{1} sigue sintiéndose bien!"),
      _INTL("{1} estira su cuerpo y se relaja."),
      _INTL("{1} está haciendo todo lo posible para seguir el ritmo de {2}."),
      _INTL("{1} está felizmente abrazado a {2}"),
      _INTL("¡{1} está lleno de energía!"),
      _INTL("¡{1} está tan contento que no puede estarse quieto!"),
      _INTL("{1} está deambulando y escuchando los diferentes sonidos."),
      _INTL("{1} le da a {2} una mirada feliz y una sonrisa."),
      _INTL("¡{1} ha empezado a respirar agitadamente por la nariz!"),
      _INTL("{1} está temblando de impaciencia!"),
      _INTL("{1} está tan contento que ha empezado a rodar"),
      _INTL("{1} parece encantado de recibir atención de {2}."),
      _INTL("{1} parece muy contento de que {2} se fije en él"),
      _INTL("¡{1} empezó a retorcer todo su cuerpo de emoción!"),
      _INTL("¡Parece que {1} apenas puede evitar abrazar a {2}!"),
      _INTL("{1} se mantiene cerca de los pies de {2}.")
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when 3
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 45])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    when 11, 16, 17, 24
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 40])
      FollowingPkmn.move_route([
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# All dialogues with the Heart animation
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :heart_generic, proc { |pkmn, random_val|
  if random_val == 4
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HEART)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} de repente empezó a caminar más cerca de {2}."),
      _INTL("¡Guau! {1} de repente abrazó a {2}."),
      _INTL("{1} se está frotando contra {2}."),
      _INTL("{1} se mantiene cerca de {2}."),
      _INTL("{1} se sonrojó."),
      _INTL("¡A {1} le encanta pasar tiempo con {2}!"),
      _INTL("¡De repente {1} está juguetón!"),
      _INTL("¡{1} se frota contra las piernas de {2}!"),
      _INTL("¡{1} está mirando a {2} con adoración!"),
      _INTL("{1} parece querer algo de afecto de {2}."),
      _INTL("{1} parece querer algo de atención de {2}."),
      _INTL("{1} parece feliz viajando con {2}."),
      _INTL("{1} parece sentir afecto por {2}."),
      _INTL("{1} está mirando a {2} con ojos cariñosos."),
      _INTL("{1} parece que quiere una golosina de {2}."),
      _INTL("¡Parece que {1} quiere que {2} lo acaricie!"),
      _INTL("{1} se está frotando contra {2} cariñosamente."),
      _INTL("{1} golpea suavemente su cabeza contra la mano de {2}."),
      _INTL("{1} se da la vuelta y mira a {2} expectante."),
      _INTL("{1} mira a {2} con ojos confiados."),
      _INTL("{1} parece estar suplicando a {2} algo de afecto"),
      _INTL("¡{1} imitó a {2}!")
    ]
    value = rand(messages.length)
    case value
    when 1, 6,
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 10])
      FollowingPkmn.move_route([
        PBMoveRoute::Jump, 0, 0
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# All dialogues with no animation
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :generic,  proc { |pkmn, random_val|
  if random_val == 5
    messages = [
      _INTL("¡{1} giró en círculo!"),
      _INTL("{1} lanzó un grito de batalla."),
      _INTL("¡{1} está al acecho!"),
      _INTL("{1} está de pie pacientemente."),
      _INTL("{1} está mirando alrededor inquieto."),
      _INTL("{1} está deambulando."),
      _INTL("{1} bosteza ruidosamente"),
      _INTL("{1} está constantemente hurgando en el suelo alrededor de los pies de {2}."),
      _INTL("{1} está mirando a {2} y sonriendo."),
      _INTL("{1} está mirando fijamente a lo lejos."),
      _INTL("{1} sigue el ritmo de {2}."),
      _INTL("{1} parece satisfecho consigo mismo."),
      _INTL("¡{1} todavía va fuerte!"),
      _INTL("{1} camina sincronizado con {2}."),
      _INTL("{1} empezó a girar en círculos."),
      _INTL("{1} mira a {2} con expectación."),
      _INTL("{1} se cayó y parece un poco avergonzado."),
      _INTL("{1} está esperando a ver qué hace {2}."),
      _INTL("{1} está mirando tranquilamente a {2}."),
      _INTL("{1} está mirando a {2} por algún tipo de señal."),
      _INTL("{1} se queda en su sitio, esperando a que {2} haga un movimiento."),
      _INTL("{1} obedientemente se sentó a los pies de {2}."),
      _INTL("¡{1} saltó sorprendido!"),
      _INTL("¡{1} saltó un poco!")
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when 0
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 15])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown
      ])
    when 2, 4
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 35])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnDown
      ])
    when 14
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 50])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown
      ])
    when 22, 23
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 10])
      FollowingPkmn.move_route([
        PBMoveRoute::Jump, 0, 0
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
