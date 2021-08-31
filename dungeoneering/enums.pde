enum AppMode {

  dm {
    public String toString() {
        return "DM mode";
    }
  },
  players {
    public String toString() {
        return "Players mode";
    }
  },
  standalone {
    public String toString() {
        return "Standalone mode";
    }
  };

};

enum AppState {

  idle {
    public String toString() {
        return "Idle";
    }
  },
  sceneLoad {
    public String toString() {
        return "Scene Load";
    }
  },
  sceneSync {
    public String toString() {
        return "Scene Sync";
    }
  },
  gridSetup {
    public String toString() {
        return "Grid Setup";
    }
  },
  tokenSetup {
    public String toString() {
        return "Token Setup";
    }
  },
  tokenMovement {
    public String toString() {
        return "Token Movement";
    }
  },
  wallSetup {
    public String toString() {
        return "Wall Setup";
    }
  },
  doorSetup {
    public String toString() {
        return "Door Setup";
    }
  },
  initiativeOrderSetup {
    public String toString() {
        return "Initiative Order Setup";
    }
  },
  mapPan {
    public String toString() {
        return "Map Pan";
    }
  };

};

enum LayerShown {

  all {
    public String toString() {
        return "All layers";
    }
  },
  players {
    public String toString() {
        return "Players' layer";
    }
  },
  dm {
    public String toString() {
        return "DM's layer";
    }
  };

};

enum ShadowType {

  lightSources {
    public String toString() {
        return "light source";
    }
  },
  linesOfSight {
    public String toString() {
        return "line of sight";
    }
  },
  sightTypes {
    public String toString() {
        return "sight type";
    }
  };

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

enum TooltipState {

  Wait,
  FadeIn,
  Show;

};
