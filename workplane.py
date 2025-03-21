import cq_queryabolt as queryabolt
import cadquery as cq

class Workplane(cq.Workplane, queryabolt.WorkplaneMixin):
    pass
