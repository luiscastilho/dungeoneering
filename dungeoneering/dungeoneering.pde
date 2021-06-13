import controlP5.*;
import processing.video.*;
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;
import org.apache.commons.lang3.exception.ExceptionUtils;

Logger logger;

AppStates appState;

ControlP5 cp5;

PGraphics mainCanvas;
PGraphics initiativeCanvas;
PGraphics uiCanvas;

PostFX postFx;
Obstacles obstacles;

Map map;

Grid grid;

Layer playersLayer;
Layer dmLayer;
Layers layerShown;

Resources resources;

Initiative initiative;

UserInterface userInterface;

color backgroundColor;

PFont loadingFont;
String loadingMessage;
color loadingFontColor, loadingFontOutlineColor;

int upkeepInterval;

int previousClickTime;

void setup() {

  fullScreen(P2D, 2);
  smooth();
  frameRate(60);

  logger = new Logger("DEBUG", this.platform);

  try {

    logger.info("Setup: dungeoneering initialization started");

    appState = AppStates.idle;

    cp5 = new ControlP5(this);
    cp5.setAutoDraw(false);

    logger.debug("Setup: controlP5 initialization done");

    mainCanvas = createGraphics(width, height, P2D);
    mainCanvas.smooth();

    initiativeCanvas = createGraphics(width, height, P2D);
    initiativeCanvas.smooth();

    uiCanvas = createGraphics(width, height, P2D);
    uiCanvas.smooth();

    logger.debug("Setup: canvases initialization done");

    postFx = new PostFX(this);
    obstacles = new Obstacles(mainCanvas, postFx);

    logger.debug("Setup: obstacles initialization done");

    map = new Map(this, mainCanvas, obstacles);

    logger.debug("Setup: map initialization done");

    grid = new Grid(mainCanvas, map);

    logger.debug("Setup: grid initialization done");

    initiative = new Initiative(initiativeCanvas);

    logger.debug("Setup: initiative initialization done");

    resources = new Resources(mainCanvas, grid);

    logger.debug("Setup: resources initialization done");

    playersLayer = new Layer(mainCanvas, grid, obstacles, resources, initiative, "Players Layer", Layers.players);
    dmLayer = new Layer(mainCanvas, grid, obstacles, resources, initiative, "DM Layer", Layers.dm);
    layerShown = Layers.players;

    logger.debug("Setup: layers initialization done");

    userInterface = new UserInterface(mainCanvas, cp5, map, grid, obstacles, playersLayer, dmLayer, resources, initiative, this.platform);

    logger.debug("Setup: UI initialization done");

    backgroundColor = color(0);

    loadingFont = loadFont("fonts/ProcessingSansPro-Semibold-18.vlw");
    loadingMessage = "Loading...";
    loadingFontColor = color(255);
    loadingFontOutlineColor = color(0);

    upkeepInterval = 5;

    previousClickTime = 0;

    logger.info("Setup: dungeoneering initialization done");

  } catch ( Exception e ) {
    logger.error("Setup: Error initializing dungeoneering");
    logger.error(ExceptionUtils.getStackTrace(e));
    exit();
  }

}

void draw() {

  background(backgroundColor);

  switch ( appState ) {
    case sceneLoad:

      textFont(loadingFont);
      outlineText(this.getGraphics(), loadingMessage, loadingFontColor, loadingFontOutlineColor, round(width/2 - textWidth(loadingMessage)/2), round(height/2));

      drawUi();
      image(uiCanvas, 0, 0, width, height);

      return;

    default:
      break;
  }

  drawScene();
  image(mainCanvas, 0, 0, width, height);

  drawInitiative();
  image(initiativeCanvas, 0, 0, width, height);

  drawUi();
  image(uiCanvas, 0, 0, width, height);

  if ( frameCount % (upkeepInterval * 60) == 0 ) {

    appUpkeep();

  }

}

void drawScene() {

  mainCanvas.beginDraw();
  mainCanvas.background(backgroundColor);

  // Draw map
  map.draw();

  // Draw grid
  grid.draw();

  // Reset shadows so they can be recalculated below
  if ( obstacles.getRecalculateShadows() )
    obstacles.resetShadows();

  // Draw tokens
  switch ( layerShown ) {
    case players:

      if ( obstacles.getRecalculateShadows() ) {
        // Gather light sources from all layers
        dmLayer.recalculateShadows(ShadowTypes.lightSources);
        playersLayer.recalculateShadows(ShadowTypes.lightSources);
        // Gather lines of sight of the layer being shown, to be used as a mask to hide/reveal light sources
        playersLayer.recalculateShadows(ShadowTypes.linesOfSight);
        // Gather sight types of the layer being shown
        playersLayer.recalculateShadows(ShadowTypes.sightTypes);
        // Compose final shadows with all of the above
        obstacles.blendShadows();
      }

      // Draw layer not being shown first
      dmLayer.draw(layerShown);
      // Draw shadows to hide/reveal areas and tokens depending on the obstacles present
      obstacles.draw();
      // Draw layer being shown
      playersLayer.draw(layerShown);

      break;
    case dm:

      if ( obstacles.getRecalculateShadows() ) {
        // Same as above, with opposite layer
        playersLayer.recalculateShadows(ShadowTypes.lightSources);
        dmLayer.recalculateShadows(ShadowTypes.lightSources);
        dmLayer.recalculateShadows(ShadowTypes.linesOfSight);
        dmLayer.recalculateShadows(ShadowTypes.sightTypes);
        obstacles.blendShadows();
      }

      // Same as above, with opposite layer
      playersLayer.draw(layerShown);
      obstacles.draw();
      dmLayer.draw(layerShown);

      break;
    case all:
    default:

      if ( obstacles.getRecalculateShadows() ) {
        // Gather light sources from all layers
        playersLayer.recalculateShadows(ShadowTypes.lightSources);
        dmLayer.recalculateShadows(ShadowTypes.lightSources);
        // Gather lines of sight from all layers, to be used as a mask to reveal/hide light sources
        playersLayer.recalculateShadows(ShadowTypes.linesOfSight);
        dmLayer.recalculateShadows(ShadowTypes.linesOfSight);
        // Gather sight types from all layers
        playersLayer.recalculateShadows(ShadowTypes.sightTypes);
        dmLayer.recalculateShadows(ShadowTypes.sightTypes);
        // Compose final shadows with all of the above
        obstacles.blendShadows();
      }

      // Draw shadows first, to hide/reveal areas depending on the obstacles present
      obstacles.draw();
      // Then draw all layers
      playersLayer.draw(layerShown);
      dmLayer.draw(layerShown);

      break;
  }

  // Set shadows as already recalculated
  if ( obstacles.getRecalculateShadows() )
    obstacles.setRecalculateShadows(false);

  // Draw UI setup helpers if any are active
  userInterface.drawSetupHelpers();

  mainCanvas.endDraw();

}

void drawInitiative() {

  initiativeCanvas.beginDraw();
  initiativeCanvas.background(0, 0);
  initiative.draw(layerShown);
  initiativeCanvas.endDraw();

}

void drawUi() {

  uiCanvas.beginDraw();
  uiCanvas.background(0, 0);
  // Draw controlP5 controllers
  cp5.draw(uiCanvas);
  // Draw UI tooltips
  userInterface.drawTooltips(uiCanvas);
  uiCanvas.endDraw();

}

void appUpkeep() {

  System.gc();
  System.runFinalization();

  long totalMemory = Runtime.getRuntime().totalMemory();
  long usedMemory = totalMemory - Runtime.getRuntime().freeMemory();
  float usedMemoryPercent = (100*(float)usedMemory/totalMemory);
  logger.debug("Stats: FPS: " + nf(frameRate, 2, 2) + " / " + "Memory usage: " + nf(usedMemoryPercent, 2, 2) + "%");

}

void controlEvent(ControlEvent controlEvent) {

  if ( userInterface == null )
    return;

  try {

    appState = userInterface.controllerEvent(controlEvent);

  } catch ( Exception e ) {
    logger.error("UserInterface: Error handling controller event");
    logger.error(ExceptionUtils.getStackTrace(e));
    throw e;
  }

}

