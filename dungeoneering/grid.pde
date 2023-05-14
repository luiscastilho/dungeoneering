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

class Grid {

  PGraphics canvas;

  Map map;

  ArrayList<ArrayList<Cell>> mapGrid;
  ArrayList<ArrayList<Cell>> canvasGrid;

  boolean set;

  int cellWidth, cellHeight;
  int rowsCount, columnsCount;

  boolean drawGrid;
  color gridColor;

  SimpleIntegerProperty gridVersion;

  Grid(PGraphics _canvas, Map _map) {

    canvas = _canvas;

    map = _map;

    mapGrid = new ArrayList<ArrayList<Cell>>();
    canvasGrid = new ArrayList<ArrayList<Cell>>();

    set = false;

    cellWidth = cellHeight = 0;
    rowsCount = columnsCount = 0;

    drawGrid = false;
    gridColor = color(0, 159);

    gridVersion = new SimpleIntegerProperty(1);

  }

  void draw() {

    if ( !drawGrid )
      return;

    for ( ArrayList<Cell> row: canvasGrid )
      for ( Cell cell: row )
        cell.draw(gridColor);

  }

  // Setup the map grid using previously saved coordinates for the first and
  // last map grid cells, as well as the cells' width and height.
  void setup(Point _mapFirstCenter, Point _mapLastCenter, int _cellWidth, int _cellHeight, boolean _drawGrid) {

    // Abort if cell size is smaller than 20x20
    if ( _cellWidth < 20 || _cellHeight < 20 )
      return;

    Point currentCenter = new Point();
    int rowIndex, columnIndex;
    int canvasMapWidthDiff, canvasMapHeightDiff;

    cellWidth = _cellWidth;
    cellHeight = _cellHeight;

    // Setup map grid - grid with map coordinates

    // For each map coordinates from first to last, create a cell and add it to map grid
    currentCenter.y = _mapFirstCenter.y;
    rowIndex = 0;
    while ( currentCenter.y <= _mapLastCenter.y ) {

      ArrayList<Cell> row = new ArrayList<Cell>();
      currentCenter.x = _mapFirstCenter.x;

      columnIndex = 0;
      while ( currentCenter.x <= _mapLastCenter.x ) {
        row.add(new Cell(canvas, currentCenter.x, currentCenter.y, cellWidth, cellHeight, rowIndex, columnIndex));
        currentCenter.x += cellWidth;
        columnIndex += 1;
      }

      mapGrid.add(row);
      currentCenter.y += cellHeight;
      rowIndex += 1;

    }

    // Setup canvas grid - grid with canvas coordinates

    // Get size difference to be added to map grid cell coordinates
    canvasMapWidthDiff = round(map.getCanvasMapWidthDiff()/2f);
    canvasMapHeightDiff = round(map.getCanvasMapHeightDiff()/2f);

    // For each cell in the map grid
    rowIndex = columnIndex = 0;
    for ( ArrayList<Cell> mapRow: mapGrid ) {
      ArrayList<Cell> canvasRow = new ArrayList<Cell>();
      columnIndex = 0;
      for ( Cell mapCell: mapRow ) {
        Point mapCellCenter = mapCell.getCenter();
        // Add a cell in the canvas grid with the same coordinates plus the size difference between canvas and map
        canvasRow.add(new Cell(canvas, mapCellCenter.x + canvasMapWidthDiff, mapCellCenter.y + canvasMapHeightDiff, cellWidth, cellHeight, rowIndex, columnIndex));
        columnIndex += 1;
      }
      canvasGrid.add(canvasRow);
      rowIndex += 1;
    }

    // Update rows and columns count
    rowsCount = rowIndex;
    columnsCount = columnIndex;

    drawGrid = _drawGrid;

    set = true;

  }

