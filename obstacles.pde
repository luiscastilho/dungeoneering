class Obstacles {
  
  PGraphics canvas;
  
  PostFX postFx;
  
  ArrayList<Wall> walls;
  ArrayList<Door> doors;
  
  boolean drawObstacles;
  int wallWidth, doorWidth;
  color wallColor, closedDoorColor, openDoorColor;
  
  Illumination illumination;
  
  PGraphics allShadows;
  PGraphics currentShadows;
  
  float currentPanX, currentPanY;
  float currentScale;
  
  boolean recalculateShadows;
  
  Obstacles(PGraphics _canvas, PostFX _postFx) {
    
    canvas = _canvas;
    
    postFx = _postFx;
    
    walls = new ArrayList<Wall>();
    doors = new ArrayList<Door>();
    
    drawObstacles = false;
    wallWidth = 4;
    doorWidth = 8;
    wallColor = color(0, 116, 217, 191);
    closedDoorColor = color(255, 166, 0, 191);
    openDoorColor = color(255, 166, 0, 127);
    
    illumination = Illumination.brightLight;
    
    allShadows = createGraphics(canvas.width, canvas.height, P2D);
    allShadows.smooth();
    allShadows.beginDraw();
    allShadows.background(illumination.getColor());
    allShadows.endDraw();
    
    currentShadows = createGraphics(canvas.width, canvas.height, P2D);
    currentShadows.smooth();
    currentShadows.beginDraw();
    currentShadows.background(illumination.getColor());
    currentShadows.endDraw();
    
    currentPanX = 0;
    currentPanY = 0;
    currentScale = 1;
    
    recalculateShadows = false;
    
  }
  
  void draw() {
    
    if (canvas != null && allShadows != null)
      try {
        canvas.mask(allShadows);
      } catch(Exception e) {}
    
    if ( drawObstacles ) {
      
      for ( Wall wall: walls )
        wall.draw(wallColor, wallWidth);
      
      for ( Door door: doors )
        door.draw(closedDoorColor, openDoorColor, doorWidth);
      
    }
    
  }
  
  void addWall(Wall _wall) {
    
    walls.add(_wall);
    
  }
  
  void removeWall(Wall _wall) {
    
    walls.remove(_wall);
    
  }
  
  void addDoor(Door _door) {
    
    doors.add(_door);
    
  }
  
  void removeDoor(Door _door) {
    
    doors.remove(_door);
    
  }
  
  void blendShadows() {
    
    allShadows.beginDraw();
    allShadows.blendMode(LIGHTEST);
    allShadows.image(currentShadows, 0, 0);
    allShadows.endDraw();
    
  }
  
  void blurShadows() {
    
    postFx.render(allShadows)
      .blur(20, 20)
      .compose(allShadows);
    
  }
  
  void resetShadows() {
    
    allShadows.beginDraw();
    allShadows.background(illumination.getColor());
    allShadows.endDraw();
    
  }
  
  void clear() {
    
    walls = new ArrayList<Wall>();
    doors = new ArrayList<Door>();
    recalculateShadows = true;
    
    System.gc();
    
  }
  
  ArrayList<Wall> getWalls() {
    return walls;
  }
  
  ArrayList<Door> getDoors() {
    return doors;
  }
  
  color getWallColor() {
    return wallColor;
  }
  
  int getWallWidth() {
    return wallWidth;
  }
  
  color getClosedDoorColor() {
    return closedDoorColor;
  }
  
  color getOpenDoorColor() {
    return closedDoorColor;
  }
  
  int getDoorWidth() {
    return doorWidth;
  }
  
  PGraphics getCurrentShadowsCanvas() {
    return currentShadows;
  }
  
  PGraphics getAllShadowsCanvas() {
    return allShadows;
  }
  
  void setCurrentPanX(float _currentPanX) {
    currentPanX = _currentPanX;
  }
  
  void setCurrentPanY(float _currentPanY) {
    currentPanY = _currentPanY;
  }
  
  void setCurrentScale(float _currentScale) {
    currentScale = _currentScale;
  }
  
  float getCurrentPanX() {
    return currentPanX;
  }
  
  float getCurrentPanY() {
    return currentPanY;
  }
  
  float getCurrentScale() {
    return currentScale;
  }
  
  boolean getRecalculateShadows() {
    return recalculateShadows;
  }
  
  void setRecalculateShadows(boolean _recalculateShadows) {
    
    recalculateShadows = _recalculateShadows;
    
    if ( DEBUG && _recalculateShadows )
      println("DEBUG: Obstacles: recalculating shadows");
    
  }
  
  Illumination getIllumination() {
    return illumination;
  }
  
  void setIllumination(Illumination _illumination) {
    illumination = _illumination;
  }
  
  boolean getDrawObstacles() {
    return drawObstacles;
  }
  
  void toggleDrawObstacles() {
    drawObstacles = !drawObstacles;
  }
  
}
