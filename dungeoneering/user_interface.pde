// dungeoneering - Virtual tabletop (VTT) for local, in-person RPG sessions
// Copyright  (C) 2019-2023  Luis Castilho

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

public class UserInterface {

  PGraphics canvas;

  HazelcastInstance sharedDataInstance;
  IMap<String, String> sharedData;
  ChangeListener<Number> sceneUpdateListener;

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

  int controllerSectionsSpacing;
  int controllerBarsSpacing;
  int controllersSpacing;

  int squareButtonWidth, squareButtonHeight;
  int instructionsHeight;
  int instructionsMaxWidth;
  int menuBarHeight;
  int toggleWidth, toggleHeight;

  int controllersTopLeftX, controllersTopLeftY;
  int controllersTopLeftInitialX, controllersTopLeftInitialY;
  int controllersMiddleLeftInitialX, controllersMiddleLeftInitialY;
  int controllersBottomLeftInitialX, controllersBottomLeftInitialY;
  int controllersTopRightX, controllersTopRightY;
  int controllersTopRightInitialX, controllersTopRightInitialY;
  int controllersBottomRightX, controllersBottomRightY;
  int controllersBottomRightInitialX, controllersBottomRightInitialY;
  int controllersLogoX, controllersLogoY;
  int controllersMenuX, controllersMenuY;
  int controllersMenuInitialX, controllersMenuInitialY;

  int menuItemsPerLine;
  boolean menuItemClicked;

  color idleBackgroundColor, mouseOverBackgroundColor, mouseClickBackgroundColor, disabledBackgroundColor;

  PFont instructionsFont;
  PFont instructionsFontSmall;
  color instructionsFontColor, instructionsFontOutlineColor, instructionsVisualColor;
  int instructionsX, instructionsY;
  int instructionsInitialX, instructionsInitialY;

  int gridHelperX, gridHelperY;
  int gridHelperToX, gridHelperToY;
  boolean gridHelperStarted;
  boolean gridHelperSet;

  Group togglableControllers;
  Group conditionMenuControllers;
  Group commonLightSourceMenuControllers;
  Group spellLightSourceMenuControllers;
  Group sightTypeMenuControllers;
  Group sizeMenuControllers;
  Group settingsMenuControllers;
  Accordion tokenMenu;

  // Maps resources to controllers
  ArrayList<String> conditionControllers;
  ArrayList<String> commonLightSourceControllers;
  ArrayList<String> spellLightSourceControllers;
  ArrayList<String> sightTypeControllers;
  ArrayList<String> sizeControllers;

  // Maps controllers to tooltips
  HashMap<String, UserInterfaceTooltip> controllerToTooltip;

  // Keeps track of previous mouse over events on controllers
  // Used to reset tooltip timers
  List<ControllerInterface<?>> previousMouseOverControllers;

  boolean fileDialogOpen;

  int platform;

  ArrayList<String> allowedControllersInPlayersMode;
  ArrayList<String> allowedControllerGroupsInPlayersMode;

  int logoMaxWidth, logoMaxHeight;

