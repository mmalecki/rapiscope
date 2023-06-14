import queryabolt
import cadquery as cq

class Workplane(queryabolt.WorkplaneMixin, cq.Workplane):
    pass

fit = 0.1

# Chamfer
c = 0.5

padding = 12.5

t = 4

rpi_w = 56
rpi_mount = [49, 58]
rpi_case_t = 25
rpi_camera_side_offset = 11.5

# rpi_offset = (rpi_w - rpi_camera_side_offset) / 2
rpi_offset = 0

basket_h = 25
basket_t = rpi_case_t + t
rpi_bolt = "M3"

v_slot_d = 20
v_slot_d_fit = v_slot_d + fit
v_slot_bolt = "M4"

w = rpi_mount[0] + padding + t * 2
h = rpi_mount[1] + padding + t

def vslotMount(): 
    pad = Workplane("YZ").rect(v_slot_d, v_slot_d).circle(queryabolt.boltData(v_slot_bolt)["diameter"] / 2).extrude(t / 2, both = True)
    return pad.val()

def rpiMount(workplane, tag = None):
    r = (workplane.rect(rpi_mount[0], rpi_mount[1]))
    if tag is not None:
        r.tag(tag)
    return r.vertices()

def mount():
    plate = Workplane("XZ").rect(w, h).extrude(t)

    plate = plate.faces(">Y").workplane().pushPoints([(-w / 4, 0), (0, 0), (w / 4, 0)]).slot2D(h / 2, 5, 90).cutThruAll()

    plate = rpiMount(plate.faces(">Y").workplane().move(0, t / 2)).nutcatchParallel(rpi_bolt)
    plate = rpiMount(plate.faces(">Y").workplane().move(0, t / 2)).boltHole(rpi_bolt, t)

    plate = plate.union(plate.faces(">Y").workplane(v_slot_d / 2)
             .center(0, -(h - v_slot_d) / 2)
             .pushPoints([[-v_slot_d_fit / 2 - t / 2 + rpi_offset, 0], [v_slot_d_fit / 2 + t / 2 + rpi_offset, 0]])
             .eachpoint(lambda loc: vslotMount().located(loc))
    )

    plate = plate.union(basket().moved(cq.Location(cq.Vector(0, -rpi_case_t / 2 - t * 1.5, -(h - basket_h) / 2))))

    # Access hole to the lower mount bolt.
    plate = rpiMount(plate.faces("<Y").workplane().move(0, t / 2)).hole(5, t)

    return plate.edges("|Z and (>X or <X)").chamfer(c).edges("|Y and (>Z or <Z)").chamfer(c).edges("|X and (>Z or <Z)").chamfer(c)

def basket():
    basket = cq.Workplane("XY").box(w, basket_t, basket_h)
    basket = basket.faces("+Z or +Y").shell(-t)

    basket = basket.faces("-Z").workplane().center(0, -t / 2).rect(15, rpi_case_t).cutThruAll() # SD card access
    basket = basket.center(w / 2 - t / 2, 0).workplane(-t).rect(t, rpi_case_t * 3 / 4).cutBlind(-basket_h) # HDMI & power
    return basket.val()


show_object(mount(), name="rpi-mount")
