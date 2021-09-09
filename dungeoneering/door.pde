// dungeoneering - minimalistic virtual tabletop (VTT)
// Copyright (C) 2019-2021 Luis Castilho

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

class Door extends Wall {

  boolean closed;

  Door(PGraphics _canvas, UUID _id) {
    super(_canvas, _id);

    closed = true;

  }

  void draw(color closedDoorColor, color openDoorColor, int doorWidth) {

    if ( closed )
      super.draw(closedDoorColor, doorWidth);
    else
      super.draw(openDoorColor, doorWidth);

  }

  void calculateShadows(Light light, PGraphics shadows) {

    if ( closed )
      super.calculateShadows(light, shadows);

  }

  void toggle() {
    closed = !closed;
  }

  boolean getClosed() {
    return closed;
  }

  void setClosed(boolean _closed) {
    closed = _closed;
  }

}
