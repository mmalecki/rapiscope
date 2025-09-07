import cadquery as cq
from ocp_vscode import *
from cq_queryabolt import boltData, nutData
from settings import Settings
from workplane import Workplane

loose_fit = Settings.loose_fit
bearing_od = 16
bearing_t = 5
bearing_id = 5

scope_d = Settings.scope_d
bolt_d = boltData(Settings.frame_bolt)['diameter']
wall_t = Settings.wall_t
v_slot_d = Settings.v_slot_d
d = scope_d + 2 * wall_t

rod = "M5"
rod_d = boltData(rod)['diameter']
rod_nut = nutData(rod)
rod_nut_t  = rod_nut['thickness']
rod_nut_w = rod_nut['width']

holder_bolt = "M3"
holder_bolt_d = boltData(holder_bolt)['diameter']

dovetail_neck_l = 75
dovetail_neck_w = 3 * wall_t
dovetail_neck_t = rod_nut_t + 2 * wall_t

running_fit = 0.121

heatset_d = 3.2
heatset_l = 4
heatset_wall_t = 1.3

dovetail_wall_t = heatset_d + heatset_wall_t * 2

slider_bolt = "M2.5"
slider_bolt_s = 35 # Mostly arbirtrary, a nice round number that fits in with design rules
slider_bolt_d = boltData(slider_bolt)['diameter']

cable_t = 1.2
cable_w = 16
cable_passthru_t = 2 * wall_t

slider_id = v_slot_d + loose_fit
slider_od = slider_id + 2 * wall_t
rod_v_slot_clearance = rod_nut_w / 2 + (bearing_od / 2 - rod_nut_w / 2) + cable_passthru_t
slider_nutcatch_l = rod_v_slot_clearance + rod_nut_w / 2 + wall_t
slider_tab_t = (loose_fit - running_fit) / 2
nut_m_w = rod_nut_w / 2 + wall_t
bearing_wall_t = wall_t

slider_shape = (cq.Sketch()
    .polygon([
        (-slider_od / 2, -slider_od / 2), (slider_od / 2, -slider_od / 2),
        (slider_od / 2, slider_od / 2), (nut_m_w, slider_od / 2 + rod_v_slot_clearance + nut_m_w),
        (-nut_m_w, (slider_od / 2 + rod_v_slot_clearance + nut_m_w)),(-slider_od / 2, slider_od / 2), 
             ])
                .rect(slider_id, slider_id, mode='s')
                .rarray(slider_id / 2, slider_id - slider_tab_t, 2, 2)
                .rect(v_slot_d / 4, slider_tab_t)
                .reset()
                .rarray(slider_id - slider_tab_t , slider_id / 2, 2, 2)
                .rect(slider_tab_t,v_slot_d / 4)
                .reset()
                .push([(0, (slider_od + cable_passthru_t) / 2)])
                .slot(cable_w + loose_fit, cable_t, 0, mode='s')
                .push([(0, -(slider_od  - wall_t)/2)])
                .rect(slider_bolt_s + slider_bolt_d + wall_t, wall_t)
                )

holder_shape = (cq.Sketch()
                .rect(slider_bolt_s + slider_bolt_d + wall_t, wall_t)
                .push([(0, -wall_t / 2- dovetail_neck_l / 2)])
                .rect(dovetail_neck_w, dovetail_neck_l)
                .push([(0, -dovetail_neck_l - scope_d / 2 - wall_t)])
                .circle(scope_d / 2 + wall_t)
                .circle(scope_d / 2, mode='s').reset())

