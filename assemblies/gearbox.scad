include <../nopscadlib/core.scad>
include <../nopscadlib/vitamins/ball_bearings.scad>
include <../nopscadlib/vitamins/screws.scad>
include <../parameters-design-rules.scad>;
include <../parameters.scad>;
include <../v-slot/parameters.scad>;
use <../catchnhole/catchnhole.scad>
use <../gearbox.scad>
use <../knob.scad>
use <../nopscadlib/utils/annotation.scad>;
use <../nopscadlib/vitamins/ball_bearing.scad>;
use <../nopscadlib/vitamins/screw.scad>;
use <../v-slot/v-slot.scad>;
use <./vitamins/fasteners.scad>

$fn = 50;

/* [ Assembly ] */
// How much to explode the assembly:
e = 25;
// How long should the arrows be:
arrow = 10;
// How to show the fasteners:
fasteners = "exploded";  // [no:No, exploded:Exploded, fastened: Fastened]
// Show the housing:
housing = true;
// Show the worm gear:
worm = true;
// Show the worm gear bearings:
worm_bearings = true;
// Show the worm shaft:
worm_shaft_ = true;
// Show the pinion gear:
pinion = true;
// Show the rail:
rail = true;
// Show the rack:
rack = true;
// Show the slider:
slider = true;

// Show ranges of motion:
rom = true;

// Housing opacity:
housing_alpha = 1;  //[0:0.1:1]

module gearbox_worm_assembly (e, fasteners) {
  fastened = fasteners == "fastened";
  e_f = fasteners == "exploded" ? e : 0;

  if (worm_shaft_) {
    gearbox_worm_to_worm_bolt() {
      if (fasteners != "no") {
        translate([ 0, 0, e_f * (5 / 4) ])
          bolt_(worm_shaft, worm_shaft_l, kind = "hex_head", arrow, fastened);
        translate([ 0, 0, -e_f * (3 / 4) + worm_bearing_h + fit / 2 ])
          nut(worm_shaft, arrow);
      }
    }
  }

  if (worm_bearings)
    gearbox_worm_to_worm_bearings() {
      translate([ 0, 0, bb_width(BB608) / 2 ]) {
        translate([ 0, 0, e ]) {
          ball_bearing(BB608);
          translate([ 0, 0, -arrow ]) arrow(length = arrow);
        }
      }
    }

  if (worm)
    gearbox_worm();
}

module gearbox_assembly (
  e = 0,
  housing = true,
  pinion = true,
  worm = true,
  rom = false,
  housing_alpha = 1
) {
  fastened = fasteners == "fastened";
  e_f = fasteners == "exploded" ? e : 0;

  if (housing) {
    color(undef, housing_alpha) gearbox_housing();
  }

  gearbox_to_drive_train() {
    gearbox_to_worm() gearbox_worm_assembly(e, fasteners);

    if (pinion)
      gearbox_to_pinion() gearbox_pinion_assembly(e, fasteners, rom = rom);
  }
}

module gearbox_pinion_assembly (e, fasteners, rom = false) {
  if (rom) {
    translate([ 0, 0, -w / 2 ]) {
      color("red", 0.25) cylinder(d = m * pinion_teeth + 2 * m, h = w);
    }
  }
  gearbox_pinion_to_mount() {
    nut(pinion_shaft);
    bolt_(pinion_shaft, length = housing_ow(), kind = "socket_head");
  }
  gearbox_pinion();
}

module drive_train_assembly (
  e = 0,
  rail = true,
  rack = true,
  housing = true,
  pinion = true,
  worm = true,
  rom = false,
  housing_alpha = 1,
) {
  gearbox_assembly(e, housing, pinion, worm, rom, housing_alpha);

  if (rack) {
    gearbox_rack();
  }

  translate([ 0, v_slot_d / 2 ]) {
    if (rail) {
      color("silver") v_slot(rack_l);
    }
    if (slider) {
      gearbox_to_drive_train() translate([ 0, 0, -slider_h() / 2 ]) slider();
    }
  }
}

drive_train_assembly(e, rail, rack, housing, pinion, worm, rom, housing_alpha);