  // Setup the map grid using helper points with map coordinates. After that,
  // setup the canvas grid - the one that's actually drawn - using the map grid
  // and adding to it's coordinates the canvas-map size difference.
  void setupFromHelper(Point helperFirstCorner, Point helperSecondCorner) {

    // Abort if cell size is smaller than 20x20
    if ( abs(helperFirstCorner.x-helperSecondCorner.x) < 60 || abs(helperFirstCorner.y-helperSecondCorner.y) < 60 )
      return;

    int helperWidth, helperHeight;
    Point firstCorner = new Point();
    Point mapFirstCenter = new Point();
    Point currentCenter = new Point();
    int rowIndex, columnIndex;
    int canvasMapWidthDiff, canvasMapHeightDiff;

    // Calculate helper size
    helperWidth = abs(helperFirstCorner.x-helperSecondCorner.x);
    helperHeight = abs(helperFirstCorner.y-helperSecondCorner.y);

    // Calculate cell size
    cellWidth = round(helperWidth/3f);
    cellHeight = round(helperHeight/3f);

    logger.trace("Grid: setupFromHelper(): Cell size: " + cellWidth + "x" + cellHeight);

    // Based on helper top corner, find grid's top corner x coordinate
    firstCorner.x = min(helperFirstCorner.x, helperSecondCorner.x);
    while ( firstCorner.x - cellWidth > 0 )
      firstCorner.x -= cellWidth;

    // Based on helper top corner, find grid's top corner y coordinate
    firstCorner.y = min(helperFirstCorner.y, helperSecondCorner.y);
    while ( firstCorner.y - cellHeight > 0 )
      firstCorner.y -= cellHeight;

    // Based on grid's top corner, calculate grid's first cell center
    mapFirstCenter = new Point(
      firstCorner.x + round(cellWidth/2f),
      firstCorner.y + round(cellHeight/2f)
    );

    logger.trace("Grid: setupFromHelper(): First cell center in map: " + mapFirstCenter);

    // Setup map grid - grid with map coordinates

    // Continue while the current cell center y coordinate plus half the cell height is still inside the map
    currentCenter.y = mapFirstCenter.y;
    rowIndex = columnIndex = 0;
    while ( currentCenter.y + round(cellHeight/2f) <= map.getHeight() ) {

      // Create a row for cells with this center y coordinate
      ArrayList<Cell> row = new ArrayList<Cell>();

      // Continue while the current cell center x coordinate plus half the cell width is still inside the map
      currentCenter.x = mapFirstCenter.x;
      columnIndex = 0;
      while ( currentCenter.x + round(cellWidth/2f) <= map.getWidth() ) {

        // Create a cell in the row created above
        row.add(new Cell(canvas, currentCenter.x, currentCenter.y, cellWidth, cellHeight, rowIndex, columnIndex));

        // Update the current cell center x coordinate
        currentCenter.x += cellWidth;

        // Update the current column index
        columnIndex += 1;

      }

      // Add populated row to grid
      mapGrid.add(row);

      // Update the current cell center y coordinate
      currentCenter.y += cellHeight;

      // Update the current row index
      rowIndex += 1;

    }

    // Setup canvas grid - grid with canvas coordinates

    // Get size difference to be added to map grid cell coordinates
    canvasMapWidthDiff = round(map.getCanvasMapWidthDiff()/2f);
    canvasMapHeightDiff = round(map.getCanvasMapHeightDiff()/2f);

    // For each cell in the map grid
    rowIndex = 0;
    for ( ArrayList<Cell> mapRow: mapGrid ) {
      ArrayList<Cell> canvasRow = new ArrayList<Cell>();
      columnIndex = 0;
      for ( Cell mapCell: mapRow ) {
        Point mapCellCenter = mapCell.getCenter();
        // Add a cell in the canvas grid with the same coordinates plus the size difference between canvas and map
        canvasRow.add(new Cell(canvas, mapCellCenter.x + canvasMapWidthDiff, mapCellCenter.y + canvasMapHeightDiff, cellWidth, cellHeight, rowIndex, columnIndex));
        columnIndex += 1;
      }
      canvasGrid.add(canvasRow);
      rowIndex += 1;
    }

    // Update rows and columns count
    rowsCount = rowIndex;
    columnsCount = columnIndex;

    set = true;

  }

  Cell getCellAt(int row, int column) {

    int rowCount, columnCount;

    rowCount = 0;
    for ( ArrayList<Cell> cellsRow: canvasGrid ) {

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

    for ( ArrayList<Cell> row: canvasGrid ) {
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

    mapGrid = new ArrayList<ArrayList<Cell>>();
    canvasGrid = new ArrayList<ArrayList<Cell>>();

    set = false;

    cellWidth = cellHeight = 0;
    rowsCount = columnsCount = 0;

    gridVersion.set(1);

    System.gc();

  }

  boolean isSet() {
    return set;
  }

  Point getMapGridFirstCellCenter() {

    if ( !set )
      return null;

    Cell firstCell = mapGrid.get(0).get(0);

    return new Point(firstCell.getCenter().x, firstCell.getCenter().y);

  }

  Point getMapGridLastCellCenter() {

    if ( !set )
      return null;

    Cell lastCell = mapGrid.get(rowsCount - 1).get(columnsCount - 1);

    return new Point(lastCell.getCenter().x, lastCell.getCenter().y);

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
    logger.info("Grid: toggleDrawGrid(): Grid " + (drawGrid ? "shown" : "hidden"));
  }

  void addSceneUpdateListener(ChangeListener<Number> _sceneUpdateListener) {
    logger.debug("Grid: addSceneUpdateListener(): Adding listener to grid version");
    gridVersion.addListener(_sceneUpdateListener);
  }

  void incrementGridVersion() {
    logger.trace("Grid: incrementGridVersion(): Incrementing grid version from " + gridVersion.getValue() + " to " + (gridVersion.getValue()+1));
    gridVersion.set(gridVersion.getValue() + 1);
  }

}
