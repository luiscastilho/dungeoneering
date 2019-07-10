class Token {
  
  PGraphics canvas;
  
  String name;
  
  String imagePath;
  PImage image;
  
  boolean set;
  boolean beingMoved;
  
  Cell cell, prevCell;
  
  Size size;
  
  ArrayList<Light> sightTypes;
  ArrayList<Light> lightSources;
  
  ArrayList<Condition> conditions;
  
  boolean disabled;
  
  Token(PGraphics _canvas) {
    
    canvas = _canvas;
    
    name = null;
    
    imagePath = null;
    image = null;
    
    set = false;
    beingMoved = false;
    
    cell = null;
    prevCell = null;
    
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
  
  void setSize(Size _size) {
    
    size = _size;
    
    image = loadImage(imagePath);
    image.resize(round(cell.getCellWidth() * size.getResizeFactor()), round(cell.getCellHeight() * size.getResizeFactor()));
    
    if ( DEBUG )
      println("DEBUG: Token " + name + ": Size set to " + size.getName());
    
  }
  
  boolean isInside(int x, int y) {
    
    if ( cell != null && cell.isInside(x, y) )
      return true;
    
    return false;
    
  }
  
}
