import javax.activation.MimetypesFileTypeMap;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;
import java.awt.Point;
import uibooster.*;
import org.apache.commons.lang3.exception.ExceptionUtils;

public class UserInterface {

  PGraphics canvas;

  ControlP5 cp5;

  Map map;

  Grid grid;

  Obstacles obstacles;

  Layer playersLayer;
  Layer dmLayer;

  Resources resources;

  Initiative initiative;

  UiBooster uiDialogs;
  boolean uiConfirmDialogAnswer;

  Wall newWall;
  Door newDoor;

  Token rightClickedToken;

  int controllerBarsSpacing;
  int controllersSpacing;

  int squareButtonWidth;
  int squareButtonHeight;
  int instructionsHeight;
  int menuBarHeight;

  int controllersTopLeftX, controllersTopLeftY;
  int controllersTopLeftInitialX, controllersTopLeftInitialY;
  int controllersMiddleLeftInitialX, controllersMiddleLeftInitialY;
  int controllersBottomLeftInitialX, controllersBottomLeftInitialY;
  int controllersTopRightX, controllersTopRightY;
  int controllersTopRightInitialX, controllersTopRightInitialY;
  int controllersBottomRightX, controllersBottomRightY;
  int controllersBottomRightInitialX, controllersBottomRightInitialY;
  int controllersMenuX, controllersMenuY;
  int controllersMenuInitialX, controllersMenuInitialY;

  int menuItemsPerLine;
  boolean menuItemClicked;

  color idleBackgroundColor, mouseOverBackgroundColor, mouseClickBackgroundColor, disabledBackgroundColor;

  PFont instructionsFont;
  color instructionsFontColor, instructionsFontOutlineColor, instructionsVisualColor;
  int instructionsX, instructionsY;
  int instructionsInitialX, instructionsInitialY;

  int gridHelperX, gridHelperY;
  int gridHelperToX, gridHelperToY;
  boolean gridHelperStarted;
  boolean gridHelperSet;

  Group togglableControllers;
  Group conditionMenuControllers;
  Group lightSourceMenuControllers;
  Group sightTypeMenuControllers;
  Group sizeMenuControllers;
  Group otherMenuControllers;
  Accordion tokenMenu;

  // Maps resources to controllers
  HashMap<String, String> conditionToController;
  HashMap<String, String> lightSourceToController;
  HashMap<String, String> sightTypeToController;
  HashMap<String, String> sizeToController;

  // Maps controllers to tooltips
  HashMap<String, UserInterfaceTooltip> controllerToTooltip;

  // Keeps track of previous mouse over events on controllers
  // Used to reset tooltip timers
  List<ControllerInterface<?>> previousMouseOverControllers;

  boolean fileDialogOpen;

  int platform;

