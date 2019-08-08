class Token {
  
  PGraphics canvas;
  
  Grid grid;
  
  String name;
  
  String imagePath;
  PImage image;
  
  boolean set;
  boolean beingMoved;
  
  Cell cell, prevCell;
  ArrayList<Cell> extraCells;
  
  Size size;
  
  ArrayList<Light> sightTypes;
  ArrayList<Light> lightSources;
  
  ArrayList<Condition> conditions;
  
  boolean disabled;
  
  Token(PGraphics _canvas, Grid _grid) {
    
    canvas = _canvas;
    
    grid = _grid;
    
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
  
  void draw() {
    
    if ( image == null || !set )
      return;
    if ( cell == null )
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
  
  void setup(String _name, String _imagePath, int cellWidth, int cellHeight, Size _size) {
    
    name = _name;
    
    size = _size;
    
    imagePath = _imagePath;
    image = loadImage(imagePath);
    image.resize(round(cellWidth * size.getResizeFactor()), round(cellHeight * size.getResizeFactor()));
    
    set = true;
    
  }
  
  void recalculateShadows() {
    
    if ( DEBUG )
      println("DEBUG: Token " + name + ": recalculating shadows");
    
    for ( Light lightSource: lightSources )
      recalculateShadows(lightSource, "Light source");
    
    if ( !disabled )
      for ( Light sightType: sightTypes )
        recalculateShadows(sightType, "Sight type");
    
  }
  
  void recalculateShadows(Light light, String type) {
    
    PGraphics shadows = obstacles.getCurrentShadowsCanvas();
    
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
    if ( DEBUG )
      println("DEBUG: Token " + name + ": " + type + " " + light.getName() + ": " + wallsReached + "/" + obstacles.getWalls().size() + " walls reached");
    
    int doorsReached = 0;
    for ( Door door: obstacles.getDoors() )
      if ( door.reachedBy(light) || door.intersectedBy(light) ) {
        door.calculateShadows(light, shadows);
        doorsReached += 1;
      }
    if ( DEBUG )
      println("DEBUG: Token " + name + ": " + type + " " + light.getName() + ": " + doorsReached + "/" + obstacles.getDoors().size() + " doors reached");
    
    shadows.endDraw();
    obstacles.blendShadows();
    
  }
  
  void setCell( Cell _cell ) {
    
    if ( _cell != null ) {
      cell = _cell;
      for ( Light light: lightSources )
        light.setPosition(cell.getCenter().x, cell.getCenter().y);
      for ( Light sight: sightTypes )
        sight.setPosition(cell.getCenter().x, cell.getCenter().y);
      
      // set extra cells occupied based on size
      switch ( size.getName() ) {
        case "Tiny":
        case "Small":
        case "Medium":
          extraCells.clear();
          break;
        case "Large":
          // three extra cells occupied:
          // X 1
          // 2 3
          extraCells.clear();
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + cell.getCellWidth(), cell.getCenter().y)));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x, cell.getCenter().y + cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + cell.getCellWidth(), cell.getCenter().y + cell.getCellHeight())));
          break;
        case "Huge":
          // eight extra cells occupied:
          // 1 2 3
          // 4 X 5
          // 6 7 8
          extraCells.clear();
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x - cell.getCellWidth(), cell.getCenter().y - cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x, cell.getCenter().y - cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + cell.getCellWidth(), cell.getCenter().y - cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x - cell.getCellWidth(), cell.getCenter().y)));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + cell.getCellWidth(), cell.getCenter().y)));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x - cell.getCellWidth(), cell.getCenter().y + cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x, cell.getCenter().y + cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + cell.getCellWidth(), cell.getCenter().y + cell.getCellHeight())));
          break;
        case "Gargantuan":
          // fifteen extra cells occupied:
          //  X  1  2  3
          //  4  5  6  7
          //  8  9 10 11
          // 12 13 14 15
          extraCells.clear();
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + cell.getCellWidth(), cell.getCenter().y)));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + 2*cell.getCellWidth(), cell.getCenter().y)));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + 3*cell.getCellWidth(), cell.getCenter().y)));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x, cell.getCenter().y + cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + cell.getCellWidth(), cell.getCenter().y + cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + 2*cell.getCellWidth(), cell.getCenter().y + cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + 3*cell.getCellWidth(), cell.getCenter().y + cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x, cell.getCenter().y + 2*cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + cell.getCellWidth(), cell.getCenter().y + 2*cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + 2*cell.getCellWidth(), cell.getCenter().y + 2*cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + 3*cell.getCellWidth(), cell.getCenter().y + 2*cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x, cell.getCenter().y + 3*cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + cell.getCellWidth(), cell.getCenter().y + 3*cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + 2*cell.getCellWidth(), cell.getCenter().y + 3*cell.getCellHeight())));
          extraCells.add(grid.getCellAt(new Point(cell.getCenter().x + 3*cell.getCellWidth(), cell.getCenter().y + 3*cell.getCellHeight())));
          break;
      }
      
    }
    
  }
  
  void setBeingMoved(boolean _beingMoved) {
    
    beingMoved = _beingMoved;
    
    if ( beingMoved )
      prevCell = cell;
    else
      prevCell = null;
    
  }
  
  void reset() {
    
    if ( prevCell != null ) {
      cell = prevCell;
      for ( Light light: lightSources )
        light.setPosition(cell.getCenter().x, cell.getCenter().y);
      for ( Light sight: sightTypes )
        sight.setPosition(cell.getCenter().x, cell.getCenter().y);
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
        
        if ( DEBUG )
          println("DEBUG: Token " + name + ": Light source " + activeLightSource.getName() + " removed");
        return;
        
      }
    
    lightSources.add(light);
    light.setPosition(cell.getCenter().x, cell.getCenter().y);
    
    if ( DEBUG )
      println("DEBUG: Token " + name + ": Light source " + light.getName() + " added");
    
  }
  
  void toggleSightType(Light sight) {
    
    for ( Light activeSightType: sightTypes )
      if ( activeSightType.getName().equals(sight.getName()) ) {
        
        sightTypes.remove(activeSightType);
        
        if ( DEBUG )
          println("DEBUG: Token " + name + ": Sight type " + activeSightType.getName() + " removed");
        return;
        
      }
    
    sightTypes.add(sight);
    sight.setPosition(cell.getCenter().x, cell.getCenter().y);
    
    if ( DEBUG )
      println("DEBUG: Token " + name + ": Sight type " + sight.getName() + " added");
    
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
        
        if ( DEBUG )
          println("DEBUG: Token " + name + ": Condition " + condition.getName() + " removed");
        return;
        
      }
    
    conditions.add(condition);
    if ( condition.disablesTarget() )
      disabled = true;
    
    if ( DEBUG )
      println("DEBUG: Token " + name + ": Condition " + condition.getName() + " added");
    
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
    
    if ( DEBUG )
      println("DEBUG: Token " + name + ": Size set to " + size.getName());
    
  }
  
  boolean isInside(int x, int y) {
    
    if ( cell != null && cell.isInside(x, y) )
      return true;
    
    for ( Cell extraCell: extraCells )
      if ( extraCell != null && extraCell.isInside(x, y) )
        return true;
    
    return false;
    
  }
  
}
