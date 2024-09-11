$fn=20;

/*[Dimensions]*/
//CONFIGSTART
// Length in mm
BOX_L_OUTER = 165; //[60:5:300]

// Width in mm
BOX_W_OUTER = 120; //[60:5:300]

// Height in mm
BOX_H_OUTER =  22; //[60:5:300]

// Corner Radius in mm
CORNER_RADIUS = 3; //[1:1:10]

// Add a top rim
RIM = true;

// Top Rim in mm 
RIM_W = 3; //[3:1:10]

// Outer Wall Thickness
WALL_THICKNESS = 1.5;

// Inner Wall Thickness
DIVIDER_THICKNESS = 1;

// Floor Thickness
FLOOR_THICKNESS = 1;

// Internal or External Lock
INTERNAL_LOCK = false;

//number of divisions on the long edge
DIVISIONS_L =1;

//number of divisions on the short edge
DIVISIONS_W =3;
//CONFIGEND
/*[Hidden]*/
FIXTURE_W = 5;
FIXTURE_THICKNESS = 4;
LOCK_W = 35;
INTERNAL_LOCK_DEPTH = 15;

BOX_L = BOX_L_OUTER-2*CORNER_RADIUS; // Box Width
BOX_W = BOX_W_OUTER-2*CORNER_RADIUS; // Box Length
BOX_H = BOX_H_OUTER; // Box Height

POST_OFFSET=10;

module box_base() {
  ext_h = RIM ? BOX_H-RIM_W : BOX_H;
  linear_extrude( ext_h )
		difference(){
			offset(r=CORNER_RADIUS) 
				square( [BOX_W , BOX_L ], center=true );

			offset( r = CORNER_RADIUS - WALL_THICKNESS )
				square( [BOX_W - WALL_THICKNESS, BOX_L - WALL_THICKNESS], center=true );
		}
  wt=WALL_THICKNESS;
	c=CORNER_RADIUS;
	corner_coordinates = [ [0,0],[0,BOX_L],[BOX_W,BOX_L],[BOX_W,0] ];

	translate ( [-BOX_W/2, -BOX_L/2] ) {
		hull(){
			for (i = corner_coordinates) {
				translate(i) cylinder(r=CORNER_RADIUS,h=FLOOR_THICKNESS);
			};
		};
	};
};

module box_rim () {
	difference(){
		hull(){
			//upper face
			translate([0,0,-RIM_W/2]){
				linear_extrude(RIM_W/2){
					offset(r=CORNER_RADIUS)	square( [BOX_W+RIM_W, BOX_L+RIM_W], center=true );
				};
			};
			//lower face
			translate([0,0,-2*RIM_W]){
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
						square([BOX_W-RIM_W/4+0.3,BOX_L-RIM_W/4+0.3],center=true);
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

module fixture_holes(offset_bottom) {
		union() {

			hole_offset= INTERNAL_LOCK ? - INTERNAL_LOCK_DEPTH/4 : FIXTURE_THICKNESS/2;
			cut=LOCK_W+WALL_THICKNESS*4;
			//upper
#			translate([-cut/2,hole_offset,BOX_H-8])
				rotate (90,[0,1,0])
		  		cylinder(cut,1);
			//lower
#			translate([-cut/2,hole_offset,offset_bottom])
				rotate (90,[0,1,0])
			  	cylinder(cut,1);
		};
};

module lock_fixture() {
  offset_bottom=FIXTURE_THICKNESS+2;
	difference () {
		translate([0,0,offset_bottom])
			union() {
			  translate([0,0,-FIXTURE_THICKNESS])
					cube([FIXTURE_W,0.3,BOX_H-2]);
				translate([0,0.3,0])
					cube([FIXTURE_W,FIXTURE_THICKNESS,BOX_H-offset_bottom]);
				translate([0,0.3,0])
					intersection() {
						rotate(90, [0,1,0]) cylinder (r=FIXTURE_THICKNESS,h=FIXTURE_W);
						translate([0,0,-FIXTURE_THICKNESS])  cube([FIXTURE_W,FIXTURE_THICKNESS,FIXTURE_THICKNESS]);
					};
			};
		//fixture holes
		fixture_holes(offset_bottom);
	};
};

module lock_internal() {
		width=LOCK_W;
		depth=INTERNAL_LOCK_DEPTH;
		translate ([0,BOX_L_OUTER/2,1])
		difference () {
			linear_extrude(BOX_H-RIM_W)
				difference () {
				  offset(3) square([width, depth], center=true);
				  square([width, depth], center=true);
				};
				translate([-width,0,0]) cube([width*2,INTERNAL_LOCK_DEPTH,BOX_H]);
				fixture_holes(FIXTURE_THICKNESS+2);
		};
};

module lock_cutout(offset) {
  cut_depth = INTERNAL_LOCK ? INTERNAL_LOCK_DEPTH : RIM_W+FIXTURE_THICKNESS;
	cut_offset = INTERNAL_LOCK ? offset-cut_depth/2 : offset + RIM_W;
	translate ([-LOCK_W/2,cut_offset,-3])
		linear_extrude(BOX_H*2)
  //		offset(r=CORNER_RADIUS)
    		square([LOCK_W,cut_depth]);
};

module division(x,y) {
  step_x=BOX_W/(x+1) ;
	for (i=[1:x]) {
	translate ([-BOX_W/2+i*step_x,0,BOX_H/2-0.5])
		cube([DIVIDER_THICKNESS,BOX_L_OUTER,BOX_H-RIM_W],center=true);
		};
  step_y=BOX_L/(y+1) ;
	for (i=[1:y]) {
	translate ([0,-BOX_L/2+i*step_y,BOX_H/2-0.5])
		cube([BOX_W_OUTER ,DIVIDER_THICKNESS,BOX_H-RIM_W],center=true);
		};
};

offset_fixture_position = BOX_L/2 + CORNER_RADIUS;
fixture_coordinates = [ [LOCK_W/2,offset_fixture_position],[-LOCK_W/2-FIXTURE_W,offset_fixture_position]];

//box
union() {
	difference (){
		union () {
			//create base shape
			box_base();

			//add top rim
			if (RIM){
				translate([0,0,BOX_H]) {
					box_rim();
				};
			};

			//add division
			division(DIVISIONS_L,DIVISIONS_W);
		};

		//make space for locking mechanism
		lock_cutout(offset_fixture_position);
		mirror ([0,1,0]){
			lock_cutout(offset_fixture_position);
		};
	};

	//add lock fixtures
	if (INTERNAL_LOCK) {
    lock_internal();
		mirror([0,1,0]) {
		lock_internal();
		};
	}
	else {
		for (i = fixture_coordinates) {
			translate (i) lock_fixture();
		}
		mirror ([0,1,0]){
			for (i = fixture_coordinates) {
				translate (i) lock_fixture();
			};
		};
	};
};
