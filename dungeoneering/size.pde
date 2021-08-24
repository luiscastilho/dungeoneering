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
