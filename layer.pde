import java.awt.Point;

class Layer {
  
  PGraphics canvas;
  
  Grid grid;
  
  Obstacles obstacles;
  
  Initiative initiative;
  
  ArrayList<Token> tokens;
  
  String name;
  
  Layers thisLayer;
  
  Layer(PGraphics _canvas, Grid _grid, Obstacles _obstacles, Initiative _initiative, String _name, Layers _thisLayer) {
    
    canvas = _canvas;
    
    grid = _grid;
    
    obstacles = _obstacles;
    
    initiative = _initiative;
    
    tokens = new ArrayList<Token>();
    
    name = _name;
    
    thisLayer = _thisLayer;
    
  }
  
  void draw(Layers layerShown) {
    
    boolean concealHidden = layerShown != Layers.all && layerShown != thisLayer;
    
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
    
    if ( obstacles.getRecalculateShadows() )
      obstacles.setRecalculateShadows(false);
    
  }
  
  void recalculateShadows() {
    
    if ( DEBUG )
      println("DEBUG: " + name + ": recalculating shadows");
    
    for ( Token token: tokens )
      token.recalculateShadows();
    
  }
  
  void addToken(File tokenImageFile) {
    
    String tokenFileName = tokenImageFile.getName();
    String[] tokenFileNameTokens = tokenFileName.split("\\.(?=[^\\.]+$)");
    String tokenBaseName = tokenFileNameTokens[0];
    
    Cell currentCell = grid.getCellAt(new Point(mouseX, mouseY));
    if ( currentCell == null )
      currentCell = grid.getCellAt(0, 0);
    
    Token token = new Token(canvas, grid);
    token.setup(tokenBaseName, tokenImageFile.getAbsolutePath(), grid.getCellWidth(), grid.getCellHeight(), resources.getSize("Medium"));
    token.setCell(currentCell);
    token.setBeingMoved(true);
    tokens.add(token);
    
    initiative.addGroup(tokenBaseName, tokenImageFile.getAbsolutePath(), token, thisLayer);
    
  }
  
  void addToken(Token token) {
    
    tokens.add(token);
    
    initiative.addGroup(token.getName(), token.getImagePath(), token, thisLayer);
    
  }
  
  void setTokenCell(Token token, int _mouseX, int _mouseY) {
    
    Cell currentCell = grid.getCellAt(new Point(_mouseX, _mouseY));
    token.setCell(currentCell);
    
  }
  
  AppStates moveToken(int _mouseX, int _mouseY, boolean done) {
    
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
      
      token.setBeingMoved(false);
      obstacles.setRecalculateShadows(true);
      return AppStates.idle;
      
    }
    
    return AppStates.tokenMovement;
    
  }
  
  void removeToken(Token tokenToRemove) {
    
    tokens.remove(tokenToRemove);
    
    initiative.removeGroup(tokenToRemove.getName(), tokenToRemove);
    
  }
  
  ArrayList<Token> getTokens() {
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
    
    tokens = new ArrayList<Token>();
    
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
  
}
