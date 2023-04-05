// dungeoneering - Virtual tabletop (VTT) for local, in-person RPG sessions
// Copyright  (C) 2019-2023  Luis Castilho

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

class Resources {

  PGraphics canvas;

  Grid grid;

  HashMap<String, Size> baseSizes;
  ArrayList<Light> baseCommonLightSources;
  ArrayList<Light> baseSpellLightSources;
  ArrayList<Light> baseSightTypes;
  ArrayList<Condition> baseConditions;
  Light baseLineOfSight;

  HashMap<String, Light> commonLightSourcesBasedOnGrid;
  HashMap<String, Light> spellLightSourcesBasedOnGrid;
  HashMap<String, Light> sightTypesBasedOnGrid;
  HashMap<String, Condition> conditionsBySize;
  Light lineOfSight;

  boolean set;

  Resources(PGraphics _canvas, Grid _grid) {

    canvas = _canvas;

    grid = _grid;

    // Base resources
    baseSizes = new LinkedHashMap<String, Size>();
    baseCommonLightSources = new ArrayList<Light>();
    baseSpellLightSources = new ArrayList<Light>();
    baseSightTypes = new ArrayList<Light>();
    baseConditions = new ArrayList<Condition>();
    baseLineOfSight = new Light("Line of Sight", 1000, 0);

    // Resources taking into account cell size
    commonLightSourcesBasedOnGrid = new LinkedHashMap<String, Light>();
    spellLightSourcesBasedOnGrid = new LinkedHashMap<String, Light>();
    sightTypesBasedOnGrid = new LinkedHashMap<String, Light>();
    conditionsBySize = new LinkedHashMap<String, Condition>();
    lineOfSight = null;

    setBaseSizes();
    setBaseCommonLightSources();
    setBaseSpellLightSources();
    setBaseSightTypes();
    setBaseConditions();

    set = false;

  }

  void reset() {

    baseSizes = new LinkedHashMap<String, Size>();
    baseCommonLightSources = new ArrayList<Light>();
    baseSpellLightSources = new ArrayList<Light>();
    baseSightTypes = new ArrayList<Light>();
    baseConditions = new ArrayList<Condition>();
    baseLineOfSight = new Light("Line of Sight", 1000, 0);

    commonLightSourcesBasedOnGrid = new LinkedHashMap<String, Light>();
    spellLightSourcesBasedOnGrid = new LinkedHashMap<String, Light>();
    sightTypesBasedOnGrid = new LinkedHashMap<String, Light>();
    conditionsBySize = new LinkedHashMap<String, Condition>();
    lineOfSight = null;

    setBaseSizes();
    setBaseCommonLightSources();
    setBaseSpellLightSources();
    setBaseSightTypes();
    setBaseConditions();

    set = false;

  }

  void setBaseSizes() {

    baseSizes.put("Tiny", new Size("Tiny", 0.5f, true));
    baseSizes.put("Small", new Size("Small", 1f, true));
    baseSizes.put("Medium", new Size("Medium", 1f, true));
    baseSizes.put("Large", new Size("Large", 2f, false));
    baseSizes.put("Huge", new Size("Huge", 3f, true));
    baseSizes.put("Gargantuan", new Size("Gargantuan", 4f, false));

  }

  void setBaseCommonLightSources() {

    baseCommonLightSources.add(new Light("Candle", 5, 10));
    baseCommonLightSources.add(new Light("Hooded Lantern", 30, 60));
    baseCommonLightSources.add(new Light("Lamp", 15, 45));
    baseCommonLightSources.add(new Light("Torch", 20, 40));
    baseCommonLightSources.add(new Light("Daylight", 1000, 0));

  }

  void setBaseSpellLightSources() {

    baseSpellLightSources.add(new Light("Light", 20, 40));
    // baseSpellLightSources.add(new Light("Dancing Lights", 0, 10));
    // baseSpellLightSources.add(new Light("Daylight", 60, 60));
    // baseSpellLightSources.add(new Light("Faerie Fire", 0, 10));
    // baseSpellLightSources.add(new Light("Produce Flame", 10, 20));

  }

  void setBaseSightTypes() {

    baseSightTypes.add(new Light("Blindsight 10'", 10, 0));
    baseSightTypes.add(new Light("Blindsight 30'", 30, 0));
    baseSightTypes.add(new Light("Blindsight 60'", 60, 0));
    baseSightTypes.add(new Light("Blindsight 90'", 90, 0));
    baseSightTypes.add(new Light("Blindsight 120'", 120, 0));
    baseSightTypes.add(new Light("Darkvision 10'", 0, 10));
    baseSightTypes.add(new Light("Darkvision 30'", 0, 30));
    baseSightTypes.add(new Light("Darkvision 60'", 0, 60));
    baseSightTypes.add(new Light("Darkvision 90'", 0, 90));
    baseSightTypes.add(new Light("Darkvision 120'", 0, 120));
    baseSightTypes.add(new Light("Truesight 120'", 120, 0));

  }

