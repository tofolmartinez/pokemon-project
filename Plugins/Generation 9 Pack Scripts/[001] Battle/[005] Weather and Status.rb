################################################################################
# 
# New GameData::Status additions.
# 
################################################################################


#-------------------------------------------------------------------------------
# Drowsy
#-------------------------------------------------------------------------------
# This status has the following effects:
#  -The user has a 33% chance to be unable to act each turn. 66% in Snow/Hail.
#  -The user takes 33% more damage while Drowsy.
#  -Drowziness may end naturally after 2-3 turns.
#  -Drowsiness may end early if a move with the "ElectrocuteUser" flag is used on or by the user.
#  -Is applied/blocked/healed/reduced in duration by the same things that interact with the Sleep status.
#-------------------------------------------------------------------------------
GameData::Status.register({
  :id            => :DROWSY,
  :name          => _INTL("Somnoliento"),
  :animation     => "Drowsy",
  :icon_position => 5
})

#-------------------------------------------------------------------------------
# Frostbite
#-------------------------------------------------------------------------------
# This has the following effects:
#  -The user takes damage at the end of each round equal to 1/16th their max HP.
#  -Damage dealt by the user's special attacks is halved.
#  -Frostbite may end early if a move with the "ThawsUser" flag is used on or by the user.
#  -Is applied/blocked/healed by the same things that interact with the Frozen status.
#-------------------------------------------------------------------------------
GameData::Status.register({
  :id            => :FROSTBITE,
  :name          => _INTL("Helado"),
  :animation     => "Frostbite",
  :icon_position => 6
})


################################################################################
# 
# Battle class changes.
# 
################################################################################


class Battle
  #-----------------------------------------------------------------------------
  # Aliased to display the correct weather start messages for Snow.
  #-----------------------------------------------------------------------------
  alias paldea_pbStartWeather pbStartWeather
  def pbStartWeather(user, newWeather, fixedDuration = false, showAnim = true)
    return if @field.weather == newWeather
    if newWeather == :Hail && Settings::HAIL_WEATHER_TYPE > 0
      @field.weather = newWeather
      duration = (fixedDuration) ? 5 : -1
      if duration > 0 && user && user.itemActive?
        duration = Battle::ItemEffects.triggerWeatherExtender(user.item, @field.weather, duration, user, self)
      end
      @field.weatherDuration = duration
      weather_data = GameData::BattleWeather.try_get(@field.weather)
      pbCommonAnimation(weather_data.animation) if showAnim && weather_data
      pbHideAbilitySplash(user) if user
      if Settings::HAIL_WEATHER_TYPE == 2
        pbDisplay(_INTL("¡Una fuerte tormenta de granizo brama!"))
      else
        pbDisplay(_INTL("¡Empezó a nevar!"))
      end
      allBattlers.each { |b| b.pbCheckFormOnWeatherChange }
      pbEndPrimordialWeather
    else
      paldea_pbStartWeather(user, newWeather, fixedDuration, showAnim)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to display the correct weather end messages for Snow.
  #-----------------------------------------------------------------------------
  alias paldea_pbEOREndWeather pbEOREndWeather
  def pbEOREndWeather(priority)
    if @field.weather == :Hail && Settings::HAIL_WEATHER_TYPE > 0
      @field.weatherDuration -= 1 if @field.weatherDuration > 0
      if @field.weatherDuration == 0
        if Settings::HAIL_WEATHER_TYPE == 2
          pbDisplay(_INTL("La granizada terminó."))
        else
          pbDisplay(_INTL("La nieve se detuvo."))
        end
        @field.weather = :None
        allBattlers.each { |battler| battler.pbCheckFormOnWeatherChange }
        pbStartWeather(nil, @field.defaultWeather) if @field.defaultWeather != :None
        return if @field.weather == :None
      end
      weather_data = GameData::BattleWeather.try_get(@field.weather)
      pbCommonAnimation(weather_data.animation) if weather_data && !@weather
      pbDisplay(_INTL("Está cayendo granizo.")) if Settings::HAIL_WEATHER_TYPE == 2
      priority.each do |battler|
        if battler.abilityActive?
          Battle::AbilityEffects.triggerEndOfRoundWeather(battler.ability, battler.effectiveWeather, battler, self)
          battler.pbFaint if battler.fainted?
        end
        pbEORWeatherDamage(battler)
      end
    else
      paldea_pbEOREndWeather(priority)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Aliased so Hail doesn't cause end of round damage if set to Snow weather.
  #-----------------------------------------------------------------------------
  alias paldea_pbEORWeatherDamage pbEORWeatherDamage
  def pbEORWeatherDamage(battler)
    return if Settings::HAIL_WEATHER_TYPE == 1 &&
              !battler.fainted? && battler.effectiveWeather == :Hail
    paldea_pbEORWeatherDamage(battler)
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to add end of round damage from Frostbite.
  #-----------------------------------------------------------------------------
  alias paldea_pbEORStatusProblemDamage pbEORStatusProblemDamage
  def pbEORStatusProblemDamage(priority)
    paldea_pbEORStatusProblemDamage(priority)
    priority.each do |battler|
      next if battler.status != :FROSTBITE || !battler.takesIndirectDamage?
      battler.droppedBelowHalfHP = false
      dmg = battler.totalhp / 16
      battler.pbContinueStatus { battler.pbReduceHP(dmg, false) }
      battler.pbItemHPHealCheck
      battler.pbAbilitiesOnDamageTaken
      battler.pbFaint if battler.fainted?
      battler.droppedBelowHalfHP = false
    end
  end
