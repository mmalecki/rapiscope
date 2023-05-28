include <../parameters.scad>;
include <../v-slot/parameters.scad>;
use <../gearbox.scad>
use <../v-slot/v-slot.scad>;

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

// Show ranges of motion:
rom = true;

// Housing opacity:
housing_alpha = 1;  //[0:0.1:1]

module gearbox_assembly (
  housing = true,
  pinion = true,
  worm = true,
  rom = false,
  housing_alpha = 1
) {
  if (housing) {
    color(undef, housing_alpha) gearbox_housing();
  }

  gearbox_to_drive_train() {
    if (worm)
      gearbox_to_worm() gearbox_worm();

    if (pinion)
      gearbox_to_pinion() gearbox_pinion_assembly(rom = rom);
  }
}

module drive_train_assembly (
  rail = true,
  rack = true,
  housing = true,
  pinion = true,
  worm = true,
  rom = false,
  housing_alpha = 1,
) {
  gearbox_assembly(housing, pinion, worm, rom, housing_alpha);

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

drive_train_assembly(rail, rack, housing, pinion, worm, rom, housing_alpha);
