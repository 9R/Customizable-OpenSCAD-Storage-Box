$fn = $preview ? 50 : 50;

/*[Part]*/
// Select part to render
PART = "container"; //[container, lid, modules]

// Select module to render. Only applies if model is selected above
MODULE = "module_snap"; //[module_snap, module_hinge_knuckle, module_hinge_leaf]

// Generate Snap module for lid. If false snap module will interconnect boxes
SNAP_MODULE_LID = true;

/*[Dimensions]*/
// Add a top rim
RIM = true;

// Add Module Bay
MODULE_BAY = false;

// Number of MODBAY Screws
MOD_SCREWS = "4"; //[2vertical, 2horizontal, 4]

// Container Length in mm
BOX_L_OUTER = 165; //[50:5:300]

// Container Width in mm
BOX_W_OUTER = 120; //[50:5:300]

// Container Height in mm
BOX_H_OUTER = 25; //[25:5:300]

// Lid Thickness in mm
LID_H = 3; //[3:1:10]

// Corner Radius in mm
CORNER_RADIUS = 3; //[1:1:10]

// Top Rim in mm. Rim height is derived from this. This might interfere with module bay on low height containers
RIM_W = 3; //[3:1:10]

// Outer Wall Thickness
WALL_THICKNESS = 1.5; //[1:0.5:10]

// Inner Wall Thickness
DIVIDER_THICKNESS = 1; //[1:1:10]

// Floor Thickness
FLOOR_THICKNESS = 1; //[1:1:10]

// Number of Divisions on the Long Edge
DIVISIONS_L = 1; //[0:1:20]

// Number of Divisions on the Short Edge
DIVISIONS_W = 3; //[0:1:20]

// Width of Lock Fixtures
FIXTURE_W = 5; //[3:1:10]

// Thickness of Lock Fixtures
FIXTURE_THICKNESS = 4; //[3:1:10]

// Diamenter of Lock Bolts
HINGE_BOLT_D = 1.1; //[1:0.1:4]

// Screw insert Diameter
INSERT_D = 4; //[3:0.5:8]

// Add Module bottom snap socket
SNAP_SOCKET = true;

/*[Hidden]*/
module __customizer_limit__() {};
// above 2 lines make sure customizer does not show parameters below

// Width of Interlocking Mechanism
MODBAY_W = 30; //[20:2.5:50]

// Depth of Modbay
MODBAY_DEPTH = 12; //[10:1:20]

// Modbay Screw Coordinates
MBCs = [
    [ [ 0, 3, 5 ], [ 0, 3, 15 ] ],                             // 2vertical
    [ [ 9, 3, 13 ], [ -9, 3, 13 ] ],                           // 2horzontal
    [ [ 0, 3, 5 ], [ 0, 3, 15 ], [ 9, 3, 13 ], [ -9, 3, 13 ] ] // 4
];

MODBAY_SCREW_COORDINATES = MOD_SCREWS == "2vertical" ? MBCs[0] : MOD_SCREWS == "2horizontal" ? MBCs[1] : MBCs[2];

BOX_L = BOX_L_OUTER - 2 * CORNER_RADIUS; // Box Width
BOX_W = BOX_W_OUTER - 2 * CORNER_RADIUS; // Box Length
BOX_H = BOX_H_OUTER;                     // Box Height

// width module center
MOD_W = 15;

// module bay gap
MODBAY_GAP = 0.1;

POST_OFFSET = 10;

// Offset between snapping parts
PART_OFFSET = 0.3;

///////////////////////////////////////////////////////////////////////////////
// Derived Variables
///////////////////////////////////////////////////////////////////////////////

module_bay_offset = BOX_L / 2 + CORNER_RADIUS;

hinge_offset = BOX_L / 2 + CORNER_RADIUS;
hinge_coordinates = [[MODBAY_W / 2 - FIXTURE_W, hinge_offset, 0], [-MODBAY_W / 2, hinge_offset, 0]];

mod_template_height = BOX_H - RIM_W;

///////////////////////////////////////////////////////////////////////////////
// Modules
///////////////////////////////////////////////////////////////////////////////

// Container modules
////////////////////

module base_plate(length, width, thickness)
{
    corner_coordinates = [ [ 0, 0 ], [ 0, length ], [ width, length ], [ width, 0 ] ];

    translate([ -width / 2, -length / 2 ])
    {
        hull()
        {
            for (i = corner_coordinates)
            {
                translate(i) cylinder(r = CORNER_RADIUS, h = thickness);
            };
        };
    };
};

module container_hull()
{
    ext_h = RIM ? BOX_H - RIM_W : BOX_H;
    linear_extrude(ext_h) difference()
    {
        offset(r = CORNER_RADIUS) square([ BOX_W, BOX_L ], center = true);

        offset(r = CORNER_RADIUS - WALL_THICKNESS)
            square([ BOX_W - WALL_THICKNESS, BOX_L - WALL_THICKNESS ], center = true);
    }
    base_plate(BOX_L, BOX_W, FLOOR_THICKNESS);
};

