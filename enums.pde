enum AppStates {
  
  idle,
  loadingScene,
  gridSetup,
  tokenSetup,
  tokenMovement,
  wallSetup,
  doorSetup,
  switchingLayer,
  switchingLightning,
  togglingCameraPan,
  togglingCameraZoom,
  initiativeOrderSetup;
  
};

enum Layers {
  
  all,
  players,
  dm;
  
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
