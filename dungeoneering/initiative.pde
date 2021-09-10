// dungeoneering - Minimalistic virtual tabletop (VTT) for local RPG sessions
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

class Initiative {

  PGraphics canvas;

  CopyOnWriteArrayList<InitiativeGroup> groups;

  int imagesSpacing;
  int xOffset, yOffset;
  int groupImageSize;
  int currentX, currentY;
  int maxWidth;

  String title;
  color titleFontColor, titleFontOutlineColor;
  int titleFontHeight;
  PFont titleFont;
  String loadingMessage;

  boolean drawInitiativeOrder;

  SimpleIntegerProperty initiativeVersion;

  boolean set;

  Initiative(PGraphics _canvas) {

    canvas = _canvas;

    groups = new CopyOnWriteArrayList<InitiativeGroup>();

    imagesSpacing = 5;
    xOffset = yOffset = int(min(canvas.width, canvas.height) * 0.05);
    groupImageSize = 100;
    currentX = currentY = 0;
    maxWidth = canvas.width;

    title = "Initiative order:";
    titleFontColor = color(255);
    titleFontOutlineColor = color(0);
    titleFontHeight = 14;
    titleFont = loadFont("fonts/ProcessingSansPro-Semibold-14.vlw");

    loadingMessage = "Loading...";

    drawInitiativeOrder = false;

    initiativeVersion = new SimpleIntegerProperty(1);

    set = true;

  }

  void draw(LayerShown layerShown) {

    if ( !drawInitiativeOrder )
      return;

    if ( groups.isEmpty() )
      return;

    boolean allHidden = true;
    for ( InitiativeGroup group: groups ) {
      if ( !group.isHidden(layerShown) ) {
        allHidden = false;
        break;
      }
    }
    if ( allHidden )
      return;

    if ( !set ) {

      currentX = xOffset;
      currentY = canvas.height - yOffset - groupImageSize - imagesSpacing - titleFontHeight;
      canvas.textFont(titleFont);
      outlineText(canvas, loadingMessage, titleFontColor, titleFontOutlineColor, currentX, currentY);
      return;

    }

    currentX = xOffset;
    currentY = canvas.height - yOffset - groupImageSize - imagesSpacing - titleFontHeight;
    canvas.textFont(titleFont);
    outlineText(canvas, title, titleFontColor, titleFontOutlineColor, currentX, currentY);

    currentX = xOffset;
    currentY = canvas.height - yOffset - groupImageSize;
    for ( InitiativeGroup group: groups ) {

      if ( group.isHidden(layerShown) )
        continue;

      canvas.imageMode(CORNER);
      canvas.image(group.image, currentX, currentY);
      currentX += groupImageSize + imagesSpacing;

    }

  }

  void clear() {

    groups = new CopyOnWriteArrayList<InitiativeGroup>();

    drawInitiativeOrder = false;

    initiativeVersion.set(1);

  }

  void addGroup(String groupName, String groupImagePath, Token token, LayerShown layer) {

    set = false;

    InitiativeGroup groupAlreadyAdded = null;

    for ( InitiativeGroup group: groups )
      if ( group.name.equals(groupName) )
        groupAlreadyAdded = group;

    if ( groupAlreadyAdded != null ) {

      groupAlreadyAdded.addToken(token);

    } else {

      InitiativeGroup newGroup = new InitiativeGroup(groupName, groupImagePath, groupImageSize, layer);
      newGroup.addToken(token);
      groups.add(newGroup);

      setGroupImageSize();

    }

    incrementInitiativeVersion();

    set = true;

  }

  void removeGroup(String groupName, Token token) {

    set = false;

    InitiativeGroup groupToRemove = null;

    for ( InitiativeGroup group: groups )
      if ( group.name.equals(groupName) )
        groupToRemove = group;

    if ( groupToRemove != null ) {

      if ( groupToRemove.getMembersCount() == 1 ) {

        groupToRemove.removeToken(token);
        groups.remove(groupToRemove);

        setGroupImageSize();

      } else {

        groupToRemove.removeToken(token);

      }

      incrementInitiativeVersion();

    }

    set = true;

  }

