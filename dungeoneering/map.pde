import java.awt.Point;

class Map {

  PApplet sketch;

  PGraphics canvas;

  Obstacles obstacles;

  String filePath;
  PImage image;
  Movie video;

  boolean set;
  boolean isVideo;
  boolean isMuted;

  boolean fitToScreen;
  float panX, panY, scale;
  float panToX, panToY, toScale;
  float lastPanX, lastPanY, lastScale;
  float panIncrement, zoomIncrement;

  boolean panEnabled;
  boolean zoomEnabled;

  Map(PApplet _sketch, PGraphics _canvas, Obstacles _obstacles) {

    sketch = _sketch;

    canvas = _canvas;

    obstacles = _obstacles;

    filePath = null;
    image = null;
    video = null;

    set = false;
    isVideo = false;
    isMuted = false;

    fitToScreen = false;
    panX = panToX = lastPanX = 0;
    panY = panToY = lastPanY = 0;
    scale = toScale = lastScale = 1;

    panIncrement = 1;
    zoomIncrement = 1;

    panEnabled = true;
    zoomEnabled = true;

  }

  void draw() {

    if ( ( image == null && video == null ) || !set )
      return;

    panX = lerp(panX, panToX, panIncrement);
    panY = lerp(panY, panToY, panIncrement);
    scale = lerp(scale, toScale, zoomIncrement);

    canvas.translate(panX, panY);
    canvas.scale(scale);

    canvas.imageMode(CENTER);
    if ( !isVideo ) {

      canvas.image(image, canvas.width/2, canvas.height/2);

    } else {

      try {
        canvas.image(video, canvas.width/2, canvas.height/2);
      } catch ( Exception e ) {
        println("ERROR: Map: Error displaying video frame");
      }

    }

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

  void setup(String _filePath, boolean _fitToScreen, boolean _isVideo, boolean _isMuted) {

    clear();

    isVideo = _isVideo;
    isMuted = _isMuted;

    filePath = _filePath;

    if ( !isVideo ) {

      image = loadImage(filePath);

      fitToScreen = _fitToScreen;
      if ( fitToScreen )
        fitToScreen();

      if ( DEBUG )
        println("DEBUG: Map: Image map loaded");

    } else {

      try {

        video = new Movie(sketch, filePath);
        video.frameRate(30);

        if ( isMuted )
          muteVideo();

        video.loop();

        if ( DEBUG )
          println("DEBUG: Map: Video map loaded");

      } catch ( Exception e ) {
        println("ERROR: Map: Error loading and starting video");
        clear();
        return;
      }

    }

    panX = panToX = 0;
    panY = panToY = 0;
    scale = toScale = 1;

    set = true;

  }

  void pan(int _mouseX, int _pmouseX, int _mouseY, int _pmouseY) {

    if ( !panEnabled )
      return;

    // avoid pmouseX/pmouseY starting too far from mouseX/mouseY in touch screens
    if ( abs(_pmouseX-_mouseX) > 100 || abs(_pmouseY-_mouseY) > 100 ) {

      _pmouseX = _mouseX;
      _pmouseY = _mouseY;

    }

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

    if ( isVideo )
      return;

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
    int mapWidth, mapHeight;
    float ratioWidth, ratioHeight;
    int widthDiff, heightDiff;

    x = p.x;
    y = p.y;

    mapWidth = mapHeight = 0;
    if ( isVideo ) {
      mapWidth = video.width;
      mapHeight = video.height;
    } else {
      mapWidth = image.width;
      mapHeight = image.height;
    }

    ratioWidth = mapWidth / float(canvas.width);
    ratioHeight = mapHeight / float(canvas.height);

    widthDiff = abs(canvas.width - mapWidth);
    heightDiff = abs(canvas.height - mapHeight);

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

    if ( set && isVideo && video != null ) {

      try {

        video.stop();
        video.dispose();

      } catch ( Exception e ) {
        println("ERROR: Map: Error stopping and disposing of video");
      }

    }

    filePath = null;
    image = null;
    video = null;

    set = false;
    isVideo = false;
    isMuted = false;

    fitToScreen = false;
    panX = panToX = 0;
    panY = panToY = 0;
    scale = toScale = 1;

    System.gc();

  }

  void reset() {

    panToX = 0;
    panToY = 0;
    toScale = 1;

  }

  boolean isSet() {
    return set;
  }

  boolean isVideo() {
    return isVideo;
  }

  int getWidth() {
    if ( isVideo )
      return video.width;
    else
      return image.width;
  }

  int getHeight() {
    if ( isVideo )
      return video.height;
    else
      return image.height;
  }

  String getFilePath() {
    return filePath;
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

  boolean isPanEnabled() {
    return panEnabled;
  }

  void toggleMute() {

    isMuted = !isMuted;
    muteVideo();

  }

  void muteVideo() {

    int volume;

    if ( isVideo && video != null ) {

      volume = isMuted ? 0 : 1;

      try {

        if ( video.playbin != null )
          video.playbin.setVolume(volume);

      } catch ( Exception e ) {
        println("ERROR: Map: Error setting video volume");
      }

    }

  }

}
