// dungeoneering - Virtual tabletop (VTT) for local, in-person RPG sessions
// Copyright  (C) 2019-2021  Luis Castilho

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

  boolean sizeIsSet;

  Condition(PGraphics _canvas, String _name, String _imagePath, boolean _disablesTarget, boolean _hidesTarget, boolean _centered) {

    canvas = _canvas;

    name = _name;

    imagePath = _imagePath;
    image = loadImage(imagePath);

    disablesTarget = _disablesTarget;
    hidesTarget = _hidesTarget;

    centered = _centered;

    sizeIsSet = false;

  }

  void setSize(Size _size, int cellWidth, int cellHeight) {

    size = _size;

    // Must be a square number: 4, 9, 16, 25
    switch ( size.getName() ) {
      case "Tiny":
      case "Small":
      case "Medium":
        maxConditionsPerToken = 4;
        break;
      case "Large":
        // Three extra cells occupied:
        // X 1
        // 2 3
        maxConditionsPerToken = 9;
        break;
      case "Huge":
        // Eight extra cells occupied:
        // 1 2 3
        // 4 X 5
        // 6 7 8
        maxConditionsPerToken = 16;
        break;
      case "Gargantuan":
        // Fifteen extra cells occupied:
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

    sizeIsSet = true;

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
          // Three extra cells occupied:
          // X 1
          // 2 3
          canvas.image(image, tokenCellCenterX + tokenCellWidth/2f, tokenCellCenterY + tokenCellHeight/2f);
          break;
        case "Huge":
          // Eight extra cells occupied:
          // 1 2 3
          // 4 X 5
          // 6 7 8
          canvas.image(image, tokenCellCenterX, tokenCellCenterY);
          break;
        case "Gargantuan":
          // Fifteen extra cells occupied:
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
          // Three extra cells occupied:
          // X 1
          // 2 3
          tokenLowRightCornerX = tokenCellCenterX + tokenCellWidth/2 + tokenCellWidth;
          tokenLowRightCornerY = tokenCellCenterY + tokenCellHeight/2 + tokenCellHeight;
          break;
        case "Huge":
          // Eight extra cells occupied:
          // 1 2 3
          // 4 X 5
          // 6 7 8
          tokenLowRightCornerX = tokenCellCenterX + tokenCellWidth/2 + tokenCellWidth;
          tokenLowRightCornerY = tokenCellCenterY + tokenCellHeight/2 + tokenCellHeight;
          break;
        case "Gargantuan":
          // Fifteen extra cells occupied:
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

  Condition copy() {
    return new Condition(
      canvas, name, imagePath, disablesTarget, hidesTarget, centered
    );
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
  public boolean equals(Object o) {
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
