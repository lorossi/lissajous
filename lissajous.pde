int started_recording; // first recorded (saved) frame
float scl; // size of cicles container
float alpha; // angle
float alpha_increment;  // increment of angle alpha at each iteration
float r; // circle radius
float phi; // angle initial phase - change with up/down arrow keys
ArrayList<Curve> curves; // ArrayList that contains all the infos about curves (period, hue, points)
PGraphics curvegraphic; // buffer containing the curves. I put this on a separate graphics item
// in order to speed up the drawing. Before this approach, I used to store
// every point inside an ArrayList in the Curve class in order to draw it all
// over again each frame. Now we just draw a line each frame and copy the whole
// item behind the circles and everything else. FPS went from 10/15 in later stages
// to a solid 60.

// least common multiplier of two numbers
float lcm(float a, float b) {
  return (a * b) / gcd(a, b);
}

// gratest common divisor of two numbers
// recursive function
float gcd(float a, float b) {
  if (a == 0) {
      return b;
    }
   return gcd(b % a, a);
}

// calculates angle increment after each frame
float angleIncrement(int duration) {
  return (float) 2 * PI / (duration * fps * alpha_scl);
}

// draws a circle and its pointer given its x, y coordinates
void drawCircle(float x, float y) {
  float rho, theta, px, py;
  rho = scl/2 * circle_scl; // radius
  if (x == 0) { // we're dealing with the column
    theta = (float) y * alpha * alpha_scl;
  } else { // it's the row
    theta = (float) x * alpha * alpha_scl;
  }
  // polar to algebric
  px = rho * cos(theta);
  py = rho * sin(theta);

  push();
  translate(x * scl + scl/2 + border * width, y * scl + scl/2 + border * height);
  // draw the circle
  stroke(255, 127);
  noFill();
  circle(0, 0, scl * circle_scl);
  // draw the small pointer
  fill(255);
  noStroke();
  circle(px, py, r*2);
  pop();
}

// draws the line connecting the pointer with the last curve in its row or column
void drawLine(float x, float y) {
  float rho, theta, px, py, px_last, py_last;
  rho = scl/2 * circle_scl; // radius
  if (x == 0) { // we're dealing with the column
    theta = (float) y * alpha * alpha_scl;
  } else { // it's the row
    theta = (float) x * alpha * alpha_scl;
  }

  // polar to algebric (start point)
  px = rho * cos(theta);
  py = rho * sin(theta);
  // polar to algebric (last point)
  px_last = rho * cos((cols - 1) * alpha * alpha_scl) + (cols - 1) * scl;
  py_last = rho * sin((rows - 1) * alpha * alpha_scl) + (rows - 1) * scl;

  push();
  translate(x * scl + scl/2  + border * width, y * scl + scl/2  + border * height);
  stroke(255, 64);
  if (x == 0) {
    line(px, py, px_last, py); // horizontal line
  } else {
    line(px, py, px, py_last); // vertical line
  }
  pop();
}

// draws each Lissajous curve inside its graphic element
void drawLissajous() {
  curvegraphic.smooth(8);
  curvegraphic.beginDraw();
  for (int x = 1; x < rows; x++) {
    for (int y = 1; y < cols; y++) {
      int i;
      Curve c;

      i = returnIndex(x - 1, y - 1, cols - 1); // x y to index conversion
      c = curves.get(i);

      // gets the period (T) of the curve to avoid drawing new points if its
      // animation has already ended
      float period = c.getPeriod();

      if (abs(alpha) < period + phi) { // valid for both directions
        // if this is false, everything has already been drawn and we are just retracing the same line
        float thetax, thetay, rho, px, py;
        // calculate angle for the corrisponding circles (row and column)
        thetax = (float) x * alpha * alpha_scl;
        thetay = (float) y * alpha * alpha_scl;
        // polar to algebric conversion
        rho = scl/2 * circle_scl;
        px = rho * cos(thetax);
        py = rho * sin(thetay);
        // add point to curve
        c.AddPoint(px, py);

        curvegraphic.push();
        curvegraphic.stroke(c.hue, 255, 255);
        curvegraphic.translate(x * scl + scl/2 + border * width, y * scl + scl/2 + border * height);
        c.drawPoints(); // draw the line (since it's so small, I call it point)
        curvegraphic.pop();
      }
    }
  }
  curvegraphic.endDraw();
}

// return array index given 2d coordinates
int returnIndex(int x, int y, int w) {
  return x + w * y;
}

// resets everything in the drawing
void resetDrawing() {
  alpha = phi;
  curvegraphic.beginDraw();
  curvegraphic.background(0); // clear curves
  curvegraphic.endDraw();

  // resets all points inside che curves
  for (Curve c : curves) {
    c.resetPoints();
  }
}

