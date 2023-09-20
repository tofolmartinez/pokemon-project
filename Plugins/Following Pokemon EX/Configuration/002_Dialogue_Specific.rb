#-------------------------------------------------------------------------------
# These are used to define what the Follower will say when spoken to under
# specific conditions like Status or Weather or Map names
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Amie Compatibility
#-------------------------------------------------------------------------------
if defined?(PkmnAR)
  EventHandlers.add(:following_pkmn_talk, :amie, proc { |_pkmn, _random_val|
    cmd = pbMessage(_INTL("¿Qué te gustaría hacer?"), [
      _INTL("Jugar"),
      _INTL("Hablar"),
      _INTL("Cancelar")
    ])
    PkmnAR.show if cmd == 0
    next true if [0, 2].include?(cmd)
  })
end
#-------------------------------------------------------------------------------
# Special Dialogue when statused
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :status, proc { |pkmn, _random_val|
  case pkmn.status
  when :POISON
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_POISON)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    pbMessage(_INTL("{1} está temblando por los efectos del veneno.", pkmn.name))
  when :BURN
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    pbMessage(_INTL("La quemadura de {1} parece dolorosa.", pkmn.name))
  when :FROZEN
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    pbMessage(_INTL("{1} parece muy frío. ¡Está congelado!", pkmn.name))
  when :SLEEP
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    pbMessage(_INTL("{1} parece muy cansado.", pkmn.name))
  when :PARALYSIS
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    pbMessage(_INTL("{1} está inmóvil y crispado.", pkmn.name))
  end
  next true if pkmn.status != :NONE
})
#-------------------------------------------------------------------------------
# Specific message if the map has the Pokemon Lab metadata flag
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :pokemon_lab, proc { |pkmn, _random_val|
  if $game_map.metadata&.has_flag?("PokemonLab")
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} está tocando algún tipo de interruptor."),
      _INTL("¡{1} tiene una cuerda en la boca!"),
      _INTL("{1} parece querer tocar la maquinaria.")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message if the map name has the players name in it like the
