import controlP5.*;

boolean DEBUG;

AppStates appState;

ControlP5 cp5;

PGraphics canvas;

Obstacles obstacles;

Map map;

Grid grid;

Layer playersLayer;
Layer dmLayer;
LayerShown layerShown;

UserInterface userInterface;

color backgroundColor;

void setup() {
  
  fullScreen();
  
  DEBUG = true;
  
  appState = AppStates.idle;
  
  cp5 = new ControlP5(this);
  
  canvas = createGraphics(width, height);
  
  obstacles = new Obstacles(canvas);
  
  map = new Map(canvas, obstacles);
  
  grid = new Grid(canvas);
  
  playersLayer = new Layer(canvas, grid, obstacles, "Players Layer");
  dmLayer = new Layer(canvas, grid, obstacles, "DM Layer");
  layerShown = LayerShown.playersOnly;
  
  userInterface = new UserInterface(canvas, cp5, map, grid, obstacles, playersLayer, dmLayer);
  
  backgroundColor = color(0);
  
}

void draw() {
  
  background(backgroundColor);
  
  switch ( appState ) {
    case loadingScene:
      
      PFont loadingFont = loadFont("fonts/ProcessingSansPro-Regular-18.vlw");
      String loadingMessage = "Loading...";
      textFont(loadingFont);
      text(loadingMessage, width/2 - textWidth(loadingMessage)/2, height/2);
      return;
      
    default:
      break;
  }
  
  canvas.beginDraw();
  canvas.background(backgroundColor);
  
  map.draw();
  
  if ( obstacles.getRecalculateShadows() )
    obstacles.resetShadows();
  
  switch ( layerShown ) {
    case playersOnly:
      
      if ( obstacles.getRecalculateShadows() )
        playersLayer.recalculateShadows();
      
      dmLayer.draw();
      obstacles.draw();
      playersLayer.draw();
      
      break;
    case dmOnly:
      
      if ( obstacles.getRecalculateShadows() )
        dmLayer.recalculateShadows();
      
      playersLayer.draw();
      obstacles.draw();
      dmLayer.draw();
      
      break;
    case all:
    default:
      
      if ( obstacles.getRecalculateShadows() ) {
        playersLayer.recalculateShadows();
        dmLayer.recalculateShadows();
      }
      
      obstacles.draw();
      playersLayer.draw();
      dmLayer.draw();
      
      break;
  }
  
  grid.draw();
  
  userInterface.draw();
  
  canvas.endDraw();
  image(canvas, 0, 0, width, height);
  
  if ( DEBUG )
    if ( frameCount % 60 == 0 )
      println("DEBUG: FPS: " + frameRate);
  
}

void controlEvent(ControlEvent controlEvent) {
  
  if ( userInterface == null )
    return;
  
  appState = userInterface.controllerEvent(controlEvent);
  
  appStateBasedAction();
  
}

void appStateBasedAction() {
  
  switch ( appState ) {
    case switchingLayer:
      
      switch ( layerShown ) {
        case playersOnly:
          layerShown = LayerShown.dmOnly;
          break;
        case dmOnly:
          layerShown = LayerShown.all;
          break;
        case all:
          layerShown = LayerShown.playersOnly;
          break;
        default:
          break;
      }
      
      obstacles.setRecalculateShadows(true);
      appState = AppStates.idle;
      
      break;
    case switchingLightning:
      
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
      
      obstacles.setRecalculateShadows(true);
      appState = AppStates.idle;
      
      break;
    default:
      break;
  }
  
}

void mousePressed() {
  
  if (userInterface.isInside())
    return;
  
  switch ( appState ) {
    case gridSetup:
      
      if ( mouseButton != LEFT )
        return;
      
      userInterface.gridHelperSetup(mouseX, mouseY, true, false);
      
      break;
    default:
      break;
  }
  
}

