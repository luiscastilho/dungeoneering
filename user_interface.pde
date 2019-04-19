import javax.activation.MimetypesFileTypeMap;
import java.util.List;
import java.awt.Point;

public class UserInterface {
  
  PGraphics canvas;
  
  ControlP5 cp5;
  
  Map map;
  
  Grid grid;
  
  Obstacles obstacles;
  
  Layer playersLayer;
  Layer dmLayer;
  
  Resources resources;
  
  Wall newWall;
  Door newDoor;
  
  Token rightClickedToken;
  
  int controllersSpacing;
  int controllersTopLeftX, controllersTopLeftY;
  int controllersTopRightX, controllersTopRightY;
  int controllersBottomRightX, controllersBottomRightY;
  int controllersMenuX, controllersMenuY;
  int controllersMenuInitialX, controllersMenuInitialY;
  
  int rectButtonWidth;
  int rectButtonHeight;
  int squareButtonWidth;
  int squareButtonHeight;
  int instructionsHeight;
  int menuBarHeight;
  
  color enabledBackgroundColor, disabledBackgroundColor, mouseOverBackgroundColor, activeBackgroundColor;
  
  PFont instructionsFont;
  color instructionsFontColor, instructionsVisualColor;
  int instructionsX, instructionsY;
  int instructionsInitialX, instructionsInitialY;
  
  int gridHelperX, gridHelperY;
  int gridHelperToX, gridHelperToY;
  boolean gridHelperSet;
  
  Group togglableControllers;
  Group menuControllers;
  Accordion tokenMenu;
  
  UserInterface(PGraphics _canvas, ControlP5 _cp5, Map _map, Grid _grid, Obstacles _obstacles, Layer _playersLayer, Layer _dmLayer, Resources _resources) {
    
    canvas = _canvas;
    
    cp5 = _cp5;
    
    map = _map;
    
    grid = _grid;
    
    obstacles = _obstacles;
    
    playersLayer = _playersLayer;
    dmLayer = _dmLayer;
    
    resources = _resources;
    
    newWall = null;
    newDoor = null;
    
    rightClickedToken = null;
    
    controllersSpacing = 5;
    controllersTopLeftX = int(min(canvas.width, canvas.height) * 0.05);
    controllersTopLeftY = int(min(canvas.width, canvas.height) * 0.05);
    controllersTopRightX = canvas.width - int(min(canvas.width, canvas.height) * 0.05);
    controllersTopRightY = int(min(canvas.width, canvas.height) * 0.05);
    controllersBottomRightX = controllersTopRightX;
    controllersBottomRightY = canvas.height - controllersTopLeftY;
    controllersMenuX = controllersSpacing;
    controllersMenuY = controllersSpacing;
    controllersMenuInitialX = controllersMenuX;
    controllersMenuInitialY = controllersMenuY;
    
    rectButtonWidth = 100;
    rectButtonHeight = 25;
    squareButtonWidth = 25;
    squareButtonHeight = 25;
    instructionsHeight = 15;
    menuBarHeight = 15;
    
    enabledBackgroundColor = color(0, 45, 90);
    disabledBackgroundColor = color(100);
    mouseOverBackgroundColor = color(0, 116, 217);
    activeBackgroundColor = color(0, 170, 255);
    
    instructionsFont = loadFont("fonts/ProcessingSansPro-Regular-12.vlw");
    instructionsFontColor = color(255);
    instructionsVisualColor = color(0, 116, 217, 127);
    instructionsX = controllersTopLeftX;
    instructionsY = canvas.height - controllersTopLeftY;
    instructionsInitialX = instructionsX;
    instructionsInitialY = instructionsY;
    
    gridHelperX = gridHelperToX = 0;
    gridHelperY = gridHelperToY = 0;
    gridHelperSet = false;
    
    togglableControllers = null;
    menuControllers = null;
    tokenMenu = null;
    
    setupControllers();
    
  }
  
  void draw() {
    
    switch ( appState ) {
      case gridSetup:
        
        if ( !gridHelperSet )
          break;
        
        canvas.rectMode(CORNERS);
        canvas.stroke(instructionsVisualColor);
        canvas.strokeWeight(1);
        canvas.fill(instructionsVisualColor);
        canvas.rect(map.transformX(gridHelperX), map.transformY(gridHelperY), map.transformX(gridHelperToX), map.transformY(gridHelperToY));
        
        break;
      case wallSetup:
        
        if ( newWall == null )
          break;
        
        newWall.draw(obstacles.getWallColor(), obstacles.getWallWidth());
        
        break;
      case doorSetup:
        
        if ( newDoor == null )
          break;
        
        newDoor.draw(obstacles.getClosedDoorColor(), obstacles.getOpenDoorColor(), obstacles.getDoorWidth());
        
        break;
      default:
        break;
    }
    
  }
  
