import math
import cadquery as cq
from workplane import Workplane
from ocp_vscode import *
from settings import Settings

set_defaults(reset_camera=False)

fit = Settings.fit
loose_fit = Settings.loose_fit
padding = 6

t = 3.6
standoff_d = 5.7
standoff_h = 3.6

rpi_mount = [58, 49, ]

rpi_bolt = "M2.5"

v_slot_d = Settings.v_slot_d
v_slot_mount_d = Settings.v_slot_d * 3

l = rpi_mount[0] + padding * 2
pi_w = rpi_mount[1] + padding * 2 + t * 2

def rpi_m(w):
    return w.rect(rpi_mount[0], rpi_mount[1], forConstruction=True).vertices()

def mount_angled():
    angle = math.radians(45)
    w = math.cos(angle) * pi_w
    h = math.sin(angle) * pi_w
    print(w, h, l)
    mount = (Workplane("YZ")
             .lineTo(0, h)
             .lineTo(w, h)
             .lineTo(0, 0)
             .close()
    ).extrude(l / 2, both=True)
    mount = mount.faces(">>Y")[0].tag("back").workplane(centerOption="CenterOfBoundBox").tag("rpi").end()

    # Create the standoffs, nutcatches and bolt holes
    mount = rpi_m(mount.workplaneFromTagged("rpi")).circle(standoff_d / 2).extrude(standoff_h)
    mount = mount.edges("%Circle").edges("<<Z[0] or <<Z[2]").fillet(standoff_h / 2)
    mount = rpi_m(mount.workplaneFromTagged("rpi").workplane(-t)).nutcatchParallel(rpi_bolt, heightClearance=l)
    mount = rpi_m(mount.faces(">>Y")[0].workplane()).boltHole(rpi_bolt, clearance=fit)

    # Cutaway calculations
    cutaway_w = w - 2 * t # This part may be potentially used to hold the head
    cutaway_l = rpi_mount[0] - padding * 2

    # Extrusion mount
    mount = mount.faces("<Y").workplane(centerOption="CenterOfBoundBox").transformed(offset=(0, 0, -l - t), rotate=(0, 180, 180)).rarray(1, h / 3, 1, 3).cboreBoltHole(Settings.v_slot_bolt, cboreDepth=l, clearance=fit, headClearance = loose_fit)
    mount = mount.faces("<Y").workplane(centerOption="CenterOfBoundBox").transformed(offset=(0, -h / 3, -l - t), rotate=(0, 180, 180)).rarray(cutaway_l / 3, 1, 3, 1).cboreBoltHole(Settings.v_slot_bolt, cboreDepth=l, clearance=fit, headClearance = loose_fit)

    # Cutaway
    mount = mount.faces(">Z").workplane(centerOption="CenterOfBoundBox", offset=-t / 2).move(0, (w - cutaway_w) / 2).rect(cutaway_l, cutaway_w).extrude(-h, combine='cut')
    mount = mount.faces(">Z").workplane(centerOption="CenterOfBoundBox").move(0, -(w - t * 4 - 2 * Settings.cable_t) / 2).slot2D(2 * Settings.cable_w, 2 * Settings.cable_t).cutThruAll()

    mount = mount.faces(">X or <X").chamfer(t / 4)
    mount = mount.faces(">Z").edges(">Y or <Y").chamfer(t / 4)
    mount = mount.faces("<<Z[6]").edges("|Y").chamfer(t / 4)
    mount = mount.faces(">Y[2]").edges("|Z").chamfer(t)
    mount = mount.faces("<Y").edges("<Z").chamfer(t / 4)
    mount = mount.faces(">X[3] or <X[3]").edges(">>Y and (not |Y)").chamfer(t / 4)

    return mount

m = mount_angled()
show(m)
m.export("rpi-mount-angled.step")