  void setBaseConditions() {

    baseConditions.add(new Condition(canvas, "Blinded", "conditions/blinded.png", true, false, false));
    baseConditions.add(new Condition(canvas, "Bloodied", "conditions/bloodied.png", false, false, false));
    baseConditions.add(new Condition(canvas, "Burned", "conditions/burned.png", false, false, false));
    baseConditions.add(new Condition(canvas, "Charmed", "conditions/charmed.png", false, false, false));
    baseConditions.add(new Condition(canvas, "Dead", "conditions/dead.png", true, false, true));
    baseConditions.add(new Condition(canvas, "Deafened", "conditions/deafened.png", false, false, false));
    baseConditions.add(new Condition(canvas, "Frightened", "conditions/frightened.png", false, false, false));
    baseConditions.add(new Condition(canvas, "Grappled", "conditions/grappled.png", false, false, false));
    baseConditions.add(new Condition(canvas, "Hidden", "conditions/hidden.png", false, true, false));
    baseConditions.add(new Condition(canvas, "Incapacitated", "conditions/incapacitated.png", true, false, false));
    baseConditions.add(new Condition(canvas, "Invisible", "conditions/invisible.png", false, true, false));
    baseConditions.add(new Condition(canvas, "Paralyzed", "conditions/paralyzed.png", true, false, false));
    baseConditions.add(new Condition(canvas, "Petrified", "conditions/petrified.png", true, false, false));
    baseConditions.add(new Condition(canvas, "Poisoned", "conditions/poisoned.png", false, false, false));
    baseConditions.add(new Condition(canvas, "Prone", "conditions/prone.png", false, false, false));
    baseConditions.add(new Condition(canvas, "Restrained", "conditions/restrained.png", false, false, false));
    baseConditions.add(new Condition(canvas, "Stunned", "conditions/stunned.png", true, false, false));
    baseConditions.add(new Condition(canvas, "Unconscious", "conditions/unconscious.png", true, false, false));

  }

  void setupBasedOnGrid() {

    setLightSourcesBasedOnGrid(baseCommonLightSources, commonLightSourcesBasedOnGrid);
    setLightSourcesBasedOnGrid(baseSpellLightSources, spellLightSourcesBasedOnGrid);
    setLightSourcesBasedOnGrid(baseSightTypes, sightTypesBasedOnGrid);
    setConditionsBasedOnGrid();
    lineOfSight = createLight(baseLineOfSight.getName(), baseLineOfSight.getBrightLightRadius(), baseLineOfSight.getDimLightRadius());

    set = true;

  }

  void setLightSourcesBasedOnGrid(ArrayList<Light> baseLightSources, HashMap<String, Light> lightSourcesBasedOnGrid) {

    for ( Light baseLightSource: baseLightSources )
      lightSourcesBasedOnGrid.put(baseLightSource.getName(), createLight(baseLightSource.getName(), baseLightSource.getBrightLightRadius(), baseLightSource.getDimLightRadius()));

  }

  Light createLight(String name, int brightLightRadiusInFeet, int dimLightRadiusInFeet) {

    int cellSize = max(grid.getCellWidth(), grid.getCellHeight());
    int brightLightRadius = brightLightRadiusInFeet != 0 ? (brightLightRadiusInFeet / 5) * cellSize + cellSize/2 : 0;
    int dimLightRadius = dimLightRadiusInFeet != 0 ? (dimLightRadiusInFeet / 5) * cellSize + cellSize/2 : 0;

    return new Light(name, brightLightRadius, dimLightRadius);

  }

  void setConditionsBasedOnGrid() {

    for ( Size size: baseSizes.values() ) {
      for ( Condition baseCondition: baseConditions ) {
        Condition conditionBySize = baseCondition.copy();
        conditionBySize.setSize(size, grid.getCellWidth(), grid.getCellHeight());
        conditionsBySize.put(size.getName() + " " + conditionBySize.getName(), conditionBySize);
      }
    }

  }

  HashMap<String, Size> getBaseSizes() {
    return baseSizes;
  }

  ArrayList<Light> getBaseCommonLightSources() {
    return baseCommonLightSources;
  }

  ArrayList<Light> getBaseSpellLightSources() {
    return baseSpellLightSources;
  }

  ArrayList<Light> getBaseSightTypes() {
    return baseSightTypes;
  }

  ArrayList<Condition> getBaseConditions() {
    return baseConditions;
  }

  Light getBaseLineOfSight() {
    return baseLineOfSight;
  }

  Size getSize(String name) {
    return baseSizes.get(name);
  }

  Light getCommonLightSource(String name) {
    return commonLightSourcesBasedOnGrid.get(name);
  }

  Light getSpellLightSource(String name) {
    return spellLightSourcesBasedOnGrid.get(name);
  }

  Light getSightType(String name) {
    return sightTypesBasedOnGrid.get(name);
  }

  Condition getCondition(String name, Size size) {
    return conditionsBySize.get(size.getName() + " " + name);
  }

  Light getLineOfSight() {
    return lineOfSight;
  }

  boolean isSet() {
    return set;
  }

}
