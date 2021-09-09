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

class Size {

  String name;

  float resizeFactor;

  boolean centered;

  Size(String _name, float _resizeFactor, boolean _centered) {

    name = _name;
    resizeFactor = _resizeFactor;
    centered = _centered;

  }

  String getName() {
    return name;
  }

  float getResizeFactor() {
    return resizeFactor;
  }

  boolean isCentered() {
    return centered;
  }

  @Override
  public int hashCode() {
    return new HashCodeBuilder(19, 31).
    append(name).
    append(centered).
    toHashCode();
  }

  @Override
  boolean equals(Object o) {
    if ( o == this )
        return true;
    if ( !(o instanceof Size) )
        return false;
    Size other = (Size)o;
    boolean sameName = (this.getName().equals(other.getName()));
    boolean sameCenteredProperty = (this.isCentered() == other.isCentered());
    return sameName && sameCenteredProperty;
  }

}