  UserInterface(PGraphics _canvas, ControlP5 _cp5,
                Map _map, Grid _grid, Obstacles _obstacles, Layer _playersLayer, Layer _dmLayer,
                Resources _resources, Initiative _initiative, int _platform,
                HazelcastInstance _sharedDataInstance, IMap<String, String> _sharedData) {

    canvas = _canvas;

    // Hazelcast instance
    sharedDataInstance = _sharedDataInstance;
    // Shared map between DM's and Players' Apps
    sharedData = _sharedData;

    // Listener that detects changes in scene and push changes to the other app - DM or Players
    sceneUpdateListener = new ChangeListener<Number>() {

      @Override
      public void changed(ObservableValue<? extends Number> observable, Number oldValue, Number newValue) {
        logger.trace("UserInterface: ChangeListener: changed(): Version changed from " + oldValue + " to " + newValue);
        pushSceneSync(false);
      }

    };

    cp5 = _cp5;

    map = _map;

    grid = _grid;
    grid.addSceneUpdateListener(sceneUpdateListener);

    obstacles = _obstacles;
    obstacles.addSceneUpdateListener(sceneUpdateListener);

    playersLayer = _playersLayer;
    playersLayer.addSceneUpdateListener(sceneUpdateListener);

    dmLayer = _dmLayer;
    dmLayer.addSceneUpdateListener(sceneUpdateListener);

    resources = _resources;

    initiative = _initiative;
    initiative.addSceneUpdateListener(sceneUpdateListener);

    platform = _platform;

    uiDialogs = new UiBooster(
      UiBoosterOptions.Theme.DARK_THEME,
      dataPath("logos/dungeoneering-icon.png")
    );
    uiConfirmDialogAnswer = false;

    newWall = null;
    newDoor = null;

    rightClickedToken = null;

    controllerSectionsSpacing = round(min(canvas.width, canvas.height) * 0.05);
    controllerBarsSpacing = 50;
    controllersSpacing = 5;

    squareButtonWidth = squareButtonHeight = 50;
    instructionsHeight = 20;
    instructionsMaxWidth = round(canvas.width * 0.5 - canvas.width * 0.15);
    menuBarHeight = 35;
    toggleWidth = 40;
    toggleHeight = 20;

    controllersTopLeftX = controllerSectionsSpacing;
    controllersTopLeftY = controllerSectionsSpacing;
    controllersTopLeftInitialX = controllerSectionsSpacing;
    controllersTopLeftInitialY = controllerSectionsSpacing;
    controllersMiddleLeftInitialX = controllersTopLeftInitialX;
    controllersMiddleLeftInitialY = controllersTopLeftInitialY + squareButtonHeight + controllerBarsSpacing + controllersSpacing;
    controllersBottomLeftInitialX = controllersMiddleLeftInitialX;
    controllersBottomLeftInitialY = controllersMiddleLeftInitialY + 5*(squareButtonHeight + controllersSpacing) + squareButtonHeight + controllerBarsSpacing + controllersSpacing;
    controllersTopRightX = canvas.width - controllerSectionsSpacing;
    controllersTopRightY = controllerSectionsSpacing;
    controllersBottomRightX = controllersTopRightX - squareButtonWidth;
    controllersBottomRightY = canvas.height - controllersTopRightY - squareButtonHeight;
    controllersBottomRightInitialX = controllersBottomRightX;
    controllersBottomRightInitialY = controllersBottomRightY;
    controllersLogoX = round(canvas.width * 0.5);
    controllersLogoY = canvas.height;
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
    instructionsFontSmall = loadFont("fonts/ProcessingSansPro-Semibold-12.vlw");
    instructionsFontColor = color(255);
    instructionsFontOutlineColor = color(0);
    instructionsVisualColor = color(#F64B29, 127);
    instructionsX = controllerSectionsSpacing;
    instructionsY = canvas.height - round(controllerSectionsSpacing * 1.5) + controllersSpacing;
    instructionsInitialX = instructionsX;
    instructionsInitialY = instructionsY;

    gridHelperX = gridHelperToX = 0;
    gridHelperY = gridHelperToY = 0;
    gridHelperStarted = false;
    gridHelperSet = false;

    togglableControllers = null;
    conditionMenuControllers = null;
    commonLightSourceMenuControllers = null;
    spellLightSourceMenuControllers = null;
    sightTypeMenuControllers = null;
    sizeMenuControllers = null;
    settingsMenuControllers = null;
    tokenMenu = null;

    conditionControllers = new ArrayList<String>();
    commonLightSourceControllers = new ArrayList<String>();
    spellLightSourceControllers = new ArrayList<String>();
    sightTypeControllers = new ArrayList<String>();
    sizeControllers = new ArrayList<String>();

    controllerToTooltip = new HashMap<String, UserInterfaceTooltip>();
    previousMouseOverControllers = new ArrayList<ControllerInterface<?>>();

    fileDialogOpen = false;

    allowedControllersInPlayersMode = new ArrayList<String>();
    allowedControllersInPlayersMode.add("Quit");
    allowedControllersInPlayersMode.add("Toggle UI");
    allowedControllersInPlayersMode.add("Toggle touch screen mode");
    allowedControllersInPlayersMode.add("Lock map pan and zoom");
    allowedControllersInPlayersMode.add("Toggle mute sound");

    allowedControllerGroupsInPlayersMode = new ArrayList<String>();
    allowedControllerGroupsInPlayersMode.add("Conditions");
    allowedControllerGroupsInPlayersMode.add("Common Light Sources");
    allowedControllerGroupsInPlayersMode.add("Spell Light Sources");
    allowedControllerGroupsInPlayersMode.add("Sight Types");
    allowedControllerGroupsInPlayersMode.add("Sizes");
    allowedControllerGroupsInPlayersMode.add("Settings");

    logoMaxWidth = 300;
    logoMaxHeight = 150;

    logger.debug("UserInterface: setup(): UI controllers setup started");

    try {

      setupControllers();
      setControllersInitialState();

    } catch ( Exception e ) {
      logger.error("UserInterface: setup(): Error setting up UI controllers");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

    logger.debug("UserInterface: setup(): UI controllers setup done");

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
    commonLightSourceMenuControllers = cp5.addGroup("Common Light Sources")
      .setBackgroundColor(color(0, 127));
    spellLightSourceMenuControllers = cp5.addGroup("Spell Light Sources")
      .setBackgroundColor(color(0, 127));
    sightTypeMenuControllers = cp5.addGroup("Sight Types")
      .setBackgroundColor(color(0, 127));
    sizeMenuControllers = cp5.addGroup("Sizes")
      .setBackgroundColor(color(0, 127));
    settingsMenuControllers = cp5.addGroup("Settings")
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
    tokenSetupIconFolder = "token/settings/";

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
    addButton("Toggle initiative order", sceneConfigIconFolder + "initiative", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);

    controllersTopLeftX += squareButtonWidth + controllersSpacing;
    addButton("Toggle grid", sceneConfigIconFolder + "grid", controllersTopLeftX, controllersTopLeftY, togglableControllers, true, false);

    controllersTopLeftX += squareButtonWidth + controllersSpacing;
    addButton("Switch active layer", sceneConfigIconFolder + "layers", controllersTopLeftX, controllersTopLeftY, togglableControllers);

    controllersTopLeftX += squareButtonWidth + controllersSpacing;
    addButton("Switch environment lighting", sceneConfigIconFolder + "lighting", controllersTopLeftX, controllersTopLeftY, togglableControllers);

    controllersTopLeftX += (squareButtonWidth - toggleWidth) / 2;
    controllersTopLeftY += squareButtonHeight + controllersSpacing;
    cp5.addToggle("Switch environment lighting toggle")
      .setPosition(controllersTopLeftX, controllersTopLeftY)
      .setSize(toggleWidth, toggleHeight)
      .setColorBackground(idleBackgroundColor)
      .setColorActive(mouseClickBackgroundColor)
      .setValue(true)
      .setMode(ControlP5.SWITCH)
      .setLabelVisible(false)
      .moveTo(togglableControllers)
      .lock()
      .hide()
      ;

    controllerToTooltip.put("Switch environment lighting toggle", new UserInterfaceTooltip("Switch lighting in which app?", mouseOverBackgroundColor, instructionsFontColor));

    controllersTopLeftX -= 12;
    controllersTopLeftY += toggleHeight + controllersSpacing/2;
    cp5.addTextlabel("Switch environment lighting DM label")
      .setText("DM")
      .setPosition(controllersTopLeftX, controllersTopLeftY)
      .setColorValue(instructionsFontColor)
      .setFont(instructionsFontSmall)
      .setOutlineText(true)
      .moveTo(togglableControllers)
      .lock()
      .hide()
      ;

    controllersTopLeftX += toggleWidth - controllersSpacing/2;
    cp5.addTextlabel("Switch environment lighting Players label")
      .setText("Players")
      .setPosition(controllersTopLeftX, controllersTopLeftY)
      .setColorValue(instructionsFontColor)
      .setFont(instructionsFontSmall)
      .setOutlineText(true)
      .moveTo(togglableControllers)
      .lock()
      .hide()
      ;

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
    addButton("Lock map pan and zoom", appIconFolder + "lock_map", controllersBottomRightX, controllersBottomRightY, togglableControllers, true, false);

    controllersBottomRightX -= squareButtonWidth + controllersSpacing;
    addButton("Toggle mute sound", appIconFolder + "mute", controllersBottomRightX, controllersBottomRightY, togglableControllers, true, false);

    // App logo

    addAppLogo(controllersLogoX, controllersLogoY, togglableControllers);

    // Token right click menu

    // Right click menu settings

    int itemsPerLine = 5;
    int currentLine = 0;
    int currentItem = 0;

    // Right click menu sections

    conditionMenuControllers.setHeight(menuBarHeight) // menu bar height
      .setBackgroundHeight(controllersSpacing)        // item height
      .setColorBackground(idleBackgroundColor)
      .setColorForeground(mouseOverBackgroundColor)
      .setFont(instructionsFont)
      ;
    conditionMenuControllers.getCaptionLabel().align(LEFT, CENTER).toUpperCase(false);

    commonLightSourceMenuControllers.setHeight(menuBarHeight) // menu bar height
      .setBackgroundHeight(controllersSpacing)                // item height
      .setColorBackground(idleBackgroundColor)
      .setColorForeground(mouseOverBackgroundColor)
      .setFont(instructionsFont)
      ;
    commonLightSourceMenuControllers.getCaptionLabel().align(LEFT, CENTER).toUpperCase(false);

    spellLightSourceMenuControllers.setHeight(menuBarHeight) // menu bar height
      .setBackgroundHeight(controllersSpacing)               // item height
      .setColorBackground(idleBackgroundColor)
      .setColorForeground(mouseOverBackgroundColor)
      .setFont(instructionsFont)
      ;
    spellLightSourceMenuControllers.getCaptionLabel().align(LEFT, CENTER).toUpperCase(false);

    sightTypeMenuControllers.setHeight(menuBarHeight) // menu bar height
      .setBackgroundHeight(controllersSpacing)        // item height
      .setColorBackground(idleBackgroundColor)
      .setColorForeground(mouseOverBackgroundColor)
      .setFont(instructionsFont)
      ;
    sightTypeMenuControllers.getCaptionLabel().align(LEFT, CENTER).toUpperCase(false);

    sizeMenuControllers.setHeight(menuBarHeight) // menu bar height
      .setBackgroundHeight(controllersSpacing)   // item height
      .setColorBackground(idleBackgroundColor)
      .setColorForeground(mouseOverBackgroundColor)
      .setFont(instructionsFont)
      ;
    sizeMenuControllers.getCaptionLabel().align(LEFT, CENTER).toUpperCase(false);

    settingsMenuControllers.setHeight(menuBarHeight) // menu bar height
      .setBackgroundHeight(controllersSpacing)       // item height
      .setColorBackground(idleBackgroundColor)
      .setColorForeground(mouseOverBackgroundColor)
      .setFont(instructionsFont)
      ;
    settingsMenuControllers.getCaptionLabel().align(LEFT, CENTER).toUpperCase(false);

    tokenMenu = cp5.addAccordion("Right click menu")
      .setPosition(0, 0)
      .setWidth((menuItemsPerLine+1)*controllersSpacing + menuItemsPerLine*squareButtonWidth) // menu bar and items width
      .setMinItemHeight(controllersSpacing)                                                   // min item height
      .updateItems()
      .setCollapseMode(Accordion.SINGLE)
      .hide()
      ;

    if ( controllerGroupIsAllowed(conditionMenuControllers) )
      tokenMenu.addItem(conditionMenuControllers);
    if ( controllerGroupIsAllowed(commonLightSourceMenuControllers) )
      tokenMenu.addItem(commonLightSourceMenuControllers);
    if ( controllerGroupIsAllowed(spellLightSourceMenuControllers) )
      tokenMenu.addItem(spellLightSourceMenuControllers);
    if ( controllerGroupIsAllowed(sightTypeMenuControllers) )
      tokenMenu.addItem(sightTypeMenuControllers);
    if ( controllerGroupIsAllowed(sizeMenuControllers) )
      tokenMenu.addItem(sizeMenuControllers);
    if ( controllerGroupIsAllowed(settingsMenuControllers) )
      tokenMenu.addItem(settingsMenuControllers);

    tokenMenu.open(0);

    // Add conditions

    currentLine = 0;
    currentItem = 0;
    for ( Condition condition: resources.getBaseConditions() ) {

      String conditionName = condition.getName();
      String conditionFilename = conditionName.replace(" ", "_").replace("'", "").toLowerCase();

      // First item in line
      if ( currentItem == 0 ) {
        conditionMenuControllers.setBackgroundHeight(conditionMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
        controllersMenuX = controllersMenuInitialX;
        // First line
        if ( currentLine == 0 ) {
          controllersMenuY = controllersMenuInitialY;
        } else {
          controllersMenuY += squareButtonWidth + controllersSpacing;
        }
      } else {
        controllersMenuX += squareButtonWidth + controllersSpacing;
      }

      addButton(conditionName, tokenConditionsIconFolder + conditionFilename, controllersMenuX, controllersMenuY, conditionMenuControllers, true, false);
      conditionControllers.add(conditionName);

      currentItem += 1;
      // Move to next line
      if ( currentItem == itemsPerLine ) {
        currentLine += 1;
        currentItem = 0;
      }

    }

    // Add common light sources

    currentLine = 0;
    currentItem = 0;
    for ( Light light: resources.getBaseCommonLightSources() ) {

      String lightName = light.getName();
      String lightFilename = lightName.replace(" ", "_").replace("'", "").toLowerCase();

      // First item in line
      if ( currentItem == 0 ) {
        commonLightSourceMenuControllers.setBackgroundHeight(commonLightSourceMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
        controllersMenuX = controllersMenuInitialX;
        // First line
        if ( currentLine == 0 ) {
          controllersMenuY = controllersMenuInitialY;
        } else {
          controllersMenuY += squareButtonWidth + controllersSpacing;
        }
      } else {
        controllersMenuX += squareButtonWidth + controllersSpacing;
      }

      addButton(lightName, tokenCommonLightSourcesIconFolder + lightFilename, controllersMenuX, controllersMenuY, commonLightSourceMenuControllers, true, false);
      commonLightSourceControllers.add(lightName);

      currentItem += 1;
      // Move to next line
      if ( currentItem == itemsPerLine ) {
        currentLine += 1;
        currentItem = 0;
      }

    }

    // Add spell light sources

    currentLine = 0;
    currentItem = 0;
    for ( Light light: resources.getBaseSpellLightSources() ) {

      String lightName = light.getName();
      String lightFilename = lightName.replace(" ", "_").replace("'", "").toLowerCase();

      // First item in line
      if ( currentItem == 0 ) {
        spellLightSourceMenuControllers.setBackgroundHeight(spellLightSourceMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
        controllersMenuX = controllersMenuInitialX;
        // First line
        if ( currentLine == 0 ) {
          controllersMenuY = controllersMenuInitialY;
        } else {
          controllersMenuY += squareButtonWidth + controllersSpacing;
        }
      } else {
        controllersMenuX += squareButtonWidth + controllersSpacing;
      }

      addButton(lightName, tokenSpellLightSourcesIconFolder + lightFilename, controllersMenuX, controllersMenuY, spellLightSourceMenuControllers, true, false);
      spellLightSourceControllers.add(lightName);

      currentItem += 1;
      // Move to next line
      if ( currentItem == itemsPerLine ) {
        currentLine += 1;
        currentItem = 0;
      }

    }

    // Add sight types

    currentLine = 0;
    currentItem = 0;
    for ( Light sight: resources.getBaseSightTypes() ) {

      String sightName = sight.getName();
      String sightFilename = sightName.replace(" ", "_").replace("'", "").toLowerCase();

      // First item in line
      if ( currentItem == 0 ) {
        sightTypeMenuControllers.setBackgroundHeight(sightTypeMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
        controllersMenuX = controllersMenuInitialX;
        // First line
        if ( currentLine == 0 ) {
          controllersMenuY = controllersMenuInitialY;
        } else {
          controllersMenuY += squareButtonWidth + controllersSpacing;
        }
      } else {
        controllersMenuX += squareButtonWidth + controllersSpacing;
      }

      addButton(sightName, tokenSightTypesIconFolder + sightFilename, controllersMenuX, controllersMenuY, sightTypeMenuControllers, true, false);
      sightTypeControllers.add(sightName);

      currentItem += 1;
      // Move to next line
      if ( currentItem == itemsPerLine ) {
        currentLine += 1;
        currentItem = 0;
      }

    }

    // Add sizes

    currentLine = 0;
    currentItem = 0;
    for ( Size size: resources.getBaseSizes().values() ) {

      String sizeName = size.getName();
      String sizeFilename = sizeName.replace(" ", "_").replace("'", "").toLowerCase();

      // First item in line
      if ( currentItem == 0 ) {
        sizeMenuControllers.setBackgroundHeight(sizeMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
        controllersMenuX = controllersMenuInitialX;
        // First line
        if ( currentLine == 0 ) {
          controllersMenuY = controllersMenuInitialY;
        } else {
          controllersMenuY += squareButtonWidth + controllersSpacing;
        }
      } else {
        controllersMenuX += squareButtonWidth + controllersSpacing;
      }

      addButton(sizeName, tokenSizesIconFolder + sizeFilename, controllersMenuX, controllersMenuY, sizeMenuControllers, true, false);
      sizeControllers.add(sizeName);

      currentItem += 1;
      // Move to next line
      if ( currentItem == itemsPerLine ) {
        currentLine += 1;
        currentItem = 0;
      }

    }

    // Add settings

    // First line in menu item
    settingsMenuControllers.setBackgroundHeight(settingsMenuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY = controllersMenuInitialY;
    addButton("Toggle initiative", tokenSetupIconFolder + "toggle_initiative", controllersMenuX, controllersMenuY, settingsMenuControllers);

    if ( appMode == AppMode.standalone || appMode == AppMode.dm ) {

      controllersMenuX += squareButtonWidth + controllersSpacing;
      addButton("Change token layer", tokenSetupIconFolder + "switch_layer", controllersMenuX, controllersMenuY, settingsMenuControllers);

      controllersMenuX += squareButtonWidth + controllersSpacing;
      addButton("Remove token", tokenSetupIconFolder + "remove", controllersMenuX, controllersMenuY, settingsMenuControllers);

    }

    // Button groups label

    instructionsX = controllersTopLeftInitialX;
    instructionsY = controllersTopLeftInitialY - instructionsHeight - controllersSpacing;

    if ( appMode == AppMode.standalone || appMode == AppMode.dm ) {

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

    }

    // Bottom left messages - setup instructions

    instructionsX = instructionsInitialX;
    instructionsY = instructionsInitialY;

    cp5.addTextlabel("Grid instructions")
      .setText(addLineBreaks("Click and drag to create a square on the map background by selecting a 3 x 3 grid " +
        "cells area. After drawing the square, you can modify its size and position using the keys W, A, S, D (for " +
        "the top left corner) and ↑, ←, ↓, → (for the bottom right corner). Once you're finished, click the Grid " +
        "Setup button to complete the process.", instructionsFont, instructionsMaxWidth))
      .setPosition(instructionsX, instructionsY)
      .setColorValue(instructionsFontColor)
      .setFont(instructionsFont)
      .setOutlineText(true)
      .setLineHeight(instructionsHeight)
      .hide()
      ;

    cp5.addTextlabel("Wall instructions")
      .setText(addLineBreaks("To draw new wall segments, click the left mouse button to add vertices. Double-click " +
        "to stop adding wall segments after the current one. Right-click on any wall to remove it. Once you're " +
        "finished, click the Add/Remove Walls button to complete the process.", instructionsFont,
        instructionsMaxWidth))
      .setPosition(instructionsX, instructionsY)
      .setColorValue(instructionsFontColor)
      .setFont(instructionsFont)
      .setOutlineText(true)
      .setLineHeight(instructionsHeight)
      .hide()
      ;

    cp5.addTextlabel("Door instructions")
      .setText(addLineBreaks("To create new doors, left-click to add vertexes. Every second vertex defines a door. " +
        "Right-click on any door to remove it. Once you have finished, click the Add/Remove Doors button to complete " +
        "the process.", instructionsFont, instructionsMaxWidth))
      .setPosition(instructionsX, instructionsY)
      .setColorValue(instructionsFontColor)
      .setFont(instructionsFont)
      .setOutlineText(true)
      .setLineHeight(instructionsHeight)
      .hide()
      ;

    cp5.addTextlabel("Initiative instructions")
      .setText(addLineBreaks("To establish the initiative order, add tokens to the initiative. To add a token, right-" +
        "click on it, navigate to Settings, and click on the Toggle Initiative button.", instructionsFont,
        instructionsMaxWidth))
      .setPosition(instructionsX, instructionsY)
      .setColorValue(instructionsFontColor)
      .setFont(instructionsFont)
      .setOutlineText(true)
      .setLineHeight(instructionsHeight)
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

    if ( isEmpty(buttonName) ) {
      logger.error("UserInterface: addButton(): Received button name is empty");
      return;
    }

    if ( isEmpty(imageBaseName) ) {
      logger.error("UserInterface: addButton(): Received image base name is empty");
      return;
    }

    // If app is running in Players mode, check if button should be added to UI
    if ( appMode == AppMode.players ) {

      boolean controllerAllowed = controllerIsAllowed(buttonName);
      boolean controllerGroupAllowed = controllerGroupIsAllowed(buttonGroup);
      if ( !(controllerAllowed || controllerGroupAllowed) )
        return;

    }

    PImage[] buttonImages = {
      loadImage("icons/" + imageBaseName + "_idle.png"),
      loadImage("icons/" + imageBaseName + "_over.png"),
      loadImage("icons/" + imageBaseName + "_click.png")
    };
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

  void addAppLogo(int buttonPositionX, int buttonPositionY, ControllerGroup buttonGroup) {

    PImage logoImage = loadImage("logos/dungeoneering.png");

    Button button = cp5.addButton("dungeoneering logo")
      .setPosition(buttonPositionX - round(logoImage.width * 0.5), buttonPositionY - logoImage.height - round(logoImage.height * 0.25))
      .setSize(logoImage.width, logoImage.height)
      .setImage(logoImage)
      .updateSize()
      ;

    if ( buttonGroup != null )
      button.moveTo(buttonGroup);

    controllerToTooltip.put("dungeoneering logo", new UserInterfaceTooltip("Visit dungeoneering.app", mouseOverBackgroundColor, instructionsFontColor));

  }

  String addLineBreaks(String text, PFont font, int maxLineWidth) {

    if ( isEmpty(text) ) {
      logger.error("UserInterface: addLineBreaks(): Received text is empty");
      return text;
    }

    String multilineText = "";
    int currentWidth = 0;

    canvas.textFont(font);
    for ( String token: Arrays.asList(text.split("\\s")) ) {
      if ( currentWidth + canvas.textWidth(token + " ") < maxLineWidth ) {
        multilineText += token + " ";
        currentWidth += canvas.textWidth(token + " ");
      } else {
        multilineText += token + "\n";
        currentWidth = 0;
      }
    }

    return multilineText;

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
    setSwitchButtonState("Toggle initiative order", false);
    setSwitchButtonState("Toggle mute sound", false);

  }

  void reset() {

    resetScene();

    setControllersInitialState();

    layerShown = LayerShown.players;

    changeAppState(AppState.idle);

    logger.debug("UserInterface: reset(): UI reset");

  }

  void resetScene() {

    initiative.clear();
    obstacles.setIllumination(Illumination.brightLight);
    obstacles.clear();
    playersLayer.clear();
    dmLayer.clear();
    grid.clear();
    map.clear();

    logger.debug("UserInterface: resetScene(): Scene reset");

  }

  AppState controllerEvent(ControlEvent controlEvent) {

    if ( controlEvent == null ) {
      logger.error("UserInterface: controllerEvent(): Received controller event is null");
      return appState;
    }

    String resourceName;
    Condition conditionTemplate;
    Light lightTemplate;
    Size sizeTemplate;

    AppState newAppState = appState;

    String controllerName = "";
    if ( controlEvent.isController() ) {
      controllerName = controlEvent.getController().getName();
    } else if ( controlEvent.isGroup() ) {
      controllerName = controlEvent.getGroup().getName();
    } else {
      logger.error("UserInterface: controllerEvent(): Received event for unknown controller");
      return appState;
    }

    logger.trace("UserInterface: controllerEvent(): Event received for controller " + controllerName);

    boolean controllerFound = false;

    // Condition controllers
    if ( conditionControllers.contains(controllerName) ) {

      if ( rightClickedToken != null ) {

        resourceName = controllerName;
        conditionTemplate = resources.getCondition(resourceName, rightClickedToken.getSize());
        if ( conditionTemplate != null ) {

          rightClickedToken.toggleCondition(conditionTemplate);
          if ( conditionTemplate.disablesTarget() )
            obstacles.setRecalculateShadows(true);
          hideMenu(0, 0);

        } else {

          logger.error("UserInterface: controllerEvent(): Condition " + resourceName + " not found");

        }

      }

      controllerFound = true;

    // Light source controllers
    } else if ( commonLightSourceControllers.contains(controllerName) || spellLightSourceControllers.contains(controllerName) ) {

      if ( rightClickedToken != null ) {

        resourceName = controllerName;
        lightTemplate = resources.getCommonLightSource(resourceName);
        if ( lightTemplate == null )
          lightTemplate = resources.getSpellLightSource(resourceName);

        if ( lightTemplate != null ) {

          rightClickedToken.toggleLightSource(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
          obstacles.setRecalculateShadows(true);
          hideMenu(0, 0);

        } else {

          logger.error("UserInterface: controllerEvent(): Common or spell light source " + resourceName + " not found");

        }

      }

      controllerFound = true;

    // Sight type controllers
    } else if ( sightTypeControllers.contains(controllerName) ) {

      if ( rightClickedToken != null ) {

        resourceName = controllerName;
        lightTemplate = resources.getSightType(resourceName);
        if ( lightTemplate != null ) {

          rightClickedToken.toggleSightType(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
          obstacles.setRecalculateShadows(true);
          hideMenu(0, 0);

        } else {

          logger.error("UserInterface: controllerEvent(): Sight type " + resourceName + " not found");

        }

      }

      controllerFound = true;

    // Size controllers
    } else if ( sizeControllers.contains(controllerName) ) {

      if ( rightClickedToken != null ) {

        resourceName = controllerName;
        sizeTemplate = resources.getSize(resourceName);
        if ( sizeTemplate != null ) {

          rightClickedToken.setSize(new Size(sizeTemplate.getName(), sizeTemplate.getResizeFactor(), sizeTemplate.isCentered()), resources);
          obstacles.setRecalculateShadows(true);
          hideMenu(0, 0);

        } else {

          logger.error("UserInterface: controllerEvent(): Size " + resourceName + " not found");

        }

      }

      controllerFound = true;

    }

    if ( !controllerFound ) {
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

          logger.info("UserInterface: controllerEvent(): New empty scene created");

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
            "Quit dungeoneering? Any unsaved changes will be lost.",
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

          if ( appMode == AppMode.dm || appMode == AppMode.players )
            sharedDataInstance.shutdown();

          logger.info("UserInterface: controllerEvent(): Exiting dungeoneering");

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
          if ( !isEmpty(link) )
            link(link);

          break;
        case "Grid setup":

          Button gridSetup = (Button)controlEvent.getController();
          Textlabel gridInstructions = (Textlabel)cp5.getController("Grid instructions");

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

            setSwitchButtonState("Toggle initiative order", false);
            disableController("Toggle initiative order");

            initiative.clear();
            playersLayer.clear();
            dmLayer.clear();
            grid.clear();

            map.reset();

            disableController("Select map");
            disableController("Add player token");
            disableController("Add DM token");
            disableController("Add/Remove walls");
            disableController("Add/Remove doors");
            disableController("Toggle UI");

            setSwitchButtonState("Toggle grid", true);

            obstacles.setIllumination(Illumination.brightLight);
            obstacles.setRecalculateShadows(true);

            gridHelperX = gridHelperToX = 0;
            gridHelperY = gridHelperToY = 0;
            gridHelperStarted = false;
            gridHelperSet = false;
            gridInstructions.show();

            PImage cursorCross = loadImage("cursors/cursor_cross_32.png");
            cursor(cursorCross);

            newAppState = AppState.gridSetup;

          } else {

            enableController("Select map");
            if ( grid.isSet() ) {
              enableController("Add player token");
              enableController("Add DM token");
            }
            enableController("Add/Remove walls");
            enableController("Add/Remove doors");
            enableController("Toggle UI");
            enableController("Toggle initiative order");

            gridInstructions.hide();

            if ( grid.isSet() ) {
              resources.setupBasedOnGrid();
              logger.info("UserInterface: controllerEvent(): Resources setup done");
            }

            cursor(ARROW);

            newAppState = AppState.idle;

            logger.info("UserInterface: controllerEvent(): Grid setup done");

          }

          break;
        case "Add/Remove walls":

          Button addWall = (Button)controlEvent.getController();
          Textlabel wallInstructions = (Textlabel)cp5.getController("Wall instructions");

          if ( addWall.isOn() ) {

            disableController("Select map");
            disableController("Grid setup");
            disableController("Add player token");
            disableController("Add DM token");
            disableController("Add/Remove doors");
            disableController("Toggle UI");

            setSwitchButtonState("Toggle initiative order", false);
            disableController("Toggle initiative order");

            obstacles.setIllumination(Illumination.brightLight);
            obstacles.setRecalculateShadows(true);

            playersLayer.reset();
            dmLayer.reset();
            obstacles.toggleDrawObstacles();

            wallInstructions.show();

            PImage cursorCross = loadImage("cursors/cursor_cross_32.png");
            cursor(cursorCross);

            newWall = null;

            newAppState = AppState.wallSetup;

          } else {

            enableController("Select map");
            enableController("Grid setup");
            if ( grid.isSet() ) {
              enableController("Add player token");
              enableController("Add DM token");
            }
            enableController("Add/Remove doors");
            enableController("Toggle UI");
            enableController("Toggle initiative order");

            obstacles.toggleDrawObstacles();

            wallInstructions.hide();

            cursor(ARROW);

            newWall = null;

            logger.info("UserInterface: controllerEvent(): Walls setup done");

            newAppState = AppState.idle;

          }

          break;
        case "Add/Remove doors":

          Button addDoor = (Button)controlEvent.getController();
          Textlabel doorInstructions = (Textlabel)cp5.getController("Door instructions");

          if ( addDoor.isOn() ) {

            disableController("Select map");
            disableController("Grid setup");
            disableController("Add player token");
            disableController("Add DM token");
            disableController("Add/Remove walls");
            disableController("Toggle UI");

            setSwitchButtonState("Toggle initiative order", false);
            disableController("Toggle initiative order");

            obstacles.setIllumination(Illumination.brightLight);
            obstacles.setRecalculateShadows(true);

            playersLayer.reset();
            dmLayer.reset();
            obstacles.toggleDrawObstacles();

            doorInstructions.show();

            PImage cursorCross = loadImage("cursors/cursor_cross_32.png");
            cursor(cursorCross);

            newDoor = null;

            newAppState = AppState.doorSetup;

          } else {

            enableController("Select map");
            enableController("Grid setup");
            if ( grid.isSet() ) {
              enableController("Add player token");
              enableController("Add DM token");
            }
            enableController("Add/Remove walls");
            enableController("Toggle UI");
            enableController("Toggle initiative order");

            obstacles.toggleDrawObstacles();

            doorInstructions.hide();

            cursor(ARROW);

            newDoor = null;

            logger.info("UserInterface: controllerEvent(): Doors setup done");

            newAppState = AppState.idle;

          }

          break;
        case "Add player token":
        case "Add DM token":

          Button addToken = (Button)controlEvent.getController();

          if ( addToken.isOn() ) {

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

            newAppState = AppState.tokenSetup;

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

            logger.info("UserInterface: controllerEvent(): Token setup done");

            newAppState = AppState.idle;

          }

          break;
        case "Switch active layer":

          switch ( layerShown ) {
            case players:
              layerShown = LayerShown.dm;
              logger.info("UserInterface: controllerEvent(): Layer switched to " + LayerShown.dm.toString());
              break;
            case dm:
              layerShown = LayerShown.all;
              logger.info("UserInterface: controllerEvent(): Layer switched to " + LayerShown.all.toString());
              break;
            case all:
              layerShown = LayerShown.players;
              logger.info("UserInterface: controllerEvent(): Layer switched to " + LayerShown.players.toString());
              break;
            default:
              break;
          }

          obstacles.setRecalculateShadows(true);

          break;
        case "Switch environment lighting":

          boolean switchLightingInWhichApp = getToggleState("Switch environment lighting toggle");

          Illumination appIllumination = null;
          if ( switchLightingInWhichApp )
            appIllumination = obstacles.getIllumination();
          else
            appIllumination = obstacles.getPlayersAppIllumination();

          if ( !switchLightingInWhichApp ) {
            if ( appIllumination == Illumination.dimLight || appIllumination == Illumination.darkness ) {

              uiDialogs.showConfirmDialog(
                "This will change environment lighting in Players' App and might reveal\nparts of the map and enemies to players. Confirm?",
                "Switch environment lighting in Players' App",
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
          }

          switch ( appIllumination ) {
            case brightLight:
              if ( switchLightingInWhichApp )
                obstacles.setIllumination(Illumination.darkness);
              else
                obstacles.setPlayersAppIllumination(Illumination.darkness);
              break;
            case dimLight:
              if ( switchLightingInWhichApp )
                obstacles.setIllumination(Illumination.brightLight);
              else
                obstacles.setPlayersAppIllumination(Illumination.brightLight);
              break;
            case darkness:
              if ( switchLightingInWhichApp )
                obstacles.setIllumination(Illumination.dimLight);
              else
                obstacles.setPlayersAppIllumination(Illumination.dimLight);
              break;
            default:
              break;
          }

          if ( switchLightingInWhichApp ) {
            logger.info("UserInterface: controllerEvent(): Environment lighting switched to " + obstacles.getIllumination().getName());
            obstacles.setRecalculateShadows(true);
          } else {
            logger.info("UserInterface: controllerEvent(): Players' App environment lighting switched to " + obstacles.getPlayersAppIllumination().getName());
            pushSceneSync(false);
          }

          break;
        case "Toggle grid":

          grid.toggleDrawGrid();
          grid.incrementGridVersion();

          break;
        case "Toggle walls":

          obstacles.toggleDrawObstacles();

          break;
        case "Toggle UI":

          Button toggleUi = (Button)controlEvent.getController();

          if ( toggleUi.isOn() ) {

            togglableControllers.show();
            logger.info("UserInterface: controllerEvent(): UI buttons shown");

          } else {

            togglableControllers.hide();
            logger.info("UserInterface: controllerEvent(): UI buttons hidden");

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
          logger.info("UserInterface: controllerEvent(): Touch screen mode " + (cp5.isTouch ? "enabled" : "disabled"));

          break;
        case "Toggle initiative order":

          initiative.toggleDrawInitiativeOrder();
          initiative.incrementInitiativeVersion();

          toggleInitiativeInstructions();

          break;
        case "Toggle mute sound":

          if ( map != null && map.isSet() )
            map.toggleMute();

          break;
        case "Lock map pan and zoom":

          if ( map != null && map.isSet() ) {
            map.togglePan();
            map.toggleZoom();
          }

          break;
        case "Conditions":
        case "Common Light Sources":
        case "Spell Light Sources":
        case "Sight Types":
        case "Sizes":
        case "Settings":

          menuItemClicked = true;

          break;
        case "Change token layer":

          if ( rightClickedToken == null )
            break;

          if ( playersLayer.hasToken(rightClickedToken) ) {

            logger.info("UserInterface: controllerEvent()Switching token " + rightClickedToken.getName() + " from " + playersLayer.getName() + " to " + dmLayer.getName());
            playersLayer.removeToken(rightClickedToken, false);
            dmLayer.addToken(rightClickedToken);

          } else {

            logger.info("UserInterface: controllerEvent()Switching token " + rightClickedToken.getName() + " from " + dmLayer.getName() + " to " + playersLayer.getName());
            dmLayer.removeToken(rightClickedToken, false);
            playersLayer.addToken(rightClickedToken);

          }

          obstacles.setRecalculateShadows(true);
          hideMenu(0, 0);

          break;
        case "Remove token":

          if ( rightClickedToken == null )
            break;

          if ( playersLayer.hasToken(rightClickedToken) ) {

            logger.info("UserInterface: controllerEvent()Removing token " + rightClickedToken.getName() + " from " + playersLayer.getName());
            playersLayer.removeToken(rightClickedToken);

          } else {

            logger.info("UserInterface: controllerEvent()Removing token " + rightClickedToken.getName() + " from " + dmLayer.getName());
            dmLayer.removeToken(rightClickedToken);

          }

          obstacles.setRecalculateShadows(true);
          hideMenu(0, 0);

          break;
        case "Toggle initiative":

          if ( rightClickedToken == null )
            break;

          logger.info("UserInterface: controllerEvent()Toggle token group " + rightClickedToken.getName() + " in initiative");
          if ( playersLayer.hasToken(rightClickedToken) )
            playersLayer.toggleTokenGroupInInitiative(rightClickedToken);
          else
            dmLayer.toggleTokenGroupInInitiative(rightClickedToken);

          obstacles.setRecalculateShadows(true);
          hideMenu(0, 0);

          if ( appMode == AppMode.standalone || appMode == AppMode.dm ) {
            setSwitchButtonState("Toggle initiative order", true);
          } else if ( appMode == AppMode.players ) {
            if ( !initiative.getDrawInitiativeOrder() )
              initiative.toggleDrawInitiativeOrder();
          }

          toggleInitiativeInstructions();

          break;
      }
    }

    return newAppState;

  }

  void mapFileSelected(File mapFile) {

    String type = null;
    boolean isVideo;
    boolean isMuted;
    boolean mapLoaded;

    fileDialogOpen = false;

    if ( mapFile == null || !fileExists(mapFile.getAbsolutePath()) )
      return;

    try {

      String mimeType = Files.probeContentType(mapFile.toPath());
      logger.trace("UserInterface: mapFileSelected(): Map file MIME type: " + mimeType);
      type = mimeType.split("/")[0];
      if ( (!type.equals("image") && !type.equals("video")) || mimeType.equals("image/tiff") ) {
        logger.error("UserInterface: mapFileSelected(): Selected map file is not of a supported image or video type");
        uiDialogs.showErrorDialog("Selected map file is not of a supported image or video type: " + mapFile.getName(), "Unknown map file type");
        return;
      }

    } catch ( Exception e ) {
      logger.error("UserInterface: mapFileSelected(): Error loading selected map");
      logger.error(ExceptionUtils.getStackTrace(e));
      return;
    }

    isVideo = type != null && type.equals("video");
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

    logger.info("UserInterface: mapFileSelected(): Map setup done");

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

    playersLayer.addToken(tokenImageFile, sceneUpdateListener);

  }

  void dmTokenImageSelected(File tokenImageFile) {

    fileDialogOpen = false;

    if ( tokenImageFile == null )
      return;

    dmLayer.addToken(tokenImageFile, sceneUpdateListener);

  }

  AppState moveToken(int _mouseX, int _mouseY, boolean done) {

    AppState newState = appState;

    if ( playersLayer.getToken(_mouseX, _mouseY) != null ) {
      newState = playersLayer.moveToken(_mouseX, _mouseY, done);
    } else {
      if ( appMode == AppMode.standalone || appMode == AppMode.dm )
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

    if ( newWall == null ) {

      UUID wallId = UUID.randomUUID();
      newWall = new Wall(canvas, wallId);

    }

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
      logger.trace("UserInterface: newWallSetup(): New wall added");

      // Create a new wall segment, its first vertex will be the last vertex of the previous segment
      UUID wallId = UUID.randomUUID();
      newWall = new Wall(canvas, wallId);
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

    if ( newDoor == null ) {

      UUID doorId = UUID.randomUUID();
      newDoor = new Door(canvas, doorId);

    }

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
      logger.trace("UserInterface: newDoorSetup(): New door added");

      // Finish this setup
      newDoor = null;

    }

  }

  void removeDoor(int _mouseX, int _mouseY) {

    Door doorToRemove = obstacles.getClosestDoor(map.transformX(_mouseX), map.transformY(_mouseY), 10);

    if ( doorToRemove != null )
      obstacles.removeDoor(doorToRemove);

  }

  void toggleDoor(int _mouseX, int _mouseY) {

    Door doorToToggle = obstacles.getClosestDoor(map.transformX(_mouseX), map.transformY(_mouseY), 20);

    if ( doorToToggle != null ) {

      doorToToggle.toggle();
      obstacles.incrementDoorsVersion();
      obstacles.setRecalculateShadows(true);

    }

  }

  void showMenu(int _mouseX, int _mouseY) {

    if ( !resources.isSet() )
      return;

    Token token;

    token = playersLayer.getToken(_mouseX, _mouseY);
    if ( token == null )
      if ( appMode == AppMode.standalone || appMode == AppMode.dm )
        token = dmLayer.getToken(_mouseX, _mouseY);
    if ( token == null )
      return;

    rightClickedToken = token;

    // Turn off all menu buttons
    ArrayList<ArrayList<String>> nestedListOfControllerNames = new ArrayList<ArrayList<String>>(
      Arrays.asList(
        conditionControllers,
        commonLightSourceControllers,
        spellLightSourceControllers,
        sightTypeControllers,
        sizeControllers
      )
    );
	  List<String> flatListOfControllerNames = nestedListOfControllerNames.stream()
        .flatMap(List::stream)
        .collect(Collectors.toList());
    for ( String controllerName: flatListOfControllerNames ) {
      setSwitchButtonState(controllerName, false, false);
    }

    // Turn on condition buttons that are active for this token
    for ( Condition condition: rightClickedToken.getConditions() ) {
      if ( conditionControllers.contains(condition.getName()) )
        setSwitchButtonState(condition.getName(), true, false);
    }

    // Turn on light source buttons that are active for this token
    for ( Light lightSource: rightClickedToken.getLightSources() ) {
      if ( commonLightSourceControllers.contains(lightSource.getName()) || spellLightSourceControllers.contains(lightSource.getName()) )
        setSwitchButtonState(lightSource.getName(), true, false);
    }

    // Turn on sight type buttons that are active for this token
    for ( Light sightType: rightClickedToken.getSightTypes() ) {
      if ( sightTypeControllers.contains(sightType.getName()) )
        setSwitchButtonState(sightType.getName(), true, false);
    }

    // Turn on the size button that is active for this token
    setSwitchButtonState(rightClickedToken.getSize().getName(), true, false);

    tokenMenu.setPosition(_mouseX, _mouseY);
    tokenMenu.show();

  }

  void hideMenu(int _mouseX, int _mouseY) {

    if ( isInsideMenu(_mouseX, _mouseY) )
      return;

    tokenMenu.hide();
    rightClickedToken = null;

  }

  void toggleInitiativeInstructions() {

    Textlabel initiativeInstructions = (Textlabel)cp5.getController("Initiative instructions");

    if (
      initiative.getDrawInitiativeOrder() &&
      initiative.isEmpty() &&
      ( appMode == AppMode.standalone || appMode == AppMode.dm )
    )
      initiativeInstructions.show();
    else
      initiativeInstructions.hide();

  }

  boolean isInsideInitiativeOrder() {

    return initiative.getDrawInitiativeOrder() && initiative.isInside(mouseX, mouseY);

  }

  AppState changeInitiativeOrder(int _mouseX, boolean done) {

    return initiative.changeInitiativeOrder(_mouseX, done);

  }

  AppState panMap(int _mouseX, int _pmouseX, int _mouseY, int _pmouseY, boolean done) {

    if ( map == null || !map.isSet() || !map.isPanEnabled() )
      return appState;

    map.pan(_mouseX, _pmouseX, _mouseY, _pmouseY);

    if ( done )
      return AppState.idle;
    else
      return AppState.mapPan;

  }

  void zoomMap(int mouseWheelAmount, int _mouseX, int _mouseY) {

    if ( map == null || !map.isSet() )
      return;

    map.zoom(mouseWheelAmount, _mouseX, _mouseY);

  }

  void saveScene(File sceneFolder) {

    try {

      fileDialogOpen = false;

      if ( sceneFolder == null || sceneFolder.getAbsolutePath().isEmpty() )
        return;
      if ( map.getFilePath() == null || map.getFilePath().isEmpty() )
        return;

      File mapFile = new File(map.getFilePath());
      String mapFileName = mapFile.getName();
      String[] mapFileNameTokens = mapFileName.split("\\.(?=[^\\.]+$)");
      String mapBaseName = mapFileNameTokens[0];
      String sceneFile = mapBaseName + ".json";

      saveScene(sceneFolder, sceneFile);

    } catch ( Exception e ) {
      logger.error("UserInterface: saveScene(): Error saving scene");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  void saveScene(File sceneFolder, String sceneFileName) {

    try {

      fileDialogOpen = false;

      if ( sceneFolder == null || sceneFolder.getAbsolutePath().isEmpty() )
        return;
      if ( sceneFileName == null || sceneFileName.isEmpty() )
        return;
      if ( map.getFilePath() == null || map.getFilePath().isEmpty() )
        return;

      logger.info("UserInterface: saveScene(): Saving scene to folder: " + sceneFolder.getAbsolutePath());

      JSONObject sceneJson = sceneToJson(false, false);

      String sceneSavePath = sceneFolder.getAbsolutePath() + File.separator + sceneFileName;
      boolean sceneSaved = saveJSONObject(sceneJson, sceneSavePath);

      if ( sceneSaved ) {
        logger.info("UserInterface: saveScene(): Scene saved to: " + sceneSavePath);
      } else {
        logger.error("UserInterface: saveScene(): Scene could not be saved: " + sceneSavePath);
        uiDialogs.showErrorDialog("Scene could not be saved: " + sceneSavePath, "Error saving scene");
      }

    } catch ( Exception e ) {
      logger.error("UserInterface: saveScene(): Error saving scene");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  JSONObject sceneToJson(boolean addReloadSceneFlag, boolean useSwitchLightingAppToggle) {

    JSONObject sceneJson = null;

    try {

      logger.debug("UserInterface: sceneToJson(): Converting scene to JSON");

      int initiativeGroupsIndex;
      int obstaclesIndex;

      sceneJson = new JSONObject();

      // Parts of the scene are only converted to JSON if running in DM or
      // Standalone modes. They are not included in JSON scenes generated in
      // Players mode because the players' app can't edit these parts, such
      // as map, grid, DM tokens, walls, and environment lighting.

      if ( appMode == AppMode.standalone || appMode == AppMode.dm )
        if ( addReloadSceneFlag )
          sceneJson.setBoolean("reloadScene", true);

      if ( appMode == AppMode.standalone || appMode == AppMode.dm ) {

        JSONObject mapJson = new JSONObject();
        if ( map.isSet() ) {
          mapJson.setString("filePath", getImageSavePath(map.getFilePath()));
          mapJson.setBoolean("fitToScreen", map.getFitToScreen());
          mapJson.setBoolean("isVideo", map.isVideo());
          String logoFilePath = map.getLogoFilePath();
          String logoLink = map.getLogoLink();
          if ( !isEmpty(logoFilePath) && !isEmpty(logoLink) ) {
            mapJson.setString("logoFilePath", getImageSavePath(logoFilePath));
            mapJson.setString("logoLink", logoLink);
          }
        }
        sceneJson.setJSONObject("map", mapJson);

        logger.debug("UserInterface: sceneToJson(): Map converted to JSON");

      }

      if ( appMode == AppMode.standalone || appMode == AppMode.dm ) {

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

        logger.debug("UserInterface: sceneToJson(): Grid converted to JSON");

      }

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

      logger.debug("UserInterface: sceneToJson(): Initiative converted to JSON");

      sceneJson.setJSONArray("playerTokens", getTokensJsonArray(playersLayer));

      if ( appMode == AppMode.standalone || appMode == AppMode.dm )
        sceneJson.setJSONArray("dmTokens", getTokensJsonArray(dmLayer));

      logger.debug("UserInterface: sceneToJson(): Tokens converted to JSON");

      if ( appMode == AppMode.standalone || appMode == AppMode.dm ) {

        JSONArray wallsArray = new JSONArray();
        obstaclesIndex = 0;
        for ( Wall wall: obstacles.getWalls() ) {
          JSONObject wallJson = new JSONObject();
          wallJson.setString("id", wall.getStringId());
          JSONArray wallVertexesJson = new JSONArray();
          for ( PVector wallVertex: wall.getMapVertexes() ) {
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

        logger.debug("UserInterface: sceneToJson(): Walls converted to JSON");

      }

      JSONArray doorsArray = new JSONArray();
      obstaclesIndex = 0;
      for ( Door door: obstacles.getDoors() ) {
        JSONObject doorJson = new JSONObject();
        doorJson.setString("id", door.getStringId());
        doorJson.setBoolean("closed", door.getClosed());
        JSONArray doorVertexesJson = new JSONArray();
        for ( PVector doorVertex: door.getMapVertexes() ) {
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

      logger.debug("UserInterface: sceneToJson(): Doors converted to JSON");

      if ( appMode == AppMode.standalone || appMode == AppMode.dm ) {

        JSONObject illuminationJson = new JSONObject();
        Illumination appIllumination = null;
        if ( useSwitchLightingAppToggle )
          appIllumination = obstacles.getPlayersAppIllumination();
        else
          appIllumination = obstacles.getIllumination();

        switch ( appIllumination ) {
          case brightLight:
            illuminationJson.setString("lighting", "brightLight");
            break;
          case dimLight:
            illuminationJson.setString("lighting", "dimLight");
            break;
          case darkness:
            illuminationJson.setString("lighting", "darkness");
            break;
        }
        sceneJson.setJSONObject("illumination", illuminationJson);

        logger.debug("UserInterface: sceneToJson(): Environment lighting converted to JSON");

      }

      logger.debug("UserInterface: sceneToJson(): Scene converted to JSON");

      return sceneJson;

    } catch ( Exception e ) {
      logger.error("UserInterface: sceneToJson(): Error converting scene to JSON");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  JSONArray getTokensJsonArray(Layer layer) {

    JSONArray tokensArray = new JSONArray();
    int tokensIndex = 0;

    for ( Token token: layer.getTokens() ) {

      JSONObject tokenJson = new JSONObject();

      tokenJson.setString("name", token.getName());
      tokenJson.setString("id", token.getStringId());
      tokenJson.setInt("version", token.getVersion());
      tokenJson.setString("imagePath", getImageSavePath(token.getImagePath()));

      tokenJson.setString("size", token.getSize().getName());

      Cell cell = token.getCell();
      tokenJson.setInt("row", cell.getRow());
      tokenJson.setInt("column", cell.getColumn());

      tokenJson.setJSONArray("lightSources", getLightSourcesJsonArray(token));
      tokenJson.setJSONArray("sightTypes", getSightTypesJsonArray(token));
      tokenJson.setJSONArray("conditions", getConditionsJsonArray(token));

      tokensArray.setJSONObject(tokensIndex, tokenJson);
      tokensIndex += 1;

    }

    return tokensArray;

  }

  JSONArray getLightSourcesJsonArray(Token token) {

    JSONArray tokenLightSourcesArray = new JSONArray();
    int lightSourcesIndex = 0;

    for ( Light lightSource: token.getLightSources() ) {
      JSONObject lightSourceJson = new JSONObject();
      lightSourceJson.setString("name", lightSource.getName());
      tokenLightSourcesArray.setJSONObject(lightSourcesIndex, lightSourceJson);
      lightSourcesIndex += 1;
    }

    return tokenLightSourcesArray;

  }

  JSONArray getSightTypesJsonArray(Token token) {

    JSONArray tokenSightTypesArray = new JSONArray();
    int sightTypesIndex = 0;

    for ( Light sightType: token.getSightTypes() ) {
      JSONObject sightTypeJson = new JSONObject();
      sightTypeJson.setString("name", sightType.getName());
      tokenSightTypesArray.setJSONObject(sightTypesIndex, sightTypeJson);
      sightTypesIndex += 1;
    }

    return tokenSightTypesArray;

  }

  JSONArray getConditionsJsonArray(Token token) {

    JSONArray tokenConditionsArray = new JSONArray();
    int conditionsIndex = 0;

    for ( Condition condition: token.getConditions() ) {
      JSONObject conditionJson = new JSONObject();
      conditionJson.setString("name", condition.getName());
      tokenConditionsArray.setJSONObject(conditionsIndex, conditionJson);
      conditionsIndex += 1;
    }

    return tokenConditionsArray;

  }

  String getImageSavePath(String imageAbsolutePath) {

    if ( isEmpty(imageAbsolutePath) )
      return "";

    String imageSavePath = null;

    // If running on macOS
    if ( platform == MACOS ) {

      // Check if image path is inside sketchPath() + /dungeoneering.app/Contents/Java
      if ( imageAbsolutePath != imageAbsolutePath.replaceFirst("^(?i)" + Pattern.quote(sketchPath() + "/dungeoneering.app/Contents/Java/"), "") ) {

        // If it is, remove sketchPath() + /dungeoneering.app/Contents/Java from image path
        imageSavePath = imageAbsolutePath.replaceFirst("^(?i)" + Pattern.quote(sketchPath() + "/dungeoneering.app/Contents/Java"), "");

       // Check if image path is inside sketchPath() + /dungeoneeringDm.app/Contents/Java
      } else if ( imageAbsolutePath != imageAbsolutePath.replaceFirst("^(?i)" + Pattern.quote(sketchPath() + "/dungeoneeringDm.app/Contents/Java/"), "") ) {

        // If it is, remove sketchPath() + /dungeoneeringDm.app/Contents/Java from image path
        imageSavePath = imageAbsolutePath.replaceFirst("^(?i)" + Pattern.quote(sketchPath() + "/dungeoneeringDm.app/Contents/Java"), "");

       // Check if image path is inside sketchPath() + /dungeoneeringPlayers.app/Contents/Java
      } else if ( imageAbsolutePath != imageAbsolutePath.replaceFirst("^(?i)" + Pattern.quote(sketchPath() + "/dungeoneeringPlayers.app/Contents/Java/"), "") ) {

        // If it is, remove sketchPath() + /dungeoneeringPlayers.app/Contents/Java from image path
        imageSavePath = imageAbsolutePath.replaceFirst("^(?i)" + Pattern.quote(sketchPath() + "/dungeoneeringPlayers.app/Contents/Java"), "");

      }

    // If not, check if image path is inside sketchPath()
    } else if ( imageAbsolutePath != imageAbsolutePath.replaceFirst("^(?i)" + Pattern.quote(sketchPath()), "") ) {

      // If it is, remove sketchPath() from image path
      imageSavePath = imageAbsolutePath.replaceFirst("^(?i)" + Pattern.quote(sketchPath()), "");

      // If it's a Windows and file separator is "\", replace it by "/", to facilitate when loading a scene
      if ( platform == WINDOWS && File.separatorChar == '\\' )
        imageSavePath = imageSavePath.replaceAll("\\\\", "/");

    // If image is not inside sketchPath() at all
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

      String mimeType = Files.probeContentType(sceneFile.toPath());
      logger.trace("UserInterface: loadScene(): Scene file MIME type: " + mimeType);
      if ( !mimeType.equals("application/json") ) {
        logger.error("UserInterface: loadScene(): Selected scene file is not a JSON text file");
        uiDialogs.showErrorDialog("Selected scene file is not a JSON text file: " + sceneFile.getName(), "Unknown scene file type");
        return;
      }

      logger.info("UserInterface: loadScene(): Loading scene from: " + sceneFile.getAbsolutePath());

      JSONObject sceneJson = loadJSONObject(sceneFile.getAbsolutePath());

      if ( sceneFromJson(sceneJson) ) {

        logger.info("UserInterface: loadScene(): Scene loaded from: " + sceneFile.getAbsolutePath());

        // If loading a scene in DM's app, send it to Players' app as well
        if ( appMode == AppMode.dm ) {
          logger.info("UserInterface: loadScene(): Pushing loaded scene to Players' App");
          pushSceneSync(true);
        }

      } else {

        logger.error("UserInterface: loadScene(): Error loading scene from JSON: " + sceneFile.getAbsolutePath());
        reset();

      }

    } catch ( Exception e ) {
      logger.error("UserInterface: loadScene(): Error loading scene");
      logger.error(ExceptionUtils.getStackTrace(e));
      reset();
    }

  }

  boolean sceneFromJson(JSONObject sceneJson) {

    try {

      logger.debug("UserInterface: sceneFromJson(): Loading scene from JSON");

      changeAppState(AppState.sceneLoad);

      resetScene();

      setSwitchButtonState("Toggle initiative order", false, false);
      setSwitchButtonState("Toggle grid", false, false);
      removeController("Map logo");

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
          logger.error("UserInterface: sceneFromJson(): Map file not found: " + mapFilePath);
          logger.error("UserInterface: sceneFromJson(): Scene could not be loaded from JSON");
          uiDialogs.showErrorDialog("Map file not found: " + mapFilePath, "Error loading scene");
          return false;
        }

        boolean isMuted = getSwitchButtonState("Toggle mute sound");

        boolean mapLoaded = map.setup(mapFilePath, fitToScreen, isVideo, isMuted);
        if ( !mapLoaded ) {
          logger.error("UserInterface: sceneFromJson(): Map could not be loaded");
          logger.error("UserInterface: sceneFromJson(): Scene could not be loaded from JSON");
          uiDialogs.showErrorDialog("Map could not be loaded: " + mapFilePath, "Error loading scene");
          return false;
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
        if ( !logoLoadPath.isEmpty() )
          logoFilePath = logoLoadPath;
        else
          logoFilePath = null;

        if ( logoFilePath != null ) {
          Point logoMinPosition = new Point(
            controllersBottomRightInitialX + squareButtonWidth,
            controllersBottomRightInitialY - controllersSpacing
          );
          map.setLogo(logoFilePath, logoLink);
          addLogoButton(logoFilePath, logoMinPosition, logoLink);
        }

        logger.debug("UserInterface: sceneFromJson(): Map loaded");

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

        if ( drawGrid ) {
          if ( appMode == AppMode.standalone || appMode == AppMode.dm )
            setSwitchButtonState("Toggle grid", true);
          else if ( appMode == AppMode.players )
            grid.toggleDrawGrid();
        }

        logger.debug("UserInterface: sceneFromJson(): Grid loaded");

      }

      if ( grid.isSet() ) {

        resources.setupBasedOnGrid();
        logger.debug("UserInterface: sceneFromJson(): Resources setup");

      }

      if ( grid.isSet() ) {

        setTokensFromJsonArray(playersLayer, sceneJson.getJSONArray("playerTokens"));
        setTokensFromJsonArray(dmLayer, sceneJson.getJSONArray("dmTokens"));

        enableController("Add player token");
        enableController("Add DM token");

        logger.debug("UserInterface: sceneFromJson(): Tokens loaded");

      } else {

        disableController("Add player token");
        disableController("Add DM token");

      }

      JSONObject initiativeJson = sceneJson.getJSONObject("initiative");
      if ( initiativeJson != null ) {

        JSONArray initiativeGroupsArray = initiativeJson.getJSONArray("initiativeGroups");
        if ( initiativeGroupsArray != null ) {

          for ( int i = 0; i < initiativeGroupsArray.size(); i++ ) {

            JSONObject initiativeGroupJson = initiativeGroupsArray.getJSONObject(i);
            String groupName = initiativeGroupJson.getString("name");
            Token token = null;

            token = playersLayer.getTokenByName(groupName);
            if ( token != null ) {
              playersLayer.toggleTokenGroupInInitiative(token);
              continue;
            }

            token = dmLayer.getTokenByName(groupName);
            if ( token != null ) {
              dmLayer.toggleTokenGroupInInitiative(token);
              continue;
            }

          }

          for ( int i = 0; i < initiativeGroupsArray.size(); i++ ) {

            JSONObject initiativeGroupJson = initiativeGroupsArray.getJSONObject(i);
            String groupName = initiativeGroupJson.getString("name");
            int groupPosition = initiativeGroupJson.getInt("position");

            initiative.moveGroupTo(groupName, groupPosition);

          }

        }

        boolean drawInitiativeOrder = initiativeJson.getBoolean("drawInitiativeOrder");
        if ( drawInitiativeOrder ) {
          if ( appMode == AppMode.standalone || appMode == AppMode.dm )
            setSwitchButtonState("Toggle initiative order", true);
          else if ( appMode == AppMode.players )
            initiative.toggleDrawInitiativeOrder();
        }

        logger.debug("UserInterface: sceneFromJson(): Initiative loaded");

      }

      JSONArray wallsArray = sceneJson.getJSONArray("walls");
      if ( wallsArray != null ) {

        for ( int i = 0; i < wallsArray.size(); i++ ) {

          JSONObject wallJson = wallsArray.getJSONObject(i);
          Wall wall = createWallFromJsonObject(wallJson);
          if ( wall != null )
            obstacles.addWall(wall);

        }

        logger.debug("UserInterface: sceneFromJson(): Walls loaded");

      }

      JSONArray doorsArray = sceneJson.getJSONArray("doors");
      if ( doorsArray != null ) {

        for ( int i = 0; i < doorsArray.size(); i++ ) {

          JSONObject doorJson = doorsArray.getJSONObject(i);
          Door door = createDoorFromJsonObject(doorJson);
          if ( door != null )
            obstacles.addDoor(door);

        }

        logger.debug("UserInterface: sceneFromJson(): Doors loaded");

      }

      JSONObject illuminationJson = sceneJson.getJSONObject("illumination");
      if ( illuminationJson != null ) {

        String lighting = illuminationJson.getString("lighting");
        switch ( lighting ) {
          case "brightLight":
            obstacles.setIllumination(Illumination.brightLight);
            obstacles.setPlayersAppIllumination(Illumination.brightLight);
            break;
          case "dimLight":
            obstacles.setIllumination(Illumination.dimLight);
            obstacles.setPlayersAppIllumination(Illumination.dimLight);
            break;
          case "darkness":
            obstacles.setIllumination(Illumination.darkness);
            obstacles.setPlayersAppIllumination(Illumination.darkness);
            break;
        }

        logger.debug("UserInterface: sceneFromJson(): Environment lighting loaded");

      }

      layerShown = LayerShown.players;

      obstacles.setRecalculateShadows(true);

      changeAppState(AppState.idle);

      logger.debug("UserInterface: sceneFromJson(): Scene loaded from JSON");

    } catch ( Exception e ) {
      logger.error("UserInterface: sceneFromJson(): Error loading scene from JSON");
      logger.error(ExceptionUtils.getStackTrace(e));
      return false;
    }

    return true;

  }

  void setTokensFromJsonArray(Layer layer, JSONArray tokensArray) {

    if ( tokensArray == null )
      return;

    for ( int i = 0; i < tokensArray.size(); i++ ) {

      JSONObject tokenJson = tokensArray.getJSONObject(i);
      Token token = createTokenFromJsonObject(tokenJson);
      if ( token != null )
        layer.addToken(token);

    }

  }

  Token createTokenFromJsonObject(JSONObject tokenJson) {

    if ( tokenJson == null )
      return null;

    Token token = null;

    try {

      String tokenName = tokenJson.getString("name");

      UUID tokenId = null;
      String tokenIdAsString = tokenJson.getString("id");
      if ( isEmpty(tokenIdAsString) ) {
        logger.warning("UserInterface: createTokenFromJsonObject(): JSON token " + tokenName + " has no ID, generating one");
        tokenId = UUID.randomUUID();
      } else {
        tokenId = UUID.fromString(tokenIdAsString);
      }

      // Don't load version, let it be calculated from initial conditions, light sources, etc
      int tokenVersion = 1;

      String tokenImagePath = tokenJson.getString("imagePath");

      String tokenSizeName = tokenJson.getString("size", "Medium");
      Size tokenSize = resources.getSize(tokenSizeName);
      if ( tokenSize == null ) {
        logger.error("UserInterface: createTokenFromJsonObject(): Token " + tokenName + " size not found: " + tokenSizeName);
        return null;
      }

      int tokenRow = tokenJson.getInt("row");
      int tokenColumn = tokenJson.getInt("column");

      String tokenImageLoadPath = getImageLoadPath(tokenImagePath);
      if ( !tokenImageLoadPath.isEmpty() ) {
        tokenImagePath = tokenImageLoadPath;
      } else {
        logger.error("UserInterface: createTokenFromJsonObject(): Token " + tokenName + " image not found: " + tokenImagePath);
        return null;
      }

      token = new Token(canvas, grid, obstacles);
      Cell cell = grid.getCellAt(tokenRow, tokenColumn);
      Light lineOfSightTemplate = resources.getLineOfSight();
      Light tokenLineOfSight = new Light(lineOfSightTemplate.getName(), lineOfSightTemplate.getBrightLightRadius(), lineOfSightTemplate.getDimLightRadius());
      token.setup(tokenName, tokenId, tokenVersion, sceneUpdateListener, tokenImagePath, grid.getCellWidth(), grid.getCellHeight(), tokenSize, tokenLineOfSight);
      token.setCell(cell);

      for ( Light lightSource: getLightSourcesFromJsonArray(tokenName, tokenJson.getJSONArray("lightSources")) )
        token.toggleLightSource(new Light(lightSource.getName(), lightSource.getBrightLightRadius(), lightSource.getDimLightRadius()));

      for ( Light sightType: getSightTypesFromJsonArray(tokenName, tokenJson.getJSONArray("sightTypes")) )
        token.toggleSightType(new Light(sightType.getName(), sightType.getBrightLightRadius(), sightType.getDimLightRadius()));

      for ( Condition condition: getConditionsFromJsonArray(tokenName, tokenJson.getJSONArray("conditions"), tokenSize) )
        token.toggleCondition(condition);

    } catch ( Exception e ) {
      logger.error("UserInterface: createTokenFromJsonObject(): Error creating token from JSON");
      logger.error(ExceptionUtils.getStackTrace(e));
      token = null;
    }

    return token;

  }

  Wall createWallFromJsonObject(JSONObject wallJson) {

    if ( wallJson == null )
      return null;

    Wall wall = null;

    try {

      UUID wallId = null;
      String wallIdAsString = wallJson.getString("id");
      if ( wallIdAsString == null || wallIdAsString.isEmpty() ) {
        logger.warning("UserInterface: createWallFromJsonObject(): JSON wall has no ID, generating one");
        wallId = UUID.randomUUID();
      } else {
        wallId = UUID.fromString(wallJson.getString("id"));
      }

      wall = new Wall(canvas, wallId);

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

      if ( wall.getCanvasVertexes().size() < 2 || wall.getMapVertexes().size() < 2 ) {
        logger.error("UserInterface: createWallFromJsonObject(): Wall has less than two vertexes, must have at least two");
        return null;
      }

    } catch ( Exception e ) {
      logger.error("UserInterface: createWallFromJsonObject(): Error creating wall from JSON");
      logger.error(ExceptionUtils.getStackTrace(e));
      wall = null;
    }

    return wall;

  }

  Door createDoorFromJsonObject(JSONObject doorJson) {

    if ( doorJson == null )
      return null;

    Door door = null;

    try {

      UUID doorId = null;
      String doorIdAsString = doorJson.getString("id");
      if ( doorIdAsString == null || doorIdAsString.isEmpty() ) {
        logger.warning("UserInterface: createDoorFromJsonObject(): JSON door has no ID, generating one");
        doorId = UUID.randomUUID();
      } else {
        doorId = UUID.fromString(doorJson.getString("id"));
      }

      door = new Door(canvas, doorId);

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

      if ( door.getCanvasVertexes().size() < 2 || door.getMapVertexes().size() < 2 ) {
        logger.error("UserInterface: createDoorFromJsonObject(): Door has less than two vertexes, must have at least two");
        return null;
      }

    } catch ( Exception e ) {
      logger.error("UserInterface: createDoorFromJsonObject(): Error creating door from JSON");
      logger.error(ExceptionUtils.getStackTrace(e));
      door = null;
    }

    return door;

  }

  ArrayList<Light> getLightSourcesFromJsonArray(String tokenName, JSONArray lightsArray) {

    ArrayList<Light> lights = new ArrayList<Light>();

    if ( lightsArray == null )
      return lights;

    for ( int j = 0; j < lightsArray.size(); j++ ) {
      JSONObject lightJson = lightsArray.getJSONObject(j);
      String name = lightJson.getString("name");
      Light light = resources.getCommonLightSource(name);
      if ( light == null )
        light = resources.getSpellLightSource(name);
      if ( light != null ) {
        lights.add(light);
      } else {
        logger.error("UserInterface: getLightSourcesFromJsonArray(): Token " + tokenName + " light source not found: " + name);
        continue;
      }
    }

    return lights;

  }

  ArrayList<Light> getSightTypesFromJsonArray(String tokenName, JSONArray sightsArray) {

    ArrayList<Light> sights = new ArrayList<Light>();

    if ( sightsArray == null )
      return sights;

    for ( int j = 0; j < sightsArray.size(); j++ ) {
      JSONObject sightJson = sightsArray.getJSONObject(j);
      String name = sightJson.getString("name");
      Light sight = resources.getSightType(name);
      if ( sight != null ) {
        sights.add(sight);
      } else {
        logger.error("UserInterface: getSightTypesFromJsonArray(): Token " + tokenName + " sight type not found: " + name);
        continue;
      }
    }

    return sights;

  }

  ArrayList<Condition> getConditionsFromJsonArray(String tokenName, JSONArray conditionsArray, Size tokenSize) {

    ArrayList<Condition> conditions = new ArrayList<Condition>();

    if ( conditionsArray == null )
      return conditions;

    for ( int j = 0; j < conditionsArray.size(); j++ ) {
      JSONObject conditionJson = conditionsArray.getJSONObject(j);
      String name = conditionJson.getString("name");
      Condition condition = resources.getCondition(name, tokenSize);
      if ( condition != null ) {
        conditions.add(condition);
      } else {
        logger.error("UserInterface: getConditionsFromJsonArray(): Token " + tokenName + " condition not found: " + name);
        continue;
      }
    }

    return conditions;

  }

  String getImageLoadPath(String imagePathFromJson) {

    if ( isEmpty(imagePathFromJson) ) {
      return "";
    }

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

    // If not, check if it's running on macOS
    } else if ( platform == MACOS ) {

      // Check if image path is inside /dungeoneering.app/Contents/Java/data/
      if ( imagePathFromJson != imagePathFromJson.replaceFirst("^(?i)" + Pattern.quote("/dungeoneering.app/Contents/Java/data/"), "") ) {

        // If it is, check if image indeed exists inside /dungeoneering.app/Contents/Java/data/
        imagePathInDataFolder = imagePathFromJson.replaceFirst("^(?i)" + Pattern.quote("/dungeoneering.app/Contents/Java/data/"), "");
        if ( fileExists(dataPath(imagePathInDataFolder)) ) {

          // Return image's absolute path, returned by dataPath()
          imageLoadPath = dataPath(imagePathInDataFolder);

        }

      // Check if image path is inside /dungeoneeringDm.app/Contents/Java/data/
      } else if ( platform == MACOS && imagePathFromJson != imagePathFromJson.replaceFirst("^(?i)" + Pattern.quote("/dungeoneeringDm.app/Contents/Java/data/"), "") ) {

        // If it is, check if image indeed exists inside /dungeoneeringDm.app/Contents/Java/data/
        imagePathInDataFolder = imagePathFromJson.replaceFirst("^(?i)" + Pattern.quote("/dungeoneeringDm.app/Contents/Java/data/"), "");
        if ( fileExists(dataPath(imagePathInDataFolder)) ) {

          // Return image's absolute path, returned by dataPath()
          imageLoadPath = dataPath(imagePathInDataFolder);

        }

      // Check if image path is inside /dungeoneeringPlayers.app/Contents/Java/data/
      } else if ( platform == MACOS && imagePathFromJson != imagePathFromJson.replaceFirst("^(?i)" + Pattern.quote("/dungeoneeringPlayers.app/Contents/Java/data/"), "") ) {

        // If it is, check if image indeed exists inside /dungeoneeringPlayers.app/Contents/Java/data/
        imagePathInDataFolder = imagePathFromJson.replaceFirst("^(?i)" + Pattern.quote("/dungeoneeringPlayers.app/Contents/Java/data/"), "");
        if ( fileExists(dataPath(imagePathInDataFolder)) ) {

          // Return image's absolute path, returned by dataPath()
          imageLoadPath = dataPath(imagePathInDataFolder);

        }

      }

    // If not
    } else {

      // Image could not be found, return an empty path
      imageLoadPath = "";

    }

    return imageLoadPath;

  }

  void addLogoButton(String logoImagePath, Point buttonMinPosition, String logoLink) {

    if ( isEmpty(logoImagePath) ) {
      logger.error("UserInterface: addLogoButton(): Logo image path is empty");
      return;
    }

    if ( isEmpty(logoLink) ) {
      logger.error("UserInterface: addLogoButton(): Logo link is empty");
      return;
    }

    if ( buttonMinPosition == null ) {
      logger.error("UserInterface: addLogoButton(): Button position is null");
      return;
    }

    PImage logoImage = loadImage(logoImagePath);
    logoImage.resize(min(logoImage.width, logoMaxWidth), 0);
    logoImage.resize(0, min(logoImage.height, logoMaxHeight));

    cp5.addButton("Map logo")
       .setPosition(buttonMinPosition.x - logoImage.width, buttonMinPosition.y - logoImage.height)
       .setSize(logoImage.width, logoImage.height)
       .setImage(logoImage)
       .updateSize()
       .setStringValue(logoLink)
       ;

    controllerToTooltip.put("Map logo", new UserInterfaceTooltip("Click to visit website", mouseOverBackgroundColor, instructionsFontColor));

  }

  void syncScene(JSONObject sceneJson) {

    if ( appMode == AppMode.standalone )
      return;

    if ( sceneJson == null || isEmpty(sceneJson.toString()) )
      return;

    if ( !map.isSet() || !grid.isSet() || sceneJson.getBoolean("reloadScene", false) ) {

      logger.info("UserInterface: syncScene(): Loading initial scene from received JSON");
      if ( !sceneFromJson(sceneJson) )
        logger.error("UserInterface: syncScene(): Error loading scene from received JSON");
      return;

    }

    try {

      changeAppState(AppState.sceneSync);

      logger.info("UserInterface: syncScene(): Syncing scene changes from received JSON");

      syncGridChanges(sceneJson.getJSONObject("grid"));

      syncTokenChanges(playersLayer, sceneJson.getJSONArray("playerTokens"));
      syncTokenChanges(dmLayer, sceneJson.getJSONArray("dmTokens"));

      syncInitiativeChanges(sceneJson.getJSONObject("initiative"));

      syncWallChanges(sceneJson.getJSONArray("walls"));

      syncDoorChanges(sceneJson.getJSONArray("doors"));

      syncLighting(sceneJson.getJSONObject("illumination"));

      obstacles.setRecalculateShadows(true);

      changeAppState(AppState.idle);

      logger.info("UserInterface: syncScene(): Scene synced from received JSON");

    } catch ( Exception e ) {
      logger.error("UserInterface: syncScene(): Error syncing scene changes");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  void syncGridChanges(JSONObject gridJson) {

    if ( gridJson == null )
      return;

    try {

      logger.debug("UserInterface: syncGridChanges(): Syncing grid changes");

      // Retrieve if grid should be drawn
      boolean drawGrid = gridJson.getBoolean("drawGrid", false);
      if ( grid.getDrawGrid() != drawGrid )
        grid.toggleDrawGrid();

      logger.debug("UserInterface: syncGridChanges(): Grid changes synced");

    } catch ( Exception e ) {
      logger.error("UserInterface: syncGridChanges(): Error syncing grid changes");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  void syncTokenChanges(Layer layer, JSONArray tokensArray) {

    if ( tokensArray == null )
      return;

    try {

      logger.debug("UserInterface: syncTokenChanges(): Syncing " + layer.getName() + " token changes");

      ArrayList<UUID> sceneTokenIds = new ArrayList<UUID>();
      ArrayList<UUID> syncTokenIds = new ArrayList<UUID>();

      // Build list with scene token IDs, used to check if a new token was added
      for ( Token token: layer.getTokens() ) {
        UUID sceneTokenId = token.getId();
        if ( sceneTokenId != null )
          sceneTokenIds.add(sceneTokenId);
        else
          logger.warning("UserInterface: syncTokenChanges(): Error syncing " + layer.getName() + " token changes: scene token has null ID");
      }

      //
      // Add new tokens found in received JSON
      //

      // For each token in JSONArray
      for ( int i = 0; i < tokensArray.size(); i++ ) {

        JSONObject tokenJson = tokensArray.getJSONObject(i);

        // Retrieve JSON token ID
        UUID tokenId = null;
        String tokenIdAsString = tokenJson.getString("id");
        if ( isEmpty(tokenIdAsString) ) {
          logger.warning("UserInterface: syncTokenChanges(): Error syncing " + layer.getName() + " token changes: JSON token has null or empty ID");
          continue;
        }
        tokenId = UUID.fromString(tokenJson.getString("id"));

        // Build list with JSON token IDs, used to check if a token was removed
        syncTokenIds.add(tokenId);

        // If token is already present in scene, continue
        if ( sceneTokenIds.contains(tokenId) )
          continue;

        // Else, create new token from JSON and add it to layer
        Token token = createTokenFromJsonObject(tokenJson);
        if ( token != null )
          layer.addToken(token);

        logger.debug("UserInterface: syncTokenChanges(): Token " + tokenId + " added to " + layer.getName());

      }

      //
      // Remove tokens not found in received JSON
      //

      // Check if a scene token was removed in the received JSON
      for ( UUID tokenId: sceneTokenIds ) {

        // If scene token is also present in JSON, continue
        if ( syncTokenIds.contains(tokenId) )
          continue;

        // Else, remove token
        layer.removeToken(layer.getTokenById(tokenId));

        logger.debug("UserInterface: syncTokenChanges(): Token " + tokenId + " removed from " + layer.getName());

      }

      //
      // Check existing tokens for changes
      //

      // For each token in JSONArray
      for ( int i = 0; i < tokensArray.size(); i++ ) {

        JSONObject tokenJson = tokensArray.getJSONObject(i);

        // Get its name, UUID and version
        String tokenName = tokenJson.getString("name");
        UUID tokenId = UUID.fromString(tokenJson.getString("id"));
        int tokenVersion = tokenJson.getInt("version");

        logger.trace("UserInterface: syncTokenChanges(): Sync token " + tokenName + ": " + tokenId + " v" + tokenVersion);

        // For each existing token in app
        for ( Token token: layer.getTokens() ) {

          logger.trace("UserInterface: syncTokenChanges(): Scene token " + token.getName() + ": " + token.getStringId() + " v" + token.getVersion());

          // If existing token has the same UUID and a different version, update it
          if ( token.getId().equals(tokenId) ) {
            if ( token.getVersion() < tokenVersion ) {

              logger.debug("UserInterface: syncTokenChanges(): Scene token " + token.getName() + " changed: " + token.getStringId() + " v" + token.getVersion());

              ArrayList<Token> tokenSceneArray = new ArrayList<Token>();
              tokenSceneArray.add(token);

              // Check if token position changed
              Cell tokenNewCell = grid.getCellAt(tokenJson.getInt("row"), tokenJson.getInt("column"));
              if ( !token.getCell().equals(tokenNewCell) ) {
                logger.debug("UserInterface: syncTokenChanges(): Position changed from " + token.getCell().getRow() + "," + token.getCell().getColumn() + " to " + tokenNewCell.getRow() + "," + tokenNewCell.getColumn());
                layer.moveToken(token, tokenNewCell);
              }

              // Check if token size changed
              Size tokenNewSize = resources.getSize(tokenJson.getString("size"));
              if ( !token.getSize().equals(tokenNewSize) ) {
                logger.debug("UserInterface: syncTokenChanges(): Size changed from " + token.getSize().getName() + " to " + tokenNewSize.getName());
                token.setSize(tokenNewSize, resources);
              }

              // Check if conditions changed
              ArrayList<Condition> tokenNewConditions = getConditionsFromJsonArray(token.getName(), tokenJson.getJSONArray("conditions"), token.getSize());
              CopyOnWriteArrayList<Condition> tokenConditions = token.getConditions();
              ArrayList<Condition> conditionsToAdd = new ArrayList<Condition>();
              ArrayList<Condition> conditionsToRemove = new ArrayList<Condition>();
              // Check if conditions were added
              for ( Condition condition: tokenNewConditions )
                if ( !tokenConditions.contains(condition) ) {
                  logger.debug("UserInterface: syncTokenChanges(): Condition " + condition.getName() + " added");
                  conditionsToAdd.add(condition);
                }
              if ( !conditionsToAdd.isEmpty() )
                for ( Condition condition: conditionsToAdd )
                  token.toggleCondition(condition);
              // Check if conditions were removed
              for ( Condition condition: tokenConditions )
                if ( !tokenNewConditions.contains(condition) ) {
                  logger.debug("UserInterface: syncTokenChanges(): Condition " + condition.getName() + " removed");
                  conditionsToRemove.add(condition);
                }
              if ( !conditionsToRemove.isEmpty() )
                for ( Condition condition: conditionsToRemove )
                  token.toggleCondition(condition);

              // Check if light sources changed
              ArrayList<Light> tokenNewLightSources = getLightSourcesFromJsonArray(token.getName(), tokenJson.getJSONArray("lightSources"));
              CopyOnWriteArrayList<Light> tokenLightSources = token.getLightSources();
              ArrayList<Light> lightSourcesToAdd = new ArrayList<Light>();
              ArrayList<Light> lightSourcesToRemove = new ArrayList<Light>();
              // Check if light sources were added
              for ( Light lightSource: tokenNewLightSources )
                if ( !tokenLightSources.contains(lightSource) ) {
                  logger.debug("UserInterface: syncTokenChanges(): Light Source " + lightSource.getName() + " added");
                  lightSourcesToAdd.add(lightSource);
                }
              if ( !lightSourcesToAdd.isEmpty() )
                for ( Light lightSource: lightSourcesToAdd )
                  token.toggleLightSource(lightSource);
              // Check if light sources were removed
              for ( Light lightSource: tokenLightSources )
                if ( !tokenNewLightSources.contains(lightSource) ) {
                  logger.debug("UserInterface: syncTokenChanges(): Light Source " + lightSource.getName() + " removed");
                  lightSourcesToRemove.add(lightSource);
                }
              if ( !lightSourcesToRemove.isEmpty() )
                for ( Light lightSource: lightSourcesToRemove )
                  token.toggleLightSource(lightSource);

              // Check if sight types changed
              ArrayList<Light> tokenNewSightTypes = getSightTypesFromJsonArray(token.getName(), tokenJson.getJSONArray("sightTypes"));
              CopyOnWriteArrayList<Light> tokenSightTypes = token.getSightTypes();
              ArrayList<Light> sightTypesToAdd = new ArrayList<Light>();
              ArrayList<Light> sightTypesToRemove = new ArrayList<Light>();
              // Check if sight types were added
              for ( Light sightType: tokenNewSightTypes )
                if ( !tokenSightTypes.contains(sightType) ) {
                  logger.debug("UserInterface: syncTokenChanges(): Sight Type " + sightType.getName() + " added");
                  sightTypesToAdd.add(sightType);
                }
              if ( !sightTypesToAdd.isEmpty() )
                for ( Light sightType: sightTypesToAdd )
                  token.toggleSightType(sightType);
              // Check if sight types were removed
              for ( Light sightType: tokenSightTypes )
                if ( !tokenNewSightTypes.contains(sightType) ) {
                  logger.debug("UserInterface: syncTokenChanges(): Sight Type " + sightType.getName() + " removed");
                  sightTypesToRemove.add(sightType);
                }
              if ( !sightTypesToRemove.isEmpty() )
                for ( Light sightType: sightTypesToRemove )
                  token.toggleSightType(sightType);

            }
          }

        }

      }

      logger.debug("UserInterface: syncTokenChanges(): " + layer.getName() + " token changes synced");

    } catch ( Exception e ) {
      logger.error("UserInterface: syncTokenChanges(): Error syncing " + layer.getName() + " token changes");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  void syncInitiativeChanges(JSONObject initiativeJson) {

    if ( initiativeJson == null )
      return;

    try {

      logger.debug("UserInterface: syncInitiativeChanges(): Syncing initiative group changes");

      ArrayList<String> sceneInitiativeGroups = new ArrayList<String>();
      ArrayList<String> syncInitiativeGroups = new ArrayList<String>();

      // Retrieve if initiative order should be drawn
      boolean drawInitiativeOrder = initiativeJson.getBoolean("drawInitiativeOrder");
      if ( initiative.getDrawInitiativeOrder() != drawInitiativeOrder )
        initiative.toggleDrawInitiativeOrder();

      // Build list with scene initiative group names, used to check if a new group was added
      for ( Initiative.InitiativeGroup initiativeGroup: initiative.getGroups() ) {
        String groupName = initiativeGroup.getName();
        if ( !isEmpty(groupName) )
          sceneInitiativeGroups.add(groupName);
        else
          logger.warning("UserInterface: syncInitiativeChanges(): Error syncing initiative group changes: initiative group has no name");
      }

      JSONArray initiativeGroupsArray = initiativeJson.getJSONArray("initiativeGroups");

      // Check if there's a new initiative group in the received JSON
      for ( int i = 0; i < initiativeGroupsArray.size(); i++ ) {

        JSONObject initiativeGroupJson = initiativeGroupsArray.getJSONObject(i);

        // Retrieve JSON initiative group name
        String jsonGroupName = initiativeGroupJson.getString("name");
        if ( isEmpty(jsonGroupName) ) {
          logger.warning("UserInterface: syncInitiativeChanges(): Error syncing initiative group changes: JSON initiative group name is null or empty");
          continue;
        }

        logger.trace("UserInterface: syncInitiativeChanges(): Sync initiative group: " + jsonGroupName);

        // Build list with JSON initiative group IDs, used to check if a group was removed
        syncInitiativeGroups.add(jsonGroupName);

        // If initiative group is already present in scene, continue
        if ( sceneInitiativeGroups.contains(jsonGroupName) )
          continue;

        // Else, retrieve token by name and add it to initiative
        Token tokenToAdd = playersLayer.getTokenByName(jsonGroupName);
        if ( tokenToAdd == null )
          tokenToAdd = dmLayer.getTokenByName(jsonGroupName);
        if ( tokenToAdd != null ) {
          if ( playersLayer.hasToken(tokenToAdd) )
            playersLayer.toggleTokenGroupInInitiative(tokenToAdd);
          else
            dmLayer.toggleTokenGroupInInitiative(tokenToAdd);
        } else {
          logger.warning("UserInterface: syncInitiativeChanges(): Error syncing initiative group changes: JSON initiative group name is null or empty");
          continue;
        }

        logger.debug("UserInterface: syncInitiativeChanges(): Initiative group " + jsonGroupName + " added");

      }

      // Check if a scene initiative group was removed in the received JSON
      for ( String initiativeGroupName: sceneInitiativeGroups ) {

        logger.trace("UserInterface: syncInitiativeChanges(): Scene initiative group: " + initiativeGroupName);

        // If scene initiative group is also present in JSON, continue
        if ( syncInitiativeGroups.contains(initiativeGroupName) )
          continue;

        // Else, remove initiative group
        Token tokenToRemove = playersLayer.getTokenByName(initiativeGroupName);
        if ( tokenToRemove == null )
          tokenToRemove = dmLayer.getTokenByName(initiativeGroupName);
        if ( tokenToRemove != null ) {
          if ( playersLayer.hasToken(tokenToRemove) )
            playersLayer.toggleTokenGroupInInitiative(tokenToRemove);
          else
            dmLayer.toggleTokenGroupInInitiative(tokenToRemove);
        } else {
          logger.warning("UserInterface: syncInitiativeChanges(): Error syncing initiative group changes: JSON initiative group name is null or empty");
          continue;
        }

        logger.debug("UserInterface: syncInitiativeChanges(): Initiative group " + initiativeGroupName + " removed");

      }

      // Check if a initiative group changed position in the received JSON
      for ( int i = 0; i < initiativeGroupsArray.size(); i++ ) {

        JSONObject initiativeGroupJson = initiativeGroupsArray.getJSONObject(i);

        // Retrieve JSON initiative group fields
        String jsonGroupName = initiativeGroupJson.getString("name");
        int jsonGroupPosition = initiativeGroupJson.getInt("position");

        logger.trace("UserInterface: syncInitiativeChanges(): Sync initiative group: " + jsonGroupName + " at position " + jsonGroupPosition);

        // Retrieve scene initiative group fields
        Initiative.InitiativeGroup sceneGroup = initiative.getGroupByName(jsonGroupName);
        int sceneGroupPosition = initiative.getGroupPosition(sceneGroup);

        logger.trace("UserInterface: syncInitiativeChanges(): Scene initiative group: " + sceneGroup.getName() + " at position " + sceneGroupPosition);

        // If scene initiative group is already in the same position as JSON, continue
        if ( sceneGroupPosition == jsonGroupPosition )
          continue;

        // If not, move scene initiative group to JSON position
        initiative.moveGroupTo(jsonGroupName, jsonGroupPosition);

        logger.debug("UserInterface: syncInitiativeChanges(): " + jsonGroupName + " initiative position changed from " + sceneGroupPosition + " to " + jsonGroupPosition);

      }

      logger.debug("UserInterface: syncInitiativeChanges(): Initiative group changes synced");

    } catch ( Exception e ) {
      logger.error("UserInterface: syncInitiativeChanges(): Error syncing initiative group changes");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  void syncWallChanges(JSONArray wallsJson) {

    if ( wallsJson == null )
      return;

    try {

      logger.debug("UserInterface: syncWallChanges(): Syncing wall changes");

      ArrayList<UUID> sceneWallIds = new ArrayList<UUID>();
      ArrayList<UUID> syncWallIds = new ArrayList<UUID>();

      // Build list with scene wall IDs, used to check if a new wall was added
      for ( Wall wall: obstacles.getWalls() ) {
        UUID sceneWallId = wall.getId();
        if ( sceneWallId != null )
          sceneWallIds.add(sceneWallId);
        else
          logger.warning("UserInterface: syncWallChanges(): Error syncing wall changes: scene wall has null ID");
      }

      // Check if there's a new wall in the received JSON
      for ( int i = 0; i < wallsJson.size(); i++ ) {

        JSONObject wallJson = wallsJson.getJSONObject(i);

        // Retrieve JSON wall ID
        UUID wallId = null;
        String wallIdAsString = wallJson.getString("id");
        if ( isEmpty(wallIdAsString) ) {
          logger.warning("UserInterface: syncWallChanges(): Error syncing wall changes: JSON wall has null or empty ID");
          continue;
        }
        wallId = UUID.fromString(wallJson.getString("id"));

        logger.trace("UserInterface: syncWallChanges(): Sync wall: " + wallId.toString());

        // Build list with JSON wall IDs, used to check if a wall was removed
        syncWallIds.add(wallId);

        // If wall is already present in scene, continue
        if ( sceneWallIds.contains(wallId) )
          continue;

        // Else, create new wall from JSON and add it to obstacles
        Wall wall = createWallFromJsonObject(wallJson);
        if ( wall != null )
          obstacles.addWall(wall);

        logger.debug("UserInterface: syncWallChanges(): Wall " + wallId + " added");

      }

      // Check if a scene wall was removed in the received JSON
      for ( UUID wallId: sceneWallIds ) {

        logger.trace("UserInterface: syncWallChanges(): Scene wall: " + wallId.toString());

        // If scene wall is also present in JSON, continue
        if ( syncWallIds.contains(wallId) )
          continue;

        // Else, remove wall
        obstacles.removeWall(obstacles.getWallById(wallId));

        logger.debug("UserInterface: syncWallChanges(): Wall " + wallId + " removed");

      }

      logger.debug("UserInterface: syncWallChanges(): Wall changes synced");

    } catch ( Exception e ) {
      logger.error("UserInterface: syncWallChanges(): Error syncing wall changes");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  void syncDoorChanges(JSONArray doorsJson) {

    if ( doorsJson == null )
      return;

    try {

      logger.debug("UserInterface: syncDoorChanges(): Syncing door changes");

      HashMap<UUID, Boolean> sceneDoorIdAndStatus = new HashMap<UUID, Boolean>();
      HashMap<UUID, Boolean> syncDoorIdAndStatus = new HashMap<UUID, Boolean>();

      // Build list with scene doors, used to check if a new door was added
      for ( Door door: obstacles.getDoors() ) {
        UUID sceneDoorId = door.getId();
        boolean sceneDoorIsClosed = door.getClosed();
        if ( sceneDoorId != null )
          sceneDoorIdAndStatus.put(sceneDoorId, sceneDoorIsClosed);
        else
          logger.warning("UserInterface: syncDoorChanges(): Error syncing door changes: scene door has null ID");
      }

      // Check if there's a new door in the received JSON
      for ( int i = 0; i < doorsJson.size(); i++ ) {

        JSONObject doorJson = doorsJson.getJSONObject(i);

        // Retrieve JSON door ID
        UUID doorId = null;
        String doorIdAsString = doorJson.getString("id");
        if ( isEmpty(doorIdAsString) ) {
          logger.warning("UserInterface: syncDoorChanges(): Error syncing door changes: JSON door has null or empty ID");
          continue;
        }
        doorId = UUID.fromString(doorJson.getString("id"));

        // Retrieve if JSON door is closed
        boolean doorIsClosed = doorJson.getBoolean("closed");

        logger.trace("UserInterface: syncDoorChanges(): Sync door: " + doorId.toString());

        // Build list with JSON doors, used to check if a door was removed
        syncDoorIdAndStatus.put(doorId, doorIsClosed);

        // If door is already present in scene, continue
        if ( sceneDoorIdAndStatus.containsKey(doorId) )
          continue;

        // Else, create new door from JSON and add it to obstacles
        Door door = createDoorFromJsonObject(doorJson);
        if ( door != null )
          obstacles.addDoor(door);

        logger.debug("UserInterface: syncDoorChanges(): Door " + doorId + " added");

      }

      // Check if a scene door was removed in the received JSON
      for ( UUID doorId: sceneDoorIdAndStatus.keySet() ) {

        logger.trace("UserInterface: syncDoorChanges(): Scene door: " + doorId.toString());

        // If scene door is also present in JSON, continue
        if ( syncDoorIdAndStatus.containsKey(doorId) )
          continue;

        // Else, remove door
        obstacles.removeDoor(obstacles.getDoorById(doorId));

        logger.debug("UserInterface: syncDoorChanges(): Door " + doorId + " removed");

      }

      // Check if a door was opened or closed
      for ( UUID sceneDoorId: sceneDoorIdAndStatus.keySet() ) {

        boolean sceneDoorIsClosed = sceneDoorIdAndStatus.get(sceneDoorId);
        boolean syncDoorIsClosed = syncDoorIdAndStatus.get(sceneDoorId);

        if ( sceneDoorIsClosed != syncDoorIsClosed )
          obstacles.getDoorById(sceneDoorId).toggle();

      }

      logger.debug("UserInterface: syncDoorChanges(): Door changes synced");

    } catch ( Exception e ) {
      logger.error("UserInterface: syncDoorChanges(): Error syncing door changes");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  void syncLighting(JSONObject illuminationJson) {

    if ( illuminationJson == null )
      return;

    try {

      logger.debug("UserInterface: syncLighting(): Syncing illumination changes");

      // Retrieve current environment illumination
      String lighting = illuminationJson.getString("lighting");
      switch ( lighting ) {
        case "brightLight":
          obstacles.setIllumination(Illumination.brightLight);
          break;
        case "dimLight":
          obstacles.setIllumination(Illumination.dimLight);
          break;
        case "darkness":
          obstacles.setIllumination(Illumination.darkness);
          break;
      }

      logger.debug("UserInterface: syncLighting(): Illumination changes synced");

    } catch ( Exception e ) {
      logger.error("UserInterface: syncLighting(): Error syncing illumination changes");
      logger.error(ExceptionUtils.getStackTrace(e));
      throw e;
    }

  }

  void pushSceneSync(boolean addReloadSceneFlag) {

    if ( appMode == AppMode.standalone )
      return;

    if ( appState == AppState.sceneLoad ) {
      logger.trace("UserInterface: pushSceneSync(): Scene being loaded. Ignoring.");
      return;
    }
    if ( appState == AppState.sceneSync ) {
      logger.trace("UserInterface: pushSceneSync(): Scene being synced. Ignoring.");
      return;
    }

    logger.warning("UserInterface: pushSceneSync(): Pushing scene from " + appMode.toString());

    JSONObject sceneJson = sceneToJson(addReloadSceneFlag, true);
    String sceneJsonAsString = sceneJson.toString();

    if ( appMode == AppMode.dm )
      sharedData.put("fromDmApp", sceneJsonAsString);
    else
      sharedData.put("fromPlayersApp", sceneJsonAsString);

  }

  void removeController(String controllerName) {

    if ( isEmpty(controllerName) ) {
      logger.error("UserInterface: removeController(): Controller name is empty");
      return;
    }

    cp5.remove(controllerName);

  }

  void enableController(String controllerName) {

    if ( isEmpty(controllerName) ) {
      logger.error("UserInterface: enableController(): Controller name is empty");
      return;
    }

    controlP5.Controller controller = cp5.getController(controllerName);

    if ( controller == null ) {
      logger.error("UserInterface: enableController(): Controller not found: " + controllerName);
      return;
    }

    String controllerImageBaseName = controller.getStringValue();
    PImage[] controllerImages = {
      loadImage("icons/" + controllerImageBaseName + "_idle.png"),
      loadImage("icons/" + controllerImageBaseName + "_over.png"),
      loadImage("icons/" + controllerImageBaseName + "_click.png")
    };
    for ( PImage img: controllerImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    controller.setImages(controllerImages);

    controller.unlock();

  }

  void disableController(String controllerName) {

    if ( isEmpty(controllerName) ) {
      logger.error("UserInterface: disableController(): Controller name is empty");
      return;
    }

    controlP5.Controller controller = cp5.getController(controllerName);

    if ( controller == null ) {
      logger.error("UserInterface: disableController(): Controller not found: " + controllerName);
      return;
    }

    String controllerImageBaseName = controller.getStringValue();
    PImage controllerImage = loadImage("icons/" + controllerImageBaseName + "_disabled.png");
    if ( controllerImage.width != squareButtonWidth || controllerImage.height != squareButtonHeight )
      controllerImage.resize(squareButtonWidth, squareButtonHeight);
    controller.setImage(controllerImage);

    controller.lock();

  }

  void showController(String controllerName) {

    if ( isEmpty(controllerName) ) {
      logger.error("UserInterface: showController(): Controller name is empty");
      return;
    }

    controlP5.Controller controller = cp5.getController(controllerName);

    if ( controller == null ) {
      logger.error("UserInterface: showController(): Controller not found: " + controllerName);
      return;
    }

    controller.unlock();
    controller.show();

  }

  void hideController(String controllerName) {

    if ( isEmpty(controllerName) ) {
      logger.error("UserInterface: hideController(): Controller name is empty");
      return;
    }

    controlP5.Controller controller = cp5.getController(controllerName);

    if ( controller == null ) {
      logger.error("UserInterface: hideController(): Controller not found: " + controllerName);
      return;
    }

    controller.lock();
    controller.hide();

  }

  boolean getSwitchButtonState(String buttonName) {

    if ( isEmpty(buttonName) ) {
      logger.error("UserInterface: getSwitchButtonState(): Button name is empty");
      return false;
    }

    Button button = (Button)cp5.getController(buttonName);

    if ( button == null ) {
      logger.error("UserInterface: setSwitchButtonState(): Button not found: " + buttonName);
      return false;
    }

    return button.isOn();

  }

  boolean getToggleState(String buttonName) {

    if ( isEmpty(buttonName) ) {
      logger.error("UserInterface: getToggleState(): Button name is empty");
      return true;
    }

    Toggle toggle = (Toggle)cp5.getController(buttonName);

    if ( toggle == null ) {
      logger.error("UserInterface: getToggleState(): Toggle not found: " + buttonName);
      return true;
    }

    if ( !toggle.isVisible() )
      return true;

    return toggle.getState();

  }

  void setSwitchButtonState(String buttonName, boolean buttonState) {

    setSwitchButtonState(buttonName, buttonState, true);

  }

  void setSwitchButtonState(String buttonName, boolean buttonState, boolean broadcastButtonPress) {

    if ( isEmpty(buttonName) ) {
      logger.error("UserInterface: setSwitchButtonState(): Button name is empty");
      return;
    }

    Button button = (Button)cp5.getController(buttonName);

    if ( button == null ) {
      logger.error("UserInterface: setSwitchButtonState(): Button not found: " + buttonName);
      return;
    }

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

    if ( controller == null ) {
      logger.error("UserInterface: isInside(): Received controller is null");
      return false;
    }

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
    if ( controllerIsAllowed(conditionMenuControllers.getName()) && conditionMenuControllers.isOpen() )
      openItemHeight = conditionMenuControllers.getBackgroundHeight();
    else if ( controllerIsAllowed(commonLightSourceMenuControllers.getName()) && commonLightSourceMenuControllers.isOpen() )
      openItemHeight = commonLightSourceMenuControllers.getBackgroundHeight();
    else if ( controllerIsAllowed(spellLightSourceMenuControllers.getName()) && spellLightSourceMenuControllers.isOpen() )
      openItemHeight = spellLightSourceMenuControllers.getBackgroundHeight();
    else if ( controllerIsAllowed(sightTypeMenuControllers.getName()) && sightTypeMenuControllers.isOpen() )
      openItemHeight = sightTypeMenuControllers.getBackgroundHeight();
    else if ( controllerIsAllowed(sizeMenuControllers.getName()) && sizeMenuControllers.isOpen() )
      openItemHeight = sizeMenuControllers.getBackgroundHeight();
    else if ( controllerIsAllowed(settingsMenuControllers.getName()) && settingsMenuControllers.isOpen() )
      openItemHeight = settingsMenuControllers.getBackgroundHeight();

    // Menu bar
    float barStartX = tokenMenu.getPosition()[0];
    float barStartY = tokenMenu.getPosition()[1];
    float barEndX = barStartX + tokenMenu.getWidth();
    float barEndY = barStartY + menuBarHeight * tokenMenu.size() + tokenMenu.size()-1;

    // Menu item
    float itemStartX = barStartX;
    float itemStartY = barEndY;
    float itemEndX = barEndX;
    float itemEndY = itemStartY + openItemHeight;

    if ( (x > barStartX && x < barEndX && y > barStartY && y < barEndY) || (x > itemStartX && x < itemEndX && y > itemStartY && y < itemEndY) )
      inside = true;

    return inside;

  }

  boolean fileExists(String filePath) {

    if ( isEmpty(filePath) )
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

  void showNewVersionDialog(String newVersion) {

    logger.info("UserInterface: showNewVersionDialog(): New version available - " + newVersion);

    uiDialogs.showConfirmDialog(
      "A new dungeoneering version is available - " + newVersion + ". Download it now?",
      "New version available",
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
      return;

    link("https://github.com/luiscastilho/dungeoneering/releases/tag/" + newVersion);

  }

  boolean controllerIsAllowed(String buttonName) {

    if ( isEmpty(buttonName) ) {
      logger.error("UserInterface: controllerIsAllowed(): Button name is empty");
      return true;
    }

    if ( appMode == AppMode.standalone )
      return true;
    if ( appMode == AppMode.dm )
      return true;

    boolean controllerAllowed = !isEmpty(buttonName) && allowedControllersInPlayersMode.contains(buttonName);

    return controllerAllowed;

  }

  boolean controllerGroupIsAllowed(ControllerGroup buttonGroup) {

    if ( buttonGroup == null ) {
      logger.error("UserInterface: controllerGroupIsAllowed(): Received controller group is null");
      return true;
    }

    if ( appMode == AppMode.standalone )
      return true;
    if ( appMode == AppMode.dm )
      return true;

    String buttonGroupName = buttonGroup.getName();
    boolean controllerGroupAllowed = !isEmpty(buttonGroupName) && allowedControllerGroupsInPlayersMode.contains(buttonGroupName);

    return controllerGroupAllowed;

  }

  void showPlayerControllersInDmApp() {

    if ( appMode == AppMode.standalone )
      return;
    if ( appMode == AppMode.players )
      return;

    showController("Switch environment lighting toggle");
    showController("Switch environment lighting DM label");
    showController("Switch environment lighting Players label");

  }

  void hidePlayerControllersInDmApp() {

    if ( appMode == AppMode.standalone )
      return;
    if ( appMode == AppMode.players )
      return;

    hideController("Switch environment lighting toggle");
    hideController("Switch environment lighting DM label");
    hideController("Switch environment lighting Players label");

  }

  boolean isEmpty(String stringToCheck) {
     return stringToCheck == null || stringToCheck.trim().isEmpty();
  }

}
