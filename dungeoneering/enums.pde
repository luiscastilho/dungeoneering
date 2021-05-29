enum AppStates {

  idle,
  sceneLoad,
  gridSetup,
  tokenSetup,
  tokenMovement,
  wallSetup,
  doorSetup,
  initiativeOrderSetup,
  mapPan;

};

enum Layers {

  all,
  players,
  dm;

};

enum ShadowTypes {

  lightSources,
  linesOfSight,
  sightTypes;

};

enum Illumination {

  brightLight(255),
  dimLight(47),
  darkness(0);

  private final int envLightColor;

  private Illumination(final int _envLightColor) {
      envLightColor = _envLightColor;
  }

  int getColor() {
    return envLightColor;
  }

}
