import queryabolt
import cadquery as cq

class Workplane(queryabolt.WorkplaneMixin, cq.Workplane):
    pass

press_fit = 0
tight_fit = 0.1

# Chamfer
c = 0.5

# Thickness. Not load-bearing by any means.
t = 2.4

v_slot_hold_h = 5

v_slot_d = 20
v_slot_slot_w = 6
v_slot_d_fit = v_slot_d + tight_fit
v_slot_bolt = "M4"

# This is to protect the camera cable from the sharp edges of the top of the
# extrusion and guide it on the right path towards the Pi.
def guide():
    d = v_slot_d_fit + 2 * t
    h = d / 4
    guide_l = d / 2
    guide_w = d / 10
    guide_h = h * 1.75

    # Make the v-slot mount, fillet edges ribbon will pass through.
    vslotMount = cq.Workplane().box(d, d, v_slot_hold_h + t)
    vslotMount = vslotMount.faces("-Z").shell(-t, kind = "intersection")
    vslotMount = vslotMount.edges("#Y and >Z").fillet(1)

    # Make the top guide.
    vslotMount = vslotMount.faces("+Z").workplane().rect(d, guide_l).extrude(h)
    vslotMount = vslotMount.edges(">Z and |X").fillet(h * 0.75)
    vslotMount = vslotMount.pushPoints([(-(d - guide_w) / 2, 0), ((d - guide_w) / 2, 0)]).rect(guide_w, guide_l).extrude(guide_h)
    vslotMount = vslotMount.edges(">Z").fillet(1)

    # And clearance for the rack.
    vslotMount = vslotMount.faces("<Y").workplane().center(0, -v_slot_hold_h / 2 - t).rect(v_slot_slot_w, v_slot_hold_h).cutThruAll()

    return vslotMount


show_object(guide(), name="guide")