module box_rim()
{
    difference()
    {
        hull()
        {
            // upper face
            translate([ 0, 0, -RIM_W / 2 ])
            {
                linear_extrude(RIM_W / 2)
                {
                    offset(r = CORNER_RADIUS) square([ BOX_W + RIM_W, BOX_L + RIM_W ], center = true);
                };
            };
            // lower face
            translate([ 0, 0, -2 * RIM_W + 1 ])
            {
                linear_extrude(RIM_W / 2)
                {
                    offset(r = CORNER_RADIUS) square([ BOX_W, BOX_L ], center = true);
                };
            };
        };
        // cutout
        union()
        {
            // upper
            translate([ 0, 0, -2 ])
            {
                linear_extrude(5)
                {
                    offset(r = CORNER_RADIUS + .3)
                        square([ BOX_W - RIM_W / 4 + PART_OFFSET, BOX_L - RIM_W / 4 + PART_OFFSET ], center = true);
                };
            };
            // lower
            translate([ 0, 0, -BOX_H / 2 ]) linear_extrude(BOX_H)
            {
                offset(r = CORNER_RADIUS - WALL_THICKNESS)
                    square([ BOX_W - WALL_THICKNESS, BOX_L - WALL_THICKNESS ], center = true);
            };
        };
    };
};

module module_bay_cutout(offset)
{
    cut_depth = MODBAY_DEPTH;
    cut_position_y = offset - cut_depth / 2;
    width = MOD_W + MODBAY_GAP;

    translate([ -width / 2, cut_position_y, 0 ])
    {
        cube([ width, cut_depth, BOX_H * 2 ]);
    };

    translate([ 0, module_bay_offset - 4, 0 ]) minkowski()
    {
        mod_template();
        translate([ 0, 0, 0 ]) cube([ MODBAY_GAP, 4, 2 ], center = true);
    };
};

module add_corner_concave(radius, thickness)
{
    rotate(90, [ 0, 1, 0 ]) difference()
    {
        cube([ radius, radius, thickness ]);
        cylinder(r = radius, h = thickness);
    };
};

module cut_corner_convex(radius, rotation, position, thickness)
{
    translate(position)
    {
        rotate(rotation, [ 1, 0, 0 ])
        {
            add_corner_concave(radius, thickness);
        };
    };
};

module module_bay()
{
    module insert_hole(coordinate)
    {
        // cut hole for screw insert
        y = coordinate[0];
        x = coordinate[1];
        z = coordinate[2];
        translate([ 4.5, y, z ])
        {
            rotate(90, [ 0, 1, 0 ])
            {
                cylinder(d = INSERT_D, h = 3, center = true);
            };
        };
    };

    translate([ 0, BOX_L_OUTER / 2, 0 ]) rotate(-90, [ 0, 0, 1 ]) render()
    {
        difference()
        {
            // shell
            translate([ 1, 0, 0 ]) rotate(-90, [ 0, 0, 1 ]) difference()
            {
                minkowski()
                {
                    mod_template();
                    translate([ 0, 1, -1 ]) cube([ 3, 4, 4 ], center = true);
                };
                translate([ -25, -1, BOX_H - 2 ]) cube(50);
                translate([ -25, -1, -50 ]) cube(50);
            };
            //  cutout
            rotate(-90, [ 0, 0, 1 ]) minkowski()
            {
                mod_template();
                translate([ 0, -1.5, 0 ]) cube([ 0.1, 3, 0.2 ], center = true);
            };
            for (i = MODBAY_SCREW_COORDINATES)
            {
                insert_hole(i);
            };
        };
    };
};

module division(count, length, width)
{
    step_x = width / (count + 1);
    for (i = [1:count])
    {
        translate([ -width / 2 + i * step_x, 0, BOX_H / 2 - 0.5 ])
        {
            cube([ DIVIDER_THICKNESS, length + RIM_W, BOX_H - RIM_W ], center = true);
        };
    };
};

// Lid modules
//////////////

module hinge_knuckle()
{
    rotate(90, [ 0, 1, 0 ]) difference()
    {
        union()
        {
            cylinder(h = MOD_W, d = 3.5, center = true);
            hull()
            {
                translate([ 1.0, 0, 0 ]) cube(size = [ 3, 3, MOD_W ], center = true);
                translate([ 3.5, 3, 0 ]) cube(size = [ 1, 3, MOD_W ], center = true);
            };
        };
        cylinder(h = MOD_W, d = HINGE_BOLT_D, center = true);
        translate([ -2.25, 0, 0 ]) cube(MOD_W / 2, center = true);
    };
};

