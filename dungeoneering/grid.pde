import java.awt.Point;

class Grid {

  PGraphics canvas;

  ArrayList<ArrayList<Cell>> grid;

  boolean set;

  int firstCenterX, firstCenterY;
  int lastCenterX, lastCenterY;
  int cellWidth, cellHeight;

  boolean drawGrid;
  color gridColor;

  Grid(PGraphics _canvas) {

    canvas = _canvas;

    grid = new ArrayList<ArrayList<Cell>>();

    set = false;

    firstCenterX = firstCenterY = 0;
    lastCenterX = lastCenterY = 0;
    cellWidth = cellHeight = 0;

    drawGrid = false;
    gridColor = color(0, 159);

  }

  void draw() {

    if ( !drawGrid )
      return;

    for ( ArrayList<Cell> row: grid )
      for ( Cell cell: row )
        cell.draw(gridColor);

  }

  void setup(int _firstCenterX, int _firstCenterY, int _lastCenterX, int _lastCenterY, int _cellWidth, int _cellHeight, boolean _drawGrid) {

    if ( abs(_firstCenterX-_lastCenterX) < 10 || abs(_firstCenterY-_lastCenterY) < 10 || _cellWidth < 10 || _cellHeight < 10 )
      return;

    int centerX, centerY;
    int rowCount, columnCount;

    firstCenterX = _firstCenterX;
    firstCenterY = _firstCenterY;
    lastCenterX = _lastCenterX;
    lastCenterY = _lastCenterY;
    cellWidth = _cellWidth;
    cellHeight = _cellHeight;

    centerY = firstCenterY;
    rowCount = 0;
    while ( centerY <= lastCenterY ) {

      ArrayList<Cell> row = new ArrayList<Cell>();
      centerX = firstCenterX;

      columnCount = 0;
      while ( centerX <= lastCenterX ) {
        row.add(new Cell(canvas, centerX, centerY, cellWidth, cellHeight, rowCount, columnCount));
        centerX += cellWidth;
        columnCount += 1;
      }

      grid.add(row);
      centerY += cellHeight;
      rowCount += 1;

    }

    drawGrid = _drawGrid;

    set = true;

  }

  void setupFromHelper(int x, int y, int toX, int toY, int mapWidth, int mapHeight, int xDiff, int yDiff) {

    if ( abs(x-toX) < 10 || abs(y-toY) < 10 )
      return;

    int helperWidth, helperHeight;
    int cornerX, cornerY;
    int centerX, centerY;
    int rowCount, columnCount;

    helperWidth = abs(x-toX);
    helperHeight = abs(y-toY);
    cellWidth = round(helperWidth/3f);
    cellHeight = round(helperHeight/3f);

    cornerX = min(x, toX);
    while ( cornerX - cellWidth > 0 )
      cornerX = cornerX - cellWidth;

    cornerY = min(y, toY);
    while ( cornerY - cellHeight > 0 )
      cornerY = cornerY - cellHeight;

    firstCenterX = cornerX + round(cellWidth/2f) + xDiff;
    firstCenterY = cornerY + round(cellHeight/2f) + yDiff;

    centerY = firstCenterY;
    rowCount = 0;
    while ( centerY <= mapHeight + yDiff - round(cellHeight/2f) ) {

      ArrayList<Cell> row = new ArrayList<Cell>();
      centerX = firstCenterX;

      columnCount = 0;
      while ( centerX <= mapWidth + xDiff - round(cellWidth/2f) ) {
        row.add(new Cell(canvas, centerX, centerY, cellWidth, cellHeight, rowCount, columnCount));
        lastCenterX = centerX;
        lastCenterY = centerY;
        centerX += cellWidth;
        columnCount += 1;
      }

      grid.add(row);
      centerY += cellHeight;
      rowCount += 1;

    }

    set = true;

  }

  Cell getCellAt(int row, int column) {

    int rowCount, columnCount;

    rowCount = 0;
    for ( ArrayList<Cell> cellsRow: grid ) {

      columnCount = 0;
      for ( Cell cell: cellsRow ) {

        if ( rowCount == row && columnCount == column )
          return cell;

        columnCount += 1;
      }

      rowCount += 1;
    }

    return null;

  }

  Cell getCellAt(Point position) {

    if ( !set )
      return null;

    int startX, startY, screenStartX, screenStartY;
    int endX, endY, screenEndX, screenEndY;

    for ( ArrayList<Cell> row: grid ) {
      for ( Cell cell: row ) {

        startX = cell.getCenter().x - round(cellWidth/2f);
        endX = startX + cellWidth;
        startY = cell.getCenter().y - round(cellHeight/2f);
        endY = startY + cellHeight;

        screenStartX = round(canvas.screenX(startX, startY));
        screenStartY = round(canvas.screenY(startX, startY));
        screenEndX = round(canvas.screenX(endX, endY));
        screenEndY = round(canvas.screenY(endX, endY));

        if ( position.x >= screenStartX && position.x <= screenEndX && position.y >= screenStartY && position.y <= screenEndY )
          return cell;

      }
    }

    return null;

  }

  void clear() {

    grid = new ArrayList<ArrayList<Cell>>();

    set = false;

    firstCenterX = firstCenterY = 0;
    lastCenterX = lastCenterY = 0;
    cellWidth = cellHeight = 0;

    System.gc();

  }

  ArrayList<ArrayList<Cell>> getCells() {
    return grid;
  }

  boolean isSet() {
    return set;
  }

  Point getFirstCellCenter() {
    return new Point(firstCenterX, firstCenterY);
  }

  Point getLastCellCenter() {
    return new Point(lastCenterX, lastCenterY);
  }

  int getCellWidth() {
    return cellWidth;
  }

  int getCellHeight() {
    return cellHeight;
  }

  boolean getDrawGrid() {
    return drawGrid;
  }

  void toggleDrawGrid() {
    drawGrid = !drawGrid;
  }

}
