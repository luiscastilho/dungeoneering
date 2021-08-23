class Condition {

  PGraphics canvas;

  String name;

  String imagePath;
  PImage image;

  boolean disablesTarget;
  boolean hidesTarget;

  boolean centered;

  int maxConditionsPerToken;
  int maxConditionRows, maxConditionColumns;

  Size size;

  Condition(PGraphics _canvas, String _name, String _imagePath, int cellWidth, int cellHeight, boolean _disablesTarget, boolean _hidesTarget, boolean _centered, Size _size) {

    canvas = _canvas;

    name = _name;

    imagePath = _imagePath;
    image = loadImage(imagePath);

    disablesTarget = _disablesTarget;
    hidesTarget = _hidesTarget;

    centered = _centered;

    size = _size;

    // must be a square number: 4, 9, 16, 25
    switch ( size.getName() ) {
      case "Tiny":
      case "Small":
      case "Medium":
        maxConditionsPerToken = 4;
        break;
      case "Large":
        // three extra cells occupied:
        // X 1
        // 2 3
        maxConditionsPerToken = 9;
        break;
      case "Huge":
        // eight extra cells occupied:
        // 1 2 3
        // 4 X 5
        // 6 7 8
        maxConditionsPerToken = 16;
        break;
      case "Gargantuan":
        // fifteen extra cells occupied:
        //  X  1  2  3
        //  4  5  6  7
        //  8  9 10 11
        // 12 13 14 15
        maxConditionsPerToken = 25;
        break;
    }

    if ( centered ) {

      image.resize(cellWidth * round(size.getResizeFactor()), cellHeight * round(size.getResizeFactor()));

    } else {

      maxConditionRows = maxConditionColumns = ceil(sqrt(maxConditionsPerToken));
      image.resize(cellWidth/maxConditionColumns * round(size.getResizeFactor()), cellHeight/maxConditionRows * round(size.getResizeFactor()));

    }

  }

  void draw(Cell tokenCell, int position) {

    if ( image == null )
      return;
    if ( tokenCell == null )
      return;

    int tokenCellCenterX = tokenCell.getCenter().x;
    int tokenCellCenterY = tokenCell.getCenter().y;
    int tokenCellWidth = tokenCell.getCellWidth();
    int tokenCellHeight = tokenCell.getCellHeight();

    if ( centered ) {

      canvas.imageMode(CENTER);

      switch ( size.getName() ) {
        case "Tiny":
        case "Small":
        case "Medium":
          canvas.image(image, tokenCellCenterX, tokenCellCenterY);
          break;
        case "Large":
          // three extra cells occupied:
          // X 1
          // 2 3
          canvas.image(image, tokenCellCenterX + tokenCellWidth/2f, tokenCellCenterY + tokenCellHeight/2f);
          break;
        case "Huge":
          // eight extra cells occupied:
          // 1 2 3
          // 4 X 5
          // 6 7 8
          canvas.image(image, tokenCellCenterX, tokenCellCenterY);
          break;
        case "Gargantuan":
          // fifteen extra cells occupied:
          //  X  1  2  3
          //  4  5  6  7
          //  8  9 10 11
          // 12 13 14 15
          canvas.image(image, tokenCellCenterX + tokenCellWidth + tokenCellWidth/2f, tokenCellCenterY + tokenCellHeight + tokenCellHeight/2f);
          break;
      }

    } else {

      if ( position > maxConditionsPerToken-1 )
        return;

      int tokenLowRightCornerX = 0;
      int tokenLowRightCornerY = 0;

      switch ( size.getName() ) {
        case "Tiny":
        case "Small":
        case "Medium":
          tokenLowRightCornerX = tokenCellCenterX + tokenCellWidth/2;
          tokenLowRightCornerY = tokenCellCenterY + tokenCellHeight/2;
          break;
        case "Large":
          // three extra cells occupied:
          // X 1
          // 2 3
          tokenLowRightCornerX = tokenCellCenterX + tokenCellWidth/2 + tokenCellWidth;
          tokenLowRightCornerY = tokenCellCenterY + tokenCellHeight/2 + tokenCellHeight;
          break;
        case "Huge":
          // eight extra cells occupied:
          // 1 2 3
          // 4 X 5
          // 6 7 8
          tokenLowRightCornerX = tokenCellCenterX + tokenCellWidth/2 + tokenCellWidth;
          tokenLowRightCornerY = tokenCellCenterY + tokenCellHeight/2 + tokenCellHeight;
          break;
        case "Gargantuan":
          // fifteen extra cells occupied:
          //  X  1  2  3
          //  4  5  6  7
          //  8  9 10 11
          // 12 13 14 15
          tokenLowRightCornerX = tokenCellCenterX + tokenCellWidth/2 + tokenCellWidth*3;
          tokenLowRightCornerY = tokenCellCenterY + tokenCellHeight/2 + tokenCellHeight*3;
          break;
      }

      int conditionRow = (position / maxConditionColumns) + 1;
      int conditionColumn = (position % maxConditionColumns) + 1;

      int conditionX = tokenLowRightCornerX - image.width * conditionColumn;
      int conditionY = tokenLowRightCornerY - image.height * conditionRow;

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

  boolean hidesTarget() {
    return hidesTarget;
  }

  boolean isCentered() {
    return centered;
  }

  @Override
  public int hashCode() {
    return new HashCodeBuilder(13, 31).
    append(name).
    append(imagePath).
    append(disablesTarget).
    append(hidesTarget).
    append(centered).
    append(size.getName()).
    append(maxConditionsPerToken).
    toHashCode();
  }

  @Override
  boolean equals(Object o) {
    if ( o == this )
        return true;
    if ( !(o instanceof Condition) )
        return false;
    Condition other = (Condition)o;
    boolean sameName = (this.getName().equals(other.getName()));
    boolean sameDisablesTargetProperty = (this.disablesTarget() == other.disablesTarget());
    boolean sameHidesTargetProperty = (this.hidesTarget() == other.hidesTarget());
    boolean sameCenteredProperty = (this.isCentered() == other.isCentered());
    return sameName && sameDisablesTargetProperty && sameHidesTargetProperty && sameCenteredProperty;
  }

}