void setup() {
  size(1000, 1000);
  background(0);
  colorMode(HSB, 255);
  frameRate(fps);

  // size of each container
  scl =  min((float) width * (1 - 2 * border) / cols, (float) height * (1 - 2 * border) / rows);
  r = scl / 50;  // circle radius
  phi = 0; // initial phase
  alpha = 0;  // angle
  started_recording = 0; // just in case
  curves = new ArrayList<Curve>();
  alpha_increment = angleIncrement(duration);// angle increment after each frame

  curvegraphic = createGraphics(width, height); // create curve container
  for (int x = 1; x < rows; x++) {
    for (int y = 1; y < cols; y++) {
      // the hue is proportional to the distance from the origin
      // set to -1 for black and white
      double hue;
      if (black_and_white) {
        hue = -1;
      } else {
        hue =  Math.sqrt((x - 1) * (x - 1) + (y - 1) * (y - 1)) / Math.sqrt((rows - 1) * (rows - 1) + (cols - 1) * (cols - 1)) * 255;
      }
      float period = 2 * PI * lcm(x * alpha_scl,y * alpha_scl) / (x * alpha_scl * y * alpha_scl);  // period of each curve

      Curve nc = new Curve((float) hue, period, curvegraphic); // create new curve
      curves.add(nc); // add new curve to the ArrayList
    }
  }

  curvegraphic.smooth(8);
  curvegraphic.beginDraw();
  curvegraphic.colorMode(HSB, 255);
  curvegraphic.background(0);
  curvegraphic.endDraw();
}

void draw() {
  background(0);

  drawLissajous(); // draw all Lissajous curves on their graphics element
  image(curvegraphic, 0, 0); // draw curves on main sketch

  // draw the circles for the first column
  for (int x = 1; x < rows; x++) {
    drawCircle(x, 0);
    drawLine(x, 0);
  }
  // draw the circles for the first line
  for (int y = 1; y < cols; y++) {
    drawCircle(0, y);
    drawLine(0, y);
  }

  // show fps
  if (show_fps) {
    int frames = (int) frameRate;
    push();
    if (frames >= fps - 5) {
      fill(85, 255, 255); // green
    } else if (frames >= fps - 15) {
      fill(43, 255, 255); // yellow
    } else {
      fill(0, 255, 255); // red
    }
    textSize(32);
    text(frames, 50, 50);
    pop();
  }

  // increase angle
  alpha += alpha_increment * (anti_clockwise ? 1 : -1);

  // if this is true, the animation has ended
  if (abs((alpha - phi) * alpha_scl) >= 2 * PI) {
    resetDrawing();
    for (Curve c : curves) {
      c.resetPoints();
    }
    if (recording) {
      recording = false; // end the recording
      println("Ended recording");
    }
  }

  // save each frame
  if (recording) {
    String folder = black_and_white ? "black_and_white" : "colors";
    saveFrame("frames/" + folder + "/frame-" + (frameCount - started_recording - 1) + ".png");
  }
}

void keyPressed() {
  // press q to toggle black and white or colored
  // press w bar to show fps
  // press e to start/stop recording
  // press r to toggle rotation direction
  // press up/down arrow to set initial phase (step of PI/4)
  // pres left/right to set duration time (1 second setps)


  println(keyCode);
  if (key == 'q') { // q
    resetDrawing();
    for (Curve c : curves) {
      c.toggleColors();
    }
  }
  else if (key == 'w') { // w
    show_fps = !show_fps;
  } else if (key == 'e') { // e
    recording = !recording;
    resetDrawing();
    started_recording = frameCount; // first recored frame
  } else if (key == 'r') {
    anti_clockwise = !anti_clockwise;
    resetDrawing();
  } else if (keyCode == 38)  { // up arrow
    phi += PI / 4;
    if (phi >= 2 * PI) phi -= (2 * PI) / alpha_scl; // constrain between 0 and 2 PI
    resetDrawing();
  } else if (keyCode == 40)  { // down arrow
    phi -= PI / 4;
    if (phi <= 0) phi += (2 * PI) / alpha_scl; // constrain between 0 and 2 PI
    resetDrawing();
  } else if (keyCode == 37) { // left arrow
    duration -= 1;
    if (duration < 1) {
      duration = 1;
    } else {
      alpha_increment = angleIncrement(duration);
    }

  } else if (keyCode == 39) { // right arrow
    duration += 1;
    alpha_increment = angleIncrement(duration);
  }
}

void mousePressed() {
  resetDrawing();
}
