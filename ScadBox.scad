$fn=20;

/*[Dimensions]*/
// Length in mm
BOX_L_OUTER = 165; //[60:5:300]
// Width in mm
BOX_W_OUTER = 120; //[60:5:300]
// Height in mm
BOX_H_OUTER =  22; //[60:5:300]
// Corner Radius in mm
CORNER_RADIUS = 2; //[1:1:10]
// Top Rim in mm 
BOX_RIM = 3; //[3:1:10]
// Outer Wall Thickness
WALL_THICKNESS = 1.5;
// Inner Wall Thickness
DIVIDER_THICKNESS = 1;
// Floor Thickness
FLOOR_THICKNESS = 1;

/*[Divisions]*/
//number of divisions on the long edge
DIVISIONS_L =1;
//number of divisions on the short edge
DIVISIONS_W =3;

/*[Hidden]*/
BOX_L = BOX_L_OUTER-2*CORNER_RADIUS; // Box Width
BOX_W = BOX_W_OUTER-2*CORNER_RADIUS; // Box Length
BOX_H = BOX_H_OUTER; // Box Height

POST_OFFSET=10;

module box_base() {
	linear_extrude( BOX_H-BOX_RIM )
		difference(){
			offset(r=CORNER_RADIUS) 
				square( [BOX_W , BOX_L ], center=true );

			offset( r = CORNER_RADIUS - WALL_THICKNESS )
				square( [BOX_W - WALL_THICKNESS, BOX_L - WALL_THICKNESS], center=true );
		}
  wt=WALL_THICKNESS;
	c=CORNER_RADIUS;
	coordinates = [ [0,0],[0,BOX_L],[BOX_W,BOX_L],[BOX_W,0] ];

	translate ( [-BOX_W/2, -BOX_L/2] ) {
		hull(){
			for (i = coordinates) {
				translate(i) cylinder(r=CORNER_RADIUS,h=FLOOR_THICKNESS);
			};
		};
	};
};

module box_rim () {
	difference(){
		hull(){
			//upper face
			translate([0,0,-BOX_RIM/2]){
				linear_extrude(BOX_RIM/2){
					offset(r=CORNER_RADIUS)	square( [BOX_W+BOX_RIM, BOX_L+BOX_RIM], center=true );
				};
			};
			//lower face
			translate([0,0,-2*BOX_RIM]){
				linear_extrude(BOX_RIM/2){
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
						square([BOX_W-BOX_RIM/4+0.3,BOX_L-BOX_RIM/4+0.3],center=true);
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

module lock_fixture() {
	difference () {
		translate([0,0,6])
		  union() {
	  		cube([5,4,BOX_H-6]);
			translate([0,0,0])
			intersection() {
			rotate(90, [0,1,0]) cylinder (r=4,h=5);
			 translate([0,0,-4])  cube([5,4,4]);
			};
			};
		union() {
		  hole_offset=2.25;
			translate([-1,hole_offset,BOX_H-8])
				rotate (90,[0,1,0])
				cylinder(BOX_RIM*3,1);
			translate([-1,hole_offset,6])
				rotate (90,[0,1,0])
				cylinder(BOX_RIM*3,1);
		};
	};
};

module fixture_cutout(offset) {
  translate ([-20,offset,0])
	cube([40,3,BOX_H]);

};

module division(x,y) {
  step_x=BOX_W/(x+1) ;
	for (i=[1:x]) {
	translate ([-BOX_W/2+i*step_x,0,BOX_H/2])
		cube([DIVIDER_THICKNESS,BOX_L,BOX_H-BOX_RIM-1],center=true);
		};
  step_y=BOX_L/(y+1) ;
	for (i=[1:y]) {
	translate ([0,-BOX_L/2+i*step_y,BOX_H/2])
		cube([BOX_W,DIVIDER_THICKNESS,BOX_H-BOX_RIM-1],center=true);
		};
};

f_offset = BOX_L/2 + CORNER_RADIUS;
coordinates = [ [20,f_offset],[-25,f_offset]];


difference (){
	union () {
		//base
		box_base();

		//top rim
		translate([0,0,BOX_H]) {
			box_rim();
		};
			division(DIVISIONS_L,DIVISIONS_W);

		//fixtures
		for (i = coordinates)
			translate (i) lock_fixture();
		mirror ([0,1,0]){
			for (i = coordinates)
				translate (i) lock_fixture();
		};
	};
	fixture_cutout(f_offset);
	mirror ([0,1,0]){
		fixture_cutout(f_offset);
	};
};
