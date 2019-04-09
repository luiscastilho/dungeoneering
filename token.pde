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
  
  ArrayList<Light> lights;
  
  Token(PGraphics _canvas) {
    
    canvas = _canvas;
    
    name = null;
    
    imagePath = null;
    image = null;
    
    set = false;
    beingMoved = false;
    
    cell = null; //new ArrayList<Cell>();
    prevCell = null; //new ArrayList<Cell>();
    
    lights = new ArrayList<Light>();
    
  }
  
  void draw() {
    
    if ( image == null || !set )
      return;
    if ( cell == null )
      return;
    
    canvas.imageMode(CENTER);
    canvas.image(image, cell.getCenter().x, cell.getCenter().y);
    
  }
  
  void setup(String _name, String _imagePath, int cellWidth, int cellHeight) {
    
    name = _name;
    
    imagePath = _imagePath;
    image = loadImage(imagePath);
    image.resize(cellWidth, cellHeight);
    
    set = true;
    
  }
  
  void recalculateShadows() {
    
    for ( Light light: lights ) {
      
      PGraphics shadows = obstacles.getCurrentShadowsCanvas();
      
      shadows.beginDraw();
      shadows.background(0);
      shadows.translate(obstacles.getCurrentPanX(), obstacles.getCurrentPanY());
      shadows.scale(obstacles.getCurrentScale());
      
      light.draw(shadows);
      
      for ( Wall wall: obstacles.getWalls() )
        wall.calculateShadows(light, shadows);
      
      for ( Door door: obstacles.getDoors() )
        door.calculateShadows(light, shadows);
      
      shadows.endDraw();
      obstacles.blendShadows();
      
    }
    
  }
  
  void setCell( Cell _cell ) {
    
    if ( _cell != null ) {
      cell = _cell;
      for ( Light light: lights )
        light.setPosition(cell.getCenter().x, cell.getCenter().y);
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
      for ( Light light: lights )
        light.setPosition(cell.getCenter().x, cell.getCenter().y);
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
  
  ArrayList<Light> getLights() {
    return lights;
  }
  
  void addLight(Light light) {
    
    lights.add(light);
    light.setPosition(cell.getCenter().x, cell.getCenter().y);
    
  }
  
  boolean isInside(int x, int y) {
    
    if ( cell != null && cell.isInside(x, y) )
      return true;
    
    return false;
    
  }
  
}
