#==============================================================================
# * Scene_Controls
#------------------------------------------------------------------------------
# Shows a help screen listing the keyboard controls.
# Display with:
#      pbEventScreen(ButtonEventScene)
#==============================================================================
class ButtonEventScene < EventScene
  def initialize(viewport = nil)
    super
    Graphics.freeze
    @current_screen = 1
    addImage(0, 0, "Graphics/Pictures/Controls help/help_bg")
    @labels = []
    @label_screens = []
    @keys = []
    @key_screens = []

    addImageForScreen(1, 44, 122, "Graphics/Pictures/Controls help/help_f1")
    addImageForScreen(1, 44, 252, "Graphics/Pictures/Controls help/help_f8")
    addLabelForScreen(1, 134, 84, 352, _INTL("Abre la ventana de Controles, donde puedes elegir qué tecla usar para cada control."))
    addLabelForScreen(1, 134, 244, 352, _INTL("Hace una captura de pantalla. Se guarda en la misma carpeta que el archivo de guardado."))

    addImageForScreen(2, 16, 158, "Graphics/Pictures/Controls help/help_arrows")
    addLabelForScreen(2, 134, 100, 352, _INTL("Usa las teclas de Dirección para mover el personaje.\r\n\r\nPuedes usarlas también para seleccionar entradas y navegar menús."))

    addImageForScreen(3, 16, 90, "Graphics/Pictures/Controls help/help_usekey")
    addImageForScreen(3, 16, 236, "Graphics/Pictures/Controls help/help_backkey")
    addLabelForScreen(3, 134, 68, 352, _INTL("Se usa para confirmar una elección, interactuar con gente y cosas, y avanzar el texto. (Por defecto: C)"))
    addLabelForScreen(3, 134, 196, 352, _INTL("Se usa para salir, cancelar una elección, y cancelar un modo. En movimiento, mantener para moverte a distinta velocidad. (Por defecto: X)"))

    addImageForScreen(4, 16, 90, "Graphics/Pictures/Controls help/help_actionkey")
    addImageForScreen(4, 16, 236, "Graphics/Pictures/Controls help/help_specialkey")
    addLabelForScreen(4, 134, 68, 352, _INTL("Se usa para abrir el Menú de Pausa. También tiene diferentes funciones dependiendo del contexto. (Por defecto: Z)"))
    addLabelForScreen(4, 134, 196, 352, _INTL("Abre el Menú Rápido, desde donde se pueden usar los objetos asignados y los movimientos de campo. (Por defecto: D)"))

    set_up_screen(@current_screen)
    Graphics.transition
    # Go to next screen when user presses USE
    onCTrigger.set(method(:pbOnScreenEnd))
  end

  def addLabelForScreen(number, x, y, width, text)
    @labels.push(addLabel(x, y, width, text))
    @label_screens.push(number)
    @picturesprites[@picturesprites.length - 1].opacity = 0
  end

  def addImageForScreen(number, x, y, filename)
    @keys.push(addImage(x, y, filename))
    @key_screens.push(number)
    @picturesprites[@picturesprites.length - 1].opacity = 0
  end

  def set_up_screen(number)
    @label_screens.each_with_index do |screen, i|
      @labels[i].moveOpacity((screen == number) ? 10 : 0, 10, (screen == number) ? 255 : 0)
    end
    @key_screens.each_with_index do |screen, i|
      @keys[i].moveOpacity((screen == number) ? 10 : 0, 10, (screen == number) ? 255 : 0)
    end
    pictureWait   # Update event scene with the changes
  end

  def pbOnScreenEnd(scene, *args)
    last_screen = [@label_screens.max, @key_screens.max].max
    if @current_screen >= last_screen
      # End scene
      $game_temp.background_bitmap = Graphics.snap_to_bitmap
      Graphics.freeze
      @viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black
      Graphics.transition(8, "fadetoblack")
      $game_temp.background_bitmap.dispose
      scene.dispose
    else
      # Next screen
      @current_screen += 1
      onCTrigger.clear
      set_up_screen(@current_screen)
      onCTrigger.set(method(:pbOnScreenEnd))
    end
  end
end
