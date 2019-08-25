import controlP5.*;
import processing.video.*;

boolean DEBUG;

AppStates appState;

ControlP5 cp5;

PGraphics canvas;
PGraphics initiativeCanvas;

Obstacles obstacles;

Map map;

Grid grid;

Layer playersLayer;
Layer dmLayer;
LayerShown layerShown;

Resources resources;

Initiative initiative;

UserInterface userInterface;

color backgroundColor;

PFont loadingFont;
String loadingMessage;

void setup() {
  
  fullScreen(P2D);
  smooth();
  frameRate(60);
  
  DEBUG = true;
  
  appState = AppStates.idle;
  
  cp5 = new ControlP5(this);
  
  canvas = createGraphics(width, height, P2D);
  canvas.smooth();
  
  initiativeCanvas = createGraphics(width, height, P2D);
  initiativeCanvas.smooth();
  
  obstacles = new Obstacles(canvas);
  
  map = new Map(this, canvas, obstacles);
  
  grid = new Grid(canvas);
  
  initiative = new Initiative(initiativeCanvas);
  
  playersLayer = new Layer(canvas, grid, obstacles, initiative, "Players Layer");
  dmLayer = new Layer(canvas, grid, obstacles, initiative, "DM Layer");
  layerShown = LayerShown.playersOnly;
  
  resources = new Resources(canvas, grid);
  
  userInterface = new UserInterface(canvas, cp5, map, grid, obstacles, playersLayer, dmLayer, resources, initiative);
  
  backgroundColor = color(0);
  
  loadingFont = loadFont("fonts/ProcessingSansPro-Semibold-18.vlw");
  loadingMessage = "Loading...";
  
}

void draw() {
  
  background(backgroundColor);
  
  switch ( appState ) {
    case loadingScene:
      
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
  
  initiativeCanvas.beginDraw();
  initiativeCanvas.background(0, 0);
  
  initiative.draw();
  
  initiativeCanvas.endDraw();
  image(initiativeCanvas, 0, 0, width, height);
  
  if ( frameCount % 180 == 0 ) {
    
    System.gc();
    System.runFinalization();
    
    if ( DEBUG ) {
      long totalMemory = Runtime.getRuntime().totalMemory();
      long usedMemory = totalMemory - Runtime.getRuntime().freeMemory();
      float usedMemoryPercent = (100*(float)usedMemory/totalMemory);
      println("DEBUG: FPS: " + nf(frameRate, 2, 2) + " / " + "Memory usage: " + nf(usedMemoryPercent, 2, 2) + "%");
    }
    
  }
  
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
  
  if (userInterface.isInside(mouseX, mouseY))
    return;
  
  switch ( appState ) {
    case idle:
        
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
  
  if (userInterface.isInside(mouseX, mouseY))
    return;
  
  switch ( appState ) {
    case idle:
      
      if ( mouseButton == RIGHT ) {
        
        userInterface.hideMenu(mouseX, mouseY);
        
        if ( map != null && map.isSet() ) {
          map.pan(mouseX, pmouseX, mouseY, pmouseY);
          break;
        }
        
      } else if ( mouseButton == LEFT ) {
        
        if ( map != null && map.isSet() ) {
          if ( grid != null && grid.isSet() ) {
            if ( userInterface.isInsideInitiativeOrder() ) {
              userInterface.hideMenu(mouseX, mouseY);
              appState = userInterface.changeInitiativeOrder(mouseX, false);
              break;
            }
          }
        }
        
        if ( map != null && map.isSet() ) {
          if ( grid != null && grid.isSet() ) {
            if ( userInterface.isOverToken(mouseX, mouseY) ) {
              userInterface.hideMenu(mouseX, mouseY);
              appState = userInterface.moveToken(mouseX, mouseY, false);
              break;
            }
          }
        }
        
      }
      
      break;
    case gridSetup:
      
      if ( mouseButton == LEFT )
        userInterface.gridHelperSetup(mouseX, mouseY, false, false);
      
      break;
    case initiativeOrderSetup:
      
      if ( mouseButton == LEFT )
        if ( userInterface.isInsideInitiativeOrder() )
          appState = userInterface.changeInitiativeOrder(mouseX, false);
        else
          appState = userInterface.changeInitiativeOrder(mouseX, true);
      
      break;
    default:
      break;
  }
  
}

void mouseReleased() {
  
  if (userInterface.isInside(mouseX, mouseY))
    return;
  
  switch ( appState ) {
    case idle:
      
      if ( mouseButton == LEFT )
        userInterface.openDoor(mouseX, mouseY);
      
      if ( mouseButton == RIGHT )
        if ( resources.isSet() )
          userInterface.showMenu(mouseX, mouseY);
      
      break;
    case gridSetup:
      
      if ( mouseButton == LEFT )
        userInterface.gridHelperSetup(mouseX, mouseY, false, true);
      
      break;
    case tokenSetup:
    case tokenMovement:
      
      if ( mouseButton == LEFT )
        appState = userInterface.moveToken(mouseX, mouseY, true);
      
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
    case initiativeOrderSetup:
      
      if ( mouseButton == LEFT )
        appState = userInterface.changeInitiativeOrder(mouseX, true);
      
      break;
    default:
      break;
  }
  
}

void mouseWheel(MouseEvent event) {
  
  if (userInterface.isInside(mouseX, mouseY))
    return;
  
  switch ( appState ) {
    case idle:
      
      if ( map != null && map.isSet() )
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

void movieEvent(Movie movie) {
  if ( !userInterface.isFileDialogOpen() )
    movie.read();
}
