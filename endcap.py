import queryabolt
import cadquery as cq

fit = 0.1
loose_fit = 0.5

v_slot_d = 20
v_slot_slot_w = 6
v_slot_slot_d = 6
v_slot_slot_outer_w = 9.16
v_slot_slot_inner_w = 11
v_slot_slot_inner_h = 1.64
v_slot_slot_inner_slope_h = 2.66
v_slot_outer_wall_t = 1.8
t_cap = 1.6
t_slot = 2.6

def endcap():
    w_fit = v_slot_slot_w - fit
    inner_w_fit = v_slot_slot_inner_w - fit
    outer_w_fit = v_slot_slot_outer_w - loose_fit # This is a tricky corner, even for properly tuned printers & filaments.
    d_fit = v_slot_slot_d - fit

    cap = cq.Workplane("XY").rect(v_slot_d, v_slot_d).extrude(t_cap)

    pts = [
        (0, 0),
        (0, -outer_w_fit / 2),
        (-v_slot_outer_wall_t, -w_fit / 2),
        (-v_slot_outer_wall_t, -inner_w_fit / 2),
        (-v_slot_outer_wall_t - v_slot_slot_inner_h, -inner_w_fit / 2),
        (-d_fit, -w_fit / 2),
        (-d_fit, 0),

        (-d_fit , w_fit / 2),
        (-v_slot_outer_wall_t - v_slot_slot_inner_h, inner_w_fit / 2),
        (-v_slot_outer_wall_t, inner_w_fit / 2),
        (-v_slot_outer_wall_t, w_fit / 2),
        (0, outer_w_fit / 2),
    ]
    s = cq.Sketch().polygon(pts)
    cap = cap.faces(">Z").workplane().polarArray(10, 0, 360, 4).placeSketch(s).extrude(t_cap + t_slot)
    return cap.edges(">Z or <Z").chamfer(0.5)

show_object(endcap(), name="endcap")
