// dungeoneering - Virtual tabletop (VTT) for local, in-person RPG sessions
// Copyright  (C) 2019-2023  Luis Castilho

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

class Wall {

  UUID id;

  PGraphics canvas;

  CopyOnWriteArrayList<PVector> canvasVertexes;
  CopyOnWriteArrayList<PVector> mapVertexes;

  PVector minVertex;
  PVector maxVertex;
  PVector minVertexDiff;
  PVector maxVertexDiff;

  int magnitude;

  Wall(PGraphics _canvas, UUID _id) {

    canvas = _canvas;

    id = _id;

    canvasVertexes = new CopyOnWriteArrayList<PVector>();
    mapVertexes = new CopyOnWriteArrayList<PVector>();

    minVertex = null;
    maxVertex = null;
    minVertexDiff = null;
    maxVertexDiff = null;

    magnitude = 100000;

  }

  void draw(color wallColor, int wallWidth) {

    canvas.stroke(wallColor);
    canvas.strokeWeight(wallWidth);
    canvas.strokeCap(SQUARE);
    canvas.noFill();
    canvas.beginShape(LINES);
    for ( PVector vertex: canvasVertexes )
      canvas.vertex(vertex.x, vertex.y);
    canvas.endShape();

  }

  void drawNewEdge(color wallColor, int wallWidth, int newVertexX, int newVertexY) {

    if ( canvasVertexes.isEmpty() )
      return;

    PVector lastVertex = canvasVertexes.get(canvasVertexes.size() - 1);

    canvas.stroke(wallColor);
    canvas.strokeWeight(wallWidth);
    canvas.strokeCap(SQUARE);
    canvas.noFill();
    canvas.beginShape(LINES);
    canvas.vertex(lastVertex.x, lastVertex.y);
    canvas.vertex(newVertexX, newVertexY);
    canvas.endShape();

  }

  boolean reachedBy(Light light) {

    if ( light == null )
      return false;

    float distance;

    for ( PVector v: canvasVertexes ) {
      distance = light.getPosition().dist(v);
      if ( distance < light.getDimLightRadius() || distance < light.getBrightLightRadius() )
        return true;
    }

    return false;

  }

  // Source: stackoverflow.com/questions/13242738/how-can-i-find-the-general-form-equation-of-a-line-from-two-points
  // Source: www.geeksforgeeks.org/check-line-touches-intersects-circle
  boolean intersectedBy(Light light) {

    if ( light == null )
      return false;

    boolean intersects = false;

    PVector lightCenter = light.getPosition();
    int lightRadius = max(light.getBrightLightRadius(), light.getDimLightRadius());

    for ( PVector i: canvasVertexes ) {

      for ( PVector j: canvasVertexes ) {

        if ( i.equals(j) )
          continue;

        // Calculate line defined by these two vertexes
        float lineA = i.y - j.y;
        float lineB = j.x - i.x;
        float lineC = (i.x - j.x) * i.y + (j.y - i.y) * i.x;

        // Calculate distance between this line and the light center
        double dist = (Math.abs(lineA * lightCenter.x + lineB * lightCenter.y + lineC)) /
                        Math.sqrt(lineA * lineA + lineB * lineB);

        // Check if light radius is greater than or equals the calculated distance
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

    if ( light == null || shadows == null )
      return;

    float angle = 0;

    for ( PVector i: canvasVertexes ) {
      for ( PVector j: canvasVertexes ) {

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

    if ( minVertex == null || maxVertex == null || minVertexDiff == null || maxVertexDiff == null )
      return;

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

  void addVertex(int canvasX, int canvasY, int mapX, int mapY) {

    canvasVertexes.add(new PVector(canvasX, canvasY));
    mapVertexes.add(new PVector(mapX, mapY));

  }

  boolean isSet() {

    return canvasVertexes.size() > 1;

  }

  CopyOnWriteArrayList<PVector> getCanvasVertexes() {
    return canvasVertexes;
  }

  CopyOnWriteArrayList<PVector> getMapVertexes() {
    return mapVertexes;
  }

  UUID getId() {
    return id;
  }

  String getStringId() {
    return id.toString();
  }

}
