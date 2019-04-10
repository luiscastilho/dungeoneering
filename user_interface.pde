import javax.activation.MimetypesFileTypeMap;
import java.util.List;
import java.awt.Point;

public class UserInterface {
  
  PGraphics canvas;
  
  ControlP5 cp5;
  Group togglableControllers;
  
  Map map;
  
  Grid grid;
  
  Layer playersLayer;
  Layer dmLayer;
  
  Obstacles obstacles;
  
  Wall newWall;
  Door newDoor;
  
  int controllersTopLeftX;
  int controllersTopLeftY;
  int controllersTopRightX;
  int controllersTopRightY;
  int controllersBottomRightX;
  int controllersBottomRightY;
  int controllersSpacing;
  
  int rectButtonWidth;
  int rectButtonHeight;
  int squareButtonWidth;
  int squareButtonHeight;
  int instructionsHeight;
  
  color enabledBackgroundColor, disabledBackgroundColor, mouseOverBackgroundColor, activeBackgroundColor;
  
  PFont instructionsFont;
  color instructionsFontColor, instructionsVisualColor;
  int instructionsX, instructionsY;
  int instructionsInitialX, instructionsInitialY;
  
  int gridHelperX, gridHelperY;
  int gridHelperToX, gridHelperToY;
  boolean gridHelperSet;
  
