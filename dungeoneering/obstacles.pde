class Obstacles {

  PGraphics canvas;

  PostFX postFx;

  CopyOnWriteArrayList<Wall> walls;
  CopyOnWriteArrayList<Door> doors;

  boolean drawObstacles;
  int wallWidth, doorWidth;
  color wallColor, closedDoorColor, openDoorColor;

  Illumination illumination;
  Illumination playersAppIllumination;

  // Accumulates all lights and shadows, serves as a mask to be applied over the entire scene
  PGraphics allShadows;
  // Temporary canvas, used to draw shadows before they are blended into other canvases
  PGraphics temporaryShadows;
  // Accumulates light sources
  PGraphics lightSources;
  // Accumulates lines of sight, used as a mask to be applied over the light sources canvas
  PGraphics linesOfSight;
  // Accumulates sight types
  PGraphics sightTypes;

  float currentPanX, currentPanY;
  float currentScale;

  SimpleIntegerProperty wallsVersion;
  SimpleIntegerProperty doorsVersion;

  boolean recalculateShadows;

  Obstacles(PGraphics _canvas, PostFX _postFx) {

    canvas = _canvas;

    postFx = _postFx;

    walls = new CopyOnWriteArrayList<Wall>();
    doors = new CopyOnWriteArrayList<Door>();

    drawObstacles = false;
    wallWidth = 4;
    doorWidth = 8;
    wallColor = color(#00BBE0, 191);
    closedDoorColor = color(#F64B29, 191);
    openDoorColor = color(#F64B29, 127);

    illumination = Illumination.brightLight;
    playersAppIllumination = Illumination.darkness;

    allShadows = createGraphics(canvas.width, canvas.height, P2D);
    allShadows.noSmooth();
    allShadows.beginDraw();
    allShadows.background(illumination.getColor());
    allShadows.endDraw();

    temporaryShadows = createGraphics(canvas.width, canvas.height, P2D);
    temporaryShadows.noSmooth();
    temporaryShadows.beginDraw();
    temporaryShadows.background(illumination.getColor());
    temporaryShadows.endDraw();

    lightSources = createGraphics(canvas.width, canvas.height, P2D);
    lightSources.noSmooth();
    lightSources.beginDraw();
    lightSources.background(0);
    lightSources.endDraw();

    linesOfSight = createGraphics(canvas.width, canvas.height, P2D);
    linesOfSight.noSmooth();
    linesOfSight.beginDraw();
    linesOfSight.background(0);
    linesOfSight.endDraw();

    sightTypes = createGraphics(canvas.width, canvas.height, P2D);
    sightTypes.noSmooth();
    sightTypes.beginDraw();
    sightTypes.background(0);
    sightTypes.endDraw();

    currentPanX = 0;
    currentPanY = 0;
    currentScale = 1;

    wallsVersion = new SimpleIntegerProperty(1);
    doorsVersion = new SimpleIntegerProperty(1);

    recalculateShadows = false;

  }

  void draw() {

    if (canvas != null && allShadows != null)
      try {
        canvas.mask(allShadows);
      } catch(Exception e) {
        logger.error("Obstacles: Error applying shadows mask");
      }

    if ( drawObstacles ) {

      for ( Wall wall: walls )
        wall.draw(wallColor, wallWidth);

      for ( Door door: doors )
        door.draw(closedDoorColor, openDoorColor, doorWidth);

    }

  }

  void addWall(Wall _wall) {

    walls.add(_wall);
    incrementWallsVersion();
    setRecalculateShadows(true);

  }

  void removeWall(Wall _wall) {

    walls.remove(_wall);
    incrementWallsVersion();
    setRecalculateShadows(true);

  }

  void addDoor(Door _door) {

    doors.add(_door);
    incrementDoorsVersion();
    setRecalculateShadows(true);

  }

  void removeDoor(Door _door) {

    doors.remove(_door);
    incrementDoorsVersion();
    setRecalculateShadows(true);

  }

  void blendLightSources() {

    lightSources.beginDraw();
    lightSources.blendMode(LIGHTEST);
    lightSources.image(temporaryShadows, 0, 0);
    lightSources.blendMode(BLEND);
    lightSources.endDraw();

  }

  void blendSightTypes() {

    sightTypes.beginDraw();
    sightTypes.blendMode(LIGHTEST);
    sightTypes.image(temporaryShadows, 0, 0);
    sightTypes.blendMode(BLEND);
    sightTypes.endDraw();

  }

  void blendLinesOfSight() {

    linesOfSight.beginDraw();
    linesOfSight.blendMode(LIGHTEST);
    linesOfSight.image(temporaryShadows, 0, 0);
    linesOfSight.blendMode(BLEND);
    linesOfSight.endDraw();

  }

  void blendShadows() {

    if ( illumination == Illumination.brightLight )
      return;

    lightSources.beginDraw();
    lightSources.mask(linesOfSight);
    lightSources.endDraw();

    switch ( illumination ) {
      case darkness:

        allShadows.beginDraw();
        allShadows.image(lightSources, 0, 0);
        allShadows.blendMode(LIGHTEST);
        allShadows.image(sightTypes, 0, 0);
        allShadows.blendMode(BLEND);
        allShadows.endDraw();

        break;
      case dimLight:

        allShadows.beginDraw();
        allShadows.image(lightSources, 0, 0);
        allShadows.blendMode(LIGHTEST);
        allShadows.noStroke();
        allShadows.fill(illumination.getColor());
        allShadows.rect(0, 0, allShadows.width, allShadows.height);
        allShadows.blendMode(BLEND);
        allShadows.endDraw();

        break;
      default:
        break;
    }

    blurShadows();

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

    temporaryShadows.beginDraw();
    temporaryShadows.background(0);
    temporaryShadows.endDraw();

    lightSources.beginDraw();
    lightSources.background(0);
    lightSources.endDraw();

    linesOfSight.beginDraw();
    linesOfSight.background(0);
    linesOfSight.endDraw();

    sightTypes.beginDraw();
    sightTypes.background(0);
    sightTypes.endDraw();

    // No need to recalculate shadows if environment lighting is bright light
    if ( illumination == Illumination.brightLight )
      recalculateShadows = false;

    logger.trace("Obstacles: shadows reset");

  }

  void clear() {

    walls = new CopyOnWriteArrayList<Wall>();
    doors = new CopyOnWriteArrayList<Door>();

    wallsVersion.set(1);
    doorsVersion.set(1);

    recalculateShadows = true;

    System.gc();

  }

  CopyOnWriteArrayList<Wall> getWalls() {
    return walls;
  }

  CopyOnWriteArrayList<Door> getDoors() {
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

  PGraphics getTemporaryShadowsCanvas() {
    return temporaryShadows;
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

    if ( recalculateShadows )
      logger.trace("Obstacles: recalculating shadows");

  }

  Illumination getIllumination() {
    return illumination;
  }

  Illumination getPlayersAppIllumination() {
    return playersAppIllumination;
  }

  void setIllumination(Illumination _illumination) {
    illumination = _illumination;
  }

  void setPlayersAppIllumination(Illumination _illumination) {
    playersAppIllumination = _illumination;
  }

  boolean getDrawObstacles() {
    return drawObstacles;
  }

  void toggleDrawObstacles() {
    drawObstacles = !drawObstacles;
  }

  Wall getClosestWall(int _mouseX, int _mouseY, int maxDistance) {

    float distanceToClosestWall = Integer.MAX_VALUE;
    Wall closestWall = null;

    for ( Wall wall: walls ) {

      if ( wall.getCanvasVertexes().size() > 2 )
        continue;

      PVector start = wall.getCanvasVertexes().get(0);
      PVector end = wall.getCanvasVertexes().get(1);

      float sqDistanceToWall = pointToLineSqDistance(start, end, new PVector(_mouseX, _mouseY));

      if ( sqDistanceToWall > sq(maxDistance) )
        continue;

      if ( sqDistanceToWall < distanceToClosestWall ) {
        distanceToClosestWall = sqDistanceToWall;
        closestWall = wall;
      }

    }

    return closestWall;

  }

  Door getClosestDoor(int _mouseX, int _mouseY, int maxDistance) {

    float distanceToClosestDoor = Integer.MAX_VALUE;
    Door closestDoor = null;

    for ( Door door: doors ) {

      if ( door.getCanvasVertexes().size() > 2 )
        continue;

      PVector start = door.getCanvasVertexes().get(0);
      PVector end = door.getCanvasVertexes().get(1);

      float sqDistanceToDoor = pointToLineSqDistance(start, end, new PVector(_mouseX, _mouseY));

      if ( sqDistanceToDoor > sq(maxDistance) )
        continue;

      if ( sqDistanceToDoor < distanceToClosestDoor ) {
        distanceToClosestDoor = sqDistanceToDoor;
        closestDoor = door;
      }

    }

    return closestDoor;

  }

  // Source: openprocessing.org/sketch/39479/
  private float pointToLineSqDistance(PVector A, PVector B, PVector P) {

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

  Wall getWallById(UUID wallID) {

    Wall wallFound = null;

    for ( Wall wall: walls ) {
      if ( wall.getId().equals(wallID) ) {
        wallFound = wall;
        break;
      }
    }

    return wallFound;

  }

  Door getDoorById(UUID doorID) {

    Door doorFound = null;

    for ( Door door: doors ) {
      if ( door.getId().equals(doorID) ) {
        doorFound = door;
        break;
      }
    }

    return doorFound;

  }

  void addSceneUpdateListener(ChangeListener<Number> _sceneUpdateListener) {
    logger.debug("Adding listener to walls version");
    wallsVersion.addListener(_sceneUpdateListener);
    logger.debug("Adding listener to doors version");
    doorsVersion.addListener(_sceneUpdateListener);
  }

  void incrementWallsVersion() {
    logger.debug("Incrementing walls version from " + wallsVersion.getValue() + " to " + (wallsVersion.getValue()+1));
    wallsVersion.set(wallsVersion.getValue() + 1);
  }

  void incrementDoorsVersion() {
    logger.debug("Incrementing doors version from " + doorsVersion.getValue() + " to " + (doorsVersion.getValue()+1));
    doorsVersion.set(doorsVersion.getValue() + 1);
  }

}
