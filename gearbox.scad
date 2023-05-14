include <parameters-design-rules.scad>;
include <parameters.scad>;
include <v-slot/parameters.scad>;
use <catchnhole/catchnhole.scad>;
use <gears/gears.scad>;
use <v-slot.scad>;
use <v-slot/v-slot.scad>;

$fn = 200;

// Width of the gears:
w = 6;

// Gear module:
m = 1;

/* [ Worm ] */
thread_starts = 2;
lead_angle = 10;

// Worm mount:
//
// We're using bolts as shafts here, so our length choices are limited. We're therefore
// going to drive parts of the worm design off the shaft length.

// Bolt size to use as shaft:
worm_shaft = "M5";
// Shaft length:
worm_shaft_l = 35;
worm_bearing_h = 7;
worm_bearing_id = 8;
worm_bearing_od = 22;
worm_bearing_holder_d = worm_bearing_od + bearing_wall_min_d;
worm_shaft_nut_h = nut_height(worm_shaft, kind = "hexagon_lock");
worm_shaft_nut_wall_d = nut_width_across_corners(worm_shaft) + nut_wall_min_d;

worm_add_l = worm_shaft_nut_h + nut_wall_min_h;
worm_length = worm_shaft_l - worm_bearing_h - worm_add_l;

worm_r = m * thread_starts / (2 * sin(lead_angle));  // From gears/gears.scad.

/* [ Pinion ] */
// Bolt size to use as shaft:
pinion_shaft = "M3";

pinion_teeth = 16;
pinion_bearing_d = 10;
pinion_bearing_t = 4;
pinion_h = pinion_bearing_t;
pinion_d = m * pinion_teeth;

/* [ Rack ] */
// Length of the rack:
rack_l = 50;
rack_mount_bolt_l = 8;
rack_mount_d = rack_mount_bolt_l;
rack_mount_t_nut_clearance = 11.5;
rack_mount_t_nut_cam_h = 1;
rack_mount_h = rack_mount_t_nut_clearance + nut_wall_min_d;

rack_mount_bolt = "M4";

/* [ Slider ] */
// Thickness of the slider wall:
slider_t = v_slot_wall_min_t;
slider_d = v_slot_d + 2 * v_slot_wall_min_t;
slider_bolt_s = 20;  // Spacing of the slider mounting bolts.
slider_bolt_x_s = slider_d + nut_wall_d;
slider_h = slider_bolt_s + nut_wall_d;

/* [ Housing ] */
housing_t = bolt_wall_d;
housing_y_offset = slider_d / 2 + nut_wall_d / 2 - housing_t / 2;
housing_l = slider_h;
housing_d = worm_bearing_holder_d / 2 + pinion_d - slider_t + worm_r;
housing_z_offset = -worm_length / 2 - worm_add_l + (worm_shaft_l - housing_l);

/* [ Print ] */
bolt_hole_sacrificial_layer = 0.2;

/* [ Assembly ] */
// Show the housing:
housing = true;
// Show the worm gear:
worm = true;
// Show the pinion gear:
pinion = true;
// Show the rail:
rail = true;
// Show the rack:
rack = true;
// Show the slider:
slider = true;

echo("Slider bolt X spacing:", slider_bolt_x_s);

module gearbox_housing () {
  difference() {
    union() {
      translate([ -housing_y_offset - housing_t, -housing_d - slider_t, housing_z_offset ])
        cube([ housing_t, housing_d, housing_l ]);

      gearbox_to_worm() {
        translate([ 0, 0, worm_length ]) {
          cylinder(d = worm_bearing_holder_d, h = worm_bearing_h);
          rotate([ 0, 0, 180 ]) translate([ 0, -worm_bearing_holder_d / 2 ])
            cube([ housing_y_offset, worm_bearing_holder_d, worm_bearing_h ]);
        }
      }

      gearbox_to_pinion() {
        translate([ 0, 0, housing_y_offset ]) {
          rotate([ 180, 0, 0 ]) {
            pinion_spacer_d = bolt_diameter(pinion_shaft) + bolt_wall_min_d;
            cylinder(
              d2 = pinion_spacer_d, d1 = pinion_spacer_d + 0.4,
              h = housing_y_offset - w / 2 - tight_fit
            );
          }
        }
      }
    }

    translate([ -housing_y_offset - housing_t / 2, 0, bolt_wall_d / 4 ]) {
      for (side = [ 1, -1 ]) {
        translate([ 0, 0, side * slider_bolt_s / 2 ]) {
          rotate([ 90, 0, 0 ])
            bolt(bolt, length = housing_d + slider_t, kind = "socket_head");
        }
      }
    }

    gearbox_to_worm() {
      translate([ 0, 0, worm_length ]) {
        cylinder(d = worm_bearing_od, h = worm_bearing_h);
      }
    }
    gearbox_to_pinion() {
      translate([ 0, 0, housing_y_offset + housing_t ]) {
        rotate([ 180, 0, 0 ]) {
          nutcatch_parallel(pinion_shaft);
          difference() {
            bolt(pinion_shaft, length = v_slot_d, kind = "socket_head");
            translate([ 0, 0, nut_height(pinion_shaft) ])
              bolt(pinion_shaft, length = bolt_hole_sacrificial_layer);
          }
        }
      }
    }
  }
}
module gearbox_to_worm () {
  translate([ 0, -worm_r - pinion_d, -worm_length / 2 ]) children();
}

