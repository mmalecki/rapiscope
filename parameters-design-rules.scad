use <catchnhole/catchnhole.scad>;

bolt = "M3";

press_fit = 0;
tight_fit = 0.1;
fit = 0.2;
v_slot_sliding_fit = 0.021;  // H7/h6 over a 20 mm "shaft"
loose_fit = 0.5;

bolt_wall_min_d = 3.6;
bolt_wall_d = bolt_diameter(bolt) + bolt_wall_min_d;

bearing_wall_min_d = 5;
v_slot_wall_min_t = 4;

nut_wall_min_h = 1.6;
nut_wall_min_d = 4;

nut_wall_h = nut_height(bolt) + nut_wall_min_h;
nut_wall_d = nut_width_across_corners(bolt) + nut_wall_min_d;
