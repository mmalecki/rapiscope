import cadquery as cq

fit = 0.1

# Chamfer
c = 0.5

slider_bolt_x_s = 38.3509
slider_bolt_y_s = 20
slider_bolt_z_s = 20

padding = 5
thickness = 5

mount_w = slider_bolt_x_s + 2 * padding
mount_h = slider_bolt_z_s + 2 * padding
mount_holder_lip = 2.5

bolt = 3
bolt_cbore = 5.5

scope_d = 50
holder_t = 7.5
holder_h = 15
holder_bolt = 3
holder_bolt_offset = 5.5
holder_od = scope_d + 2 * holder_t
holder_arm_l = 45

t_w = slider_bolt_x_s - 2 * padding
t_t = 2 * padding
t_h = t_t + t_t

box_l = t_h + t_t
box_h = mount_h


def t_shape(workplane, fit=0):
    pts = [
        (0, 0),
        (t_t / 2 + fit / 2, 0),
        (t_t / 2 + fit / 2, t_h - t_t - fit / 2),
        (t_w / 2 + fit / 2, t_h - t_t - fit / 2),
        (t_w / 2 + fit / 2, t_h + fit / 2),
        (0, t_h + fit / 2),
    ]
    return workplane.polyline(pts).mirrorY()


def t(workplane, h, fit=0):
    return t_shape(workplane, fit).extrude(h + fit)


def mount():
    result = cq.Workplane("XZ").box(mount_w, mount_h, thickness)

    plate = result.faces("<Y").workplane()

    # Aligning these was not as easy as I'd hoped, but there's probably a better way.
    box = (
        cq.Workplane("XZ")
        .transformed(offset=(0, -(mount_h - box_h) / 2, 0))
        .rect(t_w + 2 * t_t, box_h)
        .extrude(box_l)
        .edges("|Z")
        .chamfer(c)
    )
    t_fit = t(
        cq.Workplane("XY").transformed(offset=(0, -box_l, -mount_h / 2 + t_t - fit)),
        box_h - t_t,
        fit=fit,
    )
    box = box.cut(t_fit).edges(">Z").chamfer(c)

    plate = plate.union(box)
    plate.faces(">Y[2]").tag("holder_mount").end()

    plate = (
        plate.faces("<Y")
        .workplane()
        .rect(slider_bolt_x_s, slider_bolt_z_s, forConstruction=True)
        .vertices()
        .hole(bolt, box_l + thickness)
    )
    return plate


def holder():
    result = (
        cq.Workplane("XY")
        .circle(holder_od / 2)
        .circle(scope_d / 2)
        .extrude(holder_h)
        .tag("holder")
    )

    result = t(result.center(0, holder_od / 2 + holder_arm_l), holder_h)
    result = (
        result.faces(">Y")
        .workplane()
        .rect(t_t, holder_h, centered=[True, False, True])
        .extrude(until="next")
    )

    result.faces(">Y").tag("mount")

    # This mounting slot covers ~60 degrees at most. A mounting point for the lens
    # happens every 90 degrees, so we're essentially hoping for the best here.
    result = (
        result.workplaneFromTagged("holder")
        .center(0, -holder_od / 2)
        .transformed((90, 0, 90), offset=(0, 0, holder_h - holder_bolt_offset))
        .slot2D(holder_od / 2, holder_bolt, 90).cutBlind(until = "next")
    )

    return result.edges(">Z").chamfer(c).edges("<Z").chamfer(c)


assembly = (
    cq.Assembly()
    .add(mount(), name="mount")
    .add(holder(), name="holder")
    .constrain("mount?holder_mount", "holder@faces@>Y", "Plane")
    .constrain("mount@faces@>Z[1]", "holder@faces@<Z", "Axis")
)

assembly.solve()

show_object(mount().translate((mount_w + 10, 0)), {"name": "microscope-mount"})
show_object(holder().translate((mount_w + 10, -150)), {"name": "microscope-holder"})
show_object(assembly, {"name": "microscope-mount-assembly"})
