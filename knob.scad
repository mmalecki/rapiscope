use <catchnhole/catchnhole.scad>
use <knobs/knob.scad>

$fn = 50;

/* [ Knob ] */
head_d = 42;
head_h = 10;

/* [ Knob shape ] */
shape = "star";  // ["star", "round"]
chamfer = 0.5;

/* [ Star shape ] */
star_points = 4;

/* [ Spacer ] */
stem_d = 25;
stem_h = 5;

/* [ Nut ] */
nut = "M8";

module worm_knob () {
  knob(head_d, head_h, shape, chamfer, stem_d, stem_h, star_points, center = true) {
    translate([ 0, 0, -nut_height(nut) ]) nutcatch_parallel(nut);
  }
}

worm_knob();
