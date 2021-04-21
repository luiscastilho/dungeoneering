class Size {
  
  String name;
  
  float resizeFactor;
  
  boolean centered;
  
  Size(String _name, float _resizeFactor, boolean _centered) {
    
    name = _name;
    resizeFactor = _resizeFactor;
    centered = _centered;
    
  }
  
  String getName() {
    return name;
  }
  
  float getResizeFactor() {
    return resizeFactor;
  }
  
  boolean isCentered() {
    return centered;
  }
  
}
