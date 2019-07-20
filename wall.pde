class Wall {
  
  PGraphics canvas;
  
  ArrayList<PVector> vertexes;
  
  PVector minVertex;
  PVector maxVertex;
  PVector minVertexDiff;
  PVector maxVertexDiff;
  
  int magnitude;
  
  Wall(PGraphics _canvas) {
    
    canvas = _canvas;
    
    vertexes = new ArrayList<PVector>();
    
    minVertex = null;
    maxVertex = null;
    minVertexDiff = null;
    maxVertexDiff = null;
    
    magnitude = 60000;
    
  }
  
  void draw(color wallColor, int wallWidth) {
    
    canvas.stroke(wallColor);
    canvas.strokeWeight(wallWidth);
    canvas.strokeCap(SQUARE);
    canvas.noFill();
    canvas.beginShape(LINES);
    for ( PVector vertex: vertexes )
      canvas.vertex(vertex.x, vertex.y);
    canvas.endShape();
    
  }
  
  boolean reachedBy(Light light) {
    
    float distance;
    
    for ( PVector v: vertexes ) {
      distance = light.getPosition().dist(v);
      if ( distance < light.getDimLightRadius() || distance < light.getBrightLightRadius() )
        return true;
    }
    
    return false;
    
  }
  
  // Source: stackoverflow.com/questions/13242738/how-can-i-find-the-general-form-equation-of-a-line-from-two-points
  // Source: www.geeksforgeeks.org/check-line-touches-intersects-circle
  boolean intersectedBy(Light light) {
    
    boolean intersects = false;
    
    PVector lightCenter = light.getPosition();
    int lightRadius = max(light.getBrightLightRadius(), light.getDimLightRadius());
    
    for ( PVector i: vertexes ) {
      
      for ( PVector j: vertexes ) {
        
        if ( i.equals(j) )
          continue;
        
        // calculate line defined by these two vertexes 
        float lineA = i.y - j.y;
        float lineB = j.x - i.x;
        float lineC = (i.x - j.x) * i.y + (j.y - i.y) * i.x;
        
        // calculate distance between this line and the light radius
        double dist = (Math.abs(lineA * lightCenter.x + lineB * lightCenter.y + lineC)) /  
                        Math.sqrt(lineA * lineA + lineB * lineB); 
        
        // check if light radius is greater than or equals the calculated distance
        intersects = lightRadius >= dist;
        
        if ( intersects )
          break;
        
      }
      
      if ( intersects )
        break;
      
    }
    
    return intersects;
    
  }
  
  void calculateShadows(Light light, PGraphics shadows) {
    
    float angle = 0;
    
    for ( PVector i: vertexes ) {
      for ( PVector j: vertexes ) {
        
        if ( i.equals(j) )
          continue;
        
        PVector iDiff = PVector.sub(i, light.getPosition());
        PVector jDiff = PVector.sub(j, light.getPosition());
        
        if ( PVector.angleBetween(iDiff, jDiff) > angle ) {
          angle = PVector.angleBetween(iDiff, jDiff);
          minVertex = i;
          maxVertex = j;
          minVertexDiff = iDiff;
          maxVertexDiff = jDiff;
        }
        
      }
    }
    
    minVertexDiff.setMag(magnitude);
    maxVertexDiff.setMag(magnitude);
    
    shadows.noStroke();
    shadows.fill(0);
    shadows.beginShape();
    shadows.vertex(minVertex.x, minVertex.y);
    shadows.vertex(minVertex.x+minVertexDiff.x, minVertex.y+minVertexDiff.y);
    shadows.vertex(maxVertex.x+maxVertexDiff.x, maxVertex.y+maxVertexDiff.y);
    shadows.vertex(maxVertex.x, maxVertex.y);
    shadows.endShape();
    
  }
  
  void addVertex(int x, int y) {
    
    vertexes.add(new PVector(x, y));
    
  }
  
  boolean isSet() {
    
    return vertexes.size() > 1;
    
  }
  
  ArrayList<PVector> getVertexes() {
    return vertexes;
  }
  
}
