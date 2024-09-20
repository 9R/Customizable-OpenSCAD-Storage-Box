$fn= $preview ? 32 : 64;

/*[Part]*/
// Select part to render
PART = "container"; //[container, lid, module_snap]

/*[Dimensions]*/
// Add a top rim
RIM = true;

// Add Module Bay
MODULE_BAY = false;

// Number of MODBAY Screws
MOD_SCREWS = "2vertical"; //[2vertical, 2horizontal, 4]

// Container Length in mm
BOX_L_OUTER = 165; //[50:5:300]

// Container Width in mm
BOX_W_OUTER = 120; //[50:5:300]

// Container Height in mm
BOX_H_OUTER =  25; //[25:5:300]

// Lid Thickness in mm
LID_H = 3; //[3:1:10]

// Corner Radius in mm
CORNER_RADIUS = 3; //[1:1:10]

// Top Rim in mm 
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
LOCK_BOLT_D = 1.3; //[1:0.1:4]

// Screw insert Diameter
INSERT_D = 4 ; //[3:0.5:8]

/*[Hidden]*/
module __customizer_limit__ () {};
//above 2 lines make sure customizer does not show parameters below


// Width of Interlocking Mechanism
MODBAY_W = 30; //[20:2.5:50]

// Depth of Modbay
MODBAY_DEPTH = 12; //[10:1:20]

// Modbay Screw Coordinates
MODBAY_SCREW_COORDINATES = MOD_SCREWS == "2vertical" ? [[0,3,5],[0,3,15]] :
	                    MOD_SCREWS == "2horizontal" ? [[9,3,13],[-9,3,13]] :
											                              [[0,3,5],[0,3,15],[9,3,13],[-9,3,13]];
BOX_L = BOX_L_OUTER-2*CORNER_RADIUS; // Box Width
BOX_W = BOX_W_OUTER-2*CORNER_RADIUS; // Box Length
BOX_H = BOX_H_OUTER; // Box Height

POST_OFFSET=10;

// Offset between snapping parts
PART_OFFSET = 0.3;

///////////////////////////////////////////////////////////////////////////////
// Modules
///////////////////////////////////////////////////////////////////////////////

// Container modules
////////////////////

module base_plate(length, width, thickness){
	corner_coordinates = [ [0,0],[0,length],[width,length],[width,0] ];

	translate ( [-width/2, -length/2] ) {
		hull(){
			for (i = corner_coordinates) {
				translate(i) cylinder(r=CORNER_RADIUS,h=thickness);
			};
		};
	};
};

module container_hull() {
	ext_h = RIM ? BOX_H-RIM_W : BOX_H;
	linear_extrude( ext_h )
		difference(){
			offset(r=CORNER_RADIUS) 
				square( [BOX_W , BOX_L ], center=true );

			offset( r = CORNER_RADIUS - WALL_THICKNESS )
				square([BOX_W - WALL_THICKNESS, BOX_L - WALL_THICKNESS], center=true );
		}
	base_plate(BOX_L, BOX_W, FLOOR_THICKNESS);
};

module box_rim () {
	difference(){
		hull(){
			//upper face
			translate([0,0,-RIM_W/2]){
				linear_extrude(RIM_W/2){
					offset(r=CORNER_RADIUS)
						square( [BOX_W+RIM_W, BOX_L+RIM_W], center=true );
				};
			};
			//lower face
			translate([0,0,-2*RIM_W+1]){
				linear_extrude(RIM_W/2){
					offset(r=CORNER_RADIUS) 
						square( [BOX_W, BOX_L], center=true );
				};
			};
		};
		//cutout
		union(){
			//upper
			translate ([0,0,-2]) {
				linear_extrude(5){
					offset(r=CORNER_RADIUS+.3)
						square([BOX_W-RIM_W/4+PART_OFFSET,BOX_L-RIM_W/4+PART_OFFSET],
								center=true);
				};
			};
			//lower
			translate([0,0,-BOX_H/2])
				linear_extrude(BOX_H){
					offset( r= CORNER_RADIUS - WALL_THICKNESS )
						square( [BOX_W-WALL_THICKNESS, BOX_L-WALL_THICKNESS], center=true );
				};
		};
	};
};