  boolean getDrawInitiativeOrder() {
    return drawInitiativeOrder;
  }

  void toggleDrawInitiativeOrder() {
    drawInitiativeOrder = !drawInitiativeOrder;
    logger.info("Initiative: Initiative Order " + (drawInitiativeOrder ? "shown" : "hidden" ));
  }

  CopyOnWriteArrayList<InitiativeGroup> getInitiativeGroups() {
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

  AppState changeInitiativeOrder(int _mouseX, boolean done) {

    InitiativeGroup group = null;

    group = getGroupBeingMoved();

    if ( group == null )
      group = getGroup(_mouseX);

    if ( group == null )
      return appState;

    if ( !group.isBeingMoved() )
      group.setBeingMoved(true);

    moveGroupTo(group, getIndexAt(_mouseX));

    if ( done ) {

      group.setBeingMoved(false);
      incrementInitiativeVersion();
      return AppState.idle;

    }

    return AppState.initiativeOrderSetup;

  }

  InitiativeGroup getGroupBeingMoved() {

    for ( InitiativeGroup group: groups )
      if ( group.isBeingMoved() )
        return group;

    return null;

  }

  InitiativeGroup getGroup(int _mouseX) {

    if ( groups.isEmpty() )
      return null;

    return groups.get(getIndexAt(_mouseX));

  }

  InitiativeGroup getGroupByName(String groupName) {

    if ( groups.isEmpty() )
      return null;
    if ( groupName == null || groupName.trim().isEmpty() )
      return null;

    InitiativeGroup found = null;

    for ( InitiativeGroup group: groups )
      if ( group.getName().equals(groupName) )
        found = group;

    return found;

  }

  int getGroupPosition(InitiativeGroup group) {

    if ( groups.isEmpty() )
      return -1;
    if ( group == null )
      return -1;

    return groups.indexOf(group);
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

    if ( group == null )
      return;

    groups.remove(group);
    groups.add(index, group);

  }

  void moveGroupTo(String groupName, int index) {

    InitiativeGroup groupToMove = null;

    for ( InitiativeGroup group: groups )
      if ( group.name.equals(groupName) )
        groupToMove = group;

    if ( groupToMove == null )
      return;

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

  void addSceneUpdateListener(ChangeListener<Number> _sceneUpdateListener) {
    logger.debug("Adding listener to initiative version");
    initiativeVersion.addListener(_sceneUpdateListener);
  }

  void incrementInitiativeVersion() {
    logger.trace("Incrementing initiative version from " + initiativeVersion.getValue() + " to " + (initiativeVersion.getValue()+1));
    initiativeVersion.set(initiativeVersion.getValue() + 1);
  }

  CopyOnWriteArrayList<InitiativeGroup> getGroups() {
    return groups;
  }

  class InitiativeGroup {

    String name;

    String imagePath;
    PImage image;

    CopyOnWriteArrayList<Token> tokens;
    LayerShown layer;

    boolean beingMoved;

    InitiativeGroup(String _name, String _imagePath, int _imageSize, LayerShown _layer) {

      name = _name;

      imagePath = _imagePath;
      resizeImage(_imageSize);

      tokens = new CopyOnWriteArrayList<Token>();
      layer = _layer;

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

    void resizeImage(int _imageSize) {

      image = loadImage(imagePath);
      image.resize(_imageSize, _imageSize);

    }

    void addToken(Token token) {
      tokens.add(token);
    }

    void removeToken(Token token) {
      tokens.remove(token);
    }

    int getMembersCount() {
      return tokens.size();
    }

    boolean isHidden(LayerShown layerShown) {

      if ( layerShown == LayerShown.all || layerShown == layer )
        return false;
      if ( tokens.isEmpty() )
        return false;

      for ( Token token: tokens )
        if ( !token.isHidden() )
          return false;

      return true;

    }

    LayerShown getLayer() {
      return layer;
    }

  }

}
