class Door extends Wall {

  boolean closed;

  Door(PGraphics _canvas, UUID _id) {
    super(_canvas, _id);

    closed = true;

  }

  void draw(color closedDoorColor, color openDoorColor, int doorWidth) {

    if ( closed )
      super.draw(closedDoorColor, doorWidth);
    else
      super.draw(openDoorColor, doorWidth);

  }

  void calculateShadows(Light light, PGraphics shadows) {

    if ( closed )
      super.calculateShadows(light, shadows);

  }

  void toggle() {
    closed = !closed;
  }

  boolean getClosed() {
    return closed;
  }

  void setClosed(boolean _closed) {
    closed = _closed;
  }

}
