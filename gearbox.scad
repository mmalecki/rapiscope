include <parameters-design-rules.scad>;
include <parameters.scad>;
include <v-slot/parameters.scad>;
use <catchnhole/catchnhole.scad>;
use <gears/gears.scad>;
use <v-slot.scad>;
use <v-slot/v-slot.scad>;

// Error correction for OpenSCAD flickering.
ec = 0.01;

/* [ Worm ] */
thread_starts = 2;
lead_angle = 10;

worm_bearing_holder_d = worm_bearing_od + bearing_wall_min_d;
worm_shaft_nut_h = nut_height(worm_shaft, kind = "hexagon_lock");
worm_shaft_nut_wall_d = nut_width_across_corners(worm_shaft) + nut_wall_min_d;

// Worm mount:
//
// Length of the mount at the bottom of the shaft:
worm_shaft_mount_h = worm_shaft_nut_h + fastener_wall_min_h;
// Length of the worm gear itself:
worm_length = worm_shaft_l - 2 * worm_bearing_h - worm_shaft_mount_h;

worm_r = m * thread_starts / (2 * sin(lead_angle));  // From gears/gears.scad.

bearing_z = [ worm_length / 2, -worm_length / 2 - worm_shaft_mount_h - worm_bearing_h ];

pinion_d = m * pinion_teeth;

/* [ Rack ] */
// Length of the rack (120 mm for 300 mm long v-slot, 220 mm for 400 mm):
rack_mount_bolt_l = 8;
rack_mount_d = rack_mount_bolt_l;

// TODO: `rack_mount_d` can likely be derived from design rules

// Rack mount bolt.
rack_mount_bolt = "M4";
// Measured cam height of the M4 t-nut.
rack_mount_t_nut_cam_h = 1;
// Measured clearance the M4 t-nut needs to rotate in the v-slot slot.
rack_mount_t_nut_clearance = 11.5;
rack_mount_h = rack_mount_t_nut_clearance + nut_wall_min_d;

/* [ Slider ] */
// Thickness of the slider wall:
slider_t = v_slot_wall_min_t;
slider_d = v_slot_d + 2 * v_slot_wall_min_t;
// Spacing of the slider mounting bolts in Z axis (X is determined by design rules):
slider_bolt_s = 20;
slider_bolt_x_s = slider_d + nut_wall_d;
slider_h = slider_bolt_s + nut_wall_d;

/* [ Housing ] */
housing_t = bolt_wall_d;
housing_w = slider_d / 2 + nut_wall_d / 2 - housing_t / 2;
housing_h = worm_shaft_l;
housing_l = worm_bearing_holder_d / 2 + pinion_d - slider_t + worm_r;
housing_z_offset = -worm_shaft_mount_h / 2;

/* [ Print ] */
bolt_hole_sacrificial_layer = 0.2;
part = "";  // ["", "housing", "worm", "pinion", "rack", "slider"]

$fn = part == "worm" ? 64 : 128;

function slider_h () = slider_h;

// Housing outer width:
function housing_ow () = (housing_w + housing_t) * 2;

echo("Slider bolt X spacing:", slider_bolt_x_s);
echo("Housing length:", housing_l);
echo("Housing internal width:", housing_w * 2);
echo("Housing outer width:", housing_ow());
echo("Worm bearing holder length: ", worm_bearing_holder_d);

module gearbox_housing () {
  gearbox_housing_half();
  mirror([ 1, 0, 0 ]) gearbox_housing_half();
}

module gearbox_rib (a_x, a_y, b_x0, b_x1, b_y, h) {
  b_x2 = b_x0 + b_x1 + a_x;

  translate([ 0, 0, -h / 2 ]) linear_extrude(h) {
    polygon([ [ 0, 0 ], [ a_x, a_y ], [ b_x0 + a_x, b_y ], [ b_x2, b_y ], [ b_x2, 0 ] ]);
  }
}

module gearbox_worm_to_worm_bearings (top = true, bottom = true) {
  // XXX: full of hacks to get the bearing properly rotated for assembly instructions.
  // We're in the middle of the worm gear right now.
  b_z = concat(top ? [bearing_z[0]] : [], bottom ? [bearing_z[1]] : []);
  for (z = b_z) {
    translate([ 0, 0, z + (z == bearing_z[1] ? worm_bearing_h : 0) ]) {
      mirror(z == bearing_z[1] ? [ 0, 0, 1 ] : [ 0, 0, 0 ]) children();
    }
  }
}

module gearbox_worm_to_worm_bolt () {
  translate([ 0, 0, bearing_z[1] ]) children();
}