# Player's House
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :player_house, proc { |pkmn, _random_val|
  if $game_map.name.include?($player.name)
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} está olfateando por la habitación."),
      _INTL("{1} nota que la madre de {2} está cerca."),
      _INTL("{1} parece querer quedarse en casa.")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message if the map has Pokecenter metadata flag
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :pokemon_center, proc { |pkmn, _random_val|
  if $game_map.metadata&.has_flag?("PokeCenter")
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} parece feliz de ver a la enfermera."),
      _INTL("{1} se ve un poco mejor sólo estando en el Centro Pokémon."),
      _INTL("{1} parece fascinado por la maquinaria curativa."),
      _INTL("Parece que {1} quiere echarse una siesta."),
      _INTL("{1} saludó a la enfermera."),
      _INTL("{1} observa a {2} con una mirada juguetona."),
      _INTL("{1} parece estar completamente a gusto."),
      _INTL("{1} se está poniendo cómodo."),
      _INTL("Hay una expresión de satisfacción en la cara de {1}.")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message if the map has the Gym metadata flag
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :gym, proc { |pkmn, _random_val|
  if $game_map.metadata&.has_flag?("GymMap")
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("¡{1} parece ansioso por luchar!"),
      _INTL("{1} está mirando a {2} con un brillo decidido en sus ojos."),
      _INTL("{1} está intentando intimidar a los otros entrenadores."),
      _INTL("{1} confía en {2} para idear una estrategia ganadora."),
      _INTL("{1} está vigilando al líder del gimnasio."),
      _INTL("{1} está listo para pelear con alguien."),
      _INTL("Parece que {1} se está preparando para un gran enfrentamiento"),
      _INTL("¡{1} quiere mostrar lo fuerte que es!"),
      _INTL("{1} está... ¿haciendo ejercicios de calentamiento?"),
      _INTL("{1} está gruñendo tranquilamente en contemplación...")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message when the weather is Storm. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :storm_weather, proc { |pkmn, _random_val|
  if :Storm == $game_screen.weather_type
    if pkmn.hasType?(:ELECTRIC)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} está mirando al cielo."),
        _INTL("La tormenta parece estar excitando a {1}."),
        _INTL("¡{1} miró al cielo y gritó fuerte!"),
        _INTL("¡La tormenta sólo parece estar energizando a {1}!"),
        _INTL("¡{1} está feliz corriendo y saltando en círculos!"),
        _INTL("¡Los rayos no molestan a {1} en absoluto!")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} está mirando al cielo."),
        _INTL("La tormenta parece estar poniendo a {1} un poco nervioso."),
        _INTL("¡El relámpago asustó a {1}!"),
        _INTL("La lluvia no parece molestar mucho a {1}."),
        _INTL("El tiempo parece poner nervioso a {1}."),
        _INTL("¡El rayo asustó a {1} y se acurrucó con {2}!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message when the weather is Snowy. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :snow_weather, proc { |pkmn, _random_val|
  if :Snow == $game_screen.weather_type
    if pkmn.hasType?(:ICE)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} está viendo caer la nieve."),
        _INTL("¡{1} está encantado con la nieve!"),
        _INTL("{1} está mirando al cielo con una sonrisa."),
        _INTL("La nieve parece haber puesto a {1} de buen humor."),
        _INTL("¡{1} está alegre por el frío!")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} está viendo caer la nieve"),
        _INTL("{1} está mordisqueando los copos de nieve que caen."),
        _INTL("{1} quiere atrapar un copo de nieve en su boca."),
        _INTL("{1} está fascinado por la nieve."),
        _INTL("¡Los dientes de {1} castañetean!"),
        _INTL("{1} hizo su cuerpo un poco más pequeño debido al frío...")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message when the weather is Blizzard. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :blizzard_weather, proc { |pkmn, _random_val|
  if :Blizzard == $game_screen.weather_type
    if pkmn.hasType?(:ICE)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} está viendo caer el granizo."),
        _INTL("A {1} no le molesta nada el granizo."),
        _INTL("{1} está mirando al cielo con una sonrisa."),
        _INTL("El granizo parece haber puesto a {1} de buen humor."),
        _INTL("{1} está royendo un trozo de granizo.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("¡A {1} le está cayendo granizo!"),
        _INTL("{1} quiere evitar el granizo."),
        _INTL("El granizo está golpeando dolorosamente a {1}."),
        _INTL("{1} parece infeliz."),
        _INTL("{1} está temblando como una hoja!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message when the weather is Sandstorm. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :sandstorm_weather, proc { |pkmn, _random_val|
  if :Sandstorm == $game_screen.weather_type
    if [:ROCK, :GROUND].any? { |type| pkmn.hasType?(type) }
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} está cubierto de arena."),
        _INTL("¡El tiempo no parece molestar a {1} en absoluto!"),
        _INTL("¡La arena no puede frenar a {1}!"),
        _INTL("{1} está disfrutando del tiempo.")
      ]
    elsif pkmn.hasType?(:STEEL)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} está cubierto de arena, pero no parece importarle"),
        _INTL("A {1} no parece molestarle la tormenta de arena."),
        _INTL("La arena no frena a {1}."),
        _INTL("A {1} no parece importarle el tiempo.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} está cubierto de arena..."),
        _INTL("¡{1} escupió una bocanada de arena!"),
        _INTL("{1} está bizqueando a través de la tormenta de arena."),
        _INTL("La arena parece molestar a {1}.")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message if the map has the Forest metadata flag
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :forest_map, proc { |pkmn, _random_val|
  if $game_map.metadata&.has_flag?("Forest")
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_MUSIC)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    if [:BUG, :GRASS].any? { |type| pkmn.hasType?(type) }
      messages = [
        _INTL("{1} parece muy interesado en los árboles"),
        _INTL("{1} parece disfrutar con el zumbido de los Pokémon bicho."),
        _INTL("{1} está saltando inquieto por el bosque.")
      ]
    else
      messages = [
        _INTL("{1} parece muy interesado en los árboles"),
        _INTL("{1} parece disfrutar con el zumbido de los Pokémon bicho."),
        _INTL("{1} está saltando inquieto por el bosque."),
        _INTL("{1} está deambulando y escuchando los diferentes sonidos."),
        _INTL("{1} está mordisqueando la hierba."),
        _INTL("{1} está paseando y disfrutando del paisaje del bosque."),
        _INTL("{1} está jugando, arrancando trozos de hierba."),
        _INTL("{1} está mirando la luz que entra a través de los árboles."),
        _INTL("¡{1} está jugando con una hoja!"),
        _INTL("{1} parece estar escuchando el susurro de las hojas."),
        _INTL("{1} está perfectamente quieto y podría estar imitando a un árbol..."),
        _INTL("¡{1} se enredó en las ramas y casi se cae!"),
        _INTL("¡{1} se sorprendió al ser golpeado por una rama!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message when the weather is Rainy. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :rainy_weather, proc { |pkmn, _random_val|
  if [:Rain, :HeavyRain].include?($game_screen.weather_type)
    if pkmn.hasType?(:FIRE) || pkmn.hasType?(:GROUND) || pkmn.hasType?(:ROCK)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} parece muy alterado por el tiempo."),
        _INTL("{1} está temblando..."),
        _INTL("A {1} no parece gustarle estar mojado..."),
        _INTL("{1} intenta sacudirse para secarse..."),
        _INTL("{1} se acercó a {2} para estar más cómodo."),
        _INTL("{1} está mirando al cielo y frunciendo el ceño."),
        _INTL("{1} parece tener dificultades para mover su cuerpo.")
      ]
    elsif pkmn.hasType?(:WATER) || pkmn.hasType?(:GRASS)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} parece estar disfrutando del tiempo"),
        _INTL("¡{1} parece estar feliz por la lluvia!"),
        _INTL("¡{1} parece estar muy sorprendido de que esté lloviendo!"),
        _INTL("¡{1} sonrió felizmente a {2}!"),
        _INTL("{1} está mirando las nubes de lluvia."),
        _INTL("Las gotas de lluvia siguen cayendo sobre {1}."),
        _INTL("{1} está mirando hacia arriba con la boca abierta.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} está mirando al cielo."),
        _INTL("{1} parece un poco sorprendido de ver llover."),
        _INTL("{1} sigue intentando sacudirse para secarse."),
        _INTL("La lluvia no parece molestar mucho a {1}."),
        _INTL("¡{1} está jugando en un charco!"),
        _INTL("¡{1} se resbala en el agua y casi se cae!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message if the map has Beach metadata flag
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :beach_map, proc { |pkmn, _random_val|
  if $game_map.metadata&.has_flag?("Beach")
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} parece disfrutar del paisaje"),
      _INTL("{1} parece disfrutar del sonido de las olas moviendo la arena."),
      _INTL("¡Parece que {1} quiere nadar!"),
      _INTL("{1} apenas puede apartar la vista del océano."),
      _INTL("{1} está mirando anhelante al agua."),
      _INTL("{1} intenta empujar a {2} hacia el agua."),
      _INTL("¡{1} está emocionado mirando el mar!"),
      _INTL("¡{1} está feliz mirando las olas!"),
      _INTL("¡{1} está jugando en la arena!"),
      _INTL("{1} está mirando las huellas de {2} en la arena."),
      _INTL("{1} está rodando por la arena.")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
# Specific message when the weather is Sunny. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
EventHandlers.add(:following_pkmn_talk, :sunny_weather, proc { |pkmn, _random_val|
  if :Sun == $game_screen.weather_type
    if pkmn.hasType?(:GRASS)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} parece encantado de estar al sol"),
        _INTL("{1} está tomando el sol."),
        _INTL("La brillante luz del sol no parece molestar a {1} en absoluto."),
        _INTL("¡{1} envió una nube de esporas en forma de anillo al aire!"),
        _INTL("{1} ha estirado su cuerpo y se está relajando a la luz del sol."),
        _INTL("{1} desprende un aroma floral.")
      ]
    elsif pkmn.hasType?(:FIRE)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("¡{1} parece estar contento por el buen tiempo!"),
        _INTL("La brillante luz del sol no parece molestar a {1} en absoluto."),
        _INTL("¡{1} parece encantado con la luz del sol!"),
        _INTL("{1} sopló una bola de fuego."),
        _INTL("¡{1} está exhalando fuego!"),
        _INTL("¡{1} está caliente y alegre!")
      ]
    elsif pkmn.hasType?(:DARK)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} está mirando al cielo."),
        _INTL("{1} parece personalmente ofendido por la luz del sol."),
        _INTL("El sol brillante parece molestar a {1}."),
        _INTL("{1} parece molesto por alguna razón."),
        _INTL("{1} está intentando permanecer a la sombra de {2}."),
        _INTL("{1} sigue buscando refugio de la luz del sol.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} entrecierra los ojos bajo el sol"),
        _INTL("{1} está empezando a sudar."),
        _INTL("{1} parece un poco incómodo con este tiempo."),
        _INTL("{1} parece un poco acalorado."),
        _INTL("{1} parece muy acalorado..."),
        _INTL("{1} protegió su visión contra la luz centelleante.")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $player.name))
    next true
  end
})
#-------------------------------------------------------------------------------
