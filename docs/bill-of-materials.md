# Bill of materials

## Optics
| Part                             | Quantity | Notes       | Links |
| -------------------------------- | -------: | ----------- | ----- |
| C-mount microscope lens          |        1 | You can use any lens you like, but Z axis lengths are picked for the one linked | [US](https://www.amazon.com/Monocular-C-Mount-Industry-Microscope-Objective/dp/B016NUGHK2) |
| 0.5x Barlow lens                 |        1 | Optional, but increases the working distance from ~100 mm to ~200 mm | [US](https://www.amazon.com/gp/product/B071G2DSQY) |
| Raspberry Pi HQ camera           |        1 | |
| Raspberry Pi camera cable, 80 cm |        1 | The one that comes with the camera is way too short |

## Brains
| Part                        | Quantity | Notes       | Links |
| --------------------------- | -------: | ----------- | ----- |
| Raspberry Pi 3 or 4         |        1 | | |

## Frame
| Part                        | Quantity | Notes       | Links |
| --------------------------- | -------: | ----------- | ----- |
| v-slot 2020, 20 cm          |        3 |             |       |
| v-slot 2020, 30 cm or 40 cm |        1 | If using the recommended lens, pick 40 cm if using the 0.5x Barlow lens or want to keep your options open, and 30 cm otherwise. | |
| T joining plate             |        1 | | [PL](https://www.v-slot.pl/pl/p/Plytka-laczeniowa-T/192) 
| 90 degree joining plate     |        2 | | [PL](https://www.v-slot.pl/pl/p/Plyta-laczeniowa-90-stopni-do-2020/1820)
| M5x10                       |        15 | | | 
| M5 2020 t-nut               |        15 | | | 

## Gearbox
| Part                        | Quantity | Notes       | Links |
| --------------------------- | -------: | ----------- | ----- |
| M3x50                       |        5 | |
| M3 nyloc nut                |        1 | |
| 623zz bearing               |        1 | Can be customized for any small bearing with ID = 3 mm |
| M8x50 hex head              |        1 | |
| M8 nyloc nut                |        1 | |
| 608zz bearing               |        2 | |
| plastic-safe grease         | as needed | |

## Slider
| Part                        | Quantity | Notes       | Links |
| --------------------------- | -------: | ----------- | ----- |
| M3 nut                      |        8 | |

## Microscope mount
| Part                        | Quantity | Notes       | Links |
| --------------------------- | -------: | ----------- | ----- |
| M3x40                       |        4 | |
| M3x12                       |        1 | |

## Raspberry Pi mount
| Part                        | Quantity | Notes       | Links |
| --------------------------- | -------: | ----------- | ----- |
| M4x8                        |        2 | |
| M4 2020 t-nut               |        2 | |
| M3 nut                      |        4 | Optional* |
| M3x20                       |        4 | Optional* |

*: If you don't have a case for the Raspberry Pi handy, you can mount it
straight onto the mount. Otherwise, you just rest the case inside the mount.

## Printed parts

* **Material**: My build features the rack printed in PC-CF and worm and pinion printed
  in resin, because I wanted to see what would happen. They're functioning well so far.
  For general use, when PC-CF is not available, I would recommend PETG. What it lacks in
  rigidity, it makes up in its failure mode of deforming instead of becoming brittle
  and cracking.
* **Layer height**: At most 0.2 mm layer height (recommend using [variable layer height](https://help.prusa3d.com/article/variable-layer-height-function_1750)
* **Infill**: 15%
* **Perimeters**: 3

The up-to-date models can be found on [Printables](https://www.printables.com/model/505840-rapiscope) or the latest [GitHub releases](https://github.com/mmalecki/rapiscope/releases).

| Part              | Quantity | Notes       |
| ----------------- | -------: | ----------- |
| housing           |        1 |
| pinion            |        1 |
| rack              |        1 | Pick the version appropriate for your Z axis length, 140 mm for 30 cm and 240 mm for 40 cm |
| slider            |        1 |
| worm              |        1 |
| knob              |        1 |
| microscope-mount  |        1 | 
| microscope-holder |        1 | Requires supports |
| rpi-mount         |        1 |
| top-cable-clip    |        1 | |
| top-cable-guide   |        3 | Optional, you can also use zip ties |
