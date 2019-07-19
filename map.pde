import java.awt.Point;

class Map {
  
  PGraphics canvas;
  
  Obstacles obstacles;
  
  String imagePath;
  PImage image;
  
  boolean set;
  
  boolean fitToScreen;
  float panX, panY, scale;
  float panToX, panToY, toScale;
  float lastPanX, lastPanY, lastScale;
  float panIncrement, zoomIncrement;
  
  boolean panEnabled;
  boolean zoomEnabled;
  
  Map(PGraphics _canvas, Obstacles _obstacles) {
    
    canvas = _canvas;
    
    obstacles = _obstacles;
    
    imagePath = null;
    image = null;
    
    set = false;
    
    fitToScreen = false;
    panX = panToX = lastPanX = 0;
    panY = panToY = lastPanY = 0;
    scale = toScale = lastScale = 1;
    
    panIncrement = .3;
    zoomIncrement = .3;
    
    panEnabled = false;
    zoomEnabled = false;
    
  }
  
  void draw() {
    
    if ( image == null || !set )
      return;
    
    panX = lerp(panX, panToX, panIncrement);
    panY = lerp(panY, panToY, panIncrement);
    scale = lerp(scale, toScale, zoomIncrement);
    
    canvas.translate(panX, panY);
    canvas.scale(scale);
    
    canvas.imageMode(CENTER);
    canvas.image(image, canvas.width/2, canvas.height/2);
    
    if ( Math.abs(panX - lastPanX) > 0.1 || Math.abs(panY - lastPanY) > 0.1 || Math.abs(scale - lastScale) > 0.1 ) {
      obstacles.setCurrentPanX(panX);
      obstacles.setCurrentPanY(panY);
      obstacles.setCurrentScale(scale);
      
      obstacles.setRecalculateShadows(true);
      
      if ( DEBUG )
        println("DEBUG: Map: Pan or zoom change");
    }
    
    lastPanX = panX;
    lastPanY = panY;
    lastScale = scale;
    
  }
  
  void setup(String _imagePath, boolean _fitToScreen) {
    
    imagePath = _imagePath;
    image = loadImage(imagePath);
    
    fitToScreen = _fitToScreen;
    if ( fitToScreen )
      fitToScreen();
    
    panX = panToX = 0;
    panY = panToY = 0;
    scale = toScale = 1;
    
    set = true;
    
  }
  
  void pan(int _mouseX, int _pmouseX, int _mouseY, int _pmouseY) {
    
    if ( !panEnabled )
      return;
    
    panToX += _mouseX-_pmouseX;
    panToY += _mouseY-_pmouseY;
    
  }
  
  void zoom(int mouseWheelAmount, int _mouseX, int _mouseY) {
    
    if ( !zoomEnabled )
      return;
    
    float zoom = -mouseWheelAmount * .05;
    panToX -= zoom * (_mouseX - panToX);
    panToY -= zoom * (_mouseY - panToY);
    toScale *= zoom+1;
    
  }
  
  void fitToScreen() {
    
    float ratioWidth = image.width / float(canvas.width);
    float ratioHeight = image.height / float(canvas.height);
    if ( ratioWidth > ratioHeight )
      image.resize(canvas.width, 0);
    else
      image.resize(0, canvas.height);
    
  }
  
  Point mapCanvasToImage(Point p) {
    
    Point mappedPoint = new Point();
    int x, y;
    float ratioWidth, ratioHeight;
    int widthDiff, heightDiff;
    
    x = p.x;
    y = p.y;
    
    ratioWidth = image.width / float(canvas.width);
    ratioHeight = image.height / float(canvas.height);
    
    widthDiff = abs(canvas.width - image.width);
    heightDiff = abs(canvas.height - image.height);
    
    // fits into canvas
    if ( ratioWidth <= 1 && ratioHeight <= 1 ) {
      mappedPoint.x = x - widthDiff/2;
      mappedPoint.y = y - heightDiff/2;
    }
    
    // taller and wider
    else if ( ratioWidth > 1 && ratioHeight > 1 ) {
      mappedPoint.x = x + widthDiff/2;
      mappedPoint.y = y + heightDiff/2;
    }
    
    // portrait, taller than canvas
    else if ( ratioWidth < ratioHeight ) {
      mappedPoint.x = x - widthDiff/2;
      mappedPoint.y = y + heightDiff/2;
    }
    
    // landscape, wider than canvas
    else if ( ratioWidth > ratioHeight ) {
      mappedPoint.x = x + widthDiff/2;
      mappedPoint.y = y - heightDiff/2;
    }
    
    return mappedPoint;
  }
  
  void clear() {
    
    imagePath = null;
    image = null;
    
    set = false;
    
    fitToScreen = false;
    panX = panToX = 0;
    panY = panToY = 0;
    scale = toScale = 1;
    
  }
  
  void reset() {
    
    panToX = 0;
    panToY = 0;
    toScale = 1;
    
  }
  
  boolean isSet() {
    return set;
  }
  
  int getImageWidth() {
    return image.width;
  }
  
  int getImageHeight() {
    return image.height;
  }
  
  String getImagePath() {
    return imagePath;
  }
  
  boolean getFitToScreen() {
    return fitToScreen;
  }
  
  int transformX(int x){
    return int((1/scale)*(x - panX));
  }
  
  int transformY(int y){
    return int((1/scale)*(y - panY));
  }
  
  void togglePan() {
    panEnabled = !panEnabled;
  }
  
  void toggleZoom() {
    zoomEnabled = !zoomEnabled;
  }
  
}