module lid_phase()
{
    translate([ BOX_L / 2 - FIXTURE_W, BOX_W / 2 + 0.5, LID_H - 2 ])
    {
        rotate(45, [ 1, 0, 0 ])
        {
            cube([ BOX_L, LID_H, LID_H ]);
        };
    };
};

module lid_snap_lock()
{
    union()
    {
        translate([ 0, 5.5, 0 ]) cube([ 15 + 2 * MODBAY_GAP, 5, 2.1 ], center = true);
        translate([ 7.5 + MODBAY_GAP, 0, 3 ]) rotate(180, [ 0, 1, 0 ]) cube([ 4 + 2 * MODBAY_GAP, 5, LID_H ]);
        translate([ -3.5 + MODBAY_GAP, 0, 3 ]) rotate(180, [ 0, 1, 0 ]) cube([ 4 + 2 * MODBAY_GAP, 5, LID_H ]);
    };
};

//  Module bay modules
//////////////////////

module mod_clip_tip_half(positive = true)
{
    // dimensions
    lock_w = 15;
    corner_r = 3;
    thickness = 3;
    lock_offset = 0.2;
    lock_height = 10;

    module shape()
    {
        hull()
        {
            cube([ MOD_W / 2, thickness, 1 ]);

            translate([ 0, 0, lock_height ]) cube([ 1, thickness, 1 ]);
            translate([ lock_w / 2 - corner_r, corner_r, 8 ]) rotate(90, [ 1, 0, 0 ])
                cylinder(r = corner_r, h = thickness);
        };
    };

    if (positive)
    {
        shape();
    }
    else
    {
        minkowski()
        {
            shape();
            cube(size = lock_offset, center = true);
        };
    }
};

module mod_template()
{
    module mod_center()
    {
        translate([ 0, 0, 0 ])
        {
            cube([ MOD_W / 2, 3, BOX_H - 2 ]);
        };
    };

    module mod_side()
    {
        translate([ 0, 0, 3 ])
        {
            hull()
            {
                translate([ 9.5, 3, 11.7 ]) rotate(90, [ 1, 0, 0 ]) cylinder(d = 6, h = 3);
                translate([ 11.5, 3, 1.1 ]) rotate(90, [ 1, 0, 0 ]) cylinder(d = 2, h = 3);
                cube([ 1, 3, 15 ]);
            };
        };
    };

    module half_module()
    {
        mod_center();
        mod_side();
        translate([ 8.4, 0, 18.7 ]) rotate(90, [ 0, 0, 1 ]) add_corner_concave(1, 3);
    };

    union()
    {
        half_module();
        mirror([ 1, 0, 0 ]) half_module();
    };
};

module mod_template_w_screwholes(screw_coordinates)
{
    difference()
    {
        mod_template();
        for (i = screw_coordinates)
        {
            translate(i) rotate(90, [ 1, 0, 0 ]) screw_hole();
        };
    };
};

module screw_hole()
{
    hull()
    {
        cylinder(d = 6.2, h = 0.25);
        translate([ 0, 0, 2 ]) cylinder(d = 3.2, h = 0.1);
    };
    cylinder(d = 3.2, h = 10);
};

module clip_nub()
{
    translate([ 0, 1.5, 1.5 ]) rotate(90, [ 1, 0, 0 ]) hull()
    {
        cube([ 7, 3, 3 ], center = true);
        translate([ 0, 3.5, -1.5 ]) cylinder(d = 7, h = 3);
    };
};

module clip_tip(positive)
{
    difference()
    {
        union()
        {
            mod_clip_tip_half(positive);
            mirror([ 1, 0, 0 ])
            {
                mod_clip_tip_half(positive);
            };
        };
        clip_nub();
    };
};

module clip_tip_lid()
{
    difference()
    {
        hull()
        {
            translate([ 0, 2, 1 ]) cube([ 15, 2, 2 ], center = true);
            translate([ 6.5, 2, 3.5 ]) rotate(90, [ 1, 0, 0 ]) cylinder(d = 2, h = 2, center = true);
            translate([ -6.5, 2, 3.5 ]) rotate(90, [ 1, 0, 0 ]) cylinder(d = 2, h = 2, center = true);
        };
        translate([ 0, 2.5, 1.5 ]) cube([ 7, 5, 3 ], center = true);
    };
};

module phase_edge(offset, w, a = 45)
{
    translate([ 0, 0, offset ]) //
    {
        rotate(a, [ 1, 0, 0 ])
        {
            cube([ w, 12, 2 ], center = true);
        };
    };
};

module flex_joint()
{
    minkowski()
    {
        cube([ 25, 3.8, 2 ], center = true);
        sphere(d = 1);
    };
};

module mod_snap_bottom_chamfer()
{
    hull()
    {
        translate([ 3.5, 0, -3 ]) cube(3);
        translate([ 7.6, 0, 0 ]) cube(3);
    };
};

