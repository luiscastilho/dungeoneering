import java.util.Map;

class Resources {
  
  PGraphics canvas;
  
  Grid grid;
  
  HashMap<String, Size> sizes;
  HashMap<String, Light> commonLightSources;
  HashMap<String, Light> spellLightSources;
  HashMap<String, Light> sightTypes;
  HashMap<String, Condition> conditions;
  
  boolean set;
  
  Resources(PGraphics _canvas, Grid _grid) {
    
    canvas = _canvas;
    
    grid = _grid;
    
    sizes = new HashMap<String, Size>();
    commonLightSources = new HashMap<String, Light>();
    spellLightSources = new HashMap<String, Light>();
    sightTypes = new HashMap<String, Light>();
    conditions = new HashMap<String, Condition>();
    
    set = false;
    
  }
  
  void setup() {
    
    setSizes();
    setCommonLightSources();
    setSpellLightSources();
    setSightTypes();
    setConditions();
    
    set = true;
    
  }
  
  void reset() {
    
    sizes = new HashMap<String, Size>();
    commonLightSources = new HashMap<String, Light>();
    spellLightSources = new HashMap<String, Light>();
    sightTypes = new HashMap<String, Light>();
    conditions = new HashMap<String, Condition>();
    
  }
  
  void setSizes() {
    
    sizes.put("Tiny", new Size("Tiny", 0.5f, true));
    sizes.put("Small", new Size("Small", 1f, true));
    sizes.put("Medium", new Size("Medium", 1f, true));
    sizes.put("Large", new Size("Large", 2f, false));
    sizes.put("Huge", new Size("Huge", 3f, true));
    sizes.put("Gargantuan", new Size("Gargantuan", 4f, false));
    
  }
  
  void setCommonLightSources() {
    
    commonLightSources.put("Candle", createLight("Candle", 5, 10));
    commonLightSources.put("Hooded Lantern", createLight("Hooded Lantern", 30, 60));
    commonLightSources.put("Lamp", createLight("Lamp", 15, 45));
    commonLightSources.put("Torch", createLight("Torch", 20, 40));
    commonLightSources.put("Daylight", createLight("Daylight", 150, 0));
    
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
    
    for ( Size size: sizes.values() ) {
      conditions.put(size.getName() + " Blinded", new Condition(canvas, "Blinded", "conditions/blinded.png", grid.getCellWidth(), grid.getCellHeight(), true, false, size));
      conditions.put(size.getName() + " Bloodied", new Condition(canvas, "Bloodied", "conditions/bloodied.png", grid.getCellWidth(), grid.getCellHeight(), true, false, size));
      conditions.put(size.getName() + " Charmed", new Condition(canvas, "Charmed", "conditions/charmed.png", grid.getCellWidth(), grid.getCellHeight(), false, false, size));
      conditions.put(size.getName() + " Dead", new Condition(canvas, "Dead", "conditions/dead.png", grid.getCellWidth(), grid.getCellHeight(), true, true, size));
      conditions.put(size.getName() + " Deafened", new Condition(canvas, "Deafened", "conditions/deafened.png", grid.getCellWidth(), grid.getCellHeight(), false, false, size));
      conditions.put(size.getName() + " Frightened", new Condition(canvas, "Frightened", "conditions/frightened.png", grid.getCellWidth(), grid.getCellHeight(), false, false, size));
      conditions.put(size.getName() + " Grappled", new Condition(canvas, "Grappled", "conditions/grappled.png", grid.getCellWidth(), grid.getCellHeight(), false, false, size));
      conditions.put(size.getName() + " Incapacitated", new Condition(canvas, "Incapacitated", "conditions/incapacitated.png", grid.getCellWidth(), grid.getCellHeight(), true, false, size));
      conditions.put(size.getName() + " Invisible", new Condition(canvas, "Invisible", "conditions/invisible.png", grid.getCellWidth(), grid.getCellHeight(), false, false, size));
      conditions.put(size.getName() + " Paralyzed", new Condition(canvas, "Paralyzed", "conditions/paralyzed.png", grid.getCellWidth(), grid.getCellHeight(), true, false, size));
      conditions.put(size.getName() + " Petrified", new Condition(canvas, "Petrified", "conditions/petrified.png", grid.getCellWidth(), grid.getCellHeight(), true, false, size));
      conditions.put(size.getName() + " Poisoned", new Condition(canvas, "Poisoned", "conditions/poisoned.png", grid.getCellWidth(), grid.getCellHeight(), false, false, size));
      conditions.put(size.getName() + " Prone", new Condition(canvas, "Prone", "conditions/prone.png", grid.getCellWidth(), grid.getCellHeight(), false, false, size));
      conditions.put(size.getName() + " Restrained", new Condition(canvas, "Restrained", "conditions/restrained.png", grid.getCellWidth(), grid.getCellHeight(), false, false, size));
      conditions.put(size.getName() + " Stunned", new Condition(canvas, "Stunned", "conditions/stunned.png", grid.getCellWidth(), grid.getCellHeight(), true, false, size));
      conditions.put(size.getName() + " Unconscious", new Condition(canvas, "Unconscious", "conditions/unconscious.png", grid.getCellWidth(), grid.getCellHeight(), true, false, size));
    }
    
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
  
  Condition getCondition(String name, Size size) {
    return conditions.get(size.getName() + " " + name);
  }
  
  Size getSize(String name) {
    return sizes.get(name);
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
