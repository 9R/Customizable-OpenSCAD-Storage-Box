$fn=100;
BOX_W = 120; // Box Width
BOX_L = 160; // Box Length
BOX_H =  22; // Box Height

SCREW_SIZE = 1.5; // Screw size radius.

BOX_RIM = 3;

CORNER_RADIUS = 3; // Radius of corners
WALL_THICKNESS = 1.5;// Wall Thickness

POST_OFFSET=10;

module box_base() {
	linear_extrude( BOX_H-BOX_RIM )
		difference(){
			offset(r=CORNER_RADIUS) 
				square( [BOX_W, BOX_L], center=true );

			offset( r= CORNER_RADIUS - WALL_THICKNESS )
				square( [BOX_W-WALL_THICKNESS, BOX_L-WALL_THICKNESS], center=true );
		}


	coordinates = [ [0,0],[0,BOX_L],[BOX_W,BOX_L],[BOX_W,0] ];

	translate ( [-BOX_W/2, -BOX_L/2] )
		hull(){
			for (i = coordinates) {
				translate(i) cylinder(CORNER_RADIUS);
			};
		};
	p_w = BOX_W - POST_OFFSET;
	p_l = BOX_L - POST_OFFSET;
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
			translate([0,0,-BOX_RIM]){
				linear_extrude(BOX_RIM/2){
					offset(r=CORNER_RADIUS) 
						square( [BOX_W, BOX_L], center=true );
				};
			};
		};
		//cutout
		union(){
			translate ([0,0,-BOX_RIM/2]) {
				linear_extrude(BOX_H){
					offset(r=CORNER_RADIUS) square([BOX_W+BOX_RIM/4,BOX_L+BOX_RIM/4],center=true);
				};
			};
			translate([0,0,-BOX_RIM])
			linear_extrude(BOX_H){
				offset( r= CORNER_RADIUS - WALL_THICKNESS )
					square( [BOX_W-WALL_THICKNESS, BOX_L-WALL_THICKNESS], center=true );
			};
		};
	};
};

union () {
box_base();
translate([0,0,BOX_H])
box_rim();
};
