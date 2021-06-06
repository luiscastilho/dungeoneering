class Token {

  PGraphics canvas;

  Grid grid;

  Obstacles obstacles;

  String name;

  String imagePath;
  PImage image;

  boolean set;
  boolean beingMoved;

  Cell cell, prevCell;
  ArrayList<Cell> extraCells;

  Size size;

  Light lineOfSight;
  ArrayList<Light> sightTypes;
  ArrayList<Light> lightSources;

  ArrayList<Condition> conditions;

  boolean disabled;

  Token(PGraphics _canvas, Grid _grid, Obstacles _obstacles) {

    canvas = _canvas;

    grid = _grid;

    obstacles = _obstacles;

    name = null;

    imagePath = null;
    image = null;

    set = false;
    beingMoved = false;

    cell = null;
    prevCell = null;
    extraCells = new ArrayList<Cell>();

    size = null;

    sightTypes = new ArrayList<Light>();
    lightSources = new ArrayList<Light>();

    conditions = new ArrayList<Condition>();

    disabled = false;

  }

  void draw(boolean concealHidden) {

    if ( image == null || !set )
      return;
    if ( cell == null )
      return;

    for ( Condition condition: conditions )
      if ( condition.hidesTarget() && concealHidden )
        return;

    if ( size.isCentered() ) {
      canvas.imageMode(CENTER);
      canvas.image(image, cell.getCenter().x, cell.getCenter().y);
    } else {
      canvas.imageMode(CORNER);
      canvas.image(image, cell.getCenter().x - cell.getCellWidth()/2f, cell.getCenter().y - cell.getCellHeight()/2f);
    }

    int position = 0;
    for ( Condition condition: conditions ) {
      if ( !condition.isCentered() ) {

        condition.draw(cell, position);
        position += 1;

      }
    }

    for ( Condition condition: conditions )
      if ( condition.isCentered() )
        condition.draw(cell, position);

  }

  void setup(String _name, String _imagePath, int cellWidth, int cellHeight, Size _size, Light _lineOfSight) {

    name = _name;

    size = _size;

    imagePath = _imagePath;
    image = loadImage(imagePath);
    image.resize(round(cellWidth * size.getResizeFactor()), round(cellHeight * size.getResizeFactor()));

    lineOfSight = _lineOfSight;

    set = true;

  }

  void recalculateShadows(ShadowTypes shadowsToRecalculate) {

    logger.trace("Token: " + name + ": recalculating shadows");

    switch ( shadowsToRecalculate ) {
      case lightSources:
        for ( Light lightSource: lightSources ) {
          recalculateShadows(lightSource, "Light source");
          obstacles.blendLightSources();
        }
        break;
      case linesOfSight:
        if ( !disabled ) {
          recalculateShadows(lineOfSight, "Sight type");
          obstacles.blendLinesOfSight();
        }
        break;
      case sightTypes:
        if ( !disabled )
          for ( Light sightType: sightTypes ) {
            recalculateShadows(sightType, "Sight type");
            obstacles.blendSightTypes();
          }
        break;
    }

  }

  void recalculateShadows(Light light, String type) {

    PGraphics shadows = obstacles.getTemporaryShadowsCanvas();

    shadows.beginDraw();
    shadows.background(0);
    shadows.translate(obstacles.getCurrentPanX(), obstacles.getCurrentPanY());
    shadows.scale(obstacles.getCurrentScale());

    light.draw(shadows);

    int wallsReached = 0;
    for ( Wall wall: obstacles.getWalls() )
      if ( wall.reachedBy(light) || wall.intersectedBy(light) ) {
        wall.calculateShadows(light, shadows);
        wallsReached += 1;
      }
    logger.trace("Token: " + name + ": " + type + " " + light.getName() + ": " + wallsReached + "/" + obstacles.getWalls().size() + " walls reached");

    int doorsReached = 0;
    for ( Door door: obstacles.getDoors() )
      if ( door.reachedBy(light) || door.intersectedBy(light) ) {
        door.calculateShadows(light, shadows);
        doorsReached += 1;
      }
    logger.trace("Token: " + name + ": " + type + " " + light.getName() + ": " + doorsReached + "/" + obstacles.getDoors().size() + " doors reached");

    shadows.endDraw();

  }

  void setCell( Cell _cell ) {

    if ( _cell != null ) {
      cell = _cell;

      recenterLightSources();

      // set extra cells occupied based on size
      int cellRow = cell.getRow();
      int cellColumn = cell.getColumn();

      switch ( size.getName() ) {
        case "Tiny":
        case "Small":
        case "Medium":

          // no extra cells occupied
          extraCells.clear();

          break;
        case "Large":

          // three extra cells occupied:
          // X 1
          // 2 3
          extraCells.clear();
          extraCells.add(grid.getCellAt(cellRow, cellColumn+1));
          extraCells.add(grid.getCellAt(cellRow+1, cellColumn));
          extraCells.add(grid.getCellAt(cellRow+1, cellColumn+1));

          break;
        case "Huge":

          // eight extra cells occupied:
          // 1 2 3
          // 4 X 5
          // 6 7 8
          extraCells.clear();
          extraCells.add(grid.getCellAt(cellRow-1, cellColumn-1));
          extraCells.add(grid.getCellAt(cellRow-1, cellColumn));
          extraCells.add(grid.getCellAt(cellRow-1, cellColumn+1));
          extraCells.add(grid.getCellAt(cellRow, cellColumn-1));
          extraCells.add(grid.getCellAt(cellRow, cellColumn+1));
          extraCells.add(grid.getCellAt(cellRow+1, cellColumn-1));
          extraCells.add(grid.getCellAt(cellRow+1, cellColumn));
          extraCells.add(grid.getCellAt(cellRow+1, cellColumn+1));

          break;
        case "Gargantuan":

          // fifteen extra cells occupied:
          //  X  1  2  3
          //  4  5  6  7
          //  8  9 10 11
          // 12 13 14 15
          extraCells.clear();
          extraCells.add(grid.getCellAt(cellRow, cellColumn+1));
          extraCells.add(grid.getCellAt(cellRow, cellColumn+2));
          extraCells.add(grid.getCellAt(cellRow, cellColumn+3));
          extraCells.add(grid.getCellAt(cellRow+1, cellColumn));
          extraCells.add(grid.getCellAt(cellRow+1, cellColumn+1));
          extraCells.add(grid.getCellAt(cellRow+1, cellColumn+2));
          extraCells.add(grid.getCellAt(cellRow+1, cellColumn+3));
          extraCells.add(grid.getCellAt(cellRow+2, cellColumn));
          extraCells.add(grid.getCellAt(cellRow+2, cellColumn+1));
          extraCells.add(grid.getCellAt(cellRow+2, cellColumn+2));
          extraCells.add(grid.getCellAt(cellRow+2, cellColumn+3));
          extraCells.add(grid.getCellAt(cellRow+3, cellColumn));
          extraCells.add(grid.getCellAt(cellRow+3, cellColumn+1));
          extraCells.add(grid.getCellAt(cellRow+3, cellColumn+2));
          extraCells.add(grid.getCellAt(cellRow+3, cellColumn+3));

          break;
      }

    }

  }

  void recenterLightSources() {

    int tokenCenterX = 0;
    int tokenCenterY = 0;

    // calculate token center based on its size
    switch ( size.getName() ) {
      case "Tiny":
      case "Small":
      case "Medium":

        tokenCenterX = cell.getCenter().x;
        tokenCenterY = cell.getCenter().y;

        break;
      case "Large":

        tokenCenterX = cell.getCenter().x + round(cell.getCellWidth()*0.5f);
        tokenCenterY = cell.getCenter().y + round(cell.getCellHeight()*0.5f);

        break;
      case "Huge":

        tokenCenterX = cell.getCenter().x;
        tokenCenterY = cell.getCenter().y;

        break;
      case "Gargantuan":

        tokenCenterX = cell.getCenter().x + round(cell.getCellWidth()*1.5f);
        tokenCenterY = cell.getCenter().y + round(cell.getCellHeight()*1.5f);

        break;
    }

    // set line of sight, light sources and sight types center
    lineOfSight.setPosition(tokenCenterX, tokenCenterY);
    for ( Light light: lightSources )
      light.setPosition(tokenCenterX, tokenCenterY);
    for ( Light sight: sightTypes )
      sight.setPosition(tokenCenterX, tokenCenterY);

  }

  void setBeingMoved(boolean _beingMoved) {

    beingMoved = _beingMoved;

    if ( beingMoved ) {

      prevCell = cell;

    } else {

      if ( cell != prevCell )
        logger.debug(
          "Token: " + name + ": Moved from " +
          prevCell.getRow() + "," + prevCell.getColumn() +
          " to " +
          cell.getRow() + "," + cell.getColumn()
          );

      prevCell = null;

    }

  }

  void reset() {

    if ( prevCell != null ) {
      cell = prevCell;
      recenterLightSources();
    }
    beingMoved = false;

  }

  boolean isSet() {
    return set;
  }

  boolean isBeingMoved() {
    return beingMoved;
  }

  String getName() {
    return name;
  }

  String getImagePath() {
    return imagePath;
  }

  Cell getCell() {
    return cell;
  }

  ArrayList<Light> getLightSources() {
    return lightSources;
  }

  ArrayList<Light> getSightTypes() {
    return sightTypes;
  }

  ArrayList<Condition> getConditions() {
    return conditions;
  }

  Size getSize() {
    return size;
  }

  void toggleLightSource(Light light) {

    for ( Light activeLightSource: lightSources )
      if ( activeLightSource.getName().equals(light.getName()) ) {

        lightSources.remove(activeLightSource);

        logger.debug("Token: " + name + ": Light source " + activeLightSource.getName() + " removed");
        return;

      }

    lightSources.add(light);
    recenterLightSources();

    logger.debug("Token: " + name + ": Light source " + light.getName() + " added");

  }

  void toggleSightType(Light sight) {

    for ( Light activeSightType: sightTypes )
      if ( activeSightType.getName().equals(sight.getName()) ) {

        sightTypes.remove(activeSightType);

        logger.debug("Token: " + name + ": Sight type " + activeSightType.getName() + " removed");
        return;

      }

    sightTypes.add(sight);
    recenterLightSources();

    logger.debug("Token: " + name + ": Sight type " + sight.getName() + " added");

  }

  void toggleCondition(Condition condition) {

    for ( Condition activeCondition: conditions )
      if ( activeCondition.getName().equals(condition.getName()) ) {

        conditions.remove(condition);

        if ( disabled ) {

          boolean stillDisabled = false;
          for ( Condition stillActiveCondition: conditions )
            if ( stillActiveCondition.disablesTarget() )
              stillDisabled = true;

          disabled = stillDisabled;

        }

        logger.debug("Token: " + name + ": Condition " + condition.getName() + " removed");
        return;

      }

    conditions.add(condition);
    if ( condition.disablesTarget() )
      disabled = true;

    logger.debug("Token: " + name + ": Condition " + condition.getName() + " added");

  }

  void setSize(Size _size, Resources resources) {

    ArrayList<Condition> resizedConditions = new ArrayList<Condition>();

    size = _size;

    image = loadImage(imagePath);
    image.resize(round(cell.getCellWidth() * size.getResizeFactor()), round(cell.getCellHeight() * size.getResizeFactor()));

    setCell(cell);

    for ( Condition condition: conditions )
      resizedConditions.add(resources.getCondition(condition.getName(), size));
    conditions = resizedConditions;

    recenterLightSources();

    logger.debug("Token: " + name + ": Size set to " + size.getName());

  }

  boolean isInside(int x, int y) {

    if ( cell != null && cell.isInside(x, y) )
      return true;

    for ( Cell extraCell: extraCells )
      if ( extraCell != null && extraCell.isInside(x, y) )
        return true;

    return false;

  }

  boolean isHidden() {

    for ( Condition condition: conditions )
      if ( condition.hidesTarget() )
        return true;

    return false;

  }

}
