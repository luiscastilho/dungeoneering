public class UserInterfaceTooltip {

  TooltipState tooltipState;

  String message;

  float waitDelay;
  float fadeInDelay;

  int width, height;

  color backgroundColor;
  int backgroundMaxAlpha;

  PFont textFont;
  color textColor;
  int textOffset;
  int textMaxAlpha;

  Point position;

  int waitStartTime;
  int fadeInStartTime;

  float fadeInAlpha;

  UserInterfaceTooltip(String _message, color _backgroundColor, color _textColor) {

    tooltipState = TooltipState.Wait;

    message = _message;

    waitDelay = 0.5f;
    fadeInDelay = 0.1f;

    width = 0;
    height = 25;

    backgroundColor = _backgroundColor;
    backgroundMaxAlpha = 223;

    textFont = loadFont("fonts/ProcessingSansPro-Semibold-12.vlw");
    textColor = _textColor;
    textOffset = 15;
    textMaxAlpha = 255;

    position = new Point();

    waitStartTime = fadeInStartTime = 0;

    fadeInAlpha = 0;

  }

  void draw(PGraphics uiCanvas) {

    switch ( tooltipState ) {
      case Wait:

        if ( waitStartTime == 0 || mouseMoved() )
          waitStartTime = millis();

        if ( millis() > waitStartTime + waitDelay * 1000 )
          tooltipState = TooltipState.FadeIn;

        break;
      case FadeIn:

        if ( fadeInStartTime == 0 )
          fadeInStartTime = millis();

        fadeInAlpha = map(millis() - fadeInStartTime, 0, fadeInDelay * 1000, 0, 1);

        if ( fadeInAlpha > 0.95 ) {
          fadeInAlpha = 1f;
          tooltipState = TooltipState.Show;
        }

        drawTooltip(uiCanvas);

        break;
      case Show:

        drawTooltip(uiCanvas);

        break;
      default:
        break;
    }

  }

  boolean mouseMoved() {
    return abs(dist(pmouseX, pmouseY, mouseX, mouseY)) > 1;
  }

  void drawTooltip(PGraphics uiCanvas) {

    uiCanvas.textAlign(LEFT, CENTER);
    uiCanvas.textFont(textFont);
    width = round(uiCanvas.textWidth(message) + 2*textOffset);

    if ( position.x == 0 && position.y == 0 ) {
        position.x = mouseX;
        position.y = mouseY;
        if ( position.x + width > uiCanvas.width )
            position.x = mouseX - width;
    }

    uiCanvas.rectMode(CORNER);
    uiCanvas.noStroke();
    uiCanvas.fill(backgroundColor, fadeInAlpha * backgroundMaxAlpha);
    uiCanvas.rect(position.x, position.y, width, height);

    uiCanvas.fill(textColor, fadeInAlpha * textMaxAlpha);
    uiCanvas.text(message, position.x + textOffset, position.y + height/2);

  }

  void reset() {

    tooltipState = TooltipState.Wait;

    position.x = position.y = 0;

    waitStartTime = fadeInStartTime = 0;

    fadeInAlpha = 0;

  }

}
