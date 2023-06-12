use <../../catchnhole/catchnhole.scad>;
use <../../nopscadlib/utils/annotation.scad>;

height = 0.5;

ARROW_DEFAULT = 10;
ARROW_OFFSET = 0.1;

module nut (options, arrow = ARROW_DEFAULT) {
  do_arrow = is_num(arrow) ? arrow > 0 : arrow != false;
  arrow_l = !is_num(arrow) && do_arrow ? ARROW_DEFAULT : arrow;
  h = nut_height(options);
  offset_ = arrow_l * ARROW_OFFSET;

  color("gray") difference() {
    nutcatch_parallel(options);
    translate([ 0, 0, -0.01 ]) {
      bolt(options, length = h + 0.02);
    }
  }

  if (arrow) {
    translate([ 0, 0, arrow_l + h ]) rotate([ 180, 0, 0 ])
      arrow(length = arrow_l - offset_);
  }
}

// TODO: make the arrow length proportional to bolt diameter/length
module
bolt_ (options, length, kind = "socket_head", arrow = ARROW_DEFAULT, fastened = true) {
  do_arrow = is_num(arrow) ? arrow > 0 : arrow != false;
  arrow_l = !is_num(arrow) && do_arrow ? ARROW_DEFAULT : arrow;
  offset_ = arrow_l * ARROW_OFFSET;
  translate(fastened ? [ 0, 0, 0 ] : [ 0, 0, length + arrow_l ]) {
    color("gray") bolt(options, length, kind = kind);

    if (do_arrow && !fastened)
      translate([ 0, 0, -arrow_l ]) arrow(length = arrow_l - offset_);
  }
}