  UserInterface(PGraphics _canvas, ControlP5 _cp5, Map _map, Grid _grid, Obstacles _obstacles, Layer _playersLayer, Layer _dmLayer, Resources _resources, Initiative _initiative, int _platform) {

    canvas = _canvas;

    cp5 = _cp5;

    map = _map;

    grid = _grid;

    obstacles = _obstacles;

    playersLayer = _playersLayer;
    dmLayer = _dmLayer;

    resources = _resources;

    initiative = _initiative;

    uiDialogs = new UiBooster();
    uiConfirmDialogAnswer = false;

    newWall = null;
    newDoor = null;

    rightClickedToken = null;

    controllerBarsSpacing = 50;
    controllersSpacing = 5;

    squareButtonWidth = 50;
    squareButtonHeight = 50;
    instructionsHeight = 15;
    menuBarHeight = 35;

    controllersTopLeftX = round(min(canvas.width, canvas.height) * 0.05);
    controllersTopLeftY = round(min(canvas.width, canvas.height) * 0.05);
    controllersTopLeftInitialX = controllersTopLeftX;
    controllersTopLeftInitialY = controllersTopLeftY;
    controllersMiddleLeftInitialX = controllersTopLeftInitialX;
    controllersMiddleLeftInitialY = controllersTopLeftInitialY + squareButtonHeight + controllerBarsSpacing + controllersSpacing;
    controllersBottomLeftInitialX = controllersMiddleLeftInitialX;
    controllersBottomLeftInitialY = controllersMiddleLeftInitialY + 5*(squareButtonHeight + controllersSpacing) + squareButtonHeight + controllerBarsSpacing + controllersSpacing;
    controllersTopRightX = canvas.width - round(min(canvas.width, canvas.height) * 0.05);
    controllersTopRightY = round(min(canvas.width, canvas.height) * 0.05);
    controllersBottomRightX = controllersTopRightX - squareButtonWidth;
    controllersBottomRightY = canvas.height - controllersTopRightY - squareButtonHeight;
    controllersBottomRightInitialX = controllersBottomRightX;
    controllersBottomRightInitialY = controllersBottomRightY;
    controllersMenuX = controllersSpacing;
    controllersMenuY = controllersSpacing;
    controllersMenuInitialX = controllersMenuX;
    controllersMenuInitialY = controllersMenuY;

    menuItemsPerLine = 5;
    menuItemClicked = false;

    idleBackgroundColor = #222731;
    mouseOverBackgroundColor = #404854;
    mouseClickBackgroundColor = #F64B29;
    disabledBackgroundColor = #6F6F6F;

    instructionsFont = loadFont("fonts/ProcessingSansPro-Semibold-14.vlw");
    instructionsFontColor = color(255);
    instructionsFontOutlineColor = color(0);
    instructionsVisualColor = color(#F64B29, 127);
    instructionsX = controllersTopLeftX;
    instructionsY = canvas.height - controllersTopLeftY;
    instructionsInitialX = instructionsX;
    instructionsInitialY = instructionsY;

    gridHelperX = gridHelperToX = 0;
    gridHelperY = gridHelperToY = 0;
    gridHelperStarted = false;
    gridHelperSet = false;

    togglableControllers = null;
    conditionMenuControllers = null;
    lightSourceMenuControllers = null;
    sightTypeMenuControllers = null;
    sizeMenuControllers = null;
    otherMenuControllers = null;
    tokenMenu = null;

    conditionToController = new HashMap<String, String>();
    lightSourceToController = new HashMap<String, String>();
    sightTypeToController = new HashMap<String, String>();
    sizeToController = new HashMap<String, String>();

    controllerToTooltip = new HashMap<String, UserInterfaceTooltip>();
    previousMouseOverControllers = new ArrayList<ControllerInterface<?>>();

    fileDialogOpen = false;

    platform = _platform;

    logger.debug("Setup: UI controllers setup started");

    try {

      setupControllers();
      setControllersInitialState();

    } catch ( Exception e ) {
      logger.error("Setup: Error setting up UI controllers");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

    logger.debug("Setup: UI controllers setup done");

    initiative.setMaxWidth(controllersBottomRightX - controllersSpacing);

  }

  void drawSetupHelpers() {

    switch ( appState ) {
      case gridSetup:

        if ( !gridHelperSet )
          break;

        canvas.rectMode(CORNERS);
        canvas.stroke(instructionsVisualColor);
        canvas.strokeWeight(1);
        canvas.fill(instructionsVisualColor);
        canvas.rect(map.transformX(gridHelperX), map.transformY(gridHelperY), map.transformX(gridHelperToX), map.transformY(gridHelperToY));

        String gridHelperSize = "Cell size: " + abs(gridHelperX-gridHelperToX)/3 + " x " + abs(gridHelperY-gridHelperToY)/3;
        canvas.textFont(instructionsFont);
        outlineText(canvas, gridHelperSize, instructionsFontColor, instructionsFontOutlineColor, map.transformX(gridHelperToX) + 10, map.transformY(gridHelperToY) + 10);

        break;
      case wallSetup:

        if ( newWall == null )
          break;

        newWall.draw(obstacles.getWallColor(), obstacles.getWallWidth());

        if ( !isInside(mouseX, mouseY) )
          newWall.drawNewEdge(obstacles.getWallColor(), obstacles.getWallWidth(), map.transformX(mouseX), map.transformY(mouseY));

        break;
      case doorSetup:

        if ( newDoor == null )
          break;

        newDoor.draw(obstacles.getClosedDoorColor(), obstacles.getOpenDoorColor(), obstacles.getDoorWidth());

        if ( !isInside(mouseX, mouseY) )
          newDoor.drawNewEdge(obstacles.getClosedDoorColor(), obstacles.getDoorWidth(), map.transformX(mouseX), map.transformY(mouseY));

        break;
      default:
        break;
    }

  }

  void drawTooltips(PGraphics uiCanvas) {

    List<ControllerInterface<?>> mouseOverControllers = cp5.getMouseOverList();

    // Draw tooltip for controllers in mouse-over list
    for ( ControllerInterface controller: mouseOverControllers ) {
      if ( controller.isVisible() && controller.isMouseOver() ) {
        UserInterfaceTooltip tooltip = controllerToTooltip.get(controller.getName());
        if ( tooltip != null )
          tooltip.draw(uiCanvas);
      }
    }

    // If mouse-over list changed
    if ( !previousMouseOverControllers.equals(mouseOverControllers) ) {

      // Reset tooltip for controllers that were in the previous list
      for ( ControllerInterface controller: previousMouseOverControllers ) {
        UserInterfaceTooltip tooltip = controllerToTooltip.get(controller.getName());
        if ( tooltip != null )
          tooltip.reset();
      }

      // Reset previous list and populate it with controllers from current mouse-over list
      previousMouseOverControllers.clear();
      for ( ControllerInterface controller: mouseOverControllers )
        previousMouseOverControllers.add(controller);

    }

  }

  void setupControllers() {

    String appIconFolder;
    String sceneConfigIconFolder;
    String sceneSetupIconFolder;
    String tokenConditionsIconFolder;
    String tokenCommonLightSourcesIconFolder;
    String tokenSpellLightSourcesIconFolder;
    String tokenSightTypesIconFolder;
    String tokenSizesIconFolder;
    String tokenSetupIconFolder;

    // Togglable controllers group

    togglableControllers = cp5.addGroup("Toggable controllers");

    // Right click menu controller groups

    conditionMenuControllers = cp5.addGroup("Conditions")
                                    .setBackgroundColor(color(0, 127));
    lightSourceMenuControllers = cp5.addGroup("Light Sources")
                                    .setBackgroundColor(color(0, 127));
    sightTypeMenuControllers = cp5.addGroup("Sight Types")
                                    .setBackgroundColor(color(0, 127));
    sizeMenuControllers = cp5.addGroup("Sizes")
                                    .setBackgroundColor(color(0, 127));
    otherMenuControllers = cp5.addGroup("Other")
                              .setBackgroundColor(color(0, 127));

    // Icon paths
    appIconFolder = "app/";
    sceneConfigIconFolder = "scene/config/";
    sceneSetupIconFolder = "scene/setup/";
    tokenConditionsIconFolder = "token/condition/";
    tokenCommonLightSourcesIconFolder = "token/light_source/common/";
    tokenSpellLightSourcesIconFolder = "token/light_source/spell/";
    tokenSightTypesIconFolder = "token/sight_type/";
    tokenSizesIconFolder = "token/size/";
    tokenSetupIconFolder = "token/setup/";

    // Top left horizontal bar - scenes management

    controllersTopLeftX = controllersTopLeftInitialX;
    controllersTopLeftY = controllersTopLeftInitialY;
    addButton("New scene", appIconFolder + "new", controllersTopLeftX, controllersTopLeftY, togglableControllers);

    controllersTopLeftX += squareButtonWidth + controllersSpacing;
    addButton("Load scene", appIconFolder + "load", controllersTopLeftX, controllersTopLeftY, togglableControllers);

    controllersTopLeftX += squareButtonWidth + controllersSpacing;
    addButton("Save scene", appIconFolder + "save", controllersTopLeftX, controllersTopLeftY, togglableControllers);

    // Middle left vertical bar - scene setup

    controllersTopLeftX = controllersMiddleLeftInitialX;
    controllersTopLeftY = controllersMiddleLeftInitialY;
    addButton("Select map", sceneSetupIconFolder + "map", controllersTopLeftX, controllersTopLeftY, togglableControllers);

    controllersTopLeftY += squareButtonHeight + controllersSpacing;
    addButton("Grid setup", sceneSetupIconFolder + "grid", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);

    controllersTopLeftY += squareButtonHeight + controllersSpacing;
    addButton("Add/Remove walls", sceneSetupIconFolder + "wall", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);

    controllersTopLeftY += squareButtonHeight + controllersSpacing;
    addButton("Add/Remove doors", sceneSetupIconFolder + "door", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);

    controllersTopLeftY += squareButtonHeight + controllersSpacing;
    addButton("Add player token", sceneSetupIconFolder + "hero", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);

    controllersTopLeftY += squareButtonHeight + controllersSpacing;
    addButton("Add DM token", sceneSetupIconFolder + "monster", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);

    // Bottom left horizontal bar - scene config

    controllersTopLeftX = controllersBottomLeftInitialX;
    controllersTopLeftY = controllersBottomLeftInitialY;
    addButton("Toggle combat mode", sceneConfigIconFolder + "combat", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);

    controllersTopLeftX += squareButtonWidth + controllersSpacing;
    addButton("Toggle grid", sceneConfigIconFolder + "grid", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);

    controllersTopLeftX += squareButtonWidth + controllersSpacing;
    addButton("Switch active layer", sceneConfigIconFolder + "layers", controllersTopLeftX, controllersTopLeftY, togglableControllers);

    controllersTopLeftX += squareButtonWidth + controllersSpacing;
    addButton("Switch environment lighting", sceneConfigIconFolder + "lighting", controllersTopLeftX, controllersTopLeftY, togglableControllers);

    // Disabled - map pan and zoom enabled by default
    // addButton("Toggle camera pan", sceneConfigIconFolder + "pan", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);
    // addButton("Toggle camera zoom", sceneConfigIconFolder + "zoom", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);

    // Disabled - walls/doors shown during setup only
    // addButton("Toggle walls", sceneConfigIconFolder + "walls", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);

    // Top right bar - quit

    controllersTopRightX -= squareButtonWidth;
    addButton("Quit", appIconFolder + "quit", controllersTopRightX, controllersTopRightY);

    // Bottom right bar - UI config

    controllersBottomRightX = controllersBottomRightInitialX;
    controllersBottomRightY = controllersBottomRightInitialY;
    addButton("Toggle UI", appIconFolder + "ui", controllersBottomRightX, controllersBottomRightY, null, true, true);

    controllersBottomRightX -= squareButtonWidth + controllersSpacing;
    addButton("Toggle touch screen mode", appIconFolder + "touch", controllersBottomRightX, controllersBottomRightY, togglableControllers, true, false);

    controllersBottomRightX -= squareButtonWidth + controllersSpacing;
    addButton("Toggle mute sound", appIconFolder + "mute", controllersBottomRightX, controllersBottomRightY, togglableControllers, true, false);

    // Token right click menu

    conditionMenuControllers.setHeight(menuBarHeight)                  // menu bar height
                            .setBackgroundHeight(controllersSpacing)   // item height
                            .setColorBackground(idleBackgroundColor)
                            .setColorForeground(mouseOverBackgroundColor)
                            .setFont(instructionsFont)
                            ;
    conditionMenuControllers.getCaptionLabel().align(LEFT, CENTER).toUpperCase(false);

    lightSourceMenuControllers.setHeight(menuBarHeight)                // menu bar height
                              .setBackgroundHeight(controllersSpacing) // item height
                              .setColorBackground(idleBackgroundColor)
                              .setColorForeground(mouseOverBackgroundColor)
                              .setFont(instructionsFont)
                              ;
    lightSourceMenuControllers.getCaptionLabel().align(LEFT, CENTER).toUpperCase(false);

    sightTypeMenuControllers.setHeight(menuBarHeight)                  // menu bar height
                            .setBackgroundHeight(controllersSpacing)   // item height
                            .setColorBackground(idleBackgroundColor)
                            .setColorForeground(mouseOverBackgroundColor)
                            .setFont(instructionsFont)
                            ;
    sightTypeMenuControllers.getCaptionLabel().align(LEFT, CENTER).toUpperCase(false);

    sizeMenuControllers.setHeight(menuBarHeight)                       // menu bar height
                       .setBackgroundHeight(controllersSpacing)        // item height
                       .setColorBackground(idleBackgroundColor)
                       .setColorForeground(mouseOverBackgroundColor)
                       .setFont(instructionsFont)
                       ;
    sizeMenuControllers.getCaptionLabel().align(LEFT, CENTER).toUpperCase(false);

    otherMenuControllers.setHeight(menuBarHeight)                      // menu bar height
                        .setBackgroundHeight(controllersSpacing)       // item height
                        .setColorBackground(idleBackgroundColor)
                        .setColorForeground(mouseOverBackgroundColor)
                        .setFont(instructionsFont)
                        ;
    otherMenuControllers.getCaptionLabel().align(LEFT, CENTER).toUpperCase(false);

    tokenMenu = cp5.addAccordion("Right click menu")
       .setPosition(0, 0)
       .setWidth((menuItemsPerLine+1)*controllersSpacing + menuItemsPerLine*squareButtonWidth)  // menu bar and items width
       .setMinItemHeight(controllersSpacing)                                                    // min item height
       .addItem(conditionMenuControllers)
       .addItem(lightSourceMenuControllers)
       .addItem(sightTypeMenuControllers)
       .addItem(sizeMenuControllers)
       .addItem(otherMenuControllers)
       .updateItems()
       .setCollapseMode(Accordion.SINGLE)
       .open(0)
       .hide()
       ;

    // first line in menu item
    conditionMenuControllers.setBackgroundHeight(conditionMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY = controllersMenuInitialY;
    addButton("Blinded", tokenConditionsIconFolder + "blinded", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Blinded", "Blinded");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Bloodied", tokenConditionsIconFolder + "bloodied", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Bloodied", "Bloodied");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Charmed", tokenConditionsIconFolder + "charmed", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Charmed", "Charmed");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Dead", tokenConditionsIconFolder + "dead", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Dead", "Dead");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Deafened", tokenConditionsIconFolder + "deafened", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Deafened", "Deafened");

    // new line
    conditionMenuControllers.setBackgroundHeight(conditionMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY += squareButtonWidth + controllersSpacing;
    addButton("Frightened", tokenConditionsIconFolder + "frightened", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Frightened", "Frightened");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Grappled", tokenConditionsIconFolder + "grappled", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Grappled", "Grappled");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Hidden", tokenConditionsIconFolder + "hidden", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Hidden", "Hidden");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Incapacitated", tokenConditionsIconFolder + "incapacitated", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Incapacitated", "Incapacitated");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Invisible", tokenConditionsIconFolder + "invisible", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Invisible", "Invisible");

    // new line
    conditionMenuControllers.setBackgroundHeight(conditionMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY += squareButtonWidth + controllersSpacing;
    addButton("Paralyzed", tokenConditionsIconFolder + "paralyzed", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Paralyzed", "Paralyzed");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Petrified", tokenConditionsIconFolder + "petrified", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Petrified", "Petrified");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Poisoned", tokenConditionsIconFolder + "poisoned", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Poisoned", "Poisoned");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Prone", tokenConditionsIconFolder + "prone", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Prone", "Prone");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Restrained", tokenConditionsIconFolder + "restrained", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Restrained", "Restrained");

    // new line
    conditionMenuControllers.setBackgroundHeight(conditionMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY += squareButtonWidth + controllersSpacing;
    addButton("Stunned", tokenConditionsIconFolder + "stunned", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Stunned", "Stunned");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Unconscious", tokenConditionsIconFolder + "unconscious", controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
    conditionToController.put("Unconscious", "Unconscious");

    // first line in menu item
    lightSourceMenuControllers.setBackgroundHeight(lightSourceMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY = controllersMenuInitialY;
    addButton("Candle", tokenCommonLightSourcesIconFolder + "candle", controllersMenuX, controllersMenuY, lightSourceMenuControllers, true, false);
    lightSourceToController.put("Candle", "Candle");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Torch", tokenCommonLightSourcesIconFolder + "torch", controllersMenuX, controllersMenuY, lightSourceMenuControllers, true, false);
    lightSourceToController.put("Torch", "Torch");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Lamp", tokenCommonLightSourcesIconFolder + "lamp", controllersMenuX, controllersMenuY, lightSourceMenuControllers, true, false);
    lightSourceToController.put("Lamp", "Lamp");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Hooded lantern", tokenCommonLightSourcesIconFolder + "hooded_lantern", controllersMenuX, controllersMenuY, lightSourceMenuControllers, true, false);
    lightSourceToController.put("Hooded Lantern", "Hooded lantern");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Daylight", tokenCommonLightSourcesIconFolder + "daylight", controllersMenuX, controllersMenuY, lightSourceMenuControllers, true, false);
    lightSourceToController.put("Daylight", "Daylight");

    // new line
    lightSourceMenuControllers.setBackgroundHeight(lightSourceMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY += squareButtonWidth + controllersSpacing;
    addButton("Light spell", tokenSpellLightSourcesIconFolder + "light", controllersMenuX, controllersMenuY, lightSourceMenuControllers, true, false);
    lightSourceToController.put("Light", "Light spell");

    // first line in menu item
    sightTypeMenuControllers.setBackgroundHeight(sightTypeMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY = controllersMenuInitialY;
    addButton("Darkvision 60'", tokenSightTypesIconFolder + "darkvision", controllersMenuX, controllersMenuY, sightTypeMenuControllers, true, false);
    sightTypeToController.put("Darkvision 60'", "Darkvision 60'");

    // first line in menu item
    sizeMenuControllers.setBackgroundHeight(sizeMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY = controllersMenuInitialY;
    addButton("Tiny", tokenSizesIconFolder + "tiny", controllersMenuX, controllersMenuY, sizeMenuControllers, true, false);
    sizeToController.put("Tiny", "Tiny");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Small", tokenSizesIconFolder + "small", controllersMenuX, controllersMenuY, sizeMenuControllers, true, false);
    sizeToController.put("Small", "Small");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Medium", tokenSizesIconFolder + "medium", controllersMenuX, controllersMenuY, sizeMenuControllers, true, false);
    sizeToController.put("Medium", "Medium");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Large", tokenSizesIconFolder + "large", controllersMenuX, controllersMenuY, sizeMenuControllers, true, false);
    sizeToController.put("Large", "Large");

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Huge", tokenSizesIconFolder + "huge", controllersMenuX, controllersMenuY, sizeMenuControllers, true, false);
    sizeToController.put("Huge", "Huge");

    // new line
    sizeMenuControllers.setBackgroundHeight(sizeMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY += squareButtonWidth + controllersSpacing;
    addButton("Gargantuan", tokenSizesIconFolder + "gargantuan", controllersMenuX, controllersMenuY, sizeMenuControllers, true, false);
    sizeToController.put("Gargantuan", "Gargantuan");

    // first line in menu item
    otherMenuControllers.setBackgroundHeight(otherMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY = controllersMenuInitialY;
    addButton("Change token layer", tokenSetupIconFolder + "switch_layer", controllersMenuX, controllersMenuY, otherMenuControllers);

    controllersMenuX += squareButtonWidth + controllersSpacing;
    addButton("Remove token", tokenSetupIconFolder + "remove", controllersMenuX, controllersMenuY, otherMenuControllers);

    // Button groups label

    instructionsX = controllersTopLeftInitialX;
    instructionsY = controllersTopLeftInitialY - instructionsHeight - controllersSpacing;

    cp5.addTextlabel("Scenes management label")
       .setText("Scenes management")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .setOutlineText(true)
       .moveTo(togglableControllers);
       ;

    instructionsX = controllersMiddleLeftInitialX;
    instructionsY = controllersMiddleLeftInitialY - instructionsHeight - controllersSpacing;

    cp5.addTextlabel("Scene setup label")
       .setText("Scene setup")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .setOutlineText(true)
       .moveTo(togglableControllers);
       ;

    instructionsX = controllersBottomLeftInitialX;
    instructionsY = controllersBottomLeftInitialY - instructionsHeight - controllersSpacing;

    cp5.addTextlabel("Scene configuration label")
       .setText("Scene configuration")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .setOutlineText(true)
       .moveTo(togglableControllers);
       ;

    // Bottom left messages

    instructionsX = instructionsInitialX;
    instructionsY = instructionsInitialY;

    cp5.addTextlabel("Grid instructions - 2nd line")
       .setText("Once you draw this square, you can adjust its size and position using keys W, A, S, D (top left corner) and ↑, ←, ↓, → (bottom right corner).")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .setOutlineText(true)
       .hide()
       ;

    instructionsY -= instructionsHeight + controllersSpacing;

    cp5.addTextlabel("Grid instructions - 1st line")
       .setText("Click and drag to create a square the size of 3 x 3 grid cells on the map background you are using.")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .setOutlineText(true)
       .hide()
       ;

    instructionsX = instructionsInitialX;
    instructionsY = instructionsInitialY;

    cp5.addTextlabel("Wall instructions - 2nd line")
       .setText("Right click on any wall to remove it.")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .setOutlineText(true)
       .hide()
       ;

    instructionsY -= instructionsHeight + controllersSpacing;

    cp5.addTextlabel("Wall instructions - 1st line")
       .setText("Draw new wall segments, adding vertexes by left clicking. Double click to stop adding wall segments after the current one.")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .setOutlineText(true)
       .hide()
       ;

    instructionsX = instructionsInitialX;
    instructionsY = instructionsInitialY;

    cp5.addTextlabel("Door instructions - 2nd line")
       .setText("Right click on any door to remove it.")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .setOutlineText(true)
       .hide()
       ;

    instructionsY -= instructionsHeight + controllersSpacing;

    cp5.addTextlabel("Door instructions - 1st line")
       .setText("Draw new doors, adding vertexes by left clicking.")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .setOutlineText(true)
       .hide()
       ;

    tokenMenu.updateItems();

  }

  void addButton(String buttonName, String imageBaseName, int buttonPositionX, int buttonPositionY) {
    addButton(buttonName, imageBaseName, buttonPositionX, buttonPositionY, null, false, false);
  }

  void addButton(String buttonName, String imageBaseName, int buttonPositionX, int buttonPositionY, ControllerGroup buttonGroup) {
    addButton(buttonName, imageBaseName, buttonPositionX, buttonPositionY, buttonGroup, false, false);
  }

  void addButton(String buttonName, String imageBaseName, int buttonPositionX, int buttonPositionY, ControllerGroup buttonGroup, boolean isSwitch, boolean switchInitialState) {

    PImage[] buttonImages = {loadImage("icons/" + imageBaseName + "_idle.png"), loadImage("icons/" + imageBaseName + "_over.png"), loadImage("icons/" + imageBaseName + "_click.png")};
    for ( PImage img: buttonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);

    Button button = cp5.addButton(buttonName)
      .setPosition(buttonPositionX, buttonPositionY)
      .setSize(squareButtonWidth, squareButtonHeight)
      .setImages(buttonImages)
      .updateSize()
      .setStringValue(imageBaseName)
      ;

    if ( buttonGroup != null )
      button.moveTo(buttonGroup);

    if ( isSwitch ) {

      button.setSwitch(true);

      button.setBroadcast(false);
      if ( switchInitialState )
        button.setOn();
      else
        button.setOff();
      button.setBroadcast(true);

    }

    controllerToTooltip.put(buttonName, new UserInterfaceTooltip(buttonName, mouseOverBackgroundColor, instructionsFontColor));

  }

  void setControllersInitialState() {

    enableController("Select map");
    disableController("Grid setup");
    disableController("Add/Remove walls");
    disableController("Add/Remove doors");
    disableController("Add player token");
    disableController("Add DM token");
    hideController("Toggle mute sound");
    removeController("Map logo");

    setSwitchButtonState("Toggle grid", false);
    setSwitchButtonState("Toggle combat mode", false);
    setSwitchButtonState("Toggle mute sound", false);

  }

  void reset() {

    initiative.clear();
    obstacles.setIllumination(Illumination.brightLight);
    obstacles.clear();
    playersLayer.clear();
    dmLayer.clear();
    grid.clear();
    map.clear();

    setControllersInitialState();

    layerShown = Layers.players;

    appState = AppStates.idle;

  }

  AppStates controllerEvent(ControlEvent controlEvent) {

    String resourceName;
    Condition conditionTemplate;
    Light lightTemplate;
    Size sizeTemplate;

    AppStates newAppState = appState;

    String controllerName = "";
    if ( controlEvent.isController() )
      controllerName = controlEvent.getController().getName();
    else if ( controlEvent.isGroup() )
      controllerName = controlEvent.getGroup().getName();

    switch ( controllerName ) {
      case "New scene":

        if ( map.isSet() ) {

          uiDialogs.showConfirmDialog(
              "This will reset the current scene. Confirm?",
              "Create new scene",
              new Runnable() {
                public void run() {
                  uiConfirmDialogAnswer = true;
                }
              },
              new Runnable() {
                public void run() {
                  uiConfirmDialogAnswer = false;
                }
              }
          );

          if ( !uiConfirmDialogAnswer )
            break;

        }

        reset();

        logger.info("UserInterface: New empty scene created");

        break;
      case "Save scene":

        File sceneFolder = null;
        selectFolder("Select folder where to save scene:", "saveScene", sceneFolder, this);
        fileDialogOpen = true;

        break;
      case "Load scene":

        if ( map.isSet() ) {

          uiDialogs.showConfirmDialog(
              "This will replace the current scene. Confirm?",
              "Load scene",
              new Runnable() {
                public void run() {
                  uiConfirmDialogAnswer = true;
                }
              },
              new Runnable() {
                public void run() {
                  uiConfirmDialogAnswer = false;
                }
              }
          );

          if ( !uiConfirmDialogAnswer )
            break;

        }

        File sceneFile = null;
        selectInput("Select scene to load:", "loadScene", sceneFile, this);
        fileDialogOpen = true;

        break;
      case "Quit":

        uiDialogs.showConfirmDialog(
            "Quit dungeoneering?",
            "Quit",
            new Runnable() {
              public void run() {
                uiConfirmDialogAnswer = true;
              }
            },
            new Runnable() {
              public void run() {
                uiConfirmDialogAnswer = false;
              }
            }
        );

        if ( !uiConfirmDialogAnswer )
          break;

        initiative.clear();
        obstacles.clear();
        playersLayer.clear();
        dmLayer.clear();
        grid.clear();
        map.clear();

        logger.info("UserInterface: Exiting dungeoneering");

        exit();

        break;
      case "Select map":

        if ( map.isSet() ) {

          uiDialogs.showConfirmDialog(
              "This will reset the current scene. Confirm?",
              "Select new map",
              new Runnable() {
                public void run() {
                  uiConfirmDialogAnswer = true;
                }
              },
              new Runnable() {
                public void run() {
                  uiConfirmDialogAnswer = false;
                }
              }
          );

          if ( !uiConfirmDialogAnswer )
            break;

        }

        File mapFile = null;
        selectInput("Select a map:", "mapFileSelected", mapFile, this);
        fileDialogOpen = true;

        break;
      case "Map logo":

        Button logo = (Button)controlEvent.getController();
        String link = logo.getStringValue();
        if ( link != null && !link.trim().isEmpty() )
          link(link);

        break;
      case "Grid setup":

        Button gridSetup = (Button)controlEvent.getController();
        Textlabel gridInstructions1stLine = (Textlabel)cp5.getController("Grid instructions - 1st line");
        Textlabel gridInstructions2ndLine = (Textlabel)cp5.getController("Grid instructions - 2nd line");

        if ( gridSetup.isOn() ) {

          if ( grid.isSet() ) {

            uiDialogs.showConfirmDialog(
                "This will reset the current scene, leaving only the selected map. Confirm?",
                "New grid setup",
                new Runnable() {
                  public void run() {
                    uiConfirmDialogAnswer = true;
                  }
                },
                new Runnable() {
                  public void run() {
                    uiConfirmDialogAnswer = false;
                  }
                }
            );

            if ( !uiConfirmDialogAnswer ) {

              gridSetup.setBroadcast(false);
              gridSetup.setOff();
              gridSetup.setBroadcast(true);

              break;

            }

          }

          disableController("Select map");
          disableController("Add player token");
          disableController("Add DM token");
          disableController("Add/Remove walls");
          disableController("Add/Remove doors");
          disableController("Toggle UI");

          setSwitchButtonState("Toggle grid", true);

          initiative.clear();
          playersLayer.clear();
          dmLayer.clear();
          grid.clear();

          map.reset();

          gridHelperX = gridHelperToX = 0;
          gridHelperY = gridHelperToY = 0;
          gridHelperStarted = false;
          gridHelperSet = false;
          gridInstructions1stLine.show();
          gridInstructions2ndLine.show();

          PImage cursorCross = loadImage("cursors/cursor_cross_32.png");
          cursor(cursorCross);

          newAppState = AppStates.gridSetup;

        } else {

          enableController("Select map");
          if ( grid.isSet() ) {
            enableController("Add player token");
            enableController("Add DM token");
          }
          enableController("Add/Remove walls");
          enableController("Add/Remove doors");
          enableController("Toggle UI");

          gridInstructions1stLine.hide();
          gridInstructions2ndLine.hide();

          if ( grid.isSet() ) {
            resources.setup();
            logger.info("UserInterface: Resources setup done");
          }

          cursor(ARROW);

          newAppState = AppStates.idle;

          logger.info("UserInterface: Grid setup done");

        }

        break;
      case "Add/Remove walls":

        Button addWall = (Button)controlEvent.getController();
        Textlabel wallInstructions1stLine = (Textlabel)cp5.getController("Wall instructions - 1st line");
        Textlabel wallInstructions2ndLine = (Textlabel)cp5.getController("Wall instructions - 2nd line");

        if ( addWall.isOn() ) {

          disableController("Select map");
          disableController("Grid setup");
          disableController("Add player token");
          disableController("Add DM token");
          disableController("Add/Remove doors");
          disableController("Toggle UI");

          playersLayer.reset();
          dmLayer.reset();
          obstacles.toggleDrawObstacles();

          wallInstructions1stLine.show();
          wallInstructions2ndLine.show();

          PImage cursorCross = loadImage("cursors/cursor_cross_32.png");
          cursor(cursorCross);

          newWall = null;

          newAppState = AppStates.wallSetup;

        } else {

          enableController("Select map");
          enableController("Grid setup");
          if ( grid.isSet() ) {
            enableController("Add player token");
            enableController("Add DM token");
          }
          enableController("Add/Remove doors");
          enableController("Toggle UI");

          obstacles.toggleDrawObstacles();

          wallInstructions1stLine.hide();
          wallInstructions2ndLine.hide();

          cursor(ARROW);

          newWall = null;

          logger.info("UserInterface: Walls setup done");

          newAppState = AppStates.idle;

        }

        break;
      case "Add/Remove doors":

        Button addDoor = (Button)controlEvent.getController();
        Textlabel doorInstructions1stLine = (Textlabel)cp5.getController("Door instructions - 1st line");
        Textlabel doorInstructions2ndLine = (Textlabel)cp5.getController("Door instructions - 2nd line");

        if ( addDoor.isOn() ) {

          disableController("Select map");
          disableController("Grid setup");
          disableController("Add player token");
          disableController("Add DM token");
          disableController("Add/Remove walls");
          disableController("Toggle UI");

          playersLayer.reset();
          dmLayer.reset();
          obstacles.toggleDrawObstacles();

          doorInstructions1stLine.show();
          doorInstructions2ndLine.show();

          PImage cursorCross = loadImage("cursors/cursor_cross_32.png");
          cursor(cursorCross);

          newDoor = null;

          newAppState = AppStates.doorSetup;

        } else {

          enableController("Select map");
          enableController("Grid setup");
          if ( grid.isSet() ) {
            enableController("Add player token");
            enableController("Add DM token");
          }
          enableController("Add/Remove walls");
          enableController("Toggle UI");

          obstacles.toggleDrawObstacles();

          doorInstructions1stLine.hide();
          doorInstructions2ndLine.hide();

          cursor(ARROW);

          newDoor = null;

          logger.info("UserInterface: Doors setup done");

          newAppState = AppStates.idle;

        }

        break;
      case "Add player token":
      case "Add DM token":

        Button addToken = (Button)controlEvent.getController();

        if ( addToken.isOn() ) {

          map.reset();
          playersLayer.reset();
          dmLayer.reset();

          File tokenFile = null;
          if ( controllerName.equals("Add player token") )
            selectInput("Select a token image:", "playerTokenImageSelected", tokenFile, this);
          else
            selectInput("Select a token image:", "dmTokenImageSelected", tokenFile, this);
          fileDialogOpen = true;

          disableController("Select map");
          disableController("Grid setup");
          if ( controllerName.equals("Add player token") )
            disableController("Add DM token");
          else
            disableController("Add player token");
          disableController("Add/Remove walls");
          disableController("Add/Remove doors");
          disableController("Toggle UI");

          newAppState = AppStates.tokenSetup;

        } else {

          enableController("Select map");
          enableController("Grid setup");
          if ( controllerName.equals("Add player token") )
            enableController("Add DM token");
          else
            enableController("Add player token");
          enableController("Add/Remove walls");
          enableController("Add/Remove doors");
          enableController("Toggle UI");

          logger.info("UserInterface: Token setup done");

          newAppState = AppStates.idle;

        }

        break;
      case "Switch active layer":

        switch ( layerShown ) {
          case players:
            layerShown = Layers.dm;
            logger.info("UserInterface: Layer switched to " + dmLayer.getName());
            break;
          case dm:
            layerShown = Layers.all;
            logger.info("UserInterface: Layer switched to All Layers");
            break;
          case all:
            layerShown = Layers.players;
            logger.info("UserInterface: Layer switched to " + playersLayer.getName());
            break;
          default:
            break;
        }

        obstacles.setRecalculateShadows(true);

        break;
      case "Switch environment lighting":

        switch ( obstacles.getIllumination() ) {
          case brightLight:
            obstacles.setIllumination(Illumination.darkness);
            break;
          case dimLight:
            obstacles.setIllumination(Illumination.brightLight);
            break;
          case darkness:
            obstacles.setIllumination(Illumination.dimLight);
            break;
          default:
            break;
        }

        logger.info("UserInterface: Environment lighting switched to " + obstacles.getIllumination().getName());

        obstacles.setRecalculateShadows(true);

        break;
      case "Toggle grid":

        grid.toggleDrawGrid();

        break;
      case "Toggle walls":

        obstacles.toggleDrawObstacles();

        break;
      case "Toggle UI":

        Button toggleUi = (Button)controlEvent.getController();

        if ( toggleUi.isOn() ) {

          togglableControllers.show();
          logger.info("UserInterface: UI buttons shown");

        } else {

          togglableControllers.hide();
          logger.info("UserInterface: UI buttons hidden");

        }

        break;
      case "Toggle camera pan":

        if ( map != null && map.isSet() )
          map.togglePan();

        break;
      case "Toggle camera zoom":

        if ( map != null && map.isSet() )
          map.toggleZoom();

        break;
      case "Toggle touch screen mode":

        cp5.isTouch = !cp5.isTouch;
        logger.info("UserInterface: Touch screen mode " + (cp5.isTouch ? "enabled" : "disabled"));

        break;
      case "Toggle combat mode":

        initiative.toggleDrawInitiativeOrder();

        break;
      case "Toggle mute sound":

        if ( map != null && map.isSet() )
          map.toggleMute();

        break;
      case "Conditions":
      case "Light Sources":
      case "Sight Types":
      case "Sizes":
      case "Other":

        menuItemClicked = true;

        break;
      case "Blinded":

        if ( rightClickedToken == null )
          break;

        resourceName = "Blinded";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Bloodied":

        if ( rightClickedToken == null )
          break;

        resourceName = "Bloodied";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Charmed":

        if ( rightClickedToken == null )
          break;

        resourceName = "Charmed";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Dead":

        if ( rightClickedToken == null )
          break;

        resourceName = "Dead";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Deafened":

        if ( rightClickedToken == null )
          break;

        resourceName = "Deafened";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Frightened":

        if ( rightClickedToken == null )
          break;

        resourceName = "Frightened";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Grappled":

        if ( rightClickedToken == null )
          break;

        resourceName = "Grappled";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Hidden":

        if ( rightClickedToken == null )
          break;

        resourceName = "Hidden";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Incapacitated":

        if ( rightClickedToken == null )
          break;

        resourceName = "Incapacitated";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Invisible":

        if ( rightClickedToken == null )
          break;

        resourceName = "Invisible";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Paralyzed":

        if ( rightClickedToken == null )
          break;

        resourceName = "Paralyzed";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Petrified":

        if ( rightClickedToken == null )
          break;

        resourceName = "Petrified";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Poisoned":

        if ( rightClickedToken == null )
          break;

        resourceName = "Poisoned";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Prone":

        if ( rightClickedToken == null )
          break;

        resourceName = "Prone";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Restrained":

        if ( rightClickedToken == null )
          break;

        resourceName = "Restrained";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Stunned":

        if ( rightClickedToken == null )
          break;

        resourceName = "Stunned";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Unconscious":

        if ( rightClickedToken == null )
          break;

        resourceName = "Unconscious";
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate == null ) {
          logger.error("Resource: Condition " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleCondition(conditionTemplate);
        if ( conditionTemplate.disablesTarget() )
          obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Candle":

        if ( rightClickedToken == null )
          break;

        resourceName = "Candle";
        lightTemplate = resources.getCommonLightSource(resourceName);
        if ( lightTemplate == null ) {
          logger.error("Resource: Common light source " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleLightSource(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Torch":

        if ( rightClickedToken == null )
          break;

        resourceName = "Torch";
        lightTemplate = resources.getCommonLightSource(resourceName);
        if ( lightTemplate == null ) {
          logger.error("Resource: Common light source " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleLightSource(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Lamp":

        if ( rightClickedToken == null )
          break;

        resourceName = "Lamp";
        lightTemplate = resources.getCommonLightSource(resourceName);
        if ( lightTemplate == null ) {
          logger.error("Resource: Common light source " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleLightSource(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Hooded lantern":

        if ( rightClickedToken == null )
          break;

        resourceName = "Hooded Lantern";
        lightTemplate = resources.getCommonLightSource(resourceName);
        if ( lightTemplate == null ) {
          logger.error("Resource: Common light source " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleLightSource(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Light spell":

        if ( rightClickedToken == null )
          break;

        resourceName = "Light";
        lightTemplate = resources.getSpellLightSource(resourceName);
        if ( lightTemplate == null ) {
          logger.error("Resource: Spell light source " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleLightSource(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Daylight":

        if ( rightClickedToken == null )
          break;

        resourceName = "Daylight";
        lightTemplate = resources.getCommonLightSource(resourceName);
        if ( lightTemplate == null ) {
          logger.error("Resource: Spell light source " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleLightSource(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Darkvision 60'":

        if ( rightClickedToken == null )
          break;

        resourceName = "Darkvision 60'";
        lightTemplate = resources.getSightType(resourceName);
        if ( lightTemplate == null ) {
          logger.error("Resource: Sight type " + resourceName + " not found");
          break;
        }

        rightClickedToken.toggleSightType(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Tiny":

        if ( rightClickedToken == null )
          break;

        resourceName = "Tiny";
        sizeTemplate = resources.getSize(resourceName);
        if ( sizeTemplate == null ) {
          logger.error("Resource: Size " + resourceName + " not found");
          break;
        }

        rightClickedToken.setSize(new Size(sizeTemplate.getName(), sizeTemplate.getResizeFactor(), sizeTemplate.isCentered()), resources);
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Small":

        if ( rightClickedToken == null )
          break;

        resourceName = "Small";
        sizeTemplate = resources.getSize(resourceName);
        if ( sizeTemplate == null ) {
          logger.error("Resource: Size " + resourceName + " not found");
          break;
        }

        rightClickedToken.setSize(new Size(sizeTemplate.getName(), sizeTemplate.getResizeFactor(), sizeTemplate.isCentered()), resources);
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Medium":

        if ( rightClickedToken == null )
          break;

        resourceName = "Medium";
        sizeTemplate = resources.getSize(resourceName);
        if ( sizeTemplate == null ) {
          logger.error("Resource: Size " + resourceName + " not found");
          break;
        }

        rightClickedToken.setSize(new Size(sizeTemplate.getName(), sizeTemplate.getResizeFactor(), sizeTemplate.isCentered()), resources);
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Large":

        if ( rightClickedToken == null )
          break;

        resourceName = "Large";
        sizeTemplate = resources.getSize(resourceName);
        if ( sizeTemplate == null ) {
          logger.error("Resource: Size " + resourceName + " not found");
          break;
        }

        rightClickedToken.setSize(new Size(sizeTemplate.getName(), sizeTemplate.getResizeFactor(), sizeTemplate.isCentered()), resources);
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Huge":

        if ( rightClickedToken == null )
          break;

        resourceName = "Huge";
        sizeTemplate = resources.getSize(resourceName);
        if ( sizeTemplate == null ) {
          logger.error("Resource: Size " + resourceName + " not found");
          break;
        }

        rightClickedToken.setSize(new Size(sizeTemplate.getName(), sizeTemplate.getResizeFactor(), sizeTemplate.isCentered()), resources);
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Gargantuan":

        if ( rightClickedToken == null )
          break;

        resourceName = "Gargantuan";
        sizeTemplate = resources.getSize(resourceName);
        if ( sizeTemplate == null ) {
          logger.error("Resource: Size " + resourceName + " not found");
          break;
        }

        rightClickedToken.setSize(new Size(sizeTemplate.getName(), sizeTemplate.getResizeFactor(), sizeTemplate.isCentered()), resources);
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Change token layer":

        if ( rightClickedToken == null )
          break;

        if ( playersLayer.hasToken(rightClickedToken) ) {

          playersLayer.removeToken(rightClickedToken);
          dmLayer.addToken(rightClickedToken);

        } else {

          dmLayer.removeToken(rightClickedToken);
          playersLayer.addToken(rightClickedToken);

        }

        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
      case "Remove token":

        if ( rightClickedToken == null )
          break;

        if ( playersLayer.hasToken(rightClickedToken) ) {

          playersLayer.removeToken(rightClickedToken);

        } else {

          dmLayer.removeToken(rightClickedToken);

        }

        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);

        break;
    }

    return newAppState;

  }

  void mapFileSelected(File mapFile) {

    boolean isVideo;
    boolean isMuted;
    boolean mapLoaded;

    fileDialogOpen = false;

    if ( mapFile == null || !fileExists(mapFile.getAbsolutePath()) )
      return;

    MimetypesFileTypeMap mimetypesMap = new MimetypesFileTypeMap();
    mimetypesMap.addMimeTypes("image/png image/x-png png");
    mimetypesMap.addMimeTypes("image/jpeg jpg jpeg");
    mimetypesMap.addMimeTypes("image/bmp image/x-ms-bmp bmp");
    mimetypesMap.addMimeTypes("image/gif gif");
    mimetypesMap.addMimeTypes("image/tga image/x-tga tga");
    mimetypesMap.addMimeTypes("video/mp4 mp4 m4v");
    String mimetype = mimetypesMap.getContentType(mapFile);
    logger.trace("UserInterface: Map file mime type: " + mimetype);
    String type = mimetype.split("/")[0];
    if ( (!type.equals("image") && !type.equals("video")) || mimetype.equals("image/tiff") ) {
      logger.error("UserInterface: Selected map file is not of a supported image or video type");
      uiDialogs.showErrorDialog("Selected map file is not of a supported image or video type: " + mapFile.getName(), "Unknown map file type");
      return;
    }

    isVideo = type.equals("video");
    isMuted = getSwitchButtonState("Toggle mute sound");

    mapLoaded = map.setup(mapFile.getAbsolutePath(), false, isVideo, isMuted);
    if ( !mapLoaded )
      return;

    initiative.clear();
    obstacles.setIllumination(Illumination.brightLight);
    obstacles.clear();
    playersLayer.clear();
    dmLayer.clear();
    grid.clear();

    enableController("Grid setup");
    disableController("Add player token");
    disableController("Add DM token");
    enableController("Add/Remove walls");
    enableController("Add/Remove doors");
    removeController("Map logo");

    if ( isVideo )
      showController("Toggle mute sound");
    else
      hideController("Toggle mute sound");

    logger.info("UserInterface: Map setup done");

  }

  // Method called during grid setup, either by mouse click, mouse drag or mouse release
  void gridHelperSetup(int _mouseX, int _mouseY, boolean start, boolean done) {

    if ( isInside(_mouseX, _mouseY) )
      return;

    // Mouse click
    if ( start ) {

      // Clear previous grid
      grid.clear();

      // Check if grid helper start point is inside the map
      Point gridHelperStart = map.mapCanvasToMap(new Point(_mouseX, _mouseY));
      if (
        gridHelperStart.x < 0 || gridHelperStart.x > map.getWidth() ||
        gridHelperStart.y < 0 || gridHelperStart.y > map.getHeight()
      ) {
        resetGridHelper();
        return;
      }

      // Mark grid helper as started
      gridHelperX = gridHelperToX = max(_mouseX, 0);
      gridHelperY = gridHelperToY = max(_mouseY, 0);
      gridHelperStarted = true;
      gridHelperSet = false;

    // Mouse drag
    } else {

      // Continue only if grid helper start point was inside the map
      if ( !gridHelperStarted )
        return;

      // Check if grid helper end point is inside the map
      Point gridHelperEnd = map.mapCanvasToMap(new Point(_mouseX, _mouseY));
      if (
        gridHelperEnd.x < 0 || gridHelperEnd.x > map.getWidth() ||
        gridHelperEnd.y < 0 || gridHelperEnd.y > map.getHeight()
      ) {
        resetGridHelper();
        return;
      }

      // Mark grid helper as finished
      gridHelperToX = max(_mouseX, 0);
      gridHelperToY = max(_mouseY, 0);
      gridHelperSet = true;

    }

    // Mouse release
    if ( done ) {

      // Continue only if grid helper was properly started and finished
      if ( !gridHelperStarted || !gridHelperSet ) {
        resetGridHelper();
        return;
      }

      // Continue only if cell size is at least 20x20
      if ( abs(gridHelperX-gridHelperToX) < 60 || abs(gridHelperY-gridHelperToY) < 60 ) {
        resetGridHelper();
        return;
      }

      // Invert start and end points if needed, so that start is the top left corner and end is the bottom right corner
      if ( gridHelperToX < gridHelperX && gridHelperToY < gridHelperY ) {
        int tmpGridHelperX = gridHelperX;
        int tmpGridHelperY = gridHelperY;
        gridHelperX = gridHelperToX;
        gridHelperY = gridHelperToY;
        gridHelperToX = tmpGridHelperX;
        gridHelperToY = tmpGridHelperY;
      }

      // Map helper start and end points, which are points with canvas coordinates, to points with map coordinates
      // These new points will be used to calculate cell coordinates in the map space
      Point mapSpaceGridHelper = map.mapCanvasToMap(new Point(gridHelperX, gridHelperY));
      Point mapSpaceGridHelperTo = map.mapCanvasToMap(new Point(gridHelperToX, gridHelperToY));

      // Setup a grid
      grid.setupFromHelper(mapSpaceGridHelper, mapSpaceGridHelperTo);

    }

  }

  // Method called during grid setup by key presses, to adjust either grid helper top left corner or bottom right corner
  void gridHelperSetupAdjustment(int xAdjustment, int yAdjustment, boolean adjustBottomRightCorner) {

    // Continue only if grid helper has already been drawn
    if ( !gridHelperSet )
      return;

    // Clear previous grid
    grid.clear();

    // Adjust either grid helper start point or end point
    if ( adjustBottomRightCorner ) {
      gridHelperToX += xAdjustment;
      gridHelperToY += yAdjustment;
    } else {
      gridHelperX += xAdjustment;
      gridHelperY += yAdjustment;
    }

    // Check if grid helper start point is inside the map
    Point gridHelperStart = map.mapCanvasToMap(new Point(gridHelperX, gridHelperY));
    if (
      gridHelperStart.x < 0 || gridHelperStart.x > map.getWidth() ||
      gridHelperStart.y < 0 || gridHelperStart.y > map.getHeight()
    ) {
      resetGridHelper();
      return;
    }

    // Check if grid helper end point is inside the map
    Point gridHelperEnd = map.mapCanvasToMap(new Point(gridHelperToX, gridHelperToY));
    if (
      gridHelperEnd.x < 0 || gridHelperEnd.x > map.getWidth() ||
      gridHelperEnd.y < 0 || gridHelperEnd.y > map.getHeight()
    ) {
      resetGridHelper();
      return;
    }

    // Continue only if cell size is at least 20x20
    if ( abs(gridHelperX-gridHelperToX) < 60 || abs(gridHelperY-gridHelperToY) < 60 ) {
      resetGridHelper();
      return;
    }

    // Map helper start and end points, which are points with canvas coordinates, to points with map coordinates
    // These new points will be used to calculate cell coordinates in the map space
    Point mapSpaceGridHelper = map.mapCanvasToMap(new Point(gridHelperX, gridHelperY));
    Point mapSpaceGridHelperTo = map.mapCanvasToMap(new Point(gridHelperToX, gridHelperToY));

    // Setup a grid
    grid.setupFromHelper(mapSpaceGridHelper, mapSpaceGridHelperTo);

  }

  void resetGridHelper() {

    gridHelperX = gridHelperToX = 0;
    gridHelperY = gridHelperToY = 0;
    gridHelperStarted = false;
    gridHelperSet = false;

  }

  void playerTokenImageSelected(File tokenImageFile) {

    fileDialogOpen = false;

    if ( tokenImageFile == null )
      return;

    playersLayer.addToken(tokenImageFile);

  }

  void dmTokenImageSelected(File tokenImageFile) {

    fileDialogOpen = false;

    if ( tokenImageFile == null )
      return;

    dmLayer.addToken(tokenImageFile);

  }

  AppStates moveToken(int _mouseX, int _mouseY, boolean done) {

    AppStates newState = appState;

    if ( playersLayer.getToken(_mouseX, _mouseY) != null ) {
      newState = playersLayer.moveToken(_mouseX, _mouseY, done);
    } else {
      newState = dmLayer.moveToken(_mouseX, _mouseY, done);
    }

    if ( done ) {

      setSwitchButtonState("Add player token", false);
      setSwitchButtonState("Add DM token", false);

    }

    return newState;

  }

  boolean isOverToken(int _mouseX, int _mouseY) {

    if ( playersLayer.isOverToken(_mouseX, _mouseY) || dmLayer.isOverToken(_mouseX, _mouseY) )
      return true;

    return false;

  }

  void newWallSetup(int _mouseX, int _mouseY, boolean isDoubleClick) {

    if ( isInside(_mouseX, _mouseY) )
      return;

    // Double click to stop adding new wall segments
    if ( isDoubleClick ) {
      newWall = null;
      return;
    }

    if ( newWall == null )
      newWall = new Wall(canvas);

    // Vertex with canvas coordinates ignoring current transformations (pan and scale), used to draw vertex on canvas
    Point canvasVertex = new Point(
      map.transformX(_mouseX),
      map.transformY(_mouseY)
    );

    // Vertex with map coordinates, used when scene is saved/loaded
    Point mapVertex = map.mapCanvasToMap(canvasVertex);

    newWall.addVertex(
      canvasVertex.x, canvasVertex.y,
      mapVertex.x, mapVertex.y
    );

    // If wall has two vertexes already
    if ( newWall.isSet() ) {

      // Add it to obstacles
      obstacles.addWall(newWall);
      logger.trace("UserInterface: New wall added");

      // Create a new wall segment, its first vertex will be the last vertex of the previous segment
      newWall = new Wall(canvas);
      newWall.addVertex(
        canvasVertex.x, canvasVertex.y,
        mapVertex.x, mapVertex.y
      );

    }

  }

  void removeWall(int _mouseX, int _mouseY) {

    Wall wallToRemove = obstacles.getClosestWall(map.transformX(_mouseX), map.transformY(_mouseY), 10);

    if ( wallToRemove != null )
      obstacles.removeWall(wallToRemove);

  }

  void newDoorSetup(int _mouseX, int _mouseY) {

    if ( isInside(_mouseX, _mouseY) )
      return;

    if ( newDoor == null )
      newDoor = new Door(canvas);

    // Vertex with canvas coordinates ignoring current transformations (pan and scale), used to draw vertex on canvas
    Point canvasVertex = new Point(
      map.transformX(_mouseX),
      map.transformY(_mouseY)
    );

    // Vertex with map coordinates, used when scene is saved/loaded
    Point mapVertex = map.mapCanvasToMap(canvasVertex);

    newDoor.addVertex(
      canvasVertex.x, canvasVertex.y,
      mapVertex.x, mapVertex.y
    );

    // If door has two vertexes already
    if ( newDoor.isSet() ) {

      // Add it to obstacles
      obstacles.addDoor(newDoor);
      logger.trace("UserInterface: New door added");

      // Finish this setup
      newDoor = null;

    }

  }

  void removeDoor(int _mouseX, int _mouseY) {

    Door doorToRemove = obstacles.getClosestDoor(map.transformX(_mouseX), map.transformY(_mouseY), 10);

    if ( doorToRemove != null )
      obstacles.removeDoor(doorToRemove);

  }

  void openDoor(int _mouseX, int _mouseY) {

    Door doorToToggle = obstacles.getClosestDoor(map.transformX(_mouseX), map.transformY(_mouseY), 20);

    if ( doorToToggle != null ) {

      doorToToggle.toggle();
      obstacles.setRecalculateShadows(true);

    }

  }

  void showMenu(int _mouseX, int _mouseY) {

    if ( !resources.isSet() )
      return;

    Token token;

    String controllerName;
    String conditionName;
    String lightSourceName;
    String sightTypeName;
    String sizeName;

    token = playersLayer.getToken(_mouseX, _mouseY);
    if ( token == null )
      token = dmLayer.getToken(_mouseX, _mouseY);
    if ( token == null )
      return;

    rightClickedToken = token;

    // Turn off all menu buttons
    ArrayList<HashMap<String, String>> toControllerMaps = new ArrayList<HashMap<String, String>>(
      Arrays.asList(
        conditionToController,
        lightSourceToController,
        sightTypeToController,
        sizeToController
      )
    );
    for ( HashMap<String, String> toControllerMap: toControllerMaps ) {
      for ( String resourceName: toControllerMap.keySet() ) {
        controllerName = toControllerMap.get(resourceName);
        setSwitchButtonState(controllerName, false, false);
      }
    }

    // Turn on condition buttons that are active for this token
    for ( Condition condition: rightClickedToken.getConditions() ) {
      conditionName = condition.getName();
      controllerName = conditionToController.get(conditionName);
      setSwitchButtonState(controllerName, true, false);
    }

    // Turn on light source buttons that are active for this token
    for ( Light lightSource: rightClickedToken.getLightSources() ) {
      lightSourceName = lightSource.getName();
      controllerName = lightSourceToController.get(lightSourceName);
      setSwitchButtonState(controllerName, true, false);
    }

    // Turn on sight type buttons that are active for this token
    for ( Light sightType: rightClickedToken.getSightTypes() ) {
      sightTypeName = sightType.getName();
      controllerName = sightTypeToController.get(sightTypeName);
      setSwitchButtonState(controllerName, true, false);
    }

    // Turn on the size button that is active for this token
    sizeName = rightClickedToken.getSize().getName();
    controllerName = sizeToController.get(sizeName);
    setSwitchButtonState(controllerName, true, false);

    tokenMenu.setPosition(_mouseX, _mouseY);
    tokenMenu.show();

  }

  void hideMenu(int _mouseX, int _mouseY) {

    if ( isInsideMenu(_mouseX, _mouseY) )
      return;

    tokenMenu.hide();
    rightClickedToken = null;

  }

  boolean isInsideInitiativeOrder() {

    return initiative.getDrawInitiativeOrder() && initiative.isInside(mouseX, mouseY);

  }

  AppStates changeInitiativeOrder(int _mouseX, boolean done) {

    return initiative.changeInitiativeOrder(_mouseX, done);

  }

  AppStates panMap(int _mouseX, int _pmouseX, int _mouseY, int _pmouseY, boolean done) {

    if ( map == null || !map.isSet() || !map.isPanEnabled() )
      return appState;

    map.pan(_mouseX, _pmouseX, _mouseY, _pmouseY);

    if ( done )
      return AppStates.idle;
    else
      return AppStates.mapPan;

  }

  void zoomMap(int mouseWheelAmount, int _mouseX, int _mouseY) {

    if ( map == null || !map.isSet() )
      return;

    map.zoom(mouseWheelAmount, _mouseX, _mouseY);

  }

  void saveScene(File sceneFolder) {

    try {

      fileDialogOpen = false;

      if ( sceneFolder == null )
        return;
      if ( map.getFilePath() == null )
        return;

      int initiativeGroupsIndex;
      int obstaclesIndex;

      logger.info("UserInterface: Saving scene to folder: " + sceneFolder.getAbsolutePath());

      JSONObject sceneJson = new JSONObject();

      JSONObject mapJson = new JSONObject();
      if ( map.isSet() ) {
        mapJson.setString("filePath", getImageSavePath(map.getFilePath()));
        mapJson.setBoolean("fitToScreen", map.getFitToScreen());
        mapJson.setBoolean("isVideo", map.isVideo());
      }
      sceneJson.setJSONObject("map", mapJson);

      logger.debug("UserInterface: Map saved");

      JSONObject gridJson = new JSONObject();
      if ( grid.isSet() ) {
        gridJson.setInt("firstCellCenterX", grid.getMapGridFirstCellCenter().x);
        gridJson.setInt("firstCellCenterY", grid.getMapGridFirstCellCenter().y);
        gridJson.setInt("lastCellCenterX", grid.getMapGridLastCellCenter().x);
        gridJson.setInt("lastCellCenterY", grid.getMapGridLastCellCenter().y);
        gridJson.setInt("cellWidth", grid.getCellWidth());
        gridJson.setInt("cellHeight", grid.getCellHeight());
      }
      gridJson.setBoolean("drawGrid", grid.getDrawGrid());
      sceneJson.setJSONObject("grid", gridJson);

      logger.debug("UserInterface: Grid saved");

      JSONObject initiativeJson = new JSONObject();
      initiativeJson.setBoolean("drawInitiativeOrder", initiative.getDrawInitiativeOrder());
      JSONArray initiativeGroupsArray = new JSONArray();
      initiativeGroupsIndex = 0;
      for ( Initiative.InitiativeGroup group: initiative.getInitiativeGroups() ) {
        JSONObject initiativeGroupJson = new JSONObject();
        initiativeGroupJson.setString("name", group.getName());
        initiativeGroupJson.setInt("position", initiativeGroupsIndex);
        initiativeGroupsArray.setJSONObject(initiativeGroupsIndex, initiativeGroupJson);
        initiativeGroupsIndex += 1;
      }
      initiativeJson.setJSONArray("initiativeGroups", initiativeGroupsArray);
      sceneJson.setJSONObject("initiative", initiativeJson);

      logger.debug("UserInterface: Initiative saved");

      sceneJson.setJSONArray("playerTokens", getTokensJsonArray(playersLayer.getTokens()));
      sceneJson.setJSONArray("dmTokens", getTokensJsonArray(dmLayer.getTokens()));

      logger.debug("UserInterface: Tokens saved");

      JSONArray wallsArray = new JSONArray();
      obstaclesIndex = 0;
      for ( Wall wall: obstacles.getWalls() ) {
        JSONObject wallJson = new JSONObject();
        ArrayList<PVector> wallVertexes = wall.getMapVertexes();
        JSONArray wallVertexesJson = new JSONArray();
        for ( PVector wallVertex: wallVertexes ) {
          JSONArray wallVertexJson = new JSONArray();
          wallVertexJson.append(wallVertex.x);
          wallVertexJson.append(wallVertex.y);
          wallVertexesJson.append(wallVertexJson);
        }
        wallJson.setJSONArray("vertexes", wallVertexesJson);
        wallsArray.setJSONObject(obstaclesIndex, wallJson);
        obstaclesIndex += 1;
      }
      sceneJson.setJSONArray("walls", wallsArray);

      logger.debug("UserInterface: Walls saved");

      JSONArray doorsArray = new JSONArray();
      obstaclesIndex = 0;
      for ( Door door: obstacles.getDoors() ) {
        JSONObject doorJson = new JSONObject();
        doorJson.setBoolean("closed", door.getClosed());
        ArrayList<PVector> doorVertexes = door.getMapVertexes();
        JSONArray doorVertexesJson = new JSONArray();
        for ( PVector doorVertex: doorVertexes ) {
          JSONArray doorVertexJson = new JSONArray();
          doorVertexJson.append(doorVertex.x);
          doorVertexJson.append(doorVertex.y);
          doorVertexesJson.append(doorVertexJson);
        }
        doorJson.setJSONArray("vertexes", doorVertexesJson);
        doorsArray.setJSONObject(obstaclesIndex, doorJson);
        obstaclesIndex += 1;
      }
      sceneJson.setJSONArray("doors", doorsArray);

      logger.debug("UserInterface: Doors saved");

      JSONObject illuminationJson = new JSONObject();
      switch ( obstacles.getIllumination() ) {
        case brightLight:
          illuminationJson.setString("lighting", "brightLigt");
          break;
        case dimLight:
          illuminationJson.setString("lighting", "dimLight");
          break;
        case darkness:
          illuminationJson.setString("lighting", "darkness");
          break;
      }
      sceneJson.setJSONObject("illumination", illuminationJson);

      logger.debug("UserInterface: Environment lighting saved");

      File mapFile = new File(map.getFilePath());
      String mapFileName = mapFile.getName();
      String[] mapFileNameTokens = mapFileName.split("\\.(?=[^\\.]+$)");
      String mapBaseName = mapFileNameTokens[0];

      String sceneSavePath = sceneFolder.getAbsolutePath() + File.separator + mapBaseName + ".json";
      boolean sceneSaved = saveJSONObject(sceneJson, sceneSavePath);

      if ( sceneSaved ) {
        logger.info("UserInterface: Scene saved to: " + sceneSavePath);
      } else {
        logger.error("UserInterface: Scene could not be saved: " + sceneSavePath);
        uiDialogs.showErrorDialog("Scene could not be saved: " + sceneSavePath, "Error saving scene");
      }

    } catch ( Exception e ) {
      logger.error("UserInterface: Error saving scene");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  JSONArray getTokensJsonArray(ArrayList<Token> tokens) {

    JSONArray tokensArray = new JSONArray();
    int tokensIndex = 0;

    for ( Token token: tokens ) {

      JSONObject tokenJson = new JSONObject();

      tokenJson.setString("name", token.getName());
      tokenJson.setString("imagePath", getImageSavePath(token.getImagePath()));

      tokenJson.setString("size", token.getSize().getName());

      Cell cell = token.getCell();
      tokenJson.setInt("row", cell.getRow());
      tokenJson.setInt("column", cell.getColumn());

      tokenJson.setJSONArray("lightSources", getLightsJsonArray(token.getLightSources()));
      tokenJson.setJSONArray("sightTypes", getLightsJsonArray(token.getSightTypes()));
      tokenJson.setJSONArray("conditions", getConditionsJsonArray(token.getConditions()));

      tokensArray.setJSONObject(tokensIndex, tokenJson);
      tokensIndex += 1;

    }

    return tokensArray;

  }

  JSONArray getLightsJsonArray(ArrayList<Light> lights) {

    JSONArray tokenLightsArray = new JSONArray();
    int lightsIndex = 0;

    for ( Light light: lights ) {
      JSONObject lightJson = new JSONObject();
      lightJson.setString("name", light.getName());
      tokenLightsArray.setJSONObject(lightsIndex, lightJson);
      lightsIndex += 1;
    }

    return tokenLightsArray;

  }

  JSONArray getConditionsJsonArray(ArrayList<Condition> conditions) {

    JSONArray tokenConditionsArray = new JSONArray();
    int conditionsIndex = 0;

    for ( Condition condition: conditions ) {
      JSONObject conditionJson = new JSONObject();
      conditionJson.setString("name", condition.getName());
      tokenConditionsArray.setJSONObject(conditionsIndex, conditionJson);
      conditionsIndex += 1;
    }

    return tokenConditionsArray;

  }

  String getImageSavePath(String imageAbsolutePath) {

    if ( imageAbsolutePath == null || imageAbsolutePath.trim().isEmpty() )
      return "";

    String imageSavePath = null;

    // Check if image path is inside sketchPath()
    if ( imageAbsolutePath != imageAbsolutePath.replaceFirst("^(?i)" + Pattern.quote(sketchPath()), "") ) {

      // If it is, remove sketchPath() from image path
      imageSavePath = imageAbsolutePath.replaceFirst("^(?i)" + Pattern.quote(sketchPath()), "");

      // If file separator is "\", replace it by "/", to facilitate when loading a scene
      if ( File.separatorChar == '\\' )
        imageSavePath = imageSavePath.replaceAll("\\\\", "/");

    // If image is not inside sketchPath()
    } else {

      // Return its absolute path
      imageSavePath = imageAbsolutePath;

    }

    return imageSavePath;

  }

  void loadScene(File sceneFile) {

    try {

      fileDialogOpen = false;

      if ( sceneFile == null || !fileExists(sceneFile.getAbsolutePath()) )
        return;

      logger.info("UserInterface: Loading scene from: " + sceneFile.getAbsolutePath());

      appState = AppStates.sceneLoad;

      map.clear();
      grid.clear();
      playersLayer.clear();
      dmLayer.clear();
      obstacles.clear();
      initiative.clear();

      logger.debug("UserInterface: Scene reset");

      setSwitchButtonState("Toggle combat mode", false);
      setSwitchButtonState("Toggle grid", false);
      removeController("Map logo");

      JSONObject sceneJson = loadJSONObject(sceneFile.getAbsolutePath());

      JSONObject mapJson = sceneJson.getJSONObject("map");
      if ( mapJson != null ) {

        String mapFilePath = mapJson.getString("filePath", "");
        boolean fitToScreen = mapJson.getBoolean("fitToScreen", false);
        boolean isVideo = mapJson.getBoolean("isVideo", false);
        String logoFilePath = mapJson.getString("logoFilePath", "");
        String logoLink = mapJson.getString("logoLink", "");

        String mapLoadPath = getImageLoadPath(mapFilePath);
        if ( !mapLoadPath.isEmpty() ) {
          mapFilePath = mapLoadPath;
        } else {
          logger.error("UserInterface: Map file not found: " + mapFilePath);
          logger.error("UserInterface: Scene could not be loaded: " + sceneFile.getAbsolutePath());
          reset();
          uiDialogs.showErrorDialog("Map file not found: " + mapFilePath, "Error loading scene");
          return;
        }

        boolean isMuted = getSwitchButtonState("Toggle mute sound");

        boolean mapLoaded = map.setup(mapFilePath, fitToScreen, isVideo, isMuted);
        if ( !mapLoaded ) {
          logger.error("UserInterface: Map could not be loaded");
          logger.error("UserInterface: Scene could not be loaded: " + sceneFile.getAbsolutePath());
          reset();
          uiDialogs.showErrorDialog("Map could not be loaded: " + mapFilePath, "Error loading scene");
          return;
        }

        enableController("Grid setup");
        enableController("Add/Remove walls");
        enableController("Add/Remove doors");

        if ( isVideo )
          showController("Toggle mute sound");
        else
          hideController("Toggle mute sound");

        // Show logo image as link, if available

        String logoLoadPath = getImageLoadPath(logoFilePath);
        if ( !logoLoadPath.isEmpty() ) {
          logoFilePath = logoLoadPath;
        } else {
          logoFilePath = null;
        }

        if ( logoFilePath != null ) {
          Point logoMinPosition = new Point(
            controllersBottomRightInitialX + squareButtonWidth,
            controllersBottomRightInitialY - controllersSpacing
          );
          addLogoButton(logoFilePath, logoMinPosition, logoLink);
        }

        logger.debug("UserInterface: Map loaded");

      }

      JSONObject gridJson = sceneJson.getJSONObject("grid");
      if ( gridJson != null ) {

        int firstCellCenterX = gridJson.getInt("firstCellCenterX", 0);
        int firstCellCenterY = gridJson.getInt("firstCellCenterY", 0);
        int lastCellCenterX = gridJson.getInt("lastCellCenterX", 0);
        int lastCellCenterY = gridJson.getInt("lastCellCenterY", 0);
        int cellWidth = gridJson.getInt("cellWidth", 0);
        int cellHeight = gridJson.getInt("cellHeight", 0);
        boolean drawGrid = gridJson.getBoolean("drawGrid", false);

        Point mapFirstCellCenter = new Point(firstCellCenterX, firstCellCenterY);
        Point mapLastCellCenter = new Point(lastCellCenterX, lastCellCenterY);

        grid.setup(mapFirstCellCenter, mapLastCellCenter, cellWidth, cellHeight, false);

        if ( drawGrid )
          setSwitchButtonState("Toggle grid", true);

        logger.debug("UserInterface: Grid loaded");

      }

      if ( grid.isSet() ) {

        resources.setup();
        logger.debug("UserInterface: Resources setup");

      }

      if ( grid.isSet() ) {

        setTokensFromJsonArray(playersLayer, sceneJson.getJSONArray("playerTokens"));
        setTokensFromJsonArray(dmLayer, sceneJson.getJSONArray("dmTokens"));

        enableController("Add player token");
        enableController("Add DM token");

        logger.debug("UserInterface: Tokens loaded");

      } else {

        disableController("Add player token");
        disableController("Add DM token");

      }

      JSONObject initiativeJson = sceneJson.getJSONObject("initiative");
      if ( initiativeJson != null ) {

        boolean drawInitiativeOrder = initiativeJson.getBoolean("drawInitiativeOrder");
        if ( drawInitiativeOrder )
          setSwitchButtonState("Toggle combat mode", true);

        JSONArray initiativeGroupsArray = initiativeJson.getJSONArray("initiativeGroups");
        if ( initiativeGroupsArray != null ) {
          for ( int i = 0; i < initiativeGroupsArray.size(); i++ ) {

            JSONObject initiativeGroupJson = initiativeGroupsArray.getJSONObject(i);
            String groupName = initiativeGroupJson.getString("name");
            int groupPosition = initiativeGroupJson.getInt("position");

            initiative.moveGroupTo(groupName, groupPosition);

          }
        }

        logger.debug("UserInterface: Initiative loaded");

      }

      JSONArray wallsArray = sceneJson.getJSONArray("walls");
      if ( wallsArray != null ) {

        for ( int i = 0; i < wallsArray.size(); i++ ) {

          Wall wall = new Wall(canvas);
          JSONObject wallJson = wallsArray.getJSONObject(i);
          JSONArray wallVertexesJson = wallJson.getJSONArray("vertexes");
          for ( int j = 0; j < wallVertexesJson.size(); j++ ) {
            JSONArray wallVertexJson = wallVertexesJson.getJSONArray(j);

            // Vertex with map coordinates
            Point mapVertex = new Point(
              wallVertexJson.getInt(0),
              wallVertexJson.getInt(1)
            );
            // Vertex with canvas coordinates
            Point canvasVertex = map.mapMapToCanvas(mapVertex);

            wall.addVertex(
              canvasVertex.x, canvasVertex.y,
              mapVertex.x, mapVertex.y
            );
          }

          obstacles.addWall(wall);

        }

        logger.debug("UserInterface: Walls loaded");

      }

      JSONArray doorsArray = sceneJson.getJSONArray("doors");
      if ( doorsArray != null ) {

        for ( int i = 0; i < doorsArray.size(); i++ ) {

          Door door = new Door(canvas);
          JSONObject doorJson = doorsArray.getJSONObject(i);
          boolean closed = doorJson.getBoolean("closed");
          door.setClosed(closed);
          JSONArray doorVertexesJson = doorJson.getJSONArray("vertexes");
          for ( int j = 0; j < doorVertexesJson.size(); j++ ) {
            JSONArray doorVertexJson = doorVertexesJson.getJSONArray(j);

            // Vertex with map coordinates
            Point mapVertex = new Point(
              doorVertexJson.getInt(0),
              doorVertexJson.getInt(1)
            );
            // Vertex with canvas coordinates
            Point canvasVertex = map.mapMapToCanvas(mapVertex);

            door.addVertex(
              canvasVertex.x, canvasVertex.y,
              mapVertex.x, mapVertex.y
            );

          }

          obstacles.addDoor(door);

        }

        logger.debug("UserInterface: Doors loaded");

      }

      JSONObject illuminationJson = sceneJson.getJSONObject("illumination");
      if ( illuminationJson != null ) {

        String lighting = illuminationJson.getString("lighting");
        switch ( lighting ) {
          case "brightLigt":
            obstacles.setIllumination(Illumination.brightLight);
            break;
          case "dimLight":
            obstacles.setIllumination(Illumination.dimLight);
            break;
          case "darkness":
            obstacles.setIllumination(Illumination.darkness);
            break;
        }

        logger.debug("UserInterface: Environment lighting loaded");

      }

      layerShown = Layers.players;

      obstacles.setRecalculateShadows(true);

      appState = AppStates.idle;

      logger.info("UserInterface: Scene loaded from: " + sceneFile.getAbsolutePath());

    } catch ( Exception e ) {
      logger.error("UserInterface: Error loading scene");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  void setTokensFromJsonArray(Layer layer, JSONArray tokensArray) {

    if ( tokensArray != null ) {
      for ( int i = 0; i < tokensArray.size(); i++ ) {

        JSONObject tokenJson = tokensArray.getJSONObject(i);
        String tokenName = tokenJson.getString("name");
        String tokenImagePath = tokenJson.getString("imagePath");

        String tokenSizeName = tokenJson.getString("size", "Medium");
        Size tokenSize = resources.getSize(tokenSizeName);
        if ( tokenSize == null ) {
          logger.error("UserInterface: Token " + tokenName + " size not found: " + tokenSizeName);
          continue;
        }

        int tokenRow = tokenJson.getInt("row");
        int tokenColumn = tokenJson.getInt("column");

        String tokenImageLoadPath = getImageLoadPath(tokenImagePath);
        if ( !tokenImageLoadPath.isEmpty() ) {
          tokenImagePath = tokenImageLoadPath;
        } else {
          logger.error("UserInterface: Token " + tokenName + " image not found: " + tokenImagePath);
          continue;
        }

        Cell cell = grid.getCellAt(tokenRow, tokenColumn);
        Token token = new Token(canvas, grid, obstacles);
        Light lineOfSightTemplate = resources.getSightType("Line of Sight");
        Light tokenLineOfSight = new Light(lineOfSightTemplate.getName(), lineOfSightTemplate.getBrightLightRadius(), lineOfSightTemplate.getDimLightRadius());
        token.setup(tokenName, tokenImagePath, grid.getCellWidth(), grid.getCellHeight(), tokenSize, tokenLineOfSight);
        token.setCell(cell);

        for ( Light lightSource: getLightSourcesFromJsonArray(tokenName, tokenJson.getJSONArray("lightSources")) )
          token.toggleLightSource(new Light(lightSource.getName(), lightSource.getBrightLightRadius(), lightSource.getDimLightRadius()));

        for ( Light sightType: getSightTypesFromJsonArray(tokenName, tokenJson.getJSONArray("sightTypes")) )
          token.toggleSightType(new Light(sightType.getName(), sightType.getBrightLightRadius(), sightType.getDimLightRadius()));

        for ( Condition condition: getConditionsFromJsonArray(tokenName, tokenJson.getJSONArray("conditions"), tokenSize) )
          token.toggleCondition(condition);

        layer.addToken(token);

      }
    }

  }

  ArrayList<Light> getLightSourcesFromJsonArray(String tokenName, JSONArray lightsArray) {

    ArrayList<Light> lights = new ArrayList<Light>();

    if ( lightsArray != null ) {
      for ( int j = 0; j < lightsArray.size(); j++ ) {
        JSONObject lightJson = lightsArray.getJSONObject(j);
        String name = lightJson.getString("name");
        Light light = resources.getCommonLightSource(name);
        if ( light == null )
          light = resources.getSpellLightSource(name);
        if ( light != null ) {
          lights.add(light);
        } else {
          logger.error("UserInterface: Token " + tokenName + " light source not found: " + name);
          continue;
        }
      }
    }

    return lights;

  }

  ArrayList<Light> getSightTypesFromJsonArray(String tokenName, JSONArray sightsArray) {

    ArrayList<Light> sights = new ArrayList<Light>();

    if ( sightsArray != null ) {
      for ( int j = 0; j < sightsArray.size(); j++ ) {
        JSONObject sightJson = sightsArray.getJSONObject(j);
        String name = sightJson.getString("name");
        Light sight = resources.getSightType(name);
        if ( sight != null ) {
          sights.add(sight);
        } else {
          logger.error("UserInterface: Token " + tokenName + " sight type not found: " + name);
          continue;
        }
      }
    }

    return sights;

  }

  ArrayList<Condition> getConditionsFromJsonArray(String tokenName, JSONArray conditionsArray, Size tokenSize) {

    ArrayList<Condition> conditions = new ArrayList<Condition>();

    if ( conditionsArray != null ) {
      for ( int j = 0; j < conditionsArray.size(); j++ ) {
        JSONObject conditionJson = conditionsArray.getJSONObject(j);
        String name = conditionJson.getString("name");
        Condition condition = resources.getCondition(name, tokenSize);
        if ( condition != null ) {
          conditions.add(condition);
        } else {
          logger.error("UserInterface: Token " + tokenName + " condition not found: " + name);
          continue;
        }
      }
    }

    return conditions;

  }

  String getImageLoadPath(String imagePathFromJson) {

    if ( imagePathFromJson == null || imagePathFromJson.trim().isEmpty() )
      return "";

    String imageLoadPath = null;
    String imagePathInDataFolder = null;

    // If image exists in original path, it's an absolute path
    if ( fileExists(imagePathFromJson) ) {

      // Return this path without change
      imageLoadPath = imagePathFromJson;

    // If not, check if image path is inside /data
    } else if ( imagePathFromJson != imagePathFromJson.replaceFirst("^(?i)" + Pattern.quote("/data/"), "") ) {

      // If it is, check if image indeed exists inside /data
      imagePathInDataFolder = imagePathFromJson.replaceFirst("^(?i)" + Pattern.quote("/data/"), "");
      if ( fileExists(dataPath(imagePathInDataFolder)) ) {

        // Return image's absolute path, returned by dataPath()
        imageLoadPath = dataPath(imagePathInDataFolder);

      }

    // If not, check if it's a macOS and if image path is inside /dungeoneering.app/Contents/Java/data/
    } else if ( platform == MACOSX && imagePathFromJson != imagePathFromJson.replaceFirst("^(?i)" + Pattern.quote("/dungeoneering.app/Contents/Java/data/"), "") ) {

      // If it is, check if image indeed exists inside /dungeoneering.app/Contents/Java/data/
      imagePathInDataFolder = imagePathFromJson.replaceFirst("^(?i)" + Pattern.quote("/dungeoneering.app/Contents/Java/data/"), "");
      if ( fileExists(dataPath(imagePathInDataFolder)) ) {

        // Return image's absolute path, returned by dataPath()
        imageLoadPath = dataPath(imagePathInDataFolder);

      }

    // If not
    } else {

      // Image could not be found, return an empty path
      imageLoadPath = "";

    }

    return imageLoadPath;

  }

  void addLogoButton(String logoImagePath, Point buttonMinPosition, String logoLink) {

    if ( logoImagePath == null || logoImagePath.trim().isEmpty() )
      return;

    if ( buttonMinPosition == null )
      return;

    PImage logoImage = loadImage(logoImagePath);

    Button button = cp5.addButton("Map logo")
       .setPosition(buttonMinPosition.x - logoImage.width, buttonMinPosition.y - logoImage.height)
       .setSize(logoImage.width, logoImage.height)
       .setImage(logoImage)
       .updateSize()
       .setStringValue(logoLink)
       ;

    controllerToTooltip.put("Map logo", new UserInterfaceTooltip("Click to visit website", mouseOverBackgroundColor, instructionsFontColor));

  }

  void removeController(String controllerName) {

    cp5.remove(controllerName);

  }

  void enableController(String controllerName) {

    controlP5.Controller controller = cp5.getController(controllerName);

    String controllerImageBaseName = controller.getStringValue();
    PImage[] controllerImages = {loadImage("icons/" + controllerImageBaseName + "_idle.png"), loadImage("icons/" + controllerImageBaseName + "_over.png"), loadImage("icons/" + controllerImageBaseName + "_click.png")};
    for ( PImage img: controllerImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    controller.setImages(controllerImages);

    controller.unlock();

  }

  void disableController(String controllerName) {

    controlP5.Controller controller = cp5.getController(controllerName);

    String controllerImageBaseName = controller.getStringValue();
    PImage controllerImage = loadImage("icons/" + controllerImageBaseName + "_disabled.png");
    if ( controllerImage.width != squareButtonWidth || controllerImage.height != squareButtonHeight )
      controllerImage.resize(squareButtonWidth, squareButtonHeight);
    controller.setImage(controllerImage);

    controller.lock();

  }

  void showController(String controllerName) {

    controlP5.Controller controller = cp5.getController(controllerName);
    controller.unlock();
    controller.show();

  }

  void hideController(String controllerName) {

    controlP5.Controller controller = cp5.getController(controllerName);
    controller.lock();
    controller.hide();

  }

  boolean getSwitchButtonState(String buttonName) {

    Button button = (Button)cp5.getController(buttonName);
    return button.isOn();

  }

  void setSwitchButtonState(String buttonName, boolean buttonState) {

    setSwitchButtonState(buttonName, buttonState, true);

  }

  void setSwitchButtonState(String buttonName, boolean buttonState, boolean broadcastButtonPress) {

    Button button = (Button)cp5.getController(buttonName);

    if ( !broadcastButtonPress )
      button.setBroadcast(false);

    if ( buttonState && !button.isOn() )
      button.setOn();
    else if ( !buttonState && button.isOn() )
      button.setOff();

    if ( !broadcastButtonPress )
      button.setBroadcast(true);

  }

  boolean isInside(int x, int y) {

    boolean inside = false;

    inside = isInsideMenu(x, y);

    List<Button> buttons = cp5.getAll(Button.class);
    for ( Button button: buttons ) {
      if ( inside ) {
        break;
      }
      inside = inside || isInside(button, x, y);
    }

    return inside;

  }

  boolean isInside(controlP5.Controller controller, int x, int y) {

    if ( !controller.isVisible() )
      return false;

    boolean inside = false;

    float startX = controller.getPosition()[0];
    float startY = controller.getPosition()[1];
    float endX = startX + controller.getWidth();
    float endY = startY + controller.getHeight();

    if ( controller.isInside() || (x > startX && x < endX && y > startY && y < endY) )
      inside = true;

    return inside;

  }

  boolean isInsideMenu(int x, int y) {

    if ( !tokenMenu.isVisible() )
      return false;

    if ( menuItemClicked ) {

      menuItemClicked = false;
      return true;

    }

    boolean inside = false;

    int openItemHeight = 0;
    if ( conditionMenuControllers.isOpen() )
      openItemHeight = conditionMenuControllers.getBackgroundHeight();
    else if ( lightSourceMenuControllers.isOpen() )
      openItemHeight = lightSourceMenuControllers.getBackgroundHeight();
    else if ( sightTypeMenuControllers.isOpen() )
      openItemHeight = sightTypeMenuControllers.getBackgroundHeight();
    else if ( sizeMenuControllers.isOpen() )
      openItemHeight = sizeMenuControllers.getBackgroundHeight();
    else if ( otherMenuControllers.isOpen() )
      openItemHeight = otherMenuControllers.getBackgroundHeight();

    // menu bar
    float barStartX = tokenMenu.getPosition()[0];
    float barStartY = tokenMenu.getPosition()[1];
    float barEndX = barStartX + tokenMenu.getWidth();
    float barEndY = barStartY + menuBarHeight * tokenMenu.size() + tokenMenu.size()-1;

    // menu item
    float itemStartX = barStartX;
    float itemStartY = barEndY;
    float itemEndX = barEndX;
    float itemEndY = itemStartY + openItemHeight;

    if ( (x > barStartX && x < barEndX && y > barStartY && y < barEndY) || (x > itemStartX && x < itemEndX && y > itemStartY && y < itemEndY) )
      inside = true;

    return inside;

  }

  boolean fileExists(String filePath) {

    if ( filePath == null || filePath.trim().isEmpty() )
      return false;

    boolean exists = false;

    try {
      File f = new File(filePath);
      if ( f.isFile() )
        exists = true;
    } catch( Exception e ) {
      exists = false;
    }

    return exists;

  }

  boolean isFileDialogOpen() {
    return fileDialogOpen;
  }

}
