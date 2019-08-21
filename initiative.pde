class Initiative {
  
  PGraphics canvas;
  
  ArrayList<InitiativeGroup> groups;
  
  int imagesSpacing;
  int xOffset, yOffset;
  int groupImageSize;
  int currentX, currentY;
  
  String title;
  color titleFontColor;
  int titleFontHeight;
  PFont titleFont;
  
  boolean drawInitiativeOrder;
  
  Initiative(PGraphics _canvas) {
    
    canvas = _canvas;
    
    groups = new ArrayList<InitiativeGroup>();
    
    imagesSpacing = 5;
    xOffset = yOffset = int(min(canvas.width, canvas.height) * 0.05);
    groupImageSize = 100;
    currentX = currentY = 0;
    
    title = "Initiative order:";
    titleFontColor = color(255);
    titleFontHeight = 12;
    titleFont = loadFont("fonts/ProcessingSansPro-Regular-12.vlw");
    
    drawInitiativeOrder = false;
    
  }
  
  void draw() {
    
    if ( !drawInitiativeOrder )
      return;
    if ( groups.isEmpty() )
      return;
    
    currentX = xOffset;
    currentY = canvas.height - yOffset - groupImageSize - imagesSpacing - titleFontHeight;
    canvas.textFont(titleFont);
    canvas.text(title, currentX, currentY);
    
    currentX = xOffset;
    currentY = canvas.height - yOffset - groupImageSize;
    for ( InitiativeGroup group: groups ) {
      
      canvas.fill(titleFontColor);
      canvas.imageMode(CORNER);
      canvas.image(group.image, currentX, currentY);
      currentX += groupImageSize + imagesSpacing;
      
    }
    
  }
  
  void clear() {
    
    groups = new ArrayList<InitiativeGroup>();
    
  }
  
  void addGroup(String groupName, String groupImagePath) {
    
    for ( InitiativeGroup group: groups )
      if ( group.name.equals(groupName) )
        return;
    
    groups.add(new InitiativeGroup(groupName, groupImagePath, groupImageSize));
    
  }
  
  void removeGroup(String groupName) {
    
    InitiativeGroup groupToRemove = null;
    
    for ( InitiativeGroup group: groups )
      if ( group.name.equals(groupName) )
        groupToRemove = group;
    
    if ( groupToRemove != null )
      groups.remove(groupToRemove);
    
  }
  
  boolean getDrawInitiativeOrder() {
    return drawInitiativeOrder;
  }
  
  void toggleDrawInitiativeOrder() {
    drawInitiativeOrder = !drawInitiativeOrder;
  }
  
  ArrayList<InitiativeGroup> getInitiativeGroups() {
    return groups;
  }
  
  boolean isInside(int x, int y) {
    
    boolean inside = false;
    
    float startX = xOffset;
    float startY = canvas.height - yOffset - groupImageSize;
    float endX = startX + groups.size() * ( groupImageSize + imagesSpacing );
    float endY = startY + groupImageSize;
    
    if ( x > startX && x < endX && y > startY && y < endY )
      inside = true;
    
    return inside;
    
  }
  
  AppStates changeInitiativeOrder(int _mouseX, boolean done) {
    
    InitiativeGroup group;
    
    group = getGroupBeingMoved();
    
    if ( group == null )
      group = getGroup(_mouseX);
    
    if ( group == null )
      return AppStates.idle;
    
    if ( !group.isBeingMoved() ) {
      group.setBeingMoved(true);
    }
    
    moveGroupTo(group, getIndexAt(_mouseX));
    
    if ( done ) {
      
      group.setBeingMoved(false);
      return AppStates.idle;
      
    }
    
    return AppStates.initiativeOrderSetup;
    
  }
  
  InitiativeGroup getGroupBeingMoved() {
    
    for ( InitiativeGroup group: groups )
      if ( group.isBeingMoved() )
        return group;
    
    return null;
    
  }
  
  InitiativeGroup getGroup(int _mouseX) {
    
    return groups.get(getIndexAt(_mouseX));
    
  }
  
  int getIndexAt(int _mouseX) {
    
    int relativeX;
    int groupIndex;
    
    relativeX = _mouseX - xOffset;
    groupIndex = floor(float(relativeX) / float( groupImageSize + imagesSpacing ));
    groupIndex = max(groupIndex, 0);
    groupIndex = min(groupIndex, groups.size()-1);
    
    return groupIndex;
    
  }
  
  void moveGroupTo(InitiativeGroup group, int index) {
    
    groups.remove(group);
    groups.add(index, group);
    
  }
  
  void moveGroupTo(String groupName, int index) {
    
    InitiativeGroup groupToMove = null;
    
    for ( InitiativeGroup group: groups )
      if ( group.name.equals(groupName) )
        groupToMove = group;
    
    groups.remove(groupToMove);
    groups.add(index, groupToMove);
    
  }
  
  class InitiativeGroup {
    
    String name;
    
    String imagePath;
    PImage image;
    
    boolean beingMoved;
    
    InitiativeGroup(String _name, String _imagePath, int _imageSize) {
      
      name = _name;
      
      imagePath = _imagePath;
      image = loadImage(imagePath);
      image.resize(_imageSize, _imageSize);
      
      beingMoved = false;
      
    }
    
    String getName() {
      return name;
    }
    
    String getImagePath() {
      return imagePath;
    }
    
    boolean isBeingMoved() {
      return beingMoved;
    }
    
    void setBeingMoved(boolean _beingMoved) {
      beingMoved = _beingMoved;
    }
    
  }
  
}
