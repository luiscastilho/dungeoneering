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
    wallColor = color(#00BBE0, 191);
    closedDoorColor = color(#F64B29, 191);
    openDoorColor = color(#F64B29, 127);

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
    setRecalculateShadows(true);

  }

  void removeWall(Wall _wall) {

    walls.remove(_wall);
    setRecalculateShadows(true);

  }

  void addDoor(Door _door) {

    doors.add(_door);
    setRecalculateShadows(true);

  }

  void removeDoor(Door _door) {

    doors.remove(_door);
    setRecalculateShadows(true);

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

    if ( _recalculateShadows )
      logger.debug("Obstacles: recalculating shadows");

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

  Wall getClosestWall(int _mouseX, int _mouseY, int maxDistance) {

    ArrayList<Wall> walls = obstacles.getWalls();

    float distanceToClosestWall = Integer.MAX_VALUE;
    Wall closestWall = null;

    for ( Wall wall: walls ) {

      if ( wall.getVertexes().size() > 2 )
        continue;

      PVector start = wall.getVertexes().get(0);
      PVector end = wall.getVertexes().get(1);

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

    ArrayList<Door> doors = obstacles.getDoors();

    float distanceToClosestDoor = Integer.MAX_VALUE;
    Door closestDoor = null;

    for ( Door door: doors ) {

      if ( door.getVertexes().size() > 2 )
        continue;

      PVector start = door.getVertexes().get(0);
      PVector end = door.getVertexes().get(1);

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

}
