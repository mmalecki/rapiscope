// These are the main parameters you can modify to tweak your rapiscope.

// Width of the gears (this is the width of the v-slot extrusion slot):
w = 6;

// Gear module:
m = 1.5;

// The length of the rack for the Z axis motion system.
// The default here applies to the 30 cm long Z axis, set 240 mm here if
// using a 40 cm long Z axis.
rack_l = 140;
slider_bolt_s = 20;  // Spacing of the slider mounting bolts.

/* [ Worm ] */
// We're using bolts as shafts here, so our length choices are limited. We're therefore
// going to drive parts of the worm design off the shaft length.

// Bolt size to use as shaft:
worm_shaft = "M8";
// Shaft length:
worm_shaft_l = 50;

// We use the 608 bearing for the worm by default:
// Height of the worm bearing:
worm_bearing_h = 7;
// Internal diameter of the worm bearing (we don't currently handle a case where
// this is different than the worm bearing shaft, but it should amount to a single
// `cylinder`, the previous version did it):
worm_bearing_id = 8;
// Outer diameter of the worm bearing:
worm_bearing_od = 22;

/* [ Pinion ] */
// Bolt size to use as shaft:
pinion_shaft = "M3";

// How many teeth the pinion gear should have:
pinion_teeth = 16;

// Outer diameter of the pinion bearing.
pinion_bearing_od = 10;
// Height of the pinion bearing.
pinion_bearing_h = 4;
