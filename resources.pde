import java.util.Map;

class Resources {
  
  PGraphics canvas;
  
  Grid grid;
  
  HashMap<String, Light> commonLightSources;
  HashMap<String, Light> spellLightSources;
  HashMap<String, Light> sightTypes;
  HashMap<String, Condition> conditions;
  
  boolean set;
  
  Resources(PGraphics _canvas, Grid _grid) {
    
    canvas = _canvas;
    
    grid = _grid;
    
    commonLightSources = new HashMap<String, Light>();
    spellLightSources = new HashMap<String, Light>();
    sightTypes = new HashMap<String, Light>();
    conditions = new HashMap<String, Condition>();
    
    set = false;
    
  }
  
  void setup() {
    
    setCommonLightSources();
    setSpellLightSources();
    setSightTypes();
    setConditions();
    
    set = true;
    
  }
  
  void reset() {
    
    commonLightSources = new HashMap<String, Light>();
    spellLightSources = new HashMap<String, Light>();
    sightTypes = new HashMap<String, Light>();
    conditions = new HashMap<String, Condition>();
    
  }
  
  void setCommonLightSources() {
    
    commonLightSources.put("Candle", createLight("Candle", 5, 10));
    commonLightSources.put("Hooded Lantern", createLight("Hooded Lantern", 30, 60));
    commonLightSources.put("Lamp", createLight("Lamp", 15, 45));
    commonLightSources.put("Torch", createLight("Torch", 20, 40));
    
  }
  
  void setSpellLightSources() {
    
    spellLightSources.put("Dancing Lights", createLight("Dancing Lights", 0, 10));
    spellLightSources.put("Faerie Fire", createLight("Faerie Fire", 0, 10));
    spellLightSources.put("Light", createLight("Light", 20, 40));
    spellLightSources.put("Produce Flame", createLight("Produce Flame", 10, 20));
    
  }
  
  void setSightTypes() {
    
    sightTypes.put("Blindsight 30'", createLight("Blindsight 30'", 30, 0));
    sightTypes.put("Blindsight 60'", createLight("Blindsight 60'", 60, 0));
    sightTypes.put("Blindsight 120'", createLight("Blindsight 120'", 120, 0));
    sightTypes.put("Darkvision 30'", createLight("Darkvision 30'", 0, 30));
    sightTypes.put("Darkvision 60'", createLight("Darkvision 60'", 0, 60));
    sightTypes.put("Darkvision 90'", createLight("Darkvision 90'", 0, 90));
    sightTypes.put("Darkvision 120'", createLight("Darkvision 120'", 0, 120));
    sightTypes.put("Truesight 120'", createLight("Truesight 120'", 120, 0));
    
  }
  
  void setConditions() {
    
    conditions.put("Dead", new Condition(canvas, "Dead", "conditions/dead.png", grid.getCellWidth(), grid.getCellHeight()));
    
  }
  
  Light getCommonLightSource(String name) {
    return commonLightSources.get(name);
  }
  
  Light getSpellLightSource(String name) {
    return spellLightSources.get(name);
  }
  
  Light getSightType(String name) {
    return sightTypes.get(name);
  }
  
  Condition getCondition(String name) {
    return conditions.get(name);
  }
  
  Light createLight(String name, int brightLightRadiusInFeet, int dimLightRadiusInFeet) {
    
    int cellSize = max(grid.getCellWidth(), grid.getCellHeight());
    int brightLightRadius = brightLightRadiusInFeet != 0 ? (brightLightRadiusInFeet / 5) * cellSize + cellSize/2 : 0;
    int dimLightRadius = dimLightRadiusInFeet != 0 ? (dimLightRadiusInFeet / 5) * cellSize + cellSize/2 : 0;
    
    return new Light(name, brightLightRadius, dimLightRadius);
    
  }
  
  boolean isSet() {
    return set;
  }
  
}
