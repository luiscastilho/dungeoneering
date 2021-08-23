class Layer {

  PGraphics canvas;

  Grid grid;

  Obstacles obstacles;

  Resources resources;

  Initiative initiative;

  CopyOnWriteArrayList<Token> tokens;

  String name;

  LayerShown thisLayer;

  SimpleIntegerProperty layerVersion;

  Layer(PGraphics _canvas, Grid _grid, Obstacles _obstacles, Resources _resources, Initiative _initiative, String _name, LayerShown _thisLayer) {

    canvas = _canvas;

    grid = _grid;

    obstacles = _obstacles;

    resources = _resources;

    initiative = _initiative;

    tokens = new CopyOnWriteArrayList<Token>();

    name = _name;

    thisLayer = _thisLayer;

    layerVersion = new SimpleIntegerProperty(1);

  }

  void draw(LayerShown layerShown) {

    boolean concealHidden = layerShown != LayerShown.all && layerShown != thisLayer;

    switch ( appState ) {
      case tokenSetup:
      case tokenMovement:

        for ( Token token: tokens ) {
          if ( token.isBeingMoved() ) {

            token.setCell(grid.getCellAt(new Point(mouseX, mouseY)));
            token.draw(concealHidden);

          } else {
            token.draw(concealHidden);
          }
        }

        break;
      default:

        for ( Token token: tokens )
          token.draw(concealHidden);

        break;
    }

  }

  void recalculateShadows(ShadowType shadowsToRecalculate) {

    logger.trace("Layer: " + name + ": recalculating " + shadowsToRecalculate.toString() + " shadows");

    for ( Token token: tokens )
      token.recalculateShadows(shadowsToRecalculate);

    logger.trace("Layer: " + name + ": done recalculating " + shadowsToRecalculate.toString() + " shadows");

  }

  void addToken(File tokenImageFile, ChangeListener<Number> sceneUpdateListener) {

    String tokenFileName = tokenImageFile.getName();
    String[] tokenFileNameTokens = tokenFileName.split("\\.(?=[^\\.]+$)");
    String tokenBaseName = tokenFileNameTokens[0];
    UUID tokenId = UUID.randomUUID();
    int tokenVersion = 1;

    Cell currentCell = grid.getCellAt(new Point(mouseX, mouseY));
    if ( currentCell == null )
      currentCell = grid.getCellAt(0, 0);

    Token token = new Token(canvas, grid, obstacles);
    Light lineOfSightTemplate = resources.getSightType("Line of Sight");
    Light lineOfSight = new Light(lineOfSightTemplate.getName(), lineOfSightTemplate.getBrightLightRadius(), lineOfSightTemplate.getDimLightRadius());
    token.setup(tokenBaseName, tokenId, tokenVersion, sceneUpdateListener, tokenImageFile.getAbsolutePath(), grid.getCellWidth(), grid.getCellHeight(), resources.getSize("Medium"), lineOfSight);
    token.setCell(currentCell);
    token.setBeingMoved(true);
    tokens.add(token);

    initiative.addGroup(tokenBaseName, tokenImageFile.getAbsolutePath(), token, thisLayer);

    incrementLayerVersion();

    logger.info("Layer: New token added in " + name);

  }

  void addToken(Token token) {

    tokens.add(token);

    initiative.addGroup(token.getName(), token.getImagePath(), token, thisLayer);

    incrementLayerVersion();

  }

  void setTokenCell(Token token, int _mouseX, int _mouseY) {

    Cell currentCell = grid.getCellAt(new Point(_mouseX, _mouseY));
    token.setCell(currentCell);

  }

  AppState moveToken(int _mouseX, int _mouseY, boolean done) {

   if ( tokens.isEmpty() )
      return appState;

    Token token;

    token = getTokenBeingMoved();

    if ( token == null )
      token = getToken(_mouseX, _mouseY);

    if ( token == null )
      return appState;

    if ( !token.isBeingMoved() ) {
      token.setBeingMoved(true);
      tokens.remove(token);
      tokens.add(token);
    }

    setTokenCell(token, _mouseX, _mouseY);

    if ( done ) {

      if ( token.setBeingMoved(false) ) {
        token.incrementVersion();
        obstacles.setRecalculateShadows(true);
      }
      return AppState.idle;

    }

    return AppState.tokenMovement;

  }

  void moveToken(Token token, Cell cell) {

    if ( token == null || cell == null )
      return;

    if ( token.setCell(cell) ) {

      token.incrementVersion();
      obstacles.setRecalculateShadows(true);

    }

  }

  void removeToken(Token tokenToRemove) {

    removeToken(tokenToRemove, true);

  }

  void removeToken(Token tokenToRemove, boolean incrementLayerVersion) {

    tokens.remove(tokenToRemove);

    initiative.removeGroup(tokenToRemove.getName(), tokenToRemove);

    if ( incrementLayerVersion )
      incrementLayerVersion();

  }

  CopyOnWriteArrayList<Token> getTokens() {
    return tokens;
  }

  Token getTokenBeingMoved() {

    for ( Token token: tokens )
      if ( token.isBeingMoved() )
        return token;

    return null;

  }

  Token getToken(int x, int y) {

    Token chosenToken = null;

    for ( Token token: tokens )
      if ( token.isInside(x, y) )
        chosenToken = token;

    return chosenToken;

  }

  void reset() {

    for ( Token token: tokens )
      token.reset();

  }

  void clear() {

    tokens = new CopyOnWriteArrayList<Token>();

    layerVersion.set(1);

    System.gc();

  }

  boolean hasTokens() {
    return !tokens.isEmpty();
  }

  boolean isOverToken(int x, int y) {

    Token token;

    token = getTokenBeingMoved();

    if ( token == null )
      token = getToken(x, y);

    if ( token == null )
      return false;

    return true;

  }

  boolean hasToken(Token tokenToCheck) {

    for ( Token token: tokens )
      if ( token.equals(tokenToCheck) )
        return true;
    return false;

  }

  String getName() {
    return name;
  }

  void addSceneUpdateListener(ChangeListener<Number> _sceneUpdateListener) {
    logger.debug("Adding listener to " + name + " version");
    layerVersion.addListener(_sceneUpdateListener);
  }

  void incrementLayerVersion() {
    logger.debug("Incrementing " + name + " version from " + layerVersion.getValue() + " to " + (layerVersion.getValue()+1));
    layerVersion.set(layerVersion.getValue() + 1);
  }

  Token getTokenById(UUID tokenID) {

    Token tokenFound = null;

    for ( Token token: tokens ) {
      if ( token.getId().equals(tokenID) ) {
        tokenFound = token;
        break;
      }
    }

    return tokenFound;

  }

}