void mouseDragged() {
  
  if (userInterface.isInside())
    return;
  
  switch ( appState ) {
    case idle:
      
      if ( map != null && map.isSet() )
        if ( mouseButton == RIGHT )
          map.pan(mouseX, pmouseX, mouseY, pmouseY);
      
      if ( map != null && map.isSet() )
        if ( grid != null && grid.isSet() )
          if ( mouseButton == LEFT )
            appState = userInterface.moveToken(mouseX, mouseY, false);
      
      break;
    case gridSetup:
      
      if ( mouseButton == LEFT )
        userInterface.gridHelperSetup(mouseX, mouseY, false, false);
      
      break;
    default:
      break;
  }
  
}

void mouseReleased() {
  
  if (userInterface.isInside())
    return;
  
  switch ( appState ) {
    case idle:
      
      if ( mouseButton == LEFT )
        userInterface.openDoor(mouseX, mouseY);
      
      if ( mouseButton == RIGHT ) {
        Token token;
        
        token = playersLayer.getToken(mouseX, mouseY);
        if ( token == null )
          token = dmLayer.getToken(mouseX, mouseY);
        if ( token == null )
          break;
        
        Light candle = userInterface.createLight("Candle", 5, 10);
        Light torch = userInterface.createLight("Torch", 20, 40);
        Light darkvision60 = userInterface.createLight("Darkvision", 0, 60);
        Light darkvision120 = userInterface.createLight("Darkvision", 0, 120);
        
        switch ( token.getName() ) {
          case "Candle":
            token.addLight(candle);
            println("Candle added");
            break;
          case "Torch":
            token.addLight(torch);
            println("Torch added");
            break;
          case "Lia":
          case "Orsik":
          case "Luth":
          case "Claw":
          case "Gruk":
          case "Labard":
          case "Lander":
          case "Naven":
            token.addLight(torch);
            println("Torch added to token " + token.getName());
            break;
          case "Grum'shar":
          case "Goblin":
          case "Orc":
          case "Grey Ooze":
            token.addLight(darkvision60);
            println("Darkvision 60' added to token " + token.getName());
            break;
          case "Duergar":
          case "Nihiloor":
            token.addLight(darkvision120);
            println("Darkvision 120' added to token " + token.getName());
            break;
          case "Kenku":
            token.addLight(candle);
            println("Candle added to token " + token.getName());
            break;
        }
        
        obstacles.setRecalculateShadows(true);
      }
      
      break;
    case gridSetup:
      
      if ( mouseButton == LEFT )
        userInterface.gridHelperSetup(mouseX, mouseY, false, true);
      
      break;
    case tokenSetup:
    case tokenMovement:
      
      if ( mouseButton == LEFT )
        userInterface.moveToken(mouseX, mouseY, true);
      
      break;
    case wallSetup:
      
      if ( mouseButton == LEFT )
        userInterface.newWallSetup(mouseX, mouseY);
      
      if ( mouseButton == RIGHT )
        userInterface.removeWall(mouseX, mouseY);
      
      break;
    case doorSetup:
      
      if ( mouseButton == LEFT )
        userInterface.newDoorSetup(mouseX, mouseY);
      
      if ( mouseButton == RIGHT )
        userInterface.removeDoor(mouseX, mouseY);
      
      break;
    default:
      break;
  }
  
}

void mouseWheel(MouseEvent event) {
  
  if (userInterface.isInside())
    return;
  
  switch ( appState ) {
    case idle:
      
      if ( map == null || !map.isSet() )
        return;
      
      //map.zoom(event.getCount(), mouseX, mouseY);
      
      break;
    default:
      break;
  }
  
}

void keyPressed() {
  
  switch ( appState ) {
    case gridSetup:
      
      if ( key == CODED ) {
        if ( keyCode == UP )
          userInterface.gridHelperSetupAdjustment(0, 1);
        if ( keyCode == RIGHT )
          userInterface.gridHelperSetupAdjustment(1, 0);
        if ( keyCode == DOWN )
          userInterface.gridHelperSetupAdjustment(0, -1);
        if ( keyCode == LEFT )
          userInterface.gridHelperSetupAdjustment(-1, 0);
      }
      
      break;
    default:
      break;
  }
  
}
