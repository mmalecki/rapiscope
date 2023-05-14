include <parameters-design-rules.scad>;
include <v-slot/parameters.scad>;

slider_w = (v_slot_d - v_slot_slot_outer_w) / 2;
// Add a taper to lessen ringing (maybe?).
slider_taper_w = 0.1 * slider_w;

module v_slot_2d_slider (original_fit) {
  slider_h = original_fit - v_slot_sliding_fit;
  for (side = [0:3]) {
    rotate([ 0, 0, side * 90 ]) {
      translate([ v_slot_d / 2 + v_slot_sliding_fit, 0 ]) {
        for (part = [ -1, 1 ]) {
          translate([ 0, part * (v_slot_slot_outer_w / 2 + slider_w / 2) ]) {
            polygon(points = [
              [ 0, -slider_w / 2 + slider_taper_w ],
              [ 0, slider_w / 2 - slider_taper_w ],
              [ slider_h, slider_w / 2 ],
              [ slider_h, -slider_w / 2 ],
            ]);
          }
        }
      }
    }
  }
}
