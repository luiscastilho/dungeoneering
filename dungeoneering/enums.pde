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

  brightLight(255, "Bright Light"),
  dimLight(47, "Dim Light"),
  darkness(0, "Darkness");

  private final int envLightColor;
  private final String envLightName;

  private Illumination(final int _envLightColor, final String _envLightName) {
      envLightColor = _envLightColor;
      envLightName = _envLightName;
  }

  int getColor() {
    return envLightColor;
  }

  String getName() {
    return envLightName;
  }

}

enum TooltipStates {

  Wait,
  FadeIn,
  Show;

};
