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

Resources resources;

UserInterface userInterface;

color backgroundColor;

void setup() {
  
  fullScreen();
  
  DEBUG = true;
  
  appState = AppStates.idle;
  
  cp5 = new ControlP5(this);
  cp5.isTouch = false;
  
  canvas = createGraphics(width, height);
  
  obstacles = new Obstacles(canvas);
  
  map = new Map(canvas, obstacles);
  
  grid = new Grid(canvas);
  
  playersLayer = new Layer(canvas, grid, obstacles, "Players Layer");
  dmLayer = new Layer(canvas, grid, obstacles, "DM Layer");
  layerShown = LayerShown.playersOnly;
  
  resources = new Resources(canvas, grid);
  
  userInterface = new UserInterface(canvas, cp5, map, grid, obstacles, playersLayer, dmLayer, resources);
  
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
  
  grid.draw();
  
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
    case togglingCameraPan:
      
      map.togglePan();
      appState = AppStates.idle;
      
      break;
    case togglingCameraZoom:
      
      map.toggleZoom();
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
    case idle:
      
      if ( mouseButton == LEFT )
        userInterface.hideMenu(mouseX, mouseY);
      
      break;
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
      
      if ( resources.isSet() )
        if ( mouseButton == RIGHT )
          userInterface.showMenu(mouseX, mouseY);
      
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
      
      map.zoom(event.getCount(), mouseX, mouseY);
      
      break;
    default:
      break;
  }
  
}

void keyPressed() {
  
  switch ( appState ) {
    case gridSetup:
      
      if ( key == CODED ) {
        // adjust grid helper start point
        if ( keyCode == UP )
          userInterface.gridHelperSetupAdjustment(0, 1, false);
        if ( keyCode == RIGHT )
          userInterface.gridHelperSetupAdjustment(1, 0, false);
        if ( keyCode == DOWN )
          userInterface.gridHelperSetupAdjustment(0, -1, false);
        if ( keyCode == LEFT )
          userInterface.gridHelperSetupAdjustment(-1, 0, false);
      } else {
        // adjust grid helper end point
        if ( key == 'w' )
          userInterface.gridHelperSetupAdjustment(0, 1, true);
        if ( key == 'd' )
          userInterface.gridHelperSetupAdjustment(1, 0, true);
        if ( key == 's' )
          userInterface.gridHelperSetupAdjustment(0, -1, true);
        if ( key == 'a' )
          userInterface.gridHelperSetupAdjustment(-1, 0, true);
      }
      
      break;
    default:
      break;
  }
  
}