module modbay_cutout(offset) {
	cut_depth = MODULE_BAY ? MODBAY_DEPTH : RIM_W+FIXTURE_THICKNESS;
	cut_offset = MODULE_BAY ? offset-cut_depth/2 : offset;
	width = 15;
	width_l = 30;
	translate ([-width/2,cut_offset,0]) 
		cube ([width,cut_depth,BOX_H*2]);
	translate ([-width_l/2,cut_offset,0]) 
		cube ([width_l,cut_depth,BOX_H_OUTER-2*RIM_W]);
};

module add_corner_concave(radius, thickness) {
	rotate (90,[0,1,0])
		difference() {
			cube([radius, radius, thickness]);
			cylinder(r=radius, h=thickness);
		};
};

module cut_corner_convex(radius,rotation,position,thickness) {
	translate(position)
		rotate(rotation,[1,0,0]) 
		add_corner_concave(radius,thickness);
};

module module_bay_template(thickness, w_mid, w_side,sides_offset, sides_height, wall) {

	module half (thickness, w_mid, w_side, sides_offset, sides_height, wall) {
		height = RIM ? BOX_H - RIM_W + 1 : BOX_H ;
		sides_top = sides_height + sides_offset;
		union () {
			difference () {
				union () {
					//center
					cube([thickness, w_mid,height]);
					//sides
					translate([0,w_mid ,sides_offset])
						cube([thickness, w_side,sides_height]);
					//top corner center/side
					radius = 1;
					translate([0,w_mid +radius,sides_top+radius])
						rotate (-90,[1,0,0])
						add_corner_concave(radius, thickness);
				};
				//side corner top
				cut_corner_convex(3,90,[0,w_side+w_mid -3,sides_top - 3], thickness);
				//side corner bottom
				cut_corner_convex(1,0,[0,w_side+w_mid -1,sides_offset+1], thickness);
			};
			if (wall) {
				translate ([0,w_mid,0]){
					cube([WALL_THICKNESS*1.5,w_side, height]);
				};
			};
		};
	};

	module insert_hole (coordinate){
		//cut hole for screw insert
		y = coordinate[0];
		x = coordinate[1];
		z = coordinate[2];
		echo (coordinate);
		echo (y);
		echo (z);
		translate ([3.5,y,z])
			rotate (90,[0,1,0])
			cylinder(d=INSERT_D,h=3, center=true);
	};

	difference () {
		union () {
			half( thickness, w_mid, w_side, sides_offset, sides_height, wall);
			mirror([0,1,0])
				half( thickness, w_mid, w_side, sides_offset, sides_height, wall);
		};

		for ( i = MODBAY_SCREW_COORDINATES ) {
		  #insert_hole(i);
		};
	};
};

module module_bay() {
	translate([0,BOX_L_OUTER/2,0]) rotate(-90, [0,0,1])
		render () {
			difference() {
				// outer
				module_bay_template( 7, 9, 7.5, 0, 19, true);
				//params: thickness, w_mid, w_side, sides_offset, sides_height, wall)
				// cutout
				module_bay_template( 3, 7.5, 5, 3, 15, false);
			};
		};
};

module division(count, length, width) {
	step_x=width/(count+1) ;
	for (i=[1:count]) {
		translate ([-width/2+i*step_x,0,BOX_H/2-0.5])
			cube([DIVIDER_THICKNESS,length+RIM_W,BOX_H-RIM_W],center=true);
	};
};

// Lid modules
//////////////

module hinge() {
	difference () {
		union () {
			//hinge lever
			translate ([0,0,6])
				cube([FIXTURE_W, FIXTURE_THICKNESS,LID_H-3]);
			rotate(90, [0,1,0]) {
				translate([-3-LID_H,FIXTURE_THICKNESS/2,0])
					cylinder (r=FIXTURE_THICKNESS/2, h=FIXTURE_W);
			};
			//upper rounding
			translate ([0,0,FIXTURE_THICKNESS])
				rotate(90, [0,1,0]) {
					intersection () {
						cylinder (r=FIXTURE_THICKNESS, h=FIXTURE_W);
						cube([FIXTURE_W*2,FIXTURE_THICKNESS*2,FIXTURE_W]);
					};
				};
		};
		//add holes for bolt
		translate([-1,FIXTURE_THICKNESS/2,LID_H+3])	
			rotate(90, [0,1,0]) 
			cylinder (r=LOCK_BOLT_D, h=FIXTURE_W*2);
	};
};

module lid_phase() {
	translate ([BOX_L/2-FIXTURE_W,BOX_W/2+0.5,LID_H-2])
		rotate (45,[1,0,0]) cube([BOX_L,LID_H,LID_H]);
};

