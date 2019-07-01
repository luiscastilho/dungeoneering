import java.awt.Point;

class Layer {
  
  PGraphics canvas;
  
  Grid grid;
  
  Obstacles obstacles;
  
  ArrayList<Token> tokens;
  
  String name;
  
  Layer(PGraphics _canvas, Grid _grid, Obstacles _obstacles, String _name) {
    
    canvas = _canvas;
    
    grid = _grid;
    
    obstacles = _obstacles;
    
    tokens = new ArrayList<Token>();
    
    name = _name;
    
  }
  
  void draw() {
    
    switch ( appState ) {
      case idle:
      case wallSetup:
        
        for ( Token token: tokens )
          token.draw();
        
        break;
      case tokenSetup:
      case tokenMovement:
        
        for ( Token token: tokens ) {
          if ( token.isBeingMoved() ) {
            
            token.setCell(grid.getCellAt(new Point(mouseX, mouseY)));
            token.draw();
            
          } else {
            token.draw();
          }
        }
        
        break;
      default:
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
    
    Token token = new Token(canvas);
    token.setup(tokenBaseName, tokenImageFile.getAbsolutePath(), grid.getCellWidth(), grid.getCellHeight(), resources.getSize("Medium"));
    token.setCell(currentCell);
    token.setBeingMoved(true);
    tokens.add(token);
    
  }
  
  void addToken(Token token) {
    
    tokens.add(token);
    
  }
  
  void setTokenCell(Token token, int _mouseX, int _mouseY) {
    
    Cell currentCell = grid.getCellAt(new Point(_mouseX, _mouseY));
    token.setCell(currentCell);
    
  }
  
  AppStates moveToken(int _mouseX, int _mouseY, boolean done) {
    
    Token token;
    
    token = getTokenBeingMoved();
    
    if ( token == null )
      token = getToken(_mouseX, _mouseY);
    
    if ( token == null )
      return AppStates.idle;
    
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
    
    for ( Token token: tokens )
      if ( token.isInside(x, y) )
        return token;
    
    return null;
    
  }
  
  void reset() {
    
    for ( Token token: tokens )
      token.reset();
    
  }
  
  void clear() {
    
    tokens = new ArrayList<Token>();
    
  }
  
  boolean hasTokens() {
    return !tokens.isEmpty();
  }
  
}
