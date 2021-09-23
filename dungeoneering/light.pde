// dungeoneering - Virtual tabletop (VTT) for local, in-person RPG sessions
// Copyright  (C) 2019-2021  Luis Castilho

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

class Light {

  PVector position;

  String name;

  color brightLightColor;
  int brightLightRadius;

  color dimLightColor;
  int dimLightRadius;

  Light(String _name, int _brightLightRadius, int _dimLightRadius) {

    position = new PVector();

    name = _name;

    brightLightColor = 255;
    brightLightRadius = _brightLightRadius;

    dimLightColor = 47;
    dimLightRadius = _dimLightRadius;

  }

  void draw(PGraphics shadows) {

    shadows.noStroke();
    shadows.fill(dimLightColor);
    shadows.circle(position.x, position.y, dimLightRadius*2);

    shadows.noStroke();
    shadows.fill(brightLightColor);
    shadows.circle(position.x, position.y, brightLightRadius*2);

  }

  void setPosition(int x, int y) {

    position = new PVector(x, y);

  }

  PVector getPosition() {
    return position;
  }

  String getName() {
    return name;
  }

  color getBrightLightColor() {
    return brightLightColor;
  }

  int getBrightLightRadius() {
    return brightLightRadius;
  }

  color getDimLightColor() {
    return dimLightColor;
  }

  int getDimLightRadius() {
    return dimLightRadius;
  }

  @Override
  public int hashCode() {
    return new HashCodeBuilder(17, 31).
    append(name).
    append(brightLightColor).
    append(brightLightRadius).
    append(dimLightColor).
    append(dimLightRadius).
    toHashCode();
  }

  @Override
  boolean equals(Object o) {
    if ( o == this )
        return true;
    if ( !(o instanceof Light) )
        return false;
    Light other = (Light)o;
    boolean sameName = (this.getName().equals(other.getName()));
    boolean sameBrightColor = (this.getBrightLightColor() == other.getBrightLightColor());
    boolean sameBrightColorRadius = (this.getBrightLightRadius() == other.getBrightLightRadius());
    boolean sameDimColor = (this.getDimLightColor() == other.getDimLightColor());
    boolean sameDimColorRadius = (this.getDimLightRadius() == other.getDimLightRadius());
    return sameName && sameBrightColor && sameBrightColorRadius && sameDimColor && sameDimColorRadius;
  }

}
