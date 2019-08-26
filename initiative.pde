class Initiative {
  
  PGraphics canvas;
  
  ArrayList<InitiativeGroup> groups;
  
  int imagesSpacing;
  int xOffset, yOffset;
  int groupImageSize;
  int currentX, currentY;
  int maxWidth;
  
  String title;
  color titleFontColor;
  int titleFontHeight;
  PFont titleFont;
  String loadingMessage;
  
  boolean drawInitiativeOrder;
  
  boolean set;
  
  Initiative(PGraphics _canvas) {
    
    canvas = _canvas;
    
    groups = new ArrayList<InitiativeGroup>();
    
    imagesSpacing = 5;
    xOffset = yOffset = int(min(canvas.width, canvas.height) * 0.05);
    groupImageSize = 100;
    currentX = currentY = 0;
    maxWidth = canvas.width;
    
    title = "Initiative order:";
    titleFontColor = color(255);
    titleFontHeight = 14;
    titleFont = loadFont("fonts/ProcessingSansPro-Semibold-14.vlw");
    
    loadingMessage = "Loading...";
    
    drawInitiativeOrder = false;
    
    set = true;
    
  }
  
  void draw() {
    
    if ( !drawInitiativeOrder )
      return;
    if ( groups.isEmpty() )
      return;
    
    if ( !set ) {
      
      currentX = xOffset;
      currentY = canvas.height - yOffset - groupImageSize - imagesSpacing - titleFontHeight;
      canvas.fill(titleFontColor);
      canvas.textFont(titleFont);
      canvas.text(loadingMessage, currentX, currentY);
      return;
      
    }
    
    currentX = xOffset;
    currentY = canvas.height - yOffset - groupImageSize - imagesSpacing - titleFontHeight;
    canvas.fill(titleFontColor);
    canvas.textFont(titleFont);
    canvas.text(title, currentX, currentY);
    
    currentX = xOffset;
    currentY = canvas.height - yOffset - groupImageSize;
    for ( InitiativeGroup group: groups ) {
      
      canvas.imageMode(CORNER);
      canvas.image(group.image, currentX, currentY);
      currentX += groupImageSize + imagesSpacing;
      
    }
    
  }
  
  void clear() {
    
    groups = new ArrayList<InitiativeGroup>();
    
  }
  
  void addGroup(String groupName, String groupImagePath) {
    
    set = false;
    
    InitiativeGroup groupAlreadyAdded = null;
    
    for ( InitiativeGroup group: groups )
      if ( group.name.equals(groupName) )
        groupAlreadyAdded = group;
    
    if ( groupAlreadyAdded != null ) {
      
      groupAlreadyAdded.addMember();
      
    } else {
      
      groups.add(new InitiativeGroup(groupName, groupImagePath, groupImageSize));
      setGroupImageSize();
      
    }
    
    set = true;
    
  }
  
  void removeGroup(String groupName) {
    
    set = false;
    
    InitiativeGroup groupToRemove = null;
    
    for ( InitiativeGroup group: groups )
      if ( group.name.equals(groupName) )
        groupToRemove = group;
    
    if ( groupToRemove != null ) {
      
      if ( groupToRemove.getMembersCount() == 1 ) {
      
        groups.remove(groupToRemove);
        setGroupImageSize();
      
      } else {
        
        groupToRemove.removeMember();
        
      }
      
    }
    
    set = true;
    
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
  
  void setMaxWidth(int _maxWidth) {
    maxWidth = _maxWidth;
  }
  
  void setGroupImageSize() {
    
    int prevGroupImageSize = groupImageSize;
    int newGroupImageSize = groupImageSize;
    
    if ( groups.size() == 0 )
      newGroupImageSize = 100;
    else
      newGroupImageSize = min(100, ( ( maxWidth - xOffset - (imagesSpacing * groups.size()) ) / groups.size() ));
    
    if ( newGroupImageSize != prevGroupImageSize )
      for ( InitiativeGroup group: groups )
        group.resizeImage(groupImageSize);
    
    groupImageSize = newGroupImageSize;
    
  }
  
  class InitiativeGroup {
    
    String name;
    
    String imagePath;
    PImage image;
    
    boolean beingMoved;
    
    int membersCount;
    
    InitiativeGroup(String _name, String _imagePath, int _imageSize) {
      
      name = _name;
      
      imagePath = _imagePath;
      resizeImage(_imageSize);
      
      beingMoved = false;
      
      membersCount = 1;
      
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
    
    void resizeImage(int _imageSize) {
      
      image = loadImage(imagePath);
      image.resize(_imageSize, _imageSize);
      
    }
    
    void addMember() {
      membersCount += 1;
    }
    
    void removeMember() {
      membersCount -= 1;
    }
    
    int getMembersCount() {
      return membersCount;
    }
    
  }
  
}