///////////////////////////////////////////////////////////////////////////////
// Parts
///////////////////////////////////////////////////////////////////////////////

// Container
////////////

if (PART == "container")
{
    render()
    {
        union()
        {
            difference()
            {
                union()
                {
                    // create base shape
                    container_hull();

                    // add top rim
                    if (RIM)
                    {
                        translate([ 0, 0, BOX_H ])
                        {
                            box_rim();
                        };
                    };

                    // add division
                    if (DIVISIONS_W > 0)
                    {
                        division(DIVISIONS_W, BOX_L, BOX_W);
                    };
                    if (DIVISIONS_L > 0)
                    {
                        rotate(90, [ 0, 0, 1 ]) division(DIVISIONS_L, BOX_W, BOX_L);
                    };
                };
                if (MODULE_BAY)
                {
                    // make space for module bay
                    module_bay_cutout(module_bay_offset);
                    mirror([ 0, 1, 0 ])
                    {
                        module_bay_cutout(module_bay_offset);
                    };
                }
            };

            // add module_bay
            if (MODULE_BAY)
            {
                module_bay();
                mirror([ 0, 1, 0 ])
                {
                    module_bay();
                };
            }
        };
    };
};

// Lid
//////

if (PART == "lid")
{
    union()
    {
        difference()
        {
            // lid with interlocking ledge
            union()
            {
                if (RIM)
                {
                    base_plate(BOX_L, BOX_W, 3);
                    translate([ 0, 0, 3 - LID_H ]) base_plate(BOX_L + RIM_W, BOX_W + RIM_W, LID_H - 2);
                }
                else
                {
                    translate([ 0, 0, 3 - LID_H ]) base_plate(BOX_L, BOX_W, LID_H);
                };
            };
            translate([ 0, module_bay_offset - 3, 0 ]) lid_snap_lock();
            mirror([ 0, 1, 0 ]) translate([ 0, module_bay_offset - 3, 0 ]) lid_snap_lock();
        };
    };
};

if (PART == "modules")
{
    // Modbay module clip
    /////////////////////
    if (MODULE == "module_snap")
    {
        render()
        {
            difference()
            {
                union()
                {
                    // screw positions are overridden.
                    mod_template_w_screwholes(MBCs[0]);
                    if (SNAP_MODULE_LID)
                    {
                        translate([ 0, 0, mod_template_height + 1 ]) clip_tip_lid(true);
                    }
                    else
                    {
                        translate([ 0, 0, mod_template_height + 1 ]) clip_tip(true);
                    };
                };

                if (SNAP_SOCKET)
                {
                    // bottom snap slot
                    translate([ 0, 1, 0 ]) clip_tip(false);
                    mod_snap_bottom_chamfer();
                    mirror([ 1, 0, 0 ]) mod_snap_bottom_chamfer();
                }
                // flex-joint:
                translate([ 0, 0, 19.2 ]) flex_joint();
                // phased edges:
                phase_edge(BOX_H + 8, 15); // clip tip
                phase_edge(-3, 10, 47);    // bottom nub
                                           // top snap hook
                translate([ 0, 0, BOX_H - 2 ]) minkowski()
                {
                    if (!SNAP_MODULE_LID)
                    {
                        clip_nub();
                    }
                    cube(0.1, center = true);
                };
                // reduce tip thickness
                translate([ 0, -6.4, BOX_H + 3 ]) cube(size = 15, center = true);
                translate([ 6, 3.5, 10 ]) minkowski()
                {
                    cube([ MOD_W / 4, 1, 3 ], center = true);
                    sphere(r = 1);
                };
                translate([ -6, 3.5, 10 ]) minkowski()
                {
                    cube([ MOD_W / 4, 1, 3 ], center = true);
                    sphere(r = 1);
                };
            };
        };
    }

    else if (MODULE == "module_hinge_knuckle")
    {
        render()
        {
            difference()
            {
                union()
                {
                    mod_template_w_screwholes(MBCs[0]);
                    translate([ 0, -1.5, BOX_H - .5 ]) hinge_knuckle();
                };

                if (SNAP_SOCKET)
                {
                    // bottom snap slot
                    translate([ 0, 1, 0 ]) clip_tip(false);
                    mod_snap_bottom_chamfer();
                    mirror([ 1, 0, 0 ]) mod_snap_bottom_chamfer();
                }
                translate([ 0, -1.5, BOX_H - .5 ]) rotate(90, [ 0, 1, 0 ])
                    cylinder(h = MOD_W / 2, d = 4.5, center = true);
            };
        };
    }

    else if (MODULE == "module_hinge_leaf")
    {
    }
}

//		cylinder(r=100,h=1);
//		linear_extrude (3)
//			text("Sry, not designed yet. :(",halign="center",valign="center");