module gearbox_housing_half () {
  difference() {
    union() {
      translate([ -housing_w - housing_t, -housing_l - slider_t, housing_z_offset ])
        cube([ housing_t, housing_l, housing_h ]);

      gearbox_to_drive_train() {
        gearbox_to_worm() {
          gearbox_worm_to_worm_bearings() {
            translate([ 0, -worm_bearing_holder_d / 2 ])
              cube([ housing_w, worm_bearing_holder_d, worm_bearing_h ]);
          }
        }

        pinion_spacer_h = housing_w - w / 2 - tight_fit;
        pinion_spacer_d = bolt_diameter(pinion_shaft) + bolt_wall_min_d;
        rib_w = housing_l;
        translate([ -housing_w, -slider_t - rib_w ]) mirror([ 0, 1 ]) rotate([ 0, 0, 270 ])
          gearbox_rib(
            housing_l / 2,
            housing_w - worm_r -
              m,  // Length and height of first section (trying to avoid the worm gear)
            housing_l / 2 - pinion_d / 2 + slider_t - pinion_spacer_d / 2,
            pinion_spacer_d,  // Length and height of the final section (building up to
                              // the pinion gear spacer)
            pinion_spacer_h,  // Height of the final section
            pinion_spacer_d   // Width of the rib itself
          );
      }
    }

    translate([ -housing_w - housing_t / 2, 0, housing_h / 2 ]) {
      for (side = [ 1, -1 ]) {
        translate([ 0, 0, side * slider_bolt_s / 2 ]) {
          rotate([ 90, 0, 0 ])
            bolt(bolt, length = housing_l + slider_t, kind = "socket_head");
        }
      }
    }

    gearbox_to_drive_train() {
      gearbox_to_worm() {
        gearbox_worm_to_worm_bearings() {
          translate([ 0, 0, -ec ])
            cylinder(d = worm_bearing_od + press_fit, h = worm_bearing_h + ec * 2);
        }
      }
      gearbox_to_pinion() {
        gearbox_pinion_to_mount() {
          nutcatch_parallel(pinion_shaft);
          bolt(pinion_shaft, length = (housing_w + housing_t) * 2);
        }
      }
    }
  }
}
module gearbox_to_worm () {
  translate([ 0, -worm_r - pinion_d, 0 ]) children();
}

module gearbox_to_pinion () {
  translate([ 0, -pinion_d / 2 ]) rotate([ 90, 0, -90 ]) children();
}

module gearbox_pinion_to_mount () {
  translate([ 0, 0, housing_w + housing_t ]) {
    rotate([ 180, 0, 0 ]) children();
  }
}

module gearbox_pinion () {
  difference() {
    translate([ 0, 0, -w / 2 ]) {
      spur_gear(
        m, pinion_teeth, w, bore = bolt_diameter(pinion_shaft) + fit, optimized = false,
        helix_angle = -lead_angle
      );
    }
    translate([ 0, 0, -pinion_bearing_h + w / 2 ])
      cylinder(d = pinion_bearing_od, h = pinion_bearing_h);
  }
}

module gearbox_worm () {
  l_fit = worm_length - fit;
  mount_h = worm_shaft_mount_h;

  // Center around the drive train point:
  translate([ 0, 0, -l_fit / 2 - mount_h ]) {
    difference() {
      union() {
        cylinder(d = max(worm_shaft_nut_wall_d, 2 * (worm_r + m)) - m / 3, h = mount_h);
        translate([ 0, 0, mount_h ])
          worm(m, thread_starts, l_fit, bolt_diameter(worm_shaft), lead_angle = lead_angle);
      }

      nutcatch_parallel(worm_shaft, kind = "hexagon_lock");

      difference() {
        translate([ 0, 0, -worm_bearing_h ])
          bolt(worm_shaft, length = worm_shaft_l, kind = "socket_head");
        if (bolt_hole_sacrificial_layer != 0) {
          translate([ 0, 0, worm_shaft_nut_h ])
            cylinder(d = bolt_diameter(worm_shaft), h = bolt_hole_sacrificial_layer);
        }
      }
    }
  }
}

module worm_assembly () {}

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

  slider_mount_panes();
}

module slider_mount_panes () {
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
      translate([ w / 2, rack_mount_d, rack_mount_h * 3 / 4 ]) rotate([ 90, 90, 0 ]) {
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
  mx = m / cos(lead_angle);  // copied from gears/gears.scad
  translate([ w / 2, 0 ]) {
    translate([ 0, 0, mx ]) mirror([ 0, 0, 1 ]) gearbox_rack_mount();

    translate([ 0, 0, rack_l / 2 ]) rotate([ 90, 90, -90 ]) rack(
      m, length = rack_l, height = v_slot_slot_h, width = w, pressure_angle = 20,
      helix_angle = lead_angle
    );
    translate([ 0, 0, rack_l - mx ]) gearbox_rack_mount();
  }
}

module gearbox_to_drive_train () {
  translate([ 0, 0, housing_h / 2 ]) children();
}

module print () {
  if (part == "housing")
    rotate([ 90, 0, 0 ]) gearbox_housing();
  else if (part == "pinion")
    gearbox_pinion();
  else if (part == "worm")
    gearbox_worm();
  else if (part == "rack")
    rotate([ 0, 90, 0 ]) gearbox_rack();
  else if (part == "slider")
    slider();
  else
    assert(false, "part needs to be set");
}

print();
