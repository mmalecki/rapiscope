# This can be used for hot-swapping the microscope column.

import cadquery as cq
from ocp_vscode import *
from cq_queryabolt import boltData, nutData
from settings import Settings
from workplane import Workplane

set_defaults(reset_camera=Camera.KEEP)

bolt_d = boltData(Settings.v_slot_bolt)['diameter']
wall_t = Settings.wall_t
v_slot_d = Settings.v_slot_d

# Fits
fit = Settings.fit
loose_fit = Settings.loose_fit
running_fit = 0.121 * 2

channel_w = 6.2
channel_d = 6.1

slider_id = v_slot_d + loose_fit
slider_od = slider_id + 2 * wall_t
slider_tab_t = (loose_fit - running_fit) / 2

w = (bolt_d + wall_t) * 2 + slider_od
slider_shape = (cq.Sketch()
                .slot(w, v_slot_d + wall_t)
                .push([(0, wall_t / 2 - loose_fit / 2)])
                .rect(slider_id, slider_id, mode='s')
                .rarray(slider_id - slider_tab_t , slider_id / 2, 2, 2)
                .rect(slider_tab_t,v_slot_d / 4)
                )

h = 40

def receptacle():
    r = Workplane("XY")
    r = r.placeSketch(slider_shape).extrude(h)
    r = r.faces(">Z").workplane().rarray(w + v_slot_d / 2, 1, 2, 1).rect((w - slider_od) + v_slot_d / 2, v_slot_d + wall_t).cutBlind(-(h - wall_t))
    r = r.faces(">Z[1]").workplane().center(0, wall_t / 2).rarray(w, 1, 2, 1).boltHole(Settings.v_slot_bolt, clearance=loose_fit)
    r = r.faces(">Z[1]").edges("(not %Circle) and |Y").fillet(wall_t)
    r = r.faces(">Z[1]").edges("(not %Circle) and (not |Y)").fillet(wall_t / 2)
    r = r.faces(">Y").workplane(centerOption="CenterOfBoundBox").rarray(1, bolt_d * 4, 1, 2).slot2D(bolt_d * 2.5, bolt_d + loose_fit, 90).cutThruAll()
    r = r.faces(">Z or <Z").edges("not %Circle").chamfer(wall_t / 4)
    return r


r = receptacle()
r.export("z-axis-receptacle.step")
show(r)


# show_all()
