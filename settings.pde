//--------------------------------------------------------//
//                     INSTRUCTIONS                       //
// use left/rigt keys to set the animation duration       //
// use up/down arrow to set the initial angle (phase)     //
// press E to record the animation                        //
// press Q to toggle between colors and black and white   //
// press W to show fps                                    //
// press R to change the rotation direction               //
//--------------------------------------------------------//

// USER SETTINGS
boolean black_and_white = false; // set to true to draw the curves is black and white - toggle with "q"
boolean show_fps = false; // show fps on the top right corner - toggle with "w"
boolean recording = false; // record the animation - toggle with "e"
boolean anti_clockwise = true; // rotation direction - toggle with "r"
int rows = 10; // rows of circles
int cols = 10; // columns of circles
int duration = 15; // complete animation duration (seconds) - change with left/right key
int fps = 120; // anumation fps
float circle_scl = 0.75; // relative size of circles inside containers
float alpha_scl = 0.25; // circle rotation multiplier
float border = 0.1; // image border. I didn't use scale() because it slowed down
                    // the animation to less then half the fps