bearing_m_d = bearing_od / 2 + wall_t
top_shape = (cq.Sketch()
    .polygon([
        (-slider_od / 2, -slider_od / 2), (slider_od / 2, -slider_od / 2),
        (slider_od / 2, slider_od / 2), (bearing_m_d, slider_od / 2 + rod_v_slot_clearance + bearing_m_d),
        (-bearing_m_d, (slider_od / 2 + rod_v_slot_clearance + bearing_m_d)),(-slider_od / 2, slider_od / 2), 
             ])
    .circle((boltData(Settings.frame_bolt)['diameter'] + loose_fit) / 2, mode='s')
    .push([(0, (slider_od + cable_passthru_t) / 2)])
    .slot(cable_w, cable_t, 0, mode='s'))


def top():
    top = Workplane("XY")
    top = top.placeSketch(top_shape).extrude(bearing_t + bearing_wall_t).faces(">Z").workplane().move(0, rod_v_slot_clearance + slider_od / 2).tag("bearing").hole(bearing_od, depth=bearing_t)
    top = top.workplaneFromTagged("bearing").move(0, rod_v_slot_clearance + slider_od / 2).boltHole(rod, clearance=loose_fit)
    top = top.faces("<Z").workplane().tag("bottom").rect(slider_od, slider_od).extrude(wall_t) # Indexing feature

    top = top.faces("<Z").workplane().move(0, -wall_t).rect(slider_id, slider_id + wall_t * 2).cutBlind(-wall_t)
    top = top.faces(">Z[1]").edges("|X").edges(cq.selectors.LengthNthSelector(0)).chamfer(wall_t / 2)

    # Top mount
    top = top.edges(">Z and (not %Circle)").chamfer(bearing_t / 4)
    top = top.edges("|Z and (>>Y or <<Y)").fillet(bearing_od / 4)
    top = top.edges("<Z").chamfer(wall_t / 4)
    top = top.faces(">Z[1]").edges(">Y").chamfer(wall_t / 2)

    return top

def slider():
    slider = Workplane("XY")
    slider = slider.placeSketch(slider_shape).extrude(dovetail_neck_t)
    slider = slider.edges("|Z and >Y").fillet(bearing_od / 4)

    slider = slider.workplane().center(0, slider_od / 2 + rod_v_slot_clearance).tag("rod").workplane(dovetail_neck_t / 2).boltHole(rod, clearance=loose_fit)
    slider = slider.workplaneFromTagged("rod").workplane(-rod_nut_t / 2).nutcatchSidecut(rod)
    slider = slider.faces(">Y[1]").workplane(centerOption="CenterOfBoundBox").tag("mount_back").rarray(slider_bolt_s / 2, 1, 3, 1).nutcatchParallel(slider_bolt)
    slider = slider.workplaneFromTagged("mount_back").rarray(slider_bolt_s / 2, 1, 3, 1).boltHole(slider_bolt, clearance=loose_fit)

    slider = slider.edges("(>Z or <Z) and (not %Circle)").chamfer(wall_t / 4)

    return slider

def holder():
    holder = Workplane("XY")
    holder = holder.placeSketch(holder_shape).extrude(dovetail_neck_t)
    holder = holder.faces("<Y[1]").workplane(centerOption="CenterOfBoundBox").rarray(slider_bolt_s, 1, 2, 1).boltHole(slider_bolt, clearance=Settings.fit, depth=wall_t)
    holder = holder.faces(">X[1] or <X[1]").edges("<<Y").fillet(dovetail_neck_w)
    holder = holder.faces(">X[1] or <X[1]").edges(">>Y").fillet(dovetail_neck_w / 2)
    holder = holder.faces(">Y").workplane().transformed((0, 0, 0), offset=(0, 0, -d * 1.5)).slot2D(d * 3 / 4, holder_bolt_d + Settings.loose_fit).cutBlind(-d / 2)

    return holder

holder_ = holder()
slider_ = slider()
top_ = top()
show(holder_.translate((0, -(slider_od + wall_t) / 2, 0)), slider_, top_.translate((0, 0, dovetail_neck_t + wall_t)))
holder_.export("microscope-mount-holder.step")
slider_.export("microscope-mount-slider.step")
top_.export("microscope-mount-top.step")
