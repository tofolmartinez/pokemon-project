def pbEmergencySave
  oldscene = $scene
  $scene = nil
  pbMessage(_INTL("El script está tardando demasiado. El juego se reiniciará."))
  return if !$player
  if SaveData.exists?
    File.open(SaveData::FILE_PATH, "rb") do |r|
      File.open(SaveData::FILE_PATH + ".bak", "wb") do |w|
        loop do
          s = r.read(4096)
          break if !s
          w.write(s)
        end
      end
    end
  end
  if Game.save
    pbMessage(_INTL("\\se[]La partida se ha guardado.\\me[GUI save game] EL archivoa anterior de guardado ha sido respaldado.\\wtnp[30]"))
  else
    pbMessage(_INTL("\\se[]Guardado fallido.\\wtnp[30]"))
  end
  $scene = oldscene
end

#===============================================================================
#
#===============================================================================
class PokemonSave_Scene
  def pbStartScreen
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    totalsec = $stats.play_time.to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    mapname = $game_map.name
    textColor = ["0070F8,78B8E8", "E82010,F8A8B8", "0070F8,78B8E8"][$player.gender]
    locationColor = "209808,90F090"   # green
    loctext = _INTL("<ac><c3={1}>{2}</c3></ac>", locationColor, mapname)
    loctext += _INTL("Jugador<r><c3={1}>{2}</c3><br>", textColor, $player.name)
    if hour > 0
      loctext += _INTL("Tiempo<r><c3={1}>{2}h {3}m</c3><br>", textColor, hour, min)
    else
      loctext += _INTL("Tiempo<r><c3={1}>{2}m</c3><br>", textColor, min)
    end
    loctext += _INTL("Medallas<r><c3={1}>{2}</c3><br>", textColor, $player.badge_count)
    if $player.has_pokedex
      loctext += _INTL("Pokédex<r><c3={1}>{2}/{3}</c3>", textColor, $player.pokedex.owned_count, $player.pokedex.seen_count)
    end
    @sprites["locwindow"] = Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport = @viewport
    @sprites["locwindow"].x = 0
    @sprites["locwindow"].y = 0
    @sprites["locwindow"].width = 228 if @sprites["locwindow"].width < 228
    @sprites["locwindow"].visible = true
  end

  def pbEndScreen
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSaveScreen
  def initialize(scene)
    @scene = scene
  end

  def pbDisplay(text, brief = false)
    @scene.pbDisplay(text, brief)
  end

  def pbDisplayPaused(text)
    @scene.pbDisplayPaused(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

  def pbSaveScreen
    ret = false
    @scene.pbStartScreen
    if pbConfirmMessage(_INTL("¿Quieres guardar la partida?"))
      if SaveData.exists? && $game_temp.begun_new_game
        pbMessage(_INTL("¡AVISO!"))
        pbMessage(_INTL("Ya hay una partida guardada distinta."))
        pbMessage(_INTL("Si guardas ahora, la aventura en el otro archivo, incluidos objetos y Pokémon, se perderá por completo."))
        if !pbConfirmMessageSerious(_INTL("¿Quieres continuar con el guardado y sobreescribir el archivo?"))
          pbSEPlay("GUI save choice")
          @scene.pbEndScreen
          return false
        end
      end
      $game_temp.begun_new_game = false
      pbSEPlay("GUI save choice")
      if Game.save
        pbMessage(_INTL("\\se[]{1} ha guardado la partida.\\me[GUI save game]\\wtnp[30]", $player.name))
        ret = true
      else
        pbMessage(_INTL("\\se[]Guardado fallido.\\wtnp[30]"))
        ret = false
      end
    else
      pbSEPlay("GUI save choice")
    end
    @scene.pbEndScreen
    return ret
  end
end

#===============================================================================
#
#===============================================================================
def pbSaveScreen
  scene = PokemonSave_Scene.new
  screen = PokemonSaveScreen.new(scene)
  ret = screen.pbSaveScreen
  return ret
end
