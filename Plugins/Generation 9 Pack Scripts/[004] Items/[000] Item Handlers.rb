################################################################################
# 
# Updates to old item handlers (overworld use).
# 
################################################################################


#===============================================================================
# Awakening, Chesto Berry, Blue Flute
#===============================================================================
# Adds Drowsiness as a status that may be healed.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:AWAKENING, proc { |item, qty, pkmn, scene|
  if pkmn.fainted? || ![:SLEEP, :DROWSY].include?(pkmn.status)
    scene.pbDisplay(_INTL("No tendrá ningún efecto."))
    next false
  end
  case pkmn.status
  when :SLEEP  then msg = _INTL("{1} se despertó.", pkmn.name)
  when :DROWSY then msg = _INTL("{1} se puso alerta de nuevo.", pkmn.name)
  end
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(msg)
  next true
})

ItemHandlers::UseOnPokemon.copy(:AWAKENING, :CHESTOBERRY, :BLUEFLUTE, :POKEFLUTE)

#===============================================================================
# Ice Heal, Aspear Berry
#===============================================================================
# Adds Frostbite as a status that may be healed.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:ICEHEAL, proc { |item, qty, pkmn, scene|
  if pkmn.fainted? || ![:FROZEN, :FROSTBITE].include?(pkmn.status)
    scene.pbDisplay(_INTL("No tendrá ningún efecto."))
    next false
  end
  case pkmn.status
  when :FROZEN    then msg = _INTL("{1} se descongeló.", pkmn.name)
  when :FROSTBITE then msg = _INTL("Se curó la congelación de {1}.", pkmn.name)
  end
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(msg)
  next true
})

ItemHandlers::UseOnPokemon.copy(:ICEHEAL, :ASPEARBERRY)

#===============================================================================
# Reveal Glass
#===============================================================================
# Adds compatibility with Enamorus.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:REVEALGLASS, proc { |item, qty, pkmn, scene|
  if !pkmn.isSpecies?(:TORNADUS) &&
     !pkmn.isSpecies?(:THUNDURUS) &&
     !pkmn.isSpecies?(:LANDORUS) &&
     !pkmn.isSpecies?(:ENAMORUS)
    scene.pbDisplay(_INTL("No tuvo ningún efecto."))
    next false
  elsif pkmn.fainted?
    scene.pbDisplay(_INTL("No se puede usar en un Pokémon debilitado."))
    next false
  end
  newForm = (pkmn.form == 0) ? 1 : 0
  pkmn.setForm(newForm) {
    scene.pbRefresh
    scene.pbDisplay(_INTL("¡{1} cambió de forma!", pkmn.name))
  }
  next true
})

#===============================================================================
# Ability Patch
#===============================================================================
# Adds the ability to switch from a Hidden Ability.
#-------------------------------------------------------------------------------
ItemHandlers::UseOnPokemon.add(:ABILITYPATCH, proc { |item, qty, pkmn, scene|
  if scene.pbConfirm(_INTL("¿Quieres cambiar la habilidad de {1}?", pkmn.name))
    current_abi = pkmn.ability_index
    abils = pkmn.getAbilityList
    new_ability_id = nil
    abils.each { |a| new_ability_id = a[0] if (current_abi < 2 && a[1] == 2) || (current_abi == 2 && a[1] == 0) }
    if !new_ability_id || pkmn.isSpecies?(:ZYGARDE)
      scene.pbDisplay(_INTL("No tendrá ningún efecto."))
      next false
    end
    new_ability_name = GameData::Ability.get(new_ability_id).name
    pkmn.ability_index = current_abi < 2 ? 2 : 0
    pkmn.ability = nil
    scene.pbRefresh
    scene.pbDisplay(_INTL("¡La habilidad de {1} ha cambiado! ¡Su habilidad es ahora {2}!",
       pkmn.name, new_ability_name))
    next true
  end
  next false
})


################################################################################
# 
# Updates to old battle item handlers (used from the bag).
# 
################################################################################


#===============================================================================
# Awakening, Chesto Berry, Blue Flute
#===============================================================================
# Adds Drowsiness as a status that may be healed.
#-------------------------------------------------------------------------------
ItemHandlers::CanUseInBattle.add(:AWAKENING, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:SLEEP, pokemon, scene, showMessages) ||
       pbBattleItemCanCureStatus?(:DROWSY, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:AWAKENING, :CHESTOBERRY)