end


################################################################################
# 
# Battle::Battler class changes.
# 
################################################################################


class Battle::Battler
  #-----------------------------------------------------------------------------
  # Drowsy utilities. 
  #-----------------------------------------------------------------------------
  def drowsy?
    return pbHasStatus?(:DROWSY)
  end

  def pbCanDrowse?(user, showMessages, move = nil, ignoreStatus = false)
    return pbCanInflictStatus?(:DROWSY, user, showMessages, move, ignoreStatus)
  end
  
  def pbCanDrowseSynchronize?(target)
    return pbCanSynchronizeStatus?(:DROWSY, target)
  end

  def pbDrowse(user = nil, msg = nil)
    pbInflictStatus(:DROWSY, pbSleepDuration + 1, msg, user)
  end

  def pbDrowseSelf(msg = nil, duration = -1)
    pbInflictStatus(:DROWSY, pbSleepDuration(duration) + 1, msg)
  end

  #-----------------------------------------------------------------------------
  # Frostbite utilities. 
  #-----------------------------------------------------------------------------
  def frostbite?
    return pbHasStatus?(:FROSTBITE)
  end

  def pbCanFrostbite?(user, showMessages, move = nil)
    return pbCanInflictStatus?(:FROSTBITE, user, showMessages, move)
  end

  def pbCanFrostbiteSynchronize?(target)
    return pbCanSynchronizeStatus?(:FROSTBITE, target)
  end

  def pbFrostbite(user = nil, msg = nil)
    pbInflictStatus(:FROSTBITE, 0, msg, user)
  end

  #-----------------------------------------------------------------------------
  # Aliased to check for Drowsy/Frostbite. 
  #-----------------------------------------------------------------------------
  alias paldea_pbHasStatus? pbHasStatus?
  def pbHasStatus?(checkStatus)
    ret = paldea_pbHasStatus?(checkStatus)
    return ret if ret
    case checkStatus
    when :SLEEP
      return true if @status == :DROWSY && Settings::SLEEP_EFFECTS_CAUSE_DROWSY
    when :FROZEN
      return true if @status == :FROSTBITE && Settings::FREEZE_EFFECTS_CAUSE_FROSTBITE
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # Aliased to check for Drowsy/Frostbite immunities.
  # -Effects that make a battler immune to Sleep also make them immune to Drowsy.
  # =Effects that make a battler immune to Freeze also make them immune to Frostbite.
  #-----------------------------------------------------------------------------
  alias paldea_pbCanInflictStatus? pbCanInflictStatus?
  def pbCanInflictStatus?(newStatus, user, showMessages, move = nil, ignoreStatus = false)
    originalStatus = newStatus
    case newStatus
    when :SLEEP  then newStatus = :DROWSY    if Settings::SLEEP_EFFECTS_CAUSE_DROWSY
    when :FROZEN then newStatus = :FROSTBITE if Settings::FREEZE_EFFECTS_CAUSE_FROSTBITE
    end
    if [:DROWSY, :FROSTBITE].include?(newStatus)
      selfInflicted = (user && user.index == @index)
      #-------------------------------------------------------------------------
      # General immunities.
      #-------------------------------------------------------------------------
      if self.status == newStatus && !ignoreStatus
        if showMessages
          @battle.pbDisplay(_INTL("¡{1} ya está somnoliento!", pbThis))      if newStatus == :DROWSY
          @battle.pbDisplay(_INTL("¡{1} ya está congelado!", pbThis)) if newStatus == :FROSTBITE
        end
        return false
      end
      if (self.status != :NONE && !ignoreStatus && !selfInflicted) ||
         (@effects[PBEffects::Substitute] > 0 && !(move && move.ignoresSubstitute?(user)) && !selfInflicted)
        @battle.pbDisplay(_INTL("No afecta a {1}...", pbThis(true))) if showMessages
        return false
      end
      case newStatus
      #-------------------------------------------------------------------------
      # Drowzy immunities.
      #-------------------------------------------------------------------------
      when :DROWSY
        if affectedByTerrain? && @battle.field.terrain == :Electric
          @battle.pbDisplay(_INTL("¡{1} se rodea de terreno electrificado!", pbThis(true))) if showMessages
          return false
        end
        if !(hasActiveAbility?(:SOUNDPROOF) && !@battle.moldBreaker)
          @battle.allBattlers.each do |b|
            next if b.effects[PBEffects::Uproar] == 0
            @battle.pbDisplay(_INTL("¡Pero el alboroto mantuvo alerta a {1}!", pbThis(true))) if showMessages
            return false
          end
        end
      #-------------------------------------------------------------------------
      # Frostbite immunities.
      #-------------------------------------------------------------------------
      when :FROSTBITE
        if pbHasType?(:ICE) || [:Sun, :HarshSun].include?(effectiveWeather)
          @battle.pbDisplay(_INTL("No afecta a {1}...", pbThis(true))) if showMessages
          return false
        end
      end
      #-------------------------------------------------------------------------
      # Ability immunities. 
      # Abilities that block Sleep also block Drowsiness.
      # Abilities that block Freeze also block Frostbites.
      #-------------------------------------------------------------------------
      immuneByAbility = false
      immAlly = nil
      if Battle::AbilityEffects.triggerStatusImmunityNonIgnorable(self.ability, self, originalStatus)
        immuneByAbility = true
      elsif selfInflicted || !@battle.moldBreaker
        if abilityActive? && Battle::AbilityEffects.triggerStatusImmunity(self.ability, self, originalStatus)
          immuneByAbility = true
        else
          allAllies.each do |b|
            next if !b.abilityActive?
            next if !Battle::AbilityEffects.triggerStatusImmunityFromAlly(b.ability, self, originalStatus)
            immuneByAbility = true
            immAlly = b
            break
          end
        end
      end
      if immuneByAbility
        if showMessages
          @battle.pbShowAbilitySplash(immAlly || self)
          msg = ""
          if Battle::Scene::USE_ABILITY_SPLASH
            case originalStatus
            when :SLEEP  then msg = _INTL("¡{1} se mantiene alerta!", pbThis)
            when :FROZEN then msg = _INTL("¡{1} no se puede helar!", pbThis)
            end
          elsif immAlly
            case originalStatus
            when :SLEEP  then msg = _INTL("¡{1} se mantiene alerta debido al {3} de {2}!", pbThis, immAlly.pbThis(true), immAlly.abilityName)
            when :FROZEN then msg = _INTL("¡{1} no se puede helar debido al {3} de {2}!", pbThis, immAlly.pbThis(true), immAlly.abilityName)
            end
          else
            case originalStatus
            when :SLEEP  then msg = _INTL("¡El {2} de {1} evita la somnolencia!", pbThis, abilityName)
            when :FROZEN then msg = _INTL("¡El {2} de {1} evita la helada!", pbThis, abilityName)
            end
          end
          @battle.pbDisplay(msg)
          @battle.pbHideAbilitySplash(immAlly || self)
        end
        return false
      end
      #-------------------------------------------------------------------------
      # Safeguard immunity.
      #-------------------------------------------------------------------------
      if pbOwnSide.effects[PBEffects::Safeguard] > 0 && !selfInflicted && move &&
         !(user && user.hasActiveAbility?(:INFILTRATOR))
        @battle.pbDisplay(_INTL("¡El equipo de {1} está protegido por Velo sagrado!", pbThis)) if showMessages
        return false
      end
      return true
    else
      return paldea_pbCanInflictStatus?(originalStatus, user, showMessages, move, ignoreStatus)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Aliased the check if Synchronize should fail to pass Drowsy/Frostbite.
  #-----------------------------------------------------------------------------
  alias paldea_pbCanSynchronizeStatus? pbCanSynchronizeStatus?
  def pbCanSynchronizeStatus?(newStatus, target)
    ret = paldea_pbCanSynchronizeStatus?(newStatus, target)
    return false if !ret
    return false if newStatus == :FROSTBITE && pbHasType?(:ICE)
    case newStatus
    when :DROWSY    then newStatus = :SLEEP
    when :FROSTBITE then newStatus = :FROZEN
    end
    return false if Battle::AbilityEffects.triggerStatusImmunityNonIgnorable(self.ability, self, newStatus)
    return false if abilityActive? && Battle::AbilityEffects.triggerStatusImmunity(self.ability, self, newStatus)
    allAllies.each do |b|
      next if !b.abilityActive?
      next if !Battle::AbilityEffects.triggerStatusImmunityFromAlly(b.ability, self, newStatus)
      return false
    end
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Aliased for inflicting the Drowsy/Frostbite status conditions.
  #-----------------------------------------------------------------------------
  alias paldea_pbInflictStatus pbInflictStatus
  def pbInflictStatus(newStatus, newStatusCount = 0, msg = nil, user = nil)
    case newStatus
    when :SLEEP  then newStatus = :DROWSY    if Settings::SLEEP_EFFECTS_CAUSE_DROWSY
    when :FROZEN then newStatus = :FROSTBITE if Settings::FREEZE_EFFECTS_CAUSE_FROSTBITE
    end
    if [:DROWSY, :FROSTBITE].include?(newStatus)
      self.status      = newStatus
      self.statusCount = newStatusCount
      @effects[PBEffects::Toxic] = 0
      anim_name = GameData::Status.get(newStatus).animation
      @battle.pbCommonAnimation(anim_name, self) if anim_name
      if msg && !msg.empty?
        @battle.pbDisplay(msg)
      else
        case newStatus
        when :DROWSY    then @battle.pbDisplay(_INTL("¡{1} se adormeció!\nPuede que tenga demasiado sueño para moverse.", pbThis))
        when :FROSTBITE then @battle.pbDisplay(_INTL("¡{1} se congeló!", pbThis))
        end
      end
      PBDebug.log("[Status change] #{pbThis}'s drowsy count is #{newStatusCount}") if newStatus == :DROWSY
      pbCheckFormOnStatusChange
      if abilityActive?
        Battle::AbilityEffects.triggerOnStatusInflicted(self.ability, self, user, newStatus)
      end
      pbItemStatusCureCheck
      pbAbilityStatusCureCheck
    else
      paldea_pbInflictStatus(newStatus, newStatusCount, msg, user)
    end
  end

  #-----------------------------------------------------------------------------
  # Aliased for curing the Drowsy/Frostbite status conditions.
  #-----------------------------------------------------------------------------
  alias paldea_pbCureStatus pbCureStatus
  def pbCureStatus(showMessages = true)
    if [:DROWSY, :FROSTBITE].include?(self.status)
      oldStatus = status
      self.status = :NONE
      if showMessages
        case oldStatus
        when :DROWSY    then @battle.pbDisplay(_INTL("{1} se puso alerta de nuevo.", pbThis))
        when :FROSTBITE then @battle.pbDisplay(_INTL("Se curó la congelación de {1}.", pbThis))
        end
      end
      PBDebug.log("[Status change] #{pbThis}'s status was cured") if !showMessages
    else
      paldea_pbCureStatus(showMessages)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Edited for Drowsy/Frostbite effect messages.
  #-----------------------------------------------------------------------------
  def pbContinueStatus
    if self.status == :POISON && @statusCount > 0
      @battle.pbCommonAnimation("Toxic", self)
    else
      anim_name = GameData::Status.get(self.status).animation
      @battle.pbCommonAnimation(anim_name, self) if anim_name
    end
    yield if block_given?
    case self.status
    when :SLEEP
      @battle.pbDisplay(_INTL("{1} está profundamente dormido.", pbThis))
	  PBDebug.log("[Status continues] #{pbThis}'s sleep count is #{@statusCount}")
    when :POISON
      @battle.pbDisplay(_INTL("¡{1} fue herido por veneno!", pbThis))
    when :BURN
      @battle.pbDisplay(_INTL("¡{1} fue herido por su quemadura!", pbThis))
    when :PARALYSIS
      @battle.pbDisplay(_INTL("¡{1} está paralizado! ¡No puede moverse!", pbThis))
    when :FROZEN
      @battle.pbDisplay(_INTL("¡{1} está congelado!", pbThis))
    when :DROWSY
      @battle.pbDisplay(_INTL("¡{1} está demasiado somnoliento para moverse!", pbThis))
	  PBDebug.log("[Status continues] #{pbThis}'s drowsy count is #{@statusCount}")
    when :FROSTBITE
      @battle.pbDisplay(_INTL("¡{1} fue herido por su congelación!", pbThis))
    end
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to prevent the use of moves due to being Drowsy.
  #-----------------------------------------------------------------------------
  alias paldea_pbTryUseMove pbTryUseMove
  def pbTryUseMove(*args)
    ret = paldea_pbTryUseMove(*args)
    return false if !ret
    if @status == :DROWSY
      self.statusCount -= 1
      if @statusCount <= 0
        pbCureStatus
      else
        if !args[1].electrocuteUser?
          chance = (effectiveWeather == :Hail) ? 66 : 33
          if @battle.pbRandom(100) < chance
            pbContinueStatus
            @lastMoveFailed = true
            return false
          end
        end
      end
    end
    return true
  end
end