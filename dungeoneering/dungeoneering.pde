// dungeoneering - minimalistic virtual tabletop (VTT)
// Copyright (C) 2019-2021 Luis Castilho

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

import ch.bildspur.postfx.*;
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import com.hazelcast.core.Hazelcast;
import com.hazelcast.core.HazelcastInstance;
import com.vlkan.rfos.RotatingFileOutputStream;
import com.vlkan.rfos.RotationConfig;
import com.vlkan.rfos.policy.RotationPolicy;
import controlP5.*;
import java.awt.Point;
import java.io.File;
import java.io.FileFilter;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.regex.Pattern;
import javafx.beans.property.SimpleIntegerProperty;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javax.activation.MimetypesFileTypeMap;
import org.apache.commons.io.comparator.LastModifiedFileComparator;
import org.apache.commons.io.filefilter.AndFileFilter;
import org.apache.commons.io.filefilter.FileFileFilter;
import org.apache.commons.io.filefilter.WildcardFileFilter;
import org.apache.commons.lang3.SystemUtils;
import org.apache.commons.lang3.builder.HashCodeBuilder;
import org.apache.commons.lang3.exception.ExceptionUtils;
import processing.video.*;
import uibooster.*;

Logger logger;

AppMode appMode;
Config sharedDataconfig;
HazelcastInstance sharedDataInstance;
IMap<String, String> sharedData;
String localAddress;
int dmModePort, playersModePort;

AppState appState;

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
LayerShown layerShown;

Resources resources;

Initiative initiative;

UserInterface userInterface;

color backgroundColor;

PFont loadingFont;
String loadingMessage;
color loadingFontColor, loadingFontOutlineColor;

int upkeepInterval;

int previousClickTime;

String appVersion;
boolean checkedForUpdates;

void setup() {

  fullScreen(P2D, 1);
  // fullScreen(P2D, 2);
  smooth();

  logger = new Logger("DEBUG", PApplet.platform);

  try {

    logger.info("Setup: dungeoneering initialization started");

    appMode = AppMode.standalone;
    // appMode = AppMode.dm;
    // appMode = AppMode.players;

    logger.info("Setup: initializing dungeoneering in " + appMode.toString());

    if ( appMode == AppMode.dm || appMode == AppMode.players ) {

      dmModePort = 50005;
      playersModePort = 60006;
      localAddress = "127.0.0.1";

      // Create Hazelcast config based on app mode - DM or Players
      sharedDataconfig = new Config();
      sharedDataconfig.setClusterName("dungeoneering");
      if ( appMode == AppMode.dm ) {
        sharedDataconfig.getNetworkConfig().setPublicAddress(localAddress).setPort(dmModePort);
        sharedDataconfig.setInstanceName("dm-app");
      } else {
        sharedDataconfig.getNetworkConfig().setPublicAddress(localAddress).setPort(playersModePort);
        sharedDataconfig.setInstanceName("players-app");
      }

      // Instantiate Hazelcast
      sharedDataInstance = Hazelcast.newHazelcastInstance(sharedDataconfig);

      // Create shared map: String -> String
      // "fromDmApp" -> scene in JSON format sent by DM's App, as String
      // "fromPlayersApp" -> scene in JSON format sent by Players' App, as String
      sharedData = sharedDataInstance.getMap("shared");

      // Add listener to map, so it will process shared data when it's added or updated
      sharedData.addEntryListener(new EntryAdapter<String, String>() {

        @Override
        public void entryAdded(EntryEvent<String, String> event) {
          logger.debug("Entry " + event.getKey() + " added");
          logger.trace("Entry " + event.getKey() + " added: from " + event.getOldValue() + " to " + event.getValue());
          processSharedData(event.getKey());
        }

        @Override
        public void entryUpdated(EntryEvent<String, String> event) {
          logger.debug("Entry " + event.getKey() + " updated");
          logger.trace("Entry " + event.getKey() + " updated: from " + event.getOldValue() + " to " + event.getValue());
          processSharedData(event.getKey());
        }

      }, true );

      sharedDataInstance.getCluster().addMembershipListener(new MembershipListener() {

          @Override
          public void memberAdded(MembershipEvent event) {
            logger.debug("Cluster member added: " + event.toString());
            showPlayerControllersInDmApp();
          }

          @Override
          public void memberRemoved(MembershipEvent event) {
            logger.debug("Cluster member removed: " + event.toString());
            hidePlayerControllersInDmApp();
          }

      });

    }

    appState = AppState.idle;

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

    playersLayer = new Layer(mainCanvas, grid, obstacles, resources, initiative, "Players' Layer", LayerShown.players);
    dmLayer = new Layer(mainCanvas, grid, obstacles, resources, initiative, "DM's Layer", LayerShown.dm);
    layerShown = LayerShown.players;

    logger.debug("Setup: layers initialization done");

    userInterface = new UserInterface(mainCanvas, cp5, map, grid, obstacles, playersLayer, dmLayer, resources, initiative, PApplet.platform, sharedDataInstance, sharedData);

    logger.debug("Setup: UI initialization done");

    backgroundColor = color(0);

    loadingFont = loadFont("fonts/ProcessingSansPro-Semibold-18.vlw");
    loadingMessage = "Loading...";
    loadingFontColor = color(255);
    loadingFontOutlineColor = color(0);

    upkeepInterval = 5;

    previousClickTime = 0;

    appVersion = "v1.2.1";
    checkedForUpdates = false;

    logger.info("Setup: dungeoneering initialization done");

  } catch ( Exception e ) {
    logger.error("Setup: Error initializing dungeoneering");
    logger.error(ExceptionUtils.getStackTrace(e));
    exit();
  }

  // Set framerate as the last step in setup to avoid an exception in Processing PSurfaceJOGL
  // Otherwise it will throw a RuntimeException if setup doesn't finish in 5s or less
  // In exported versions, dungeoneering won't finish loading and will get stuck in a grey screen
  // Source: https://github.com/processing/processing/issues/4468#issuecomment-228532848
  frameRate(60);

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

  try {

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
          dmLayer.recalculateShadows(ShadowType.lightSources);
          playersLayer.recalculateShadows(ShadowType.lightSources);
          // Gather lines of sight of the layer being shown, to be used as a mask to hide/reveal light sources
          playersLayer.recalculateShadows(ShadowType.linesOfSight);
          // Gather sight types of the layer being shown
          playersLayer.recalculateShadows(ShadowType.sightTypes);
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
          playersLayer.recalculateShadows(ShadowType.lightSources);
          dmLayer.recalculateShadows(ShadowType.lightSources);
          dmLayer.recalculateShadows(ShadowType.linesOfSight);
          dmLayer.recalculateShadows(ShadowType.sightTypes);
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
          playersLayer.recalculateShadows(ShadowType.lightSources);
          dmLayer.recalculateShadows(ShadowType.lightSources);
          // Gather lines of sight from all layers, to be used as a mask to reveal/hide light sources
          playersLayer.recalculateShadows(ShadowType.linesOfSight);
          dmLayer.recalculateShadows(ShadowType.linesOfSight);
          // Gather sight types from all layers
          playersLayer.recalculateShadows(ShadowType.sightTypes);
          dmLayer.recalculateShadows(ShadowType.sightTypes);
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

  } catch ( Exception e ) {
    logger.error("UserInterface: Error drawing scene");
    logger.error(ExceptionUtils.getStackTrace(e));
  }

}

void drawInitiative() {

  try {

    initiativeCanvas.beginDraw();
    initiativeCanvas.background(0, 0);
    initiative.draw(layerShown);
    initiativeCanvas.endDraw();

  } catch ( Exception e ) {
    logger.error("UserInterface: Error drawing initiative");
    logger.error(ExceptionUtils.getStackTrace(e));
  }

}

void drawUi() {

  try {

    uiCanvas.beginDraw();
    uiCanvas.background(0, 0);
    // Draw controlP5 controllers
    cp5.draw(uiCanvas);
    // Draw UI tooltips
    userInterface.drawTooltips(uiCanvas);
    uiCanvas.endDraw();

  } catch ( Exception e ) {
    logger.error("UserInterface: Error drawing user interface");
    logger.error(ExceptionUtils.getStackTrace(e));
  }

}

void changeAppState(AppState newAppState) {
  if ( appState != newAppState ) {
    logger.info("App state changed from " + appState.toString() + " to " + newAppState.toString());
    appState = newAppState;
  }
}

void appUpkeep() {

  System.gc();
  System.runFinalization();

  if ( !checkedForUpdates ) {

    // Check for updates in a separate thread
    thread("checkForUpdates");

    // Mark that we have already checked for updates
    checkedForUpdates = true;

  }

  long totalMemory = Runtime.getRuntime().totalMemory();
  long usedMemory = totalMemory - Runtime.getRuntime().freeMemory();
  float usedMemoryPercent = (100*(float)usedMemory/totalMemory);
  logger.debug("Stats: FPS: " + nf(frameRate, 2, 2) + " / " + "Memory usage: " + nf(usedMemoryPercent, 2, 2) + "%");

}

void checkForUpdates() {

  // Retrieve latest_version file from GitHub repository, main branch
  String[] latestVersionContents = loadStrings("https://raw.githubusercontent.com/luiscastilho/dungeoneering/main/docs/latest_version");

  // If latest_version could be retrieved, compare it to application version
  if ( latestVersionContents != null ) {

    int appVersionNumber = int(appVersion.replace("v", "").replace(".", ""));

    String latestVersion = latestVersionContents[0];
    int latestVersionNumber = int(latestVersion.replace("v", "").replace(".", ""));
    if ( latestVersionNumber > appVersionNumber )
      userInterface.showNewVersionDialog(latestVersion);
    else
      logger.info("CheckForUpdates: dungeoneering is running the latest version");

  } else {

    logger.error("CheckForUpdates: Couldn't retrieve latest version from GitHub");

  }

}

void controlEvent(ControlEvent controlEvent) {

  if ( userInterface == null )
    return;

  try {

    changeAppState(userInterface.controllerEvent(controlEvent));

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
          changeAppState(userInterface.changeInitiativeOrder(mouseX, false));
        else if ( userInterface.isOverToken(mouseX, mouseY) )
          changeAppState(userInterface.moveToken(mouseX, mouseY, false));
        else
          changeAppState(userInterface.panMap(mouseX, pmouseX, mouseY, pmouseY, false));

      } else if ( mouseButton == CENTER ) {

        changeAppState(userInterface.panMap(mouseX, pmouseX, mouseY, pmouseY, false));

      }

      break;
    case gridSetup:

      if ( mouseButton == LEFT )
        userInterface.gridHelperSetup(mouseX, mouseY, false, false);

      break;
    case initiativeOrderSetup:

      if ( mouseButton == LEFT )
        if ( userInterface.isInsideInitiativeOrder() )
          changeAppState(userInterface.changeInitiativeOrder(mouseX, false));
        else
          changeAppState(userInterface.changeInitiativeOrder(mouseX, true));

      break;
    case mapPan:

      if ( mouseButton == LEFT || mouseButton == CENTER )
        userInterface.panMap(mouseX, pmouseX, mouseY, pmouseY, false);

      break;
    case wallSetup:
    case doorSetup:
    case tokenSetup:
    case tokenMovement:

      if ( mouseButton == CENTER )
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
        userInterface.toggleDoor(mouseX, mouseY);

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
        changeAppState(userInterface.moveToken(mouseX, mouseY, true));

      if ( mouseButton == CENTER )
        userInterface.panMap(mouseX, pmouseX, mouseY, pmouseY, true);

      break;
    case wallSetup:

      if ( mouseButton == LEFT )
        userInterface.newWallSetup(mouseX, mouseY, doubleClick);

      if ( mouseButton == RIGHT )
        userInterface.removeWall(mouseX, mouseY);

      if ( mouseButton == CENTER )
        userInterface.panMap(mouseX, pmouseX, mouseY, pmouseY, true);

      break;
    case doorSetup:

      if ( mouseButton == LEFT )
        userInterface.newDoorSetup(mouseX, mouseY);

      if ( mouseButton == RIGHT )
        userInterface.removeDoor(mouseX, mouseY);

      if ( mouseButton == CENTER )
        userInterface.panMap(mouseX, pmouseX, mouseY, pmouseY, true);

      break;
    case initiativeOrderSetup:

      if ( mouseButton == LEFT )
        changeAppState(userInterface.changeInitiativeOrder(mouseX, true));

      break;
    case mapPan:

      if ( mouseButton == LEFT || mouseButton == CENTER )
        changeAppState(userInterface.panMap(mouseX, pmouseX, mouseY, pmouseY, true));

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

void processSharedData(String fromApp) {

  if ( appMode == AppMode.standalone )
    return;

  if ( fromApp == null || fromApp.trim().isEmpty() )
    return;

  // Ignore messages sent by this app
  if ( appMode == AppMode.dm && fromApp.equals("fromDmApp") )
    return;
  if ( appMode == AppMode.players && fromApp.equals("fromPlayersApp") )
    return;

  try {

    // JSONObject is shared as String
    String sharedJsonObjectAsString = sharedData.get(fromApp);
    if ( sharedJsonObjectAsString == null || sharedJsonObjectAsString.trim().isEmpty() ) {
      logger.debug("UserInterface: Received shared data is empty");
      return;
    }

    // Convert String to JSONObject
    JSONObject sceneJson = JSONObject.parse(sharedJsonObjectAsString);

    logger.info("UserInterface: Received shared data from app in " + appMode.toString());

    // Sync scene with received JSON
    userInterface.syncScene(sceneJson);

  } catch ( Exception e ) {
    logger.error("UserInterface: Error handling shared data");
    logger.error(ExceptionUtils.getStackTrace(e));
    throw e;
  }

}

void showPlayerControllersInDmApp() {

  if ( appMode == AppMode.standalone )
    return;
  if ( appMode == AppMode.players )
    return;

  userInterface.showPlayerControllersInDmApp();

}

void hidePlayerControllersInDmApp() {

  if ( appMode == AppMode.standalone )
    return;
  if ( appMode == AppMode.players )
    return;

  userInterface.hidePlayerControllersInDmApp();

}
