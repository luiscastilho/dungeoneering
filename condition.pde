class Condition {
  
  static final int maxConditionsPerToken = 4;
  
  PGraphics canvas;
  
  String name;
  
  String imagePath;
  PImage image;
  
  boolean disablesTarget;
  
  boolean centered;
  
  int maxConditionRows, maxConditionColumns;
  
  Condition(PGraphics _canvas, String _name, String _imagePath, int cellWidth, int cellHeight, boolean _disablesTarget, boolean _centered) {
    
    canvas = _canvas;
    
    name = _name;
    
    imagePath = _imagePath;
    image = loadImage(imagePath);
    
    disablesTarget = _disablesTarget;
    
    centered = _centered;
    
    if ( centered ) {
      
      image.resize(cellWidth, cellHeight);
      
    } else {
      
      maxConditionRows = maxConditionColumns = ceil(sqrt(maxConditionsPerToken));
      image.resize(cellWidth/maxConditionColumns, cellHeight/maxConditionRows);
      
    }
    
  }
  
  void draw(Cell tokenCell, int position) {
    
    if ( image == null )
      return;
    
    if ( centered ) {
      
      canvas.imageMode(CENTER);
      canvas.image(image, tokenCell.getCenter().x, tokenCell.getCenter().y);
      
    } else {
      
      if ( position > maxConditionsPerToken-1 )
        return;
      
      int cellLowRightCornerX = tokenCell.getCenter().x + tokenCell.getCellWidth()/2;
      int cellLowRightCornerY = tokenCell.getCenter().y + tokenCell.getCellHeight()/2;
      
      int conditionRow = (position / maxConditionColumns) + 1;
      int conditionColumn = (position % maxConditionColumns) + 1;
      
      int conditionX = cellLowRightCornerX - image.width * conditionColumn;
      int conditionY = cellLowRightCornerY - image.height * conditionRow;
      
      canvas.imageMode(CORNER);
      canvas.image(image, conditionX, conditionY);
      
    }
    
  }
  
  String getName() {
    return name;
  }
  
  boolean disablesTarget() {
    return disablesTarget;
  }
  
}