  void setupControllers() {
    
    // Togglable controllers group
    
    togglableControllers = cp5.addGroup("Toggable controllers");
    
    // Right click menu controllers group
    
    menuControllers = cp5.addGroup("Actions")
                         .setBackgroundColor(color(0, 127));
    
    // Top left bar
    
    cp5.addButton("Select map")
       .setPosition(controllersTopLeftX, controllersTopLeftY)
       .setSize(rectButtonWidth, rectButtonHeight)
       .moveTo(togglableControllers)
       ;
    
    controllersTopLeftY = controllersTopLeftY + rectButtonHeight + controllersSpacing;
    
    cp5.addButton("Grid setup")
       .setPosition(controllersTopLeftX, controllersTopLeftY)
       .setSize(rectButtonWidth, rectButtonHeight)
       .setSwitch(true)
       .setOff()
       .lock()
       .setColorBackground(disabledBackgroundColor)
       .moveTo(togglableControllers)
       ;
    
    controllersTopLeftY = controllersTopLeftY + rectButtonHeight + controllersSpacing;
    
    cp5.addButton("Add player token")
       .setPosition(controllersTopLeftX, controllersTopLeftY)
       .setSize(rectButtonWidth, rectButtonHeight)
       .setSwitch(true)
       .setOff()
       .lock()
       .setColorBackground(disabledBackgroundColor)
       .moveTo(togglableControllers)
       ;
    
    controllersTopLeftY = controllersTopLeftY + rectButtonHeight + controllersSpacing;
    
    cp5.addButton("Add DM token")
       .setPosition(controllersTopLeftX, controllersTopLeftY)
       .setSize(rectButtonWidth, rectButtonHeight)
       .setSwitch(true)
       .setOff()
       .lock()
       .setColorBackground(disabledBackgroundColor)
       .moveTo(togglableControllers)
       ;
       
    controllersTopLeftY = controllersTopLeftY + rectButtonHeight + controllersSpacing;
    
    cp5.addButton("Add/Remove walls")
       .setPosition(controllersTopLeftX, controllersTopLeftY)
       .setSize(rectButtonWidth, rectButtonHeight)
       .setSwitch(true)
       .setOff()
       .lock()
       .setColorBackground(disabledBackgroundColor)
       .moveTo(togglableControllers)
       ;
    
    controllersTopLeftY = controllersTopLeftY + rectButtonHeight + controllersSpacing;
    
    cp5.addButton("Add/Remove doors")
       .setPosition(controllersTopLeftX, controllersTopLeftY)
       .setSize(rectButtonWidth, rectButtonHeight)
       .setSwitch(true)
       .setOff()
       .lock()
       .setColorBackground(disabledBackgroundColor)
       .moveTo(togglableControllers)
       ;
    
    // Top right bar
    
    controllersTopRightX = controllersTopRightX - squareButtonWidth;
    
    PImage[] loadButtonImages = {loadImage("icons/load_default.png"), loadImage("icons/load_over.png"), loadImage("icons/load_active.png")};
    for ( PImage img: loadButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Load scene")
       .setPosition(controllersTopRightX, controllersTopRightY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(loadButtonImages)
       .updateSize()
       .moveTo(togglableControllers)
       ;
    
    controllersTopRightX = controllersTopRightX - squareButtonWidth - controllersSpacing;
    
    PImage[] saveButtonImages = {loadImage("icons/save_default.png"), loadImage("icons/save_over.png"), loadImage("icons/save_active.png")};
    for ( PImage img: saveButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Save scene")
       .setPosition(controllersTopRightX, controllersTopRightY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(saveButtonImages)
       .updateSize()
       .moveTo(togglableControllers)
       ;
    
    controllersTopRightY = controllersTopRightY + squareButtonHeight + controllersSpacing;
    controllersTopRightX = controllersTopRightX + squareButtonWidth + controllersSpacing;
    
    PImage[] gridButtonImages = {loadImage("icons/grid_default.png"), loadImage("icons/grid_over.png"), loadImage("icons/grid_active.png")};
    for ( PImage img: gridButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Toggle grid")
       .setPosition(controllersTopRightX, controllersTopRightY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(gridButtonImages)
       .updateSize()
       .setSwitch(true)
       .setOff()
       .moveTo(togglableControllers)
       ;
    
    controllersTopRightX = controllersTopRightX - squareButtonWidth - controllersSpacing;
    
    PImage[] wallButtonImages = {loadImage("icons/wall_default.png"), loadImage("icons/wall_over.png"), loadImage("icons/wall_active.png")};
    for ( PImage img: wallButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Toggle walls")
       .setPosition(controllersTopRightX, controllersTopRightY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(wallButtonImages)
       .updateSize()
       .setSwitch(true)
       .setOff()
       .moveTo(togglableControllers)
       ;
    
    controllersTopRightX = controllersTopRightX - squareButtonWidth - controllersSpacing;
    
    PImage[] lightningButtonImages = {loadImage("icons/lightning_default.png"), loadImage("icons/lightning_over.png"), loadImage("icons/lightning_active.png")};
    for ( PImage img: lightningButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Switch lightning")
       .setPosition(controllersTopRightX, controllersTopRightY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(lightningButtonImages)
       .updateSize()
       .moveTo(togglableControllers)
       ;
    
    controllersTopRightX = controllersTopRightX - squareButtonWidth - controllersSpacing;
    
    PImage[] layersButtonImages = {loadImage("icons/layers_default.png"), loadImage("icons/layers_over.png"), loadImage("icons/layers_active.png")};
    for ( PImage img: layersButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Switch layer")
       .setPosition(controllersTopRightX, controllersTopRightY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(layersButtonImages)
       .updateSize()
       .moveTo(togglableControllers)
       ;
    
    // Bottom right bar
    
    controllersBottomRightX = controllersBottomRightX - squareButtonWidth;
    
    PImage[] uiButtonImages = {loadImage("icons/ui_default.png"), loadImage("icons/ui_over.png"), loadImage("icons/ui_active.png")};
    for ( PImage img: uiButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Toggle UI")
       .setPosition(controllersBottomRightX, controllersBottomRightY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(uiButtonImages)
       .updateSize()
       .setSwitch(true)
       .setOn()
       ;
    
    controllersBottomRightX = controllersBottomRightX - squareButtonWidth - controllersSpacing;
    
    PImage[] panButtonImages = {loadImage("icons/pan_default.png"), loadImage("icons/pan_over.png"), loadImage("icons/pan_active.png")};
    for ( PImage img: panButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Toggle camera pan")
       .setPosition(controllersBottomRightX, controllersBottomRightY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(panButtonImages)
       .updateSize()
       .setSwitch(true)
       .setOn()
       ;
    
    controllersBottomRightX = controllersBottomRightX - squareButtonWidth - controllersSpacing;
    
    PImage[] zoomButtonImages = {loadImage("icons/zoom_default.png"), loadImage("icons/zoom_over.png"), loadImage("icons/zoom_active.png")};
    for ( PImage img: zoomButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Toggle camera zoom")
       .setPosition(controllersBottomRightX, controllersBottomRightY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(zoomButtonImages)
       .updateSize()
       .setSwitch(true)
       .setOff()
       ;
    
    // Token right click menu
    
    menuControllers.setHeight(menuBarHeight)                // menu bar height
                   .setBackgroundHeight(controllersSpacing) // item height
                   ;
    tokenMenu = cp5.addAccordion("Right click menu")
       .setPosition(0, 0)
       .setWidth(controllersSpacing)         // menu bar and items width
       .setMinItemHeight(controllersSpacing) // min item height
       .addItem(menuControllers)
       .updateItems()
       .setCollapseMode(Accordion.SINGLE)
       .open(0)
       .hide()
       ;
    
    PImage[] candleButtonImages = {loadImage("icons/candle_default.png"), loadImage("icons/candle_over.png"), loadImage("icons/candle_active.png")};
    for ( PImage img: candleButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Add light source candle")
       .setPosition(controllersMenuX, controllersMenuY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(candleButtonImages)
       .updateSize()
       .moveTo(menuControllers)
       ;
    
    controllersMenuX = controllersMenuX + squareButtonWidth + controllersSpacing;
    tokenMenu.setWidth(tokenMenu.getWidth() + squareButtonWidth + controllersSpacing);
    menuControllers.setBackgroundHeight(menuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    
    PImage[] torchButtonImages = {loadImage("icons/torch_default.png"), loadImage("icons/torch_over.png"), loadImage("icons/torch_active.png")};
    for ( PImage img: torchButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Add light source torch")
       .setPosition(controllersMenuX, controllersMenuY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(torchButtonImages)
       .updateSize()
       .moveTo(menuControllers)
       ;
    
    controllersMenuX = controllersMenuX + squareButtonWidth + controllersSpacing;
    tokenMenu.setWidth(tokenMenu.getWidth() + squareButtonWidth + controllersSpacing);
    
    PImage[] darkvisionButtonImages = {loadImage("icons/darkvision_default.png"), loadImage("icons/darkvision_over.png"), loadImage("icons/darkvision_active.png")};
    for ( PImage img: darkvisionButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Add sight type darkvision")
       .setPosition(controllersMenuX, controllersMenuY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(darkvisionButtonImages)
       .updateSize()
       .moveTo(menuControllers)
       ;
    
    controllersMenuX = controllersMenuX + squareButtonWidth + controllersSpacing;
    tokenMenu.setWidth(tokenMenu.getWidth() + squareButtonWidth + controllersSpacing);
    
    PImage[] deathButtonImages = {loadImage("icons/death_default.png"), loadImage("icons/death_over.png"), loadImage("icons/death_active.png")};
    for ( PImage img: deathButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Toggle condition dead")
       .setPosition(controllersMenuX, controllersMenuY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(deathButtonImages)
       .updateSize()
       .moveTo(menuControllers)
       ;
    
    controllersMenuX = controllersMenuX + squareButtonWidth + controllersSpacing;
    tokenMenu.setWidth(tokenMenu.getWidth() + squareButtonWidth + controllersSpacing);
    
    controllersMenuX = controllersMenuInitialX;
    controllersMenuY = controllersMenuY + squareButtonWidth + controllersSpacing;
    
    PImage[] switchLayerButtonImages = {loadImage("icons/switch_layer_default.png"), loadImage("icons/switch_layer_over.png"), loadImage("icons/switch_layer_active.png")};
    for ( PImage img: switchLayerButtonImages )
      if ( img.width != squareButtonWidth || img.height != squareButtonHeight )
        img.resize(squareButtonWidth, squareButtonHeight);
    cp5.addButton("Switch token layer")
       .setPosition(controllersMenuX, controllersMenuY)
       .setSize(squareButtonWidth, squareButtonHeight)
       .setImages(switchLayerButtonImages)
       .updateSize()
       .moveTo(menuControllers)
       ;
    
    controllersMenuX = controllersMenuX + squareButtonWidth + controllersSpacing;
    menuControllers.setBackgroundHeight(menuControllers.getBackgroundHeight() + squareButtonHeight + controllersSpacing);
    
    // Bottom left messages
    
    // Roll20 "Grid Alignment Tool" instructions:
    //   This tool allows you to quickly size your map background to match the Roll20 grid on the current page.
    //   Instructions: Click and drag to create a box the size of 3 x 3 grid cells on the map background you are using.
    
    cp5.addTextlabel("Grid instructions - 2nd line")
       .setText("Once you draw this square, you can adjust its size using the arrow keys.")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .hide()
       ;
    
    instructionsY = instructionsY - instructionsHeight - controllersSpacing;
    
    cp5.addTextlabel("Grid instructions - 1st line")
       .setText("Click and drag to create a square the size of 3 x 3 grid cells on the map background you are using.")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .hide()
       ;
    
    instructionsX = instructionsInitialX;
    instructionsY = instructionsInitialY;
    
    cp5.addTextlabel("Wall instructions - 2nd line")
       .setText("Right click over any wall to remove it.")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .hide()
       ;
    
    instructionsY = instructionsY - instructionsHeight - controllersSpacing;
    
    cp5.addTextlabel("Wall instructions - 1st line")
       .setText("Draw a new wall, adding vertexes to it by left clicking.")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .hide()
       ;
    
    instructionsX = instructionsInitialX;
    instructionsY = instructionsInitialY;
    
    cp5.addTextlabel("Door instructions - 2nd line")
       .setText("Right click over any door to remove it.")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .hide()
       ;
    
    instructionsY = instructionsY - instructionsHeight - controllersSpacing;
    
    cp5.addTextlabel("Door instructions - 1st line")
       .setText("Draw a new door, adding vertexes to it by left clicking.")
       .setPosition(instructionsX, instructionsY)
       .setColorValue(instructionsFontColor)
       .setFont(instructionsFont)
       .hide()
       ;
    
  }
  
  AppStates controllerEvent(ControlEvent controlEvent) {
    
    String resourceName;
    Light lightTemplate;
    Condition conditionTemplate;
    
    AppStates newAppState = AppStates.idle;
    
    String controllerName = "";
    if ( controlEvent.isController() )
      controllerName = controlEvent.getController().getName();
    else if ( controlEvent.isGroup() )
      controllerName = controlEvent.getGroup().getName();
    
    switch ( controllerName ) {
      case "Select map":
        
        File mapFile = null;
        selectInput("Select a map:", "mapImageSelected", mapFile, this);
        
        newAppState = AppStates.idle;
        
        break;
      case "Grid setup":
        
        Button gridSetup = (Button)controlEvent.getController();
        Textlabel gridInstructions1stLine = (Textlabel)cp5.getController("Grid instructions - 1st line");
        Textlabel gridInstructions2ndLine = (Textlabel)cp5.getController("Grid instructions - 2nd line");
        
        if ( gridSetup.isOn() ) {
          
          disableController("Select map");
          disableController("Add player token");
          disableController("Add DM token");
          disableController("Add/Remove walls");
          disableController("Add/Remove doors");
          disableController("Toggle UI");
          
          Button toggleGrid = (Button)cp5.getController("Toggle grid");
          if ( !toggleGrid.isOn() )
            toggleGrid.setOn();
          
          obstacles.clear();
          playersLayer.clear();
          dmLayer.clear();
          grid.clear();
          
          map.reset();
          
          gridHelperX = gridHelperToX = 0;
          gridHelperY = gridHelperToY = 0;
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
          
          if ( grid.isSet() )
            resources.setup();
          
          cursor(ARROW);
          
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
          
          newAppState = AppStates.idle;
          
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
          
          Button toggleWalls = (Button)cp5.getController("Toggle walls");
          if ( !toggleWalls.isOn() )
            toggleWalls.setOn();
          
          playersLayer.reset();
          dmLayer.reset();
          
          newWall = new Wall(canvas);
          
          wallInstructions1stLine.show();
          wallInstructions2ndLine.show();
          
          PImage cursorCross = loadImage("cursors/cursor_cross_32.png");
          cursor(cursorCross);
          
          newAppState = AppStates.wallSetup;
          
        } else {
          
          if ( newWall.isSet() )
            obstacles.addWall(newWall);
          
          enableController("Select map");
          enableController("Grid setup");
          if ( grid.isSet() ) {
            enableController("Add player token");
            enableController("Add DM token");
          }
          enableController("Add/Remove doors");
          enableController("Toggle UI");
          
          wallInstructions1stLine.hide();
          wallInstructions2ndLine.hide();
          
          cursor(ARROW);
          
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
          
          Button toggleWalls = (Button)cp5.getController("Toggle walls");
          if ( !toggleWalls.isOn() )
            toggleWalls.setOn();
          
          playersLayer.reset();
          dmLayer.reset();
          
          newDoor = new Door(canvas);
          
          doorInstructions1stLine.show();
          doorInstructions2ndLine.show();
          
          PImage cursorCross = loadImage("cursors/cursor_cross_32.png");
          cursor(cursorCross);
          
          newAppState = AppStates.doorSetup;
          
        } else {
          
          if ( newDoor.isSet() )
            obstacles.addDoor(newDoor);
          
          enableController("Select map");
          enableController("Grid setup");
          if ( grid.isSet() ) {
            enableController("Add player token");
            enableController("Add DM token");
          }
          enableController("Add/Remove walls");
          enableController("Toggle UI");
          
          doorInstructions1stLine.hide();
          doorInstructions2ndLine.hide();
          
          cursor(ARROW);
          
          newAppState = AppStates.idle;
          
        }
        
        break;
      case "Save scene":
        
        File sceneFolder = null;
        selectFolder("Select folder where to save scene:", "saveScene", sceneFolder, this);
        
        newAppState = AppStates.idle;
        
        break;
      case "Load scene":
        
        File sceneFile = null;
        selectInput("Select scene to load:", "loadScene", sceneFile, this);
        
        newAppState = AppStates.idle;
        
        break;
      case "Switch layer":
        
        newAppState = AppStates.switchingLayer;
        
        break;
      case "Switch lightning":
        
        newAppState = AppStates.switchingLightning;
        
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
          
        } else {
          
          togglableControllers.hide();
          
        }
        
        break;
      case "Toggle camera pan":
        
        newAppState = AppStates.togglingCameraPan;
        
        break;
      case "Toggle camera zoom":
        
        newAppState = AppStates.togglingCameraZoom;
        
        break;
      case "Add light source candle":
        
        if ( rightClickedToken == null )
          break;
        
        resourceName = "Candle";
        lightTemplate = resources.getCommonLightSource(resourceName);
        if ( lightTemplate == null ) {
          println("Resource: Common light source " + resourceName + " not found");
          break;
        }
        
        rightClickedToken.addLightSource(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);
        
        break;
      case "Add light source torch":
        
        if ( rightClickedToken == null )
          break;
        
        resourceName = "Torch";
        lightTemplate = resources.getCommonLightSource(resourceName);
        if ( lightTemplate == null ) {
          println("Resource: Common light source " + resourceName + " not found");
          break;
        }
        
        rightClickedToken.addLightSource(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);
        
        break;
      case "Add sight type darkvision":
        
        if ( rightClickedToken == null )
          break;
        
        resourceName = "Darkvision 60'";
        lightTemplate = resources.getSightType(resourceName);
        if ( lightTemplate == null ) {
          println("Resource: Sight type " + resourceName + " not found");
          break;
        }
        
        rightClickedToken.addSightType(new Light(lightTemplate.getName(), lightTemplate.getBrightLightRadius(), lightTemplate.getDimLightRadius()));
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);
        
        break;
      case "Toggle condition dead":
        
        if ( rightClickedToken == null )
          break;
        
        resourceName = "Dead";
        conditionTemplate = resources.getCondition("Dead");
        if ( conditionTemplate == null ) {
          println("Resource: Condition " + resourceName + " not found");
          break;
        }
        
        rightClickedToken.toggleCondition(conditionTemplate);
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);
        
        break;
      case "Switch token layer":
        
        if ( rightClickedToken == null )
          break;
        
        Point rightClickedTokenPosition = rightClickedToken.getCell().getCenter();
        
        if ( rightClickedToken.equals(playersLayer.getToken(rightClickedTokenPosition.x, rightClickedTokenPosition.y)) ) {
          
          playersLayer.removeToken(rightClickedToken);
          dmLayer.addToken(rightClickedToken);
          
        } else {
          
          dmLayer.removeToken(rightClickedToken);
          playersLayer.addToken(rightClickedToken);
          
        }
        
        obstacles.setRecalculateShadows(true);
        hideMenu(0, 0);
        
        break;
    }
    
    return newAppState;
    
  }
  
  void mapImageSelected(File mapImageFile) {
    
    if ( mapImageFile == null )
      return;
    
    MimetypesFileTypeMap mimetypesMap = new MimetypesFileTypeMap();
    mimetypesMap.addMimeTypes("image png tif tiff jpg jpeg bmp gif");
    String mimetype = mimetypesMap.getContentType(mapImageFile);
    String type = mimetype.split("/")[0];
    if ( !type.equals("image") ) {
      println("Map selection: selected file is not an image");
      return;
    }
    
    map.setup(mapImageFile.getAbsolutePath(), false);
    
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
    
  }
  
  void gridHelperSetup(int x, int y, boolean start, boolean done) {
    
    if ( isInside() )
      return;
    
    if ( start ) {
      
      gridHelperX = gridHelperToX = max(x, 0);
      gridHelperY = gridHelperToY = max(y, 0);
      gridHelperSet = false;
      grid.clear();
      
    } else {
      
      gridHelperToX = max(x, 0);
      gridHelperToY = max(y, 0);
      gridHelperSet = true;
      
    }
    
    if ( done ) {
      
      if ( abs(gridHelperX-gridHelperToX) < 10 || abs(gridHelperY-gridHelperToY) < 10 ) {
        
        gridHelperX = gridHelperToX = 0;
        gridHelperY = gridHelperToY = 0;
        gridHelperSet = false;
        return;
        
      }
      
      Point mappedStartPos = map.mapCanvasToImage(new Point(gridHelperX, gridHelperY));
      Point mappedEndPos = map.mapCanvasToImage(new Point(gridHelperToX, gridHelperToY));
      int xDiff = gridHelperX-mappedStartPos.x;
      int yDiff = gridHelperY-mappedStartPos.y;
      grid.setupFromHelper(mappedStartPos.x, mappedStartPos.y, mappedEndPos.x, mappedEndPos.y, map.getImageWidth(), map.getImageHeight(), xDiff, yDiff);
      
    }
    
  }
  
  void gridHelperSetupAdjustment(int xAdjustment, int yAdjustment, boolean toPosition) {
    
    if ( !gridHelperSet )
      return;
    
    grid.clear();
    
    if ( toPosition ) {
      gridHelperToX += xAdjustment;
      gridHelperToY += yAdjustment;
    } else {
      gridHelperX += xAdjustment;
      gridHelperY += yAdjustment;
    }
    
    if ( abs(gridHelperX-gridHelperToX) < 10 || abs(gridHelperY-gridHelperToY) < 10 ) {
      
      gridHelperX = gridHelperToX = 0;
      gridHelperY = gridHelperToY = 0;
      gridHelperSet = false;
      return;
      
    }
    
    Point mappedStartPos = map.mapCanvasToImage(new Point(gridHelperX, gridHelperY));
    Point mappedEndPos = map.mapCanvasToImage(new Point(gridHelperToX, gridHelperToY));
    int xDiff = gridHelperX-mappedStartPos.x;
    int yDiff = gridHelperY-mappedStartPos.y;
    grid.setupFromHelper(mappedStartPos.x, mappedStartPos.y, mappedEndPos.x, mappedEndPos.y, map.getImageWidth(), map.getImageHeight(), xDiff, yDiff);
    
  }
  
  void playerTokenImageSelected(File tokenImageFile) {
    
    if ( tokenImageFile == null )
      return;
    
    playersLayer.addToken(tokenImageFile);
    
  }
  
  void dmTokenImageSelected(File tokenImageFile) {
    
    if ( tokenImageFile == null )
      return;
    
    dmLayer.addToken(tokenImageFile);
    
  }
  
  AppStates moveToken(int _mouseX, int _mouseY, boolean done) {
    
    AppStates newState = null;
    
    if ( playersLayer.getToken(_mouseX, _mouseY) != null ) {
      newState = playersLayer.moveToken(_mouseX, _mouseY, done);
    } else {
      newState = dmLayer.moveToken(_mouseX, _mouseY, done);
    }
    
    if ( done ) {
      
      Button addTokenButton;
      
      addTokenButton = (Button)cp5.getController("Add player token");
      addTokenButton.setOff();
      
      addTokenButton = (Button)cp5.getController("Add DM token");
      addTokenButton.setOff();
      
    }
    
    return newState;
    
  }
  
  void newWallSetup(int _mouseX, int _mouseY) {
    
    if ( isInside() )
      return;
    
    newWall.addVertex(map.transformX(_mouseX), map.transformY(_mouseY));
    
  }
  
  void removeWall(int _mouseX, int _mouseY) {
    
    Wall wallToRemove = getClosestWall(map.transformX(_mouseX), map.transformY(_mouseY), 10);
    
    if ( wallToRemove != null )
      obstacles.removeWall(wallToRemove);
    
  }
  
  void newDoorSetup(int _mouseX, int _mouseY) {
    
    if ( isInside() )
      return;
    
    newDoor.addVertex(map.transformX(_mouseX), map.transformY(_mouseY));
    
  }
  
  void removeDoor(int _mouseX, int _mouseY) {
    
    Door doorToRemove = getClosestDoor(map.transformX(_mouseX), map.transformY(_mouseY), 10);
    
    if ( doorToRemove != null )
      obstacles.removeDoor(doorToRemove);
    
  }
  
  void openDoor(int _mouseX, int _mouseY) {
    
    Door doorToToggle = getClosestDoor(map.transformX(_mouseX), map.transformY(_mouseY), 20);
    
    if ( doorToToggle != null ) {
      doorToToggle.toggle();
      obstacles.setRecalculateShadows(true);
    }
    
  }
  
  Wall getClosestWall(int _mouseX, int _mouseY, int maxAllowedClickDistance) {
    
    ArrayList<Wall> walls = obstacles.getWalls();
    
    float distanceToClosestWall = Integer.MAX_VALUE;
    Wall closestWall = null;
    
    for ( Wall wall: walls ) {
      
      if ( wall.getVertexes().size() > 2 )
        continue;
      
      PVector start = wall.getVertexes().get(0);
      PVector end = wall.getVertexes().get(1);
      
      float sqDistanceToWall = pointToLineSqDistance(start, end, new PVector(_mouseX, _mouseY));
      
      if ( sqDistanceToWall > sq(maxAllowedClickDistance) )
        continue;
      
      if ( sqDistanceToWall < distanceToClosestWall ) {
        distanceToClosestWall = sqDistanceToWall;
        closestWall = wall;
      }
      
    }
    
    return closestWall;
    
  }
  
  Door getClosestDoor(int _mouseX, int _mouseY, int maxAllowedClickDistance) {
    
    ArrayList<Door> doors = obstacles.getDoors();
    
    float distanceToClosestDoor = Integer.MAX_VALUE;
    Door closestDoor = null;
    
    for ( Door door: doors ) {
      
      if ( door.getVertexes().size() > 2 )
        continue;
      
      PVector start = door.getVertexes().get(0);
      PVector end = door.getVertexes().get(1);
      
      float sqDistanceToDoor = pointToLineSqDistance(start, end, new PVector(_mouseX, _mouseY));
      
      if ( sqDistanceToDoor > sq(maxAllowedClickDistance) )
        continue;
      
      if ( sqDistanceToDoor < distanceToClosestDoor ) {
        distanceToClosestDoor = sqDistanceToDoor;
        closestDoor = door;
      }
      
    }
    
    return closestDoor;
    
  }
  
  // Source: openprocessing.org/sketch/39479/
  float pointToLineSqDistance(PVector A, PVector B, PVector P) {
    
    float vx = P.x-A.x, vy = P.y-A.y;  // v = A->P
    float ux = B.x-A.x, uy = B.y-A.y;  // u = A->B
    float det = vx*ux + vy*uy; 
    
    // its outside the line segment near A
    if ( det <= 0 ) {
      return vx*vx + vy*vy;
    }
    
    float len = ux*ux + uy*uy;  // len = u^2
    
    // its outside the line segment near B
    if ( det >= len ) {
      return sq(B.x-P.x) + sq(B.y-P.y);  
    }
    
    // its near line segment between A and B
    return sq(ux*vy-uy*vx) / len;  // (u X v)^2 / len
    
  }
  
  void showMenu(int _mouseX, int _mouseY) {
    
    Token token;
    
    token = playersLayer.getToken(_mouseX, _mouseY);
    if ( token == null )
      token = dmLayer.getToken(_mouseX, _mouseY);
    if ( token == null )
      return;
    
    rightClickedToken = token;
    
    int menuX = token.getCell().getCenter().x;
    int menuY = token.getCell().getCenter().y;
    
    tokenMenu.setPosition(menuX, menuY);
    tokenMenu.show();
    
  }
  
  void hideMenu(int _mouseX, int _mouseY) {
    
    if ( isInsideMenu(_mouseX, _mouseY) )
      return;
    
    tokenMenu.hide();
    rightClickedToken = null;
    
  }
  
  void saveScene(File sceneFolder) {
    
    if ( sceneFolder == null )
      return;
    if ( map.getImagePath() == null )
      return;
    
    String sketchPath = sketchPath().replaceAll("\\\\", "/");
    
    int obstaclesIndex;
    
    JSONObject sceneJson = new JSONObject();
    
    JSONObject mapJson = new JSONObject();
    mapJson.setString("imagePath", map.getImagePath().replaceAll("\\\\", "/").replaceFirst("^" + sketchPath, ""));
    mapJson.setBoolean("fitToScreen", map.getFitToScreen());
    sceneJson.setJSONObject("map", mapJson);
    
    JSONObject gridJson = new JSONObject();
    gridJson.setInt("firstCellCenterX", grid.getFirstCellCenter().x);
    gridJson.setInt("firstCellCenterY", grid.getFirstCellCenter().y);
    gridJson.setInt("lastCellCenterX", grid.getLastCellCenter().x);
    gridJson.setInt("lastCellCenterY", grid.getLastCellCenter().y);
    gridJson.setInt("cellWidth", grid.getCellWidth());
    gridJson.setInt("cellHeight", grid.getCellHeight());
    gridJson.setBoolean("drawGrid", grid.getDrawGrid());
    sceneJson.setJSONObject("grid", gridJson);
    
    sceneJson.setJSONArray("playerTokens", getTokensJsonArray(playersLayer.getTokens(), sketchPath));
    sceneJson.setJSONArray("dmTokens", getTokensJsonArray(dmLayer.getTokens(), sketchPath));
    
    JSONArray wallsArray = new JSONArray();
    ArrayList<Wall> walls = obstacles.getWalls();
    obstaclesIndex = 0;
    for ( Wall wall: walls ) {
      JSONObject wallJson = new JSONObject();
      ArrayList<PVector> wallVertexes = wall.getVertexes();
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
    
    JSONArray doorsArray = new JSONArray();
    ArrayList<Door> doors = obstacles.getDoors();
    obstaclesIndex = 0;
    for ( Door door: doors ) {
      JSONObject doorJson = new JSONObject();
      doorJson.setBoolean("closed", door.getClosed());
      ArrayList<PVector> doorVertexes = door.getVertexes();
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
    
    JSONObject illuminationJson = new JSONObject();
    switch ( obstacles.getIllumination() ) {
      case brightLight:
        illuminationJson.setString("lightning", "brightLigt");
        break;
      case dimLight:
        illuminationJson.setString("lightning", "dimLight");
        break;
      case darkness:
        illuminationJson.setString("lightning", "darkness");
        break;
    }
    sceneJson.setJSONObject("illumination", illuminationJson);
    
    File mapFile = new File(map.getImagePath());
    String mapFileName = mapFile.getName();
    String[] mapFileNameTokens = mapFileName.split("\\.(?=[^\\.]+$)");
    String mapBaseName = mapFileNameTokens[0];
    
    saveJSONObject(sceneJson, sceneFolder.getAbsolutePath() + "\\" + mapBaseName + ".json");
    
    println("Scene saved to: " + sceneFolder.getAbsolutePath() + "\\" + mapBaseName + ".json");
    
  }
  
  JSONArray getTokensJsonArray(ArrayList<Token> tokens, String sketchPath) {
    
    JSONArray tokensArray = new JSONArray();
    int tokensIndex = 0;
    
    for ( Token token: tokens ) {
      
      JSONObject tokenJson = new JSONObject();
      
      tokenJson.setString("name", token.getName());
      tokenJson.setString("imagePath", token.getImagePath().replaceAll("\\\\", "/").replaceFirst("^" + sketchPath, ""));
      
      Cell cell = token.getCell();
      tokenJson.setInt("row", cell.getRow());
      tokenJson.setInt("column", cell.getColumn());
      
      tokenJson.setJSONArray("lightSources", getLightsJsonArray(token.getLightSources()));
      tokenJson.setJSONArray("sightTypes", getLightsJsonArray(token.getSightTypes()));
      
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
      lightJson.setInt("brightLightRadius", light.getBrightLightRadius());
      lightJson.setInt("dimLightRadius", light.getDimLightRadius());
      tokenLightsArray.setJSONObject(lightsIndex, lightJson);
      lightsIndex += 1;
    }
    
    return tokenLightsArray;
    
  }
  
  void loadScene(File sceneFile) {
    
    if ( sceneFile == null )
      return;
    
    String sketchPath = sketchPath().replaceAll("\\\\", "/");
    
    appState = AppStates.loadingScene;
    
    map.reset();
    grid.clear();
    playersLayer.clear();
    dmLayer.clear();
    obstacles.clear();
    
    JSONObject sceneJson = loadJSONObject(sceneFile.getAbsolutePath());
    
    JSONObject mapJson = sceneJson.getJSONObject("map");
    if ( mapJson != null ) {
      
      String mapImagePath = mapJson.getString("imagePath");
      boolean fitToScreen = mapJson.getBoolean("fitToScreen");
      
      if ( !fileExists(mapImagePath) ) {
        if ( fileExists(sketchPath + mapImagePath) )
          mapImagePath = sketchPath + mapImagePath;
      }
      
      map.setup(mapImagePath, fitToScreen);
      
      enableController("Grid setup");
      enableController("Add/Remove walls");
      enableController("Add/Remove doors");
      
    }
    
    JSONObject gridJson = sceneJson.getJSONObject("grid");
    if ( gridJson != null ) {
      
      int firstCellCenterX = gridJson.getInt("firstCellCenterX");
      int firstCellCenterY = gridJson.getInt("firstCellCenterY");
      int lastCellCenterX = gridJson.getInt("lastCellCenterX");
      int lastCellCenterY = gridJson.getInt("lastCellCenterY");
      int cellWidth = gridJson.getInt("cellWidth");
      int cellHeight = gridJson.getInt("cellHeight");
      boolean drawGrid = gridJson.getBoolean("drawGrid");
      grid.setup(firstCellCenterX, firstCellCenterY, lastCellCenterX, lastCellCenterY, cellWidth, cellHeight, drawGrid);
    }
    
    if ( grid.isSet() )
      resources.setup();
    
    if ( grid.isSet() ) {
      
      setTokensFromJsonArray(playersLayer, sceneJson.getJSONArray("playerTokens"), sketchPath);
      setTokensFromJsonArray(dmLayer, sceneJson.getJSONArray("dmTokens"), sketchPath);
      
      enableController("Add player token");
      enableController("Add DM token");
      
    } else {
      
      disableController("Add player token");
      disableController("Add DM token");
      
    }
    
    JSONArray wallsArray = sceneJson.getJSONArray("walls");
    if ( wallsArray != null ) {
      for ( int i = 0; i < wallsArray.size(); i++ ) {
        
        Wall wall = new Wall(canvas);
        JSONObject wallJson = wallsArray.getJSONObject(i);
        JSONArray wallVertexesJson = wallJson.getJSONArray("vertexes");
        for ( int j = 0; j < wallVertexesJson.size(); j++ ) {
          JSONArray wallVertexJson = wallVertexesJson.getJSONArray(j);
          int vertexX = wallVertexJson.getInt(0);
          int vertexY = wallVertexJson.getInt(1);
          wall.addVertex(vertexX, vertexY);
        }
        
        obstacles.addWall(wall);
        
      }
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
          int vertexX = doorVertexJson.getInt(0);
          int vertexY = doorVertexJson.getInt(1);
          door.addVertex(vertexX, vertexY);
        }
        
        obstacles.addDoor(door);
        
      }
    }
    
    JSONObject illuminationJson = sceneJson.getJSONObject("illumination");
    if ( illuminationJson != null ) {
      
      String lightning = illuminationJson.getString("lightning");
      switch ( lightning ) {
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
      
    }
    
    println("Scene loaded from: " + sceneFile.getAbsolutePath());
    
    layerShown = LayerShown.playersOnly;
    
    obstacles.setRecalculateShadows(true);
    
    appState = AppStates.idle;
    
  }
  
  void setTokensFromJsonArray(Layer layer, JSONArray tokensArray, String sketchPath) {
    
    if ( tokensArray != null ) {
      for ( int i = 0; i < tokensArray.size(); i++ ) {
        
        JSONObject tokenJson = tokensArray.getJSONObject(i);
        String tokenName = tokenJson.getString("name");
        String tokenImagePath = tokenJson.getString("imagePath");
        int tokenRow = tokenJson.getInt("row");
        int tokenColumn = tokenJson.getInt("column");
        
        if ( !fileExists(tokenImagePath) ) {
          if ( fileExists(sketchPath + tokenImagePath) )
            tokenImagePath = sketchPath + tokenImagePath;
        }
        
        Cell cell = grid.getCellAt(tokenRow, tokenColumn);
        Token token = new Token(canvas);
        token.setup(tokenName, tokenImagePath, grid.getCellWidth(), grid.getCellHeight());
        token.setCell(cell);
        
        for ( Light lightSource: getLightsFromJsonArray(tokenJson.getJSONArray("lightSources")) )
          token.addLightSource(lightSource);
        
        for ( Light sightType: getLightsFromJsonArray(tokenJson.getJSONArray("sightTypes")) )
          token.addSightType(sightType);
        
        layer.addToken(token);
        
      }
    }
    
  }
  
  ArrayList<Light> getLightsFromJsonArray(JSONArray lightsArray) {
    
    ArrayList<Light> lights = new ArrayList<Light>();
    
    if ( lightsArray != null ) {
      for ( int j = 0; j < lightsArray.size(); j++ ) {
        JSONObject lightJson = lightsArray.getJSONObject(j);
        String name = lightJson.getString("name");
        int brightLightRadius = lightJson.getInt("brightLightRadius");
        int dimLightRadius = lightJson.getInt("dimLightRadius");
        Light light = new Light(name, brightLightRadius, dimLightRadius);
        lights.add(light);
      }
    }
    
    return lights;
    
  }
  
  void enableController(String controllerName) {
    
    Controller controller = cp5.getController(controllerName);
    controller.setColorBackground(enabledBackgroundColor);
    controller.unlock();
    
  }
  
  void disableController(String controllerName) {
    
    Controller controller = cp5.getController(controllerName);
    controller.setColorBackground(disabledBackgroundColor);
    controller.lock();
    
  }
  
  boolean isInside() {
    
    boolean inside = false;
    int x = mouseX;
    int y = mouseX;
    
    List<Button> buttons = cp5.getAll(Button.class);
    for ( Button button: buttons )
      inside = inside || isInside(button, x, y);
    
    return inside;
    
  }
  
  boolean isInside(Controller controller, int x, int y) {
    
    boolean inside = false;
    
    float startX = controller.getPosition()[0];
    float startY = controller.getPosition()[1];
    float endX = startX + controller.getWidth();
    float endY = startY + controller.getHeight();
    
    if ( controller.isInside() || (x > startX && x < endX && y > startY && y < endY ) )
      inside = true;
    
    return inside;
    
  }
  
  boolean isInsideMenu(int x, int y) {
    
    boolean inside = false;
    
    // menu bar
    float barStartX = tokenMenu.getPosition()[0];
    float barStartY = tokenMenu.getPosition()[1];
    float barEndX = barStartX + tokenMenu.getWidth();
    float barEndY = barStartY + menuControllers.getHeight();
    
    // menu item
    float itemStartX = barStartX;
    float itemStartY = barEndY;
    float itemEndX = barEndX;
    float itemEndY = itemStartY + menuControllers.getBackgroundHeight();
    
    if ( (x > barStartX && x < barEndX && y > barStartY && y < barEndY) || (x > itemStartX && x < itemEndX && y > itemStartY && y < itemEndY) )
      inside = true;
    
    return inside;
    
  }
  
  boolean fileExists(String filePath) {
    
    boolean exists = false;
    
    try {
      File f = new File(filePath);
      if ( f.isFile() )
        exists = true;
    } catch(Exception e) {
      exists = false;
    }
    
    return exists;
    
  }
  
}
