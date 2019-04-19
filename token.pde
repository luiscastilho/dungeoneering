class Token {
  
  PGraphics canvas;
  
  String name;
  
  String imagePath;
  PImage image;
  
  boolean set;
  boolean beingMoved;
  
  Cell cell, prevCell;
  //ArrayList<Cell> cell;
  //ArrayList<Cell> prevCell;
  
  ArrayList<Light> sightTypes;
  ArrayList<Light> lightSources;
  
  ArrayList<Condition> conditions;
  
  Token(PGraphics _canvas) {
    
    canvas = _canvas;
    
    name = null;
    
    imagePath = null;
    image = null;
    
    set = false;
    beingMoved = false;
    
    cell = null; //new ArrayList<Cell>();
    prevCell = null; //new ArrayList<Cell>();
    
    sightTypes = new ArrayList<Light>();
    lightSources = new ArrayList<Light>();
    
    conditions = new ArrayList<Condition>();
    
  }
  
  void draw() {
    
    if ( image == null || !set )
      return;
    if ( cell == null )
      return;
    
    canvas.imageMode(CENTER);
    canvas.image(image, cell.getCenter().x, cell.getCenter().y);
    
    for ( Condition condition: conditions )
      condition.draw(cell.getCenter().x, cell.getCenter().y);
    
  }
  
  void setup(String _name, String _imagePath, int cellWidth, int cellHeight) {
    
    name = _name;
    
    imagePath = _imagePath;
    image = loadImage(imagePath);
    image.resize(cellWidth, cellHeight);
    
    set = true;
    
  }
  
  void recalculateShadows() {
    
    if ( DEBUG )
      println("DEBUG: Token " + name + ": recalculating shadows");
    
    for ( Light lightSource: lightSources )
      recalculateShadows(lightSource, "Light source");
    
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
      if ( wall.reachedBy(light) ) {
        wall.calculateShadows(light, shadows);
        wallsReached += 1;
      }
    if ( DEBUG )
      println("DEBUG: Token " + name + ": " + type + " " + light.getName() + ": " + wallsReached + "/" + obstacles.getWalls().size() + " walls reached");
    
    int doorsReached = 0;
    for ( Door door: obstacles.getDoors() )
      if ( door.reachedBy(light) ) {
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
  
  void addLightSource(Light light) {
    
    for ( Light activeLightSource: lightSources )
      if ( activeLightSource.getName().equals(light.getName()) ) {
        if ( DEBUG )
          println("DEBUG: Token " + name + ": Light source " + light.getName() + " already present");
        return;
      }
    
    lightSources.add(light);
    light.setPosition(cell.getCenter().x, cell.getCenter().y);
    
    if ( DEBUG )
      println("DEBUG: Token " + name + ": Light source " + light.getName() + " added");
    
  }
  
  void addSightType(Light sight) {
    
    for ( Light activeSightType: sightTypes )
      if ( activeSightType.getName().equals(sight.getName()) ) {
        if ( DEBUG )
          println("DEBUG: Token " + name + ": Sight type " + sight.getName() + " already present");
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
        if ( DEBUG )
          println("DEBUG: Token " + name + ": Condition " + condition.getName() + " removed");
        return;
      }
    
    conditions.add(condition);
    
    if ( DEBUG )
      println("DEBUG: Token " + name + ": Condition " + condition.getName() + " added");
    
  }
  
  boolean isInside(int x, int y) {
    
    if ( cell != null && cell.isInside(x, y) )
      return true;
    
    return false;
    
  }
  
}