ItemHandlers::CanUseInBattle.add(:BLUEFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if battler&.hasActiveAbility?(:SOUNDPROOF)
    scene.pbDisplay(_INTL("No tendrá ningún efecto.")) if showMessages
    next false
  end
  next pbBattleItemCanCureStatus?(:SLEEP, pokemon, scene, showMessages) ||
       pbBattleItemCanCureStatus?(:DROWSY, pokemon, scene, showMessages)
})

ItemHandlers::BattleUseOnPokemon.add(:AWAKENING, proc { |item, pokemon, battler, choices, scene|
  oldStatus = pokemon.status
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  case oldStatus
  when :SLEEP  then scene.pbDisplay(_INTL("{1} se despertó.", name))
  when :DROWSY then scene.pbDisplay(_INTL("{1} se puso alerta de nuevo.", name))
  end
})

ItemHandlers::BattleUseOnPokemon.copy(:AWAKENING, :CHESTOBERRY, :BLUEFLUTE)

#===============================================================================
# Poke Flute
#===============================================================================
# Adds Drowsiness as a status that may be healed.
#-------------------------------------------------------------------------------
ItemHandlers::CanUseInBattle.add(:POKEFLUTE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if battle.allBattlers.none? { |b| [:SLEEP, :DROWSY].include?(b.status) && !b.hasActiveAbility?(:SOUNDPROOF) }
    scene.pbDisplay(_INTL("No tendrá ningún efecto.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::UseInBattle.add(:POKEFLUTE, proc { |item, battler, battle|
  battle.allBattlers.each do |b|
    b.pbCureStatus(false) if [:SLEEP, :DROWSY].include?(b.status) && !b.hasActiveAbility?(:SOUNDPROOF)
  end
  battle.pbDisplay(_INTL("¡La melodía despertó a todos los Pokémon!"))
})

#===============================================================================
# Ice Heal, Aspear Berry
#===============================================================================
# Adds Frostbite as a status that may be healed.
#-------------------------------------------------------------------------------
ItemHandlers::CanUseInBattle.add(:ICEHEAL, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  next pbBattleItemCanCureStatus?(:FROZEN, pokemon, scene, showMessages) ||
       pbBattleItemCanCureStatus?(:FROSTBITE, pokemon, scene, showMessages)
})

ItemHandlers::CanUseInBattle.copy(:ICEHEAL, :ASPEARBERRY)

ItemHandlers::BattleUseOnPokemon.add(:ICEHEAL, proc { |item, pokemon, battler, choices, scene|
  oldStatus = pokemon.status
  pokemon.heal_status
  battler&.pbCureStatus(false)
  name = (battler) ? battler.pbThis : pokemon.name
  scene.pbRefresh
  case oldStatus
  when :FROZEN    then scene.pbDisplay(_INTL("{1} se descongeló.", name))
  when :FROSTBITE then scene.pbDisplay(_INTL("Se curó la congelación de {1}.", name))
  end
})

ItemHandlers::BattleUseOnPokemon.copy(:ICEHEAL, :ASPEARBERRY)


################################################################################
# 
# Updates to old battle item handlers (held items).
# 
################################################################################


#===============================================================================
# Lum Berry
#===============================================================================
# Adds Drowsy/Frostbite as statuses that may be healed.
#-------------------------------------------------------------------------------
Battle::ItemEffects::StatusCure.add(:LUMBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.status == :NONE &&
                  battler.effects[PBEffects::Confusion] == 0
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    oldStatus = battler.status
    oldConfusion = (battler.effects[PBEffects::Confusion] > 0)
    battler.pbCureStatus(forced)
    battler.pbCureConfusion
    if forced
      battle.pbDisplay(_INTL("{1} ya no está confuso.", battler.pbThis)) if oldConfusion
    else
      case oldStatus
      when :SLEEP
        battle.pbDisplay(_INTL("¡El {1} de {2} le despertó!", battler.pbThis, itemName))
      when :POISON
        battle.pbDisplay(_INTL("¡El {2} de {1} curó su envenenamiento!", battler.pbThis, itemName))
      when :BURN
        battle.pbDisplay(_INTL("¡El {2} de {1} curó su quemadura!", battler.pbThis, itemName))
      when :PARALYSIS
        battle.pbDisplay(_INTL("¡El {2} de {1} ha curado su parálisis!", battler.pbThis, itemName))
      when :FROZEN
        battle.pbDisplay(_INTL("¡El {2} de {1} le descongeló!", battler.pbThis, itemName))
	  when :DROWSY
        battle.pbDisplay(_INTL("¡El {2} de {1} lo puso en alerta de nuevo!", battler.pbThis, itemName))
	  when :FROSTBITE
        battle.pbDisplay(_INTL("¡El {2} de {1} curó su congelación!", battler.pbThis, itemName))
      end
      if oldConfusion
        battle.pbDisplay(_INTL("¡El {2} de {1} le sacó de su confusión!", battler.pbThis, itemName))
      end
    end
    next true
  }
)

