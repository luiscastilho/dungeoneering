import java.awt.Point;

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
    int endX, endY, screenEndX, screenlEndY;
        
    startX = centerX - round(cellWidth/2f);
    endX = startX + cellWidth;
    startY = centerY - round(cellHeight/2f);
    endY = startY + cellHeight;
    
    screenStartX = round(canvas.screenX(startX, startY));
    screenStartY = round(canvas.screenY(startX, startY));
    screenEndX = round(canvas.screenX(endX, endY));
    screenlEndY = round(canvas.screenY(endX, endY));
    
    if ( x >= screenStartX && x <= screenEndX && y >= screenStartY && y <= screenlEndY )
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
  
}
