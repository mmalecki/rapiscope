import cadquery as cq
from workplane import Workplane
from ocp_vscode import *
from settings import Settings

set_defaults(reset_camera=False)

fit = Settings.fit
loose_fit = Settings.loose_fit
padding = 8

t = 3.6
standoff_d = 5
standoff_h = 3.6

rpi_w = 56
rpi_mount = [58, 49, ]
rpi_camera_side_offset = 11.5
rpi_bottom_clearance = 45 # HDMI, power, etc.

rpi_bolt = "M2"
rpi_h = 10
insert_d = 3.2 # CNC Kitchen M2 heatset insert
insert_h = 4

v_slot_d = Settings.v_slot_d
v_slot_mount_d = Settings.v_slot_d * 3

w = rpi_mount[0] + padding * 2 + t * 2
pi_h = rpi_mount[1] + padding * 2 + t * 2
h = pi_h + rpi_bottom_clearance

def rpi_m(w):
    return w.rect(rpi_mount[0], rpi_mount[1], forConstruction=True).vertices()

def mount():
    mount = (Workplane("XZ")
             .moveTo(0, h / 2).lineTo(w / 2, h / 2)
             .lineTo(w / 2, -h / 2 + rpi_bottom_clearance)
             .lineTo(v_slot_mount_d / 2, -h / 2)
             .lineTo(v_slot_mount_d / 2, -h / 2 - v_slot_d)
             .lineTo(0,  -h / 2 - v_slot_d)
             .mirrorY()
    )
    mount = mount.extrude(t).edges("|Y").fillet(3)

    mount.faces(">Y").workplane(centerOption="CenterOfBoundBox").center(0, v_slot_d / 2 + rpi_bottom_clearance / 2).tag("pi_front").end()
    mount.faces("<Y").workplane(centerOption="CenterOfBoundBox").center(0, v_slot_d / 2 + rpi_bottom_clearance / 2).tag("pi_back").end()

    mount.faces(">Y").workplane(centerOption="CenterOfBoundBox").center(0, -h / 2).tag("mount").end()

    # Save some filament.
    mount = mount.workplaneFromTagged("pi_front").polygon(6, rpi_mount[0]).extrude(-t / 2, combine='s')
    mount = mount.edges("|Y and >Y[1]").fillet(t)

    mount = rpi_m(mount.workplaneFromTagged("pi_front")).circle(standoff_d / 2).extrude(standoff_h)

    mount = mount.faces(">Y[2]").edges("%Circle").edges(cq.selectors.RadiusNthSelector(0)).fillet(standoff_h * 3/4)

    mount = rpi_m(mount.workplaneFromTagged("pi_back")).hole(insert_d, depth=insert_h)
    mount = rpi_m(mount.faces(">Y").workplane()).boltHole(rpi_bolt, clearance=Settings.fit)

    mount = mount.workplaneFromTagged("pi_front").boltHole(Settings.v_slot_bolt, clearance = fit)

    mount = (mount.workplaneFromTagged("mount")
             .rarray(v_slot_d, 1, 3, 1)
             .cboreBoltHole(Settings.v_slot_bolt, clearance = fit,cboreDepth=t / 4, headClearance = 2 * loose_fit)
             )

    mount = (mount
             .rarray(1, v_slot_d, 1, 5)
             .cboreBoltHole(Settings.v_slot_bolt, clearance = fit,cboreDepth=t / 4, headClearance = 2 * loose_fit) # This actually only creates 3 visible holes
             )

    mount = mount.workplaneFromTagged("pi_front").rarray(rpi_mount[0] / 2, 1, 2, 1).slot2D(rpi_mount[1] * 3/4, rpi_mount[0] / 8, 90).cutThruAll()

    # The only integral part of this case: a stopper to prevent the
    # scope head from ramming into the Pi.
    mount = mount.workplaneFromTagged("pi_front").move(0, pi_h / 2 - t / 2).rect(w, t).extrude(standoff_h + rpi_h)
    mount = mount.edges("|Y and >Z").fillet(3)

    mount = mount.faces("<Y").edges("%Circle").edges(cq.selectors.RadiusNthSelector(0)).chamfer(insert_h / 8)

    mount = mount.edges("#Y").edges(">>Y[2]").edges(">Z").fillet(t / 2)
    return mount

m = mount()
show(m)
m.export("rpi-mount.step")
