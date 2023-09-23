#===============================================================================
#
#===============================================================================
def pbPCItemStorage
  command = 0
  loop do
    command = pbShowCommandsWithHelp(nil,
       [_INTL("Sacar Objeto"),
        _INTL("Dejar Objeto"),
        _INTL("Tirar Objeto"),
        _INTL("Salir")],
       [_INTL("Sacar objetos desde el PC."),
        _INTL("Guardar objetos en el PC."),
        _INTL("Tirar objetos guardados en el PC."),
        _INTL("Ir al menú anterior.")], -1, command)
    case command
    when 0   # Withdraw Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("No hay objetos."))
      else
        pbFadeOutIn {
          scene = WithdrawItemScene.new
          screen = PokemonBagScreen.new(scene, $bag)
          screen.pbWithdrawItemScreen
        }
      end
    when 1   # Deposit Item
      pbFadeOutIn {
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $bag)
        screen.pbDepositItemScreen
      }
    when 2   # Toss Item
      if !$PokemonGlobal.pcItemStorage
        $PokemonGlobal.pcItemStorage = PCItemStorage.new
      end
      if $PokemonGlobal.pcItemStorage.empty?
        pbMessage(_INTL("No hay objetos."))
      else
        pbFadeOutIn {
          scene = TossItemScene.new
          screen = PokemonBagScreen.new(scene, $bag)
          screen.pbTossItemScreen
        }
      end
    else
      break
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbPCMailbox
  if !$PokemonGlobal.mailbox || $PokemonGlobal.mailbox.length == 0
    pbMessage(_INTL("No hay Carta."))
  else
    loop do
      command = 0
      commands = []
      $PokemonGlobal.mailbox.each do |mail|
        commands.push(mail.sender)
      end
      commands.push(_INTL("Cancelar"))
      command = pbShowCommands(nil, commands, -1, command)
      if command >= 0 && command < $PokemonGlobal.mailbox.length
        mailIndex = command
        commandMail = pbMessage(
          _INTL("¿Qué quieres hacer con la Carta de {1}?", $PokemonGlobal.mailbox[mailIndex].sender),
          [_INTL("Leer"),
           _INTL("Mover a la Bolsa"),
           _INTL("Dar"),
           _INTL("Cancelar")], -1
        )
        case commandMail
        when 0   # Read
          pbFadeOutIn {
            pbDisplayMail($PokemonGlobal.mailbox[mailIndex])
          }
        when 1   # Move to Bag
          if pbConfirmMessage(_INTL("El mensaje se perderá. ¿Te parece bien?"))
            if $bag.add($PokemonGlobal.mailbox[mailIndex].item)
              pbMessage(_INTL("La Carta ha sido devuelta a la Bolsa con el mensaje borrado."))
              $PokemonGlobal.mailbox.delete_at(mailIndex)
            else
              pbMessage(_INTL("La Bolsa está llena."))
            end
          end
        when 2   # Give
          pbFadeOutIn {
            sscene = PokemonParty_Scene.new
            sscreen = PokemonPartyScreen.new(sscene, $player.party)
            sscreen.pbPokemonGiveMailScreen(mailIndex)
          }
        end
      else
        break
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbTrainerPC
  pbMessage(_INTL("\\se[PC open]{1} ha encendido el PC.", $player.name))
  pbTrainerPCMenu
  pbSEPlay("PC close")
end

def pbTrainerPCMenu
  command = 0
  loop do
    command = pbMessage(_INTL("¿Qué quieres hacer?"),
                        [_INTL("Almacenamiento de objetos"),
                         _INTL("Buzón"),
                         _INTL("Apagar")], -1, nil, command)
    case command
    when 0 then pbPCItemStorage
    when 1 then pbPCMailbox
    else        break
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbPokeCenterPC
  pbMessage(_INTL("\\se[PC open]{1} ha encendido el PC.", $player.name))
  # Get all commands
  command_list = []
  commands = []
  MenuHandlers.each_available(:pc_menu) do |option, hash, name|
    command_list.push(name)
    commands.push(hash)
  end
  # Main loop
  command = 0
  loop do
    choice = pbMessage(_INTL("¿A qué PC quieres acceder?"), command_list, -1, nil, command)
    if choice < 0
      pbPlayCloseMenuSE
      break
    end
    break if commands[choice]["effect"].call
  end
  pbSEPlay("PC close")
end

def pbGetStorageCreator
  return GameData::Metadata.get.storage_creator
end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:pc_menu, :pokemon_storage, {
  "name"      => proc {
    next ($player.seen_storage_creator) ? _INTL("PC de {1}", pbGetStorageCreator) : _INTL("Someone's PC")
  },
  "order"     => 10,
  "effect"    => proc { |menu|
    pbMessage(_INTL("\\se[PC access]Es Sistema de Almacenamiento Pokémon Storage System se ha abierto."))
    command = 0
    loop do
      command = pbShowCommandsWithHelp(nil,
         [_INTL("Organizar Cajas"),
          _INTL("Sacar Pokémon"),
          _INTL("Dejar Pokémon"),
          _INTL("¡Nos vemos!")],
         [_INTL("Organizar Pokémon en Cajas y en el equipo."),
          _INTL("Mover Pokémon guardados en cajas al equipo."),
          _INTL("Guardar Pokémon en el equipo en Cajas."),
          _INTL("Volver al menú anterior.")], -1, command)
      break if command < 0
      case command
      when 1   # Withdraw
        if $PokemonStorage.party_full?
          pbMessage(_INTL("¡Tu equipo está completo!"))
          next
        end
      when 2   # Deposit
        count = 0
        $PokemonStorage.party.each do |p|
          count += 1 if p && !p.egg? && p.hp > 0
        end
        if count <= 1
          pbMessage(_INTL("No puedes dejar tu último Pokémon!"))
          next
        end
      end
      pbFadeOutIn {
        scene = PokemonStorageScene.new
        screen = PokemonStorageScreen.new(scene, $PokemonStorage)
        screen.pbStartScreen(command)
      }
    end
    next false
  }
})

MenuHandlers.add(:pc_menu, :player_pc, {
  "name"      => proc { next _INTL("{1}'s PC", $player.name) },
  "order"     => 20,
  "effect"    => proc { |menu|
    pbMessage(_INTL("\\se[PC access]Has accedido al PC de {1}.", $player.name))
    pbTrainerPCMenu
    next false
  }
})

MenuHandlers.add(:pc_menu, :close, {
  "name"      => _INTL("Desconectar"),
  "order"     => 100,
  "effect"    => proc { |menu|
    next true
  }
})