// Module bay modules
/////////////////////

module mod_template (){

	module mod_center () {
		translate ([0,0,0])
			cube([7.4,3,25]);
	};

	module mod_side () {
		translate ([0,0,3])
			hull() {
				translate([9.4, 3, 11.7])
					rotate(90,[1,0,0])
					cylinder (d=6,h=3);
				translate([11.4, 3, 1.1])
					rotate(90,[1,0,0])
					cylinder (d=2,h=3);
				cube ([1,3,14.7]);
			};
	};

	module mod_cutout () {
		hull () {
			cube ([7.4,3,1]);

			translate([0,0,10])
				cube ([1,3,1]);
			translate([4.4,3,8])
				rotate(90,[1,0,0])
				cylinder (d=6,h=3);
		};
	};
	module mod_center_tip_clip () {
	};

	module screw_hole () {
		hull (){
			cylinder (d=6.2,h=0.25);
			translate ([0,0,2])
				cylinder (d=3.2,h=0.1);
		};
		cylinder (d=3.2,h=10);
	};

	module nub (){
		translate ([0,1.5,1.5])
			rotate(90,[1,0,0]) 
			hull () {
				cube([7,3,3], center=true);
				translate ([0,3.5,-1.5])
					cylinder (d=7,h=3);
			};
	};

	module half_module() {
		mod_center();
		mod_side();
		translate([8.4, 0, 18.7])
			rotate (90, [0, 0, 1])
			add_corner_concave(1, 3);
	};

	difference() {
		union () {
			half_module();
			mirror([1, 0, 0])
				half_module();
		};
		translate ([0, 1, 0]){
			mod_cutout();
			mirror([1,0,0]){
				mod_cutout();
			};
		};
		for (i = MODBAY_SCREW_COORDINATES ){
			translate (i)
				rotate (90,[1,0,0])
				screw_hole();
		};
	};
	difference() {
		nub();
		translate (MODBAY_SCREW_COORDINATES[0])
			rotate (90,[1,0,0])
			screw_hole();
	};
};

module mod_clip (){
};

///////////////////////////////////////////////////////////////////////////////
// Derived Variables
///////////////////////////////////////////////////////////////////////////////

modbay_offset = BOX_L/2 + CORNER_RADIUS;

hinge_offset = BOX_L/2 + CORNER_RADIUS;
hinge_coordinates = [	[MODBAY_W/2-FIXTURE_W, hinge_offset, 0],
									[-MODBAY_W/2, hinge_offset, 0]];

///////////////////////////////////////////////////////////////////////////////
// Parts
///////////////////////////////////////////////////////////////////////////////

// Container
////////////

if (PART == "container"){
	render () {
		union() {
			difference (){
				union () {
					//create base shape
					container_hull();

					//add top rim
					if (RIM){
						translate([0,0,BOX_H]) {
							box_rim();
						};
					};

					//add division
					if (DIVISIONS_W > 0) {
						division(DIVISIONS_W, BOX_L, BOX_W);
					};
					if (DIVISIONS_L > 0) {
						rotate (90,[0,0,1])
							division(DIVISIONS_L, BOX_W, BOX_L);
					};
				};
				if (MODULE_BAY) {
					//make space for module bay
					modbay_cutout(modbay_offset);
					mirror ([0,1,0]){
						modbay_cutout(modbay_offset);
					};
				}
			};

			//add module_bay
			if ( MODULE_BAY ) {
				module_bay();
				mirror([0,1,0]) {
					module_bay();
				};
			}
		};
	};
};

// Lid
//////

if (PART == "lid"){
	union() {
		difference() {
			//lid with interlocking ledge
			union(){
				base_plate(BOX_L, BOX_W, LID_H);
				if (RIM) {
					base_plate(BOX_L + RIM_W, BOX_W + RIM_W, LID_H-2);
				};
			};
			//make space for latch / hinge
			modbay_cutout(modbay_offset);
			lid_phase();
			mirror ([0,1,0])
				modbay_cutout(modbay_offset);
			mirror ([1,0,0])
				lid_phase();
		};
		//add hinges
		for (i = hinge_coordinates) {
			translate (i) hinge();
		}
	};
};

// Modbay module clip
/////////////////////

if (PART == "module_snap"){
	render () {
		union () {
			mod_template();
		};
	};
};
//		cylinder(r=100,h=1);
//		linear_extrude (3)
//			text("Sry, not designed yet. :(",halign="center",valign="center");