void mousePressed() {

  if ( userInterface.isInside(mouseX, mouseY) )
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

  if ( userInterface.isInside(mouseX, mouseY) )
    return;

  switch ( appState ) {
    case idle:

      if ( mouseButton == LEFT ) {

        userInterface.hideMenu(mouseX, mouseY);

        if ( userInterface.isInsideInitiativeOrder() )
          appState = userInterface.changeInitiativeOrder(mouseX, false);
        else if ( userInterface.isOverToken(mouseX, mouseY) )
          appState = userInterface.moveToken(mouseX, mouseY, false);
        else
          appState = userInterface.panMap(mouseX, pmouseX, mouseY, pmouseY, false);

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
    case mapPan:

      if ( mouseButton == LEFT )
        userInterface.panMap(mouseX, pmouseX, mouseY, pmouseY, false);

      break;
    default:
      break;
  }

}

void mouseReleased() {

  int currentClickTime;
  boolean doubleClick;

  currentClickTime = millis();
  doubleClick = false;
  if ( currentClickTime - previousClickTime < 500 )
    doubleClick = true;
  previousClickTime = currentClickTime;

  if ( userInterface.isInside(mouseX, mouseY) )
    return;

  switch ( appState ) {
    case idle:

      if ( mouseButton == LEFT )
        userInterface.openDoor(mouseX, mouseY);

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
        appState = userInterface.moveToken(mouseX, mouseY, true);

      break;
    case wallSetup:

      if ( mouseButton == LEFT )
        userInterface.newWallSetup(mouseX, mouseY, doubleClick);

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
    case mapPan:

      if ( mouseButton == LEFT )
        appState = userInterface.panMap(mouseX, pmouseX, mouseY, pmouseY, true);

      break;
    default:
      break;
  }

}

void mouseWheel(MouseEvent event) {

  if ( userInterface.isInside(mouseX, mouseY) )
    return;

  switch ( appState ) {
    case idle:

      userInterface.zoomMap(event.getCount(), mouseX, mouseY);

      break;
    default:
      break;
  }

}

void keyPressed() {

  // Disable exiting the application when ESC is pressed
  if ( key == ESC )
    key = 0;

  switch ( appState ) {
    case gridSetup:

      if ( key == CODED ) {

        // Adjust grid helper bottom right corner
        if ( keyCode == UP )
          userInterface.gridHelperSetupAdjustment(0, -1, true);
        else if ( keyCode == RIGHT )
          userInterface.gridHelperSetupAdjustment(1, 0, true);
        else if ( keyCode == DOWN )
          userInterface.gridHelperSetupAdjustment(0, 1, true);
        else if ( keyCode == LEFT )
          userInterface.gridHelperSetupAdjustment(-1, 0, true);

      } else {

        // Adjust grid helper top left corner
        if ( key == 'w' || key == 'W' )
          userInterface.gridHelperSetupAdjustment(0, -1, false);
        else if ( key == 'd' || key == 'D' )
          userInterface.gridHelperSetupAdjustment(1, 0, false);
        else if ( key == 's' || key == 'S' )
          userInterface.gridHelperSetupAdjustment(0, 1, false);
        else if ( key == 'a' || key == 'A' )
          userInterface.gridHelperSetupAdjustment(-1, 0, false);

      }

      break;
    default:
      break;
  }

}

void movieEvent(Movie movie) {

  if ( !userInterface.isFileDialogOpen() ) {
    try {
      if ( movie.available() )
        movie.read();
    } catch ( Exception e ) {
      logger.error("Map: Error reading video frame");
    }
  }

}

void outlineText(PGraphics canvas, String text, color textColor, color outlineColor, int x, int y) {

  int outlineWidth = 1;

  canvas.fill(outlineColor);
  for ( int outlineX = x-outlineWidth; outlineX <= x+outlineWidth; outlineX++ )
    for ( int outlineY = y-outlineWidth; outlineY <= y+outlineWidth; outlineY++ )
      canvas.text(text, outlineX, outlineY);

  canvas.fill(textColor);
  canvas.text(text, x, y);

}
