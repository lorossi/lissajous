// class containing informations about each curve
class Curve {
  boolean black_and_white;
  float hue;
  float period;
  PVector last, current;
  PGraphics graphics;

  Curve(float _hue, float _period, PGraphics _graphics) {
    hue = _hue;
    if (hue == -1) {
      black_and_white = true;
    }
    period = _period;
    graphics = _graphics;
    current = null;
    last = null;
  }

  // add a point to the curve
  void AddPoint(float x, float y) {
    if (current != null) {
      // if the current is null, we are setting the first point
      last = current.copy();
    }
    current = new PVector(x, y);
  }

  // since the graphics item we are working on does not reset each frame,
  // we can just draw another line over it
  void drawPoints() {
    if (current == null || last == null) {
      return;
    }

    graphics.push();
    if (black_and_white) {
      graphics.stroke(255);
    } else {
      graphics.stroke(hue, 255, 255);
    }
    graphics.strokeWeight(1);
    graphics.noFill();
    graphics.line(last.x, last.y, current.x, current.y);
    graphics.pop();
  }

  // return curve period
  float getPeriod() {
    return period;
  }

  // deletes all saved points
  void resetPoints() {
    current = null;
    last = null;
  }

  void toggleColors() {
    black_and_white = !black_and_white;
  }

}
