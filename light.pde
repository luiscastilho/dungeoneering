class Light {
  
  PVector position;
  
  String name;
  
  color brightLightColor;
  int brightLightRadius;
  
  color dimLightColor;
  int dimLightRadius;
  
  Light(String _name, int _brightLightRadius, int _dimLightRadius) {
    
    position = new PVector();
    
    name = _name;
    
    brightLightColor = 255;
    brightLightRadius = _brightLightRadius;
    
    dimLightColor = 47;
    dimLightRadius = _dimLightRadius;
    
  }
  
  void draw(PGraphics shadows) {
    
    shadows.noStroke();
    shadows.fill(dimLightColor);
    shadows.circle(position.x, position.y, dimLightRadius*2);
    
    shadows.noStroke();
    shadows.fill(brightLightColor);
    shadows.circle(position.x, position.y, brightLightRadius*2);
    
  }
  
  void setPosition(int x, int y) {
    
    position = new PVector(x, y);
    
  }
  
  PVector getPosition() {
    return position;
  }
  
  String getName() {
    return name;
  }
  
  int getBrightLightRadius() {
    return brightLightRadius;
  }
  
  int getDimLightRadius() {
    return dimLightRadius;
  }
  
}
