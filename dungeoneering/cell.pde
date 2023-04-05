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

class Cell {

  PGraphics canvas;

  int centerX, centerY;

  int cellWidth, cellHeight;

  int row, column;

  Cell(PGraphics _canvas, int _centerX, int _centerY, int _width, int _height, int _row, int _column) {

    canvas = _canvas;

    centerX = _centerX;
    centerY = _centerY;

    cellWidth = _width;
    cellHeight = _height;

    row = _row;
    column = _column;

  }

  void draw(color gridColor) {

    canvas.rectMode(CENTER);
    canvas.stroke(gridColor);
    canvas.strokeWeight(1);
    canvas.noFill();
    canvas.rect(centerX, centerY, cellWidth, cellHeight);

  }

  boolean isInside(int x, int y) {

    int startX, startY, screenStartX, screenStartY;
    int endX, endY, screenEndX, screenEndY;

    startX = centerX - round(cellWidth/2f);
    endX = startX + cellWidth;
    startY = centerY - round(cellHeight/2f);
    endY = startY + cellHeight;

    screenStartX = round(canvas.screenX(startX, startY));
    screenStartY = round(canvas.screenY(startX, startY));
    screenEndX = round(canvas.screenX(endX, endY));
    screenEndY = round(canvas.screenY(endX, endY));

    if ( x >= screenStartX && x <= screenEndX && y >= screenStartY && y <= screenEndY )
      return true;

    return false;

  }

  Point getCenter() {
    return new Point(centerX, centerY);
  }

  int getRow() {
    return row;
  }

  int getColumn() {
    return column;
  }

  int getCellWidth() {
    return cellWidth;
  }

  int getCellHeight() {
    return cellHeight;
  }

  @Override
  public int hashCode() {
    return new HashCodeBuilder(11, 31).
    append(centerX).
    append(centerY).
    append(cellWidth).
    append(cellHeight).
    append(row).
    append(column).
    toHashCode();
  }

  @Override
  public boolean equals(Object o) {
    if ( o == this )
        return true;
    if ( !(o instanceof Cell) )
        return false;
    Cell other = (Cell)o;
    boolean samePosition = (this.getRow() == other.getRow() && this.getColumn() == other.getColumn());
    boolean sameCenter = (this.getCenter().equals(other.getCenter()));
    boolean sameDimensions = (this.getCellWidth() == other.getCellWidth() && this.getCellHeight() == other.getCellHeight());
    return samePosition && sameCenter && sameDimensions;
  }

}