  UserInterface(PGraphics _canvas, ControlP5 _cp5, Map _map, Grid _grid, Obstacles _obstacles, Layer _playersLayer, Layer _dmLayer) {
    
    canvas = _canvas;
    
    cp5 = _cp5;
    togglableControllers = cp5.addGroup("Toggable controllers");
    
    map = _map;
    
    grid = _grid;
    
    playersLayer = _playersLayer;
    dmLayer = _dmLayer;
    
    obstacles = _obstacles;
    
    newWall = null;
    newDoor = null;
    
    controllersTopLeftX = int(min(canvas.width, canvas.height) * 0.05);
    controllersTopLeftY = int(min(canvas.width, canvas.height) * 0.05);
    controllersTopRightX = canvas.width - int(min(canvas.width, canvas.height) * 0.05);
    controllersTopRightY = int(min(canvas.width, canvas.height) * 0.05);
    controllersBottomRightX = controllersTopRightX;
    controllersBottomRightY = canvas.height - controllersTopLeftY;
    controllersSpacing = 5;
    
    rectButtonWidth = 100;
    rectButtonHeight = 25;
    squareButtonWidth = 25;
    squareButtonHeight = 25;
    instructionsHeight = 15;
    
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
    
    AppStates newAppState = AppStates.idle;
    
    Controller controller = controlEvent.getController();
    String controllerName = controller.getName();
    
    switch ( controllerName ) {
      case "Select map":
        
        File mapFile = null;
        selectInput("Select a map:", "mapImageSelected", mapFile, this);
        
        newAppState = AppStates.idle;
        
        break;
      case "Grid setup":
        
        Button gridSetup = (Button)controller;
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
          
          cursor(ARROW);
          
          newAppState = AppStates.idle;
          
        }
        
        break;
      case "Add player token":
      case "Add DM token":
        
        Button addToken = (Button)controller;
        
        if ( addToken.isOn() ) {
          
          //map.reset();
          playersLayer.reset();
          dmLayer.reset();
          
          File tokenFile = null;
          if ( controllerName.equals("Add player token") )
            selectInput("Select a token image:", "playerTokenImageSelected", tokenFile, this);
          else
            selectInput("Select a token image:", "dmTokenImageSelected", tokenFile, this);
          
          if ( controllerName.equals("Add player token") )
            layerShown = LayerShown.playersOnly;
          else
            layerShown = LayerShown.dmOnly;
          obstacles.setRecalculateShadows(true);
          
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
        
        Button addWall = (Button)controller;
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
        
        Button addDoor = (Button)controller;
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
        
        Button toggleUi = (Button)controller;
        
        if ( toggleUi.isOn() ) {
          
          togglableControllers.show();
          
        } else {
          
          togglableControllers.hide();
          
        }
        
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
  
  void gridHelperSetupAdjustment(int xAdjustment, int yAdjustment) {
    
    if ( !gridHelperSet )
      return;
    
    grid.clear();
    
    gridHelperToX += xAdjustment;
    gridHelperToY += yAdjustment;
    
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
  
  void saveScene(File sceneFolder) {
    
    if ( sceneFolder == null )
      return;
    if ( map.getImagePath() == null )
      return;
    
    String sketchPath = sketchPath().replaceAll("\\\\", "/");
    
    int tokensIndex, obstaclesIndex, lightsIndex;
    
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
    sceneJson.setJSONObject("grid", gridJson);
    
    JSONArray playerTokensArray = new JSONArray();
    ArrayList<Token> playerTokens = playersLayer.getTokens();
    tokensIndex = 0;
    for ( Token token: playerTokens ) {
      
      JSONObject tokenJson = new JSONObject();
      
      tokenJson.setString("name", token.getName());
      tokenJson.setString("imagePath", token.getImagePath().replaceAll("\\\\", "/").replaceFirst("^" + sketchPath, ""));
      
      Cell cell = token.getCell();
      tokenJson.setInt("row", cell.getRow());
      tokenJson.setInt("column", cell.getColumn());
      
      JSONArray tokenLightsArray = new JSONArray();
      ArrayList<Light> tokenLights = token.getLights();
      lightsIndex = 0;
      for ( Light light: tokenLights ) {
        JSONObject lightJson = new JSONObject();
        lightJson.setString("name", light.getName());
        lightJson.setInt("brightLightRadius", light.getBrightLightRadius());
        lightJson.setInt("dimLightRadius", light.getDimLightRadius());
        tokenLightsArray.setJSONObject(lightsIndex, lightJson);
      }
      tokenJson.setJSONArray("lights", tokenLightsArray);
      
      playerTokensArray.setJSONObject(tokensIndex, tokenJson);
      tokensIndex += 1;
      
    }
    sceneJson.setJSONArray("playerTokens", playerTokensArray);
    
    JSONArray dmTokensArray = new JSONArray();
    ArrayList<Token> dmTokens = dmLayer.getTokens();
    tokensIndex = 0;
    for ( Token token: dmTokens ) {
      
      JSONObject tokenJson = new JSONObject();
      
      tokenJson.setString("name", token.getName());
      tokenJson.setString("imagePath", token.getImagePath().replaceAll("\\\\", "/").replaceFirst("^" + sketchPath, ""));
      
      Cell cell = token.getCell();
      tokenJson.setInt("row", cell.getRow());
      tokenJson.setInt("column", cell.getColumn());
      
      JSONArray tokenLightsArray = new JSONArray();
      ArrayList<Light> tokenLights = token.getLights();
      lightsIndex = 0;
      for ( Light light: tokenLights ) {
        JSONObject lightJson = new JSONObject();
        lightJson.setString("name", light.getName());
        lightJson.setInt("brightLightRadius", light.getBrightLightRadius());
        lightJson.setInt("dimLightRadius", light.getDimLightRadius());
        tokenLightsArray.setJSONObject(lightsIndex, lightJson);
      }
      tokenJson.setJSONArray("lights", tokenLightsArray);
      
      dmTokensArray.setJSONObject(tokensIndex, tokenJson);
      tokensIndex += 1;
      
    }
    sceneJson.setJSONArray("dmTokens", dmTokensArray);
    
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
      grid.setup(firstCellCenterX, firstCellCenterY, lastCellCenterX, lastCellCenterY, cellWidth, cellHeight);
      
    }
    
    if ( grid.isSet() ) {
      
      JSONArray playerTokensArray = sceneJson.getJSONArray("playerTokens");
      if ( playerTokensArray != null ) {
        for ( int i = 0; i < playerTokensArray.size(); i++ ) {
          
          JSONObject tokenJson = playerTokensArray.getJSONObject(i);
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
          
          JSONArray tokenLightsArray = tokenJson.getJSONArray("lights");
          if ( tokenLightsArray != null ) {
            for ( int j = 0; j < tokenLightsArray.size(); j++ ) {
              JSONObject lightJson = tokenLightsArray.getJSONObject(j);
              String lightName = lightJson.getString("name");
              int lightBrightLightRadius = lightJson.getInt("brightLightRadius");
              int lightDimLightRadius = lightJson.getInt("dimLightRadius");
              Light light = new Light(lightName, lightBrightLightRadius, lightDimLightRadius);
              token.addLight(light);
            }
          }
          
          playersLayer.addToken(token);
          
        }
      }
      
      JSONArray dmTokensArray = sceneJson.getJSONArray("dmTokens");
      if ( dmTokensArray != null ) {
        for ( int i = 0; i < dmTokensArray.size(); i++ ) {
          
          JSONObject tokenJson = dmTokensArray.getJSONObject(i);
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
          
          JSONArray tokenLightsArray = tokenJson.getJSONArray("lights");
          if ( tokenLightsArray != null ) {
            for ( int j = 0; j < tokenLightsArray.size(); j++ ) {
              JSONObject lightJson = tokenLightsArray.getJSONObject(j);
              String lightName = lightJson.getString("name");
              int lightBrightLightRadius = lightJson.getInt("brightLightRadius");
              int lightDimLightRadius = lightJson.getInt("dimLightRadius");
              Light light = new Light(lightName, lightBrightLightRadius, lightDimLightRadius);
              token.addLight(light);
            }
          }
          
          dmLayer.addToken(token);
          
        }
      }
      
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
    
    obstacles.setRecalculateShadows(true);
    
    println("Scene loaded from: " + sceneFile.getAbsolutePath());
    
    appState = AppStates.idle;
    
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
    
    if ( x > startX && x < endX && y > startY && y < endY )
      inside = true;
    
    return inside;
    
  }
  
  Light createLight(String name, int brightLightRadiusInFeet, int dimLightRadiusInFeet) {
    
    int cellSize = max(grid.getCellWidth(), grid.getCellHeight());
    int brightLightRadius = brightLightRadiusInFeet != 0 ? (brightLightRadiusInFeet / 5) * cellSize + cellSize/2 : 0;
    int dimLightRadius = dimLightRadiusInFeet != 0 ? (dimLightRadiusInFeet / 5) * cellSize + cellSize/2 : 0;
    
    return new Light(name, brightLightRadius, dimLightRadius);
    
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
