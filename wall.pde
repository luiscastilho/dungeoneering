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
    canvas.beginShape();
    for ( PVector vertex: vertexes )
      canvas.vertex(vertex.x, vertex.y);
    canvas.endShape();
    
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