#===============================================================================
# Chesto Berry
#===============================================================================
# Adds Drowsiness as a status that may be healed.
#-------------------------------------------------------------------------------
Battle::ItemEffects::StatusCure.add(:CHESTOBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if ![:SLEEP, :DROWSY].include?(battler.status)
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    case battler.status
    when :SLEEP  then msg = _INTL("¡El {1} de {2} le despertó!", battler.pbThis, itemName)
    when :DROWSY then msg = _INTL("¡El {2} de {1} lo puso en alerta de nuevo!", battler.pbThis, itemName)
    end
    battler.pbCureStatus(forced)
    battle.pbDisplay(msg) if !forced
    next true
  }
)

#===============================================================================
# Aspear Berry
#===============================================================================
# Adds Frostbite as a status that may be healed.
#-------------------------------------------------------------------------------
Battle::ItemEffects::StatusCure.add(:ASPEARBERRY,
  proc { |item, battler, battle, forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if ![:FROZEN, :FROSTBITE].include?(battler.status)
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    case battler.status
    when :FROZEN    then msg = _INTL("¡El {2} de {1} le descongeló!", battler.pbThis, itemName)
    when :FROSTBITE then msg = _INTL("¡El {2} de {1} curó su congelación!", battler.pbThis, itemName)
    end
    battler.pbCureStatus(forced)
    battle.pbDisplay(msg) if !forced
    next true
  }
)

#===============================================================================
# Red Card
#===============================================================================
# Adds Guard Dog immunity.
#-------------------------------------------------------------------------------
Battle::ItemEffects::AfterMoveUseFromTarget.add(:REDCARD,
  proc { |item, battler, user, move, switched_battlers, battle|
    next if !switched_battlers.empty? || user.fainted?
    newPkmn = battle.pbGetReplacementPokemonIndex(user.index, true)
    next if newPkmn < 0
    battle.pbCommonAnimation("UseItem", battler)
    battle.pbDisplay(_INTL("¡{1} sostuvo su {2} contra {3}!",
       battler.pbThis, battler.itemName, user.pbThis(true)))
    battler.pbConsumeItem
    next if user.effects[PBEffects::Commander]
    if user.hasActiveAbility?([:SUCTIONCUPS, :GUARDDOG]) && !battle.moldBreaker
      battle.pbShowAbilitySplash(user)
      if Battle::Scene::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("¡{1} se ancla a sí mismo!", user.pbThis))
      else
        battle.pbDisplay(_INTL("¡{1} se ancla con {2}!", user.pbThis, user.abilityName))
      end
      battle.pbHideAbilitySplash(user)
      next
    end
    if user.effects[PBEffects::Ingrain]
      battle.pbDisplay(_INTL("¡{1} se ancló con sus raíces!", user.pbThis))
      next
    end
    battle.pbRecallAndReplace(user.index, newPkmn, true)
    battle.pbDisplay(_INTL("¡{1} fue arrastrado!", user.pbThis))
    battle.pbClearChoice(user.index)
    switched_battlers.push(user.index)
    battle.moldBreaker = false
    battle.pbOnBattlerEnteringBattle(user.index)
  }
)

#===============================================================================
# Quick Claw
#===============================================================================
# Cannot trigger if the user has Mycelium Might and used a status move.
#-------------------------------------------------------------------------------
Battle::ItemEffects::PriorityBracketChange.add(:QUICKCLAW,
  proc { |item, battler, battle|
    if battler.hasActiveAbility?(:MYCELIUMMIGHT)
      pri = Battle::AbilityEffects.triggerPriorityBracketChange(battler.ability, battler, battle)
      next pri if pri != 0
    end
    next 1 if battle.pbRandom(100) < 20
  }
)