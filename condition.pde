class Condition {
  
  PGraphics canvas;
  
  String name;
  
  String imagePath;
  PImage image;
  
  boolean disablesTarget;
  
  Condition(PGraphics _canvas, String _name, String _imagePath, int cellWidth, int cellHeight, boolean _disablesTarget) {
    
    canvas = _canvas;
    
    name = _name;
    
    imagePath = _imagePath;
    image = loadImage(imagePath);
    image.resize(cellWidth, cellHeight);
    
    disablesTarget = _disablesTarget;
    
  }
  
  void draw(int x, int y) {
    
    if ( image == null )
      return;
    
    canvas.imageMode(CENTER);
    canvas.image(image, x, y);
    
  }
  
  String getName() {
    return name;
  }
  
  boolean disablesTarget() {
    return disablesTarget;
  }
  
}
