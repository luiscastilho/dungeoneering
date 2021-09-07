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

  String logoFilePath;
  String logoLink;

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

    logoFilePath = null;
    logoLink = null;

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
        logger.error("Map: Error displaying video frame");
      }

    }

    if ( abs(panX - lastPanX) > 0.1 || abs(panY - lastPanY) > 0.1 || abs(scale - lastScale) > 0.1 ) {
      obstacles.setCurrentPanX(panX);
      obstacles.setCurrentPanY(panY);
      obstacles.setCurrentScale(scale);

      obstacles.setRecalculateShadows(true);

      logger.trace("Map: Pan or zoom change");
      logger.trace("Map: Current pan: " + panX + ", " + panY);
      logger.trace("Map: Current scale: " + scale);
    }

    lastPanX = panX;
    lastPanY = panY;
    lastScale = scale;

  }

  boolean setup(String _filePath, boolean _fitToScreen, boolean _isVideo, boolean _isMuted) {

    int triesCount;
    int maxTries;
    int sleepTimeMillis;

    clear();

    isVideo = _isVideo;
    isMuted = _isMuted;

    filePath = _filePath;

    if ( !isVideo ) {

      try {

        image = loadImage(filePath);

      } catch ( Exception e ) {
        logger.error("Map: Error loading image map");
        logger.error(ExceptionUtils.getStackTrace(e));
        clear();
        return false;
      }

      if ( getWidth() <= 0 || getHeight() <= 0 ) {

        logger.error("Map: Error loading image map");
        clear();
        return false;

      }

      fitToScreen = _fitToScreen;
      if ( fitToScreen )
        fitToScreen();

      logger.info("Map: Image map loaded");

    } else {

      maxTries = 5;
      sleepTimeMillis = 1000;

      triesCount = 0;
      while ( true ) {

        try {

          video = new Movie(sketch, filePath);
          video.frameRate(30);

          if ( isMuted )
            muteVideo();

          video.loop();

          break;

        } catch ( Exception e ) {

          logger.error("Map: Error loading and starting video map");

          triesCount += 1;
          if ( triesCount == maxTries ) {

            clear();
            return false;

          } else {

            delay(sleepTimeMillis);
            logger.error("Map: Retrying...");

          }

        }

      }

      triesCount = 0;
      while ( true ) {

        if ( getWidth() > 0 && getHeight() > 0 ) {

          break;

        } else {

          logger.warning("Map: Video map returned zero width/height. Waiting to retry...");
          delay(sleepTimeMillis);

        }

        triesCount += 1;
        if ( triesCount == maxTries ) {

          logger.warning("Map: Error loading and starting video map");
          clear();
          return false;

        }

      }

      logger.info("Map: Video map loaded");

    }

    panX = panToX = 0;
    panY = panToY = 0;
    scale = toScale = 1;

    set = true;

    return true;

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

    if ( toScale >= 2 && mouseWheelAmount < 0 )
      return;
    if ( toScale <= 0.5 && mouseWheelAmount > 0 )
      return;

    float zoom = -mouseWheelAmount * .05;
    panToX -= zoom * (_mouseX - panToX);
    panToY -= zoom * (_mouseY - panToY);
    toScale *= zoom+1;

  }

  void fitToScreen() {

    if ( isVideo )
      return;

    float widthRatio = image.width / float(canvas.width);
    float heightRatio = image.height / float(canvas.height);
    if ( widthRatio > heightRatio )
      image.resize(canvas.width, 0);
    else
      image.resize(0, canvas.height);

  }

  // Maps a point in canvas to a point in the map. For example,
  // considering a 100x100 map centralized in a 200x200 canvas,
  // point 100,100 in the canvas would be mapped to point 50,50
  // in the map.
  Point mapCanvasToMap(Point canvasPoint) {

    Point mapPoint = new Point();
    float widthRatio, heightRatio;
    int widthDiff, heightDiff;

    // Ratio between map and canvas, to check if map fits into canvas,
    // is taller and wider, etc
    widthRatio = getWidth() / float(canvas.width);
    heightRatio = getHeight() / float(canvas.height);

    // Absolute difference between canvas and map sizes
    widthDiff = abs(canvas.width - getWidth());
    heightDiff = abs(canvas.height - getHeight());

    // Map fits into canvas
    if ( widthRatio <= 1 && heightRatio <= 1 ) {
      mapPoint.x = canvasPoint.x - widthDiff/2;
      mapPoint.y = canvasPoint.y - heightDiff/2;
    }

    // Map is taller and wider
    else if ( widthRatio > 1 && heightRatio > 1 ) {
      mapPoint.x = canvasPoint.x + widthDiff/2;
      mapPoint.y = canvasPoint.y + heightDiff/2;
    }

    // Map is taller than canvas - portrait
    else if ( widthRatio < heightRatio ) {
      mapPoint.x = canvasPoint.x - widthDiff/2;
      mapPoint.y = canvasPoint.y + heightDiff/2;
    }

    // Map is wider than canvas - landscape
    else if ( widthRatio > heightRatio ) {
      mapPoint.x = canvasPoint.x + widthDiff/2;
      mapPoint.y = canvasPoint.y - heightDiff/2;
    }

    logger.trace("Map: Canvas point " + canvasPoint + " mapped to map point " + mapPoint + "");

    return mapPoint;

  }

  // Similar to mapCanvasToMap, but maps a point in the map to a
  // point in canvas.
  Point mapMapToCanvas(Point mapPoint) {

    Point canvasPoint = new Point();
    float widthRatio, heightRatio;
    int widthDiff, heightDiff;

    // Ratio between map and canvas, to check if map fits into canvas,
    // is taller and wider, etc
    widthRatio = getWidth() / float(canvas.width);
    heightRatio = getHeight() / float(canvas.height);

    // Absolute difference between canvas and map sizes
    widthDiff = abs(canvas.width - getWidth());
    heightDiff = abs(canvas.height - getHeight());

    // Map fits into canvas
    if ( widthRatio <= 1 && heightRatio <= 1 ) {
      canvasPoint.x = mapPoint.x + widthDiff/2;
      canvasPoint.y = mapPoint.y + heightDiff/2;
    }

    // Map is taller and wider
    else if ( widthRatio > 1 && heightRatio > 1 ) {
      canvasPoint.x = mapPoint.x - widthDiff/2;
      canvasPoint.y = mapPoint.y - heightDiff/2;
    }

    // Map is taller than canvas - portrait
    else if ( widthRatio < heightRatio ) {
      canvasPoint.x = mapPoint.x + widthDiff/2;
      canvasPoint.y = mapPoint.y - heightDiff/2;
    }

    // Map is wider than canvas - landscape
    else if ( widthRatio > heightRatio ) {
      canvasPoint.x = mapPoint.x - widthDiff/2;
      canvasPoint.y = mapPoint.y + heightDiff/2;
    }

    logger.trace("Map: Map point " + mapPoint + " mapped to canvas point " + canvasPoint + "");

    return canvasPoint;

  }

  int getCanvasMapWidthDiff() {
    return canvas.width - getWidth();
  }

  int getCanvasMapHeightDiff() {
    return canvas.height - getHeight();
  }

  void clear() {

    if ( set && isVideo && video != null ) {

      try {

        video.stop();
        video.dispose();

      } catch ( Exception e ) {
        logger.error("Map: Error stopping and disposing of video");
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
    logger.info("Map: Map panning toggled " + (panEnabled ? "on" : "off"));
  }

  void toggleZoom() {
    zoomEnabled = !zoomEnabled;
    logger.info("Map: Map zooming toggled " + (zoomEnabled ? "on" : "off"));
  }

  boolean isPanEnabled() {
    return panEnabled;
  }

  void toggleMute() {

    isMuted = !isMuted;
    muteVideo();

    logger.info("Map: Video sound toggled " + (isMuted ? "off" : "on"));

  }

  void muteVideo() {

    int volume;

    if ( isVideo && video != null ) {

      volume = isMuted ? 0 : 1;

      try {

        video.volume(volume);

      } catch ( Exception e ) {
        logger.error("Map: Error setting video volume");
      }

    }

  }

  void setLogo(String _logoFilePath, String _logoLink) {
    logoFilePath = _logoFilePath;
    logoLink = _logoLink;
  }

  String getLogoFilePath() {
    return logoFilePath;
  }

  String getLogoLink() {
    return logoLink;
  }

}