module gearbox_to_pinion () {
  translate([ 0, -pinion_d / 2 ]) rotate([ 90, 0, -90 ]) children();
}

module gearbox_pinion () {
  difference() {
    translate([ 0, 0, -w / 2 ]) spur_gear(
      m, pinion_teeth, w, bore = bolt_diameter(pinion_shaft) + fit, optimized = false,
      helix_angle = -lead_angle
    );
    translate([ 0, 0, -pinion_bearing_t + w / 2 ])
      cylinder(d = pinion_bearing_d, h = pinion_bearing_t);
  }
}

module gearbox_worm () {
  l_fit = worm_length - fit;
  difference() {
    union() {
      translate([ 0, 0, l_fit ]) cylinder(d = worm_bearing_id, h = worm_bearing_h + fit);
      worm(m, thread_starts, l_fit, bolt_diameter(worm_shaft), lead_angle = lead_angle);
      translate([ 0, 0, -worm_add_l + fit ])
        cylinder(d = worm_shaft_nut_wall_d, h = worm_add_l);
    }

    translate([ 0, 0, -worm_add_l + fit ]) {
      nutcatch_parallel(worm_shaft, kind = "hexagon_lock");

      difference() {
        bolt(worm_shaft, length = worm_shaft_l, kind = "socket_head");
        if (bolt_hole_sacrificial_layer != 0) {
          translate([ 0, 0, worm_shaft_nut_h ])
            cylinder(d = bolt_diameter(worm_shaft), h = bolt_hole_sacrificial_layer);
        }
      }
    }
  }
}

module slider () {
  d = slider_d;
  linear_extrude(slider_h) {
    difference() {
      square([ d, d ], center = true);
      translate([ -v_slot_slot_outer_w / 2, -d / 2 ])
        square([ v_slot_slot_outer_w, v_slot_wall_min_t ]);
      v_slot_2d_clearance(fit = loose_fit);
    }
    v_slot_2d_slider(loose_fit);
  }

  // This is pretty convoluted.
  for (side_x = [ 1, -1 ]) {
    for (side_y = [ 1, -1 ]) {
      translate([
        side_x * (slider_d / 2 + nut_wall_d / 2),
        side_y * (slider_d / 2 - nut_wall_h / 2),
      ]) {
        difference() {
          translate([ -nut_wall_d / 2, -nut_wall_h / 2 ]) {
            cube([ nut_wall_d, nut_wall_h, slider_h ]);
          }
          translate([ 0, 0, slider_h / 2 ]) {
            for (nutcatch_side_z = [ 1, -1 ]) {
              translate([ 0, 0, nutcatch_side_z * slider_bolt_s / 2 ]) {
                rotate([ side_y == 1 ? 90 : 270, 0, 0 ]) {
                  nutcatch_parallel(bolt);
                  rotate([ 0, 180, 0 ]) bolt(bolt, length = nut_wall_h);
                }
              }
            }
          }
        }
      }
    }
  }
}

module gearbox_rack_mount () {
  translate([ -w, -(rack_mount_d - v_slot_slot_h) ]) {
    difference() {
      cube([ w, rack_mount_d, rack_mount_h ]);
      translate([ w / 2, rack_mount_d, rack_mount_h / 2 ]) rotate([ 90, 90, 0 ]) {
        bolt(rack_mount_bolt, rack_mount_bolt_l, kind = "socket_head");
        cylinder(
          h = v_slot_slot_h - (v_slot_slot_cam_h - rack_mount_t_nut_cam_h - tight_fit),
          d = rack_mount_t_nut_clearance
        );
      }
    }
  }
}

module gearbox_rack () {
  translate([ w / 2, 0 ]) {
    translate([ 0, 0, -rack_l / 2 - rack_mount_h + 2 * m ]) gearbox_rack_mount();

    rotate([ 90, 90, -90 ]) rack(
      m, length = rack_l, height = v_slot_slot_h, width = w, pressure_angle = 20,
      helix_angle = lead_angle
    );
    translate([ 0, 0, rack_l / 2 ]) gearbox_rack_mount();
  }
}

module assembly (rail = true, pinion = true, housing = true) {
  if (housing)
    gearbox_housing();

  if (worm)
    gearbox_to_worm() gearbox_worm();

  if (pinion)
    gearbox_to_pinion() gearbox_pinion();

  if (rack) {
    gearbox_rack();
  }

  translate([ 0, v_slot_d / 2 ]) {
    if (rail) {
      translate([ 0, 0, -rack_l / 2 ]) color("silver") v_slot(rack_l);
    }
    if (slider) {
      translate([ 0, 0, housing_z_offset ]) slider();
    }
  }
}

assembly(rail, pinion, housing);
