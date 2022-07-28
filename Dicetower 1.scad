// version 0.0.8
// Spring used from the examples included in OpenScad

//variables
quality = 16;
gaps = 16;


// taken from openscad example 20
module coil(r1 = 100, r2 = 10, h = 100, stepsize=1/16, twists)
{
    hr = h / (twists * 2);
    module segment(i1, i2) {
        alpha1 = i1 * 360*r2/hr;
        alpha2 = i2 * 360*r2/hr;
        len1 = sin(acos(i1*2-1))*r2;
        len2 = sin(acos(i2*2-1))*r2;
        if (len1 < 0.01)
            polygon([
                [ cos(alpha1)*r1, sin(alpha1)*r1 ],
                [ cos(alpha2)*(r1-len2), sin(alpha2)*(r1-len2) ],
                [ cos(alpha2)*(r1+len2), sin(alpha2)*(r1+len2) ]
            ]);
        if (len2 < 0.01)
            polygon([
                [ cos(alpha1)*(r1+len1), sin(alpha1)*(r1+len1) ],
                [ cos(alpha1)*(r1-len1), sin(alpha1)*(r1-len1) ],
                [ cos(alpha2)*r1, sin(alpha2)*r1 ],
            ]);
        if (len1 >= 0.01 && len2 >= 0.01)
            polygon([
                [ cos(alpha1)*(r1+len1), sin(alpha1)*(r1+len1) ],
                [ cos(alpha1)*(r1-len1), sin(alpha1)*(r1-len1) ],
                [ cos(alpha2)*(r1-len2), sin(alpha2)*(r1-len2) ],
                [ cos(alpha2)*(r1+len2), sin(alpha2)*(r1+len2) ]
            ]);
    }
    linear_extrude(height = h, twist = 180*h/hr,
            $fn = (hr/r2)/stepsize, convexity = 5) {
        for (i = [ stepsize : stepsize : 1+stepsize/2 ]) 
            segment(i-stepsize, min(i, 1));
    }
}

module battlement(radius= 7.5, width = 1, bgaps=8) {
    difference() {
        cylinder(h=1, r=radius, center=true, $fn=(quality*2));
        union() {        
            cylinder(h=2, r=radius-width, center=true, $fn=(quality*2));
            if(bgaps>0)
                for(bar = [1: bgaps])
                    rotate([0,0,(360/bgaps)*bar]) cube([1,(radius*2)+1,1.5],center=true);
        }
    }
}

X1 = 4;
X2 = 3;
RD = 0.25;
SH = 20.001;
TW = 2;
rcnt = 4;

module tube() {
    
    difference() {
        coil(r1 = X1, r2 = X2, h = SH, stepsize = 1/quality, twists = TW);
        union() {
            for(rnum = [1 : rcnt])
                translate([0,0,1.25+(rnum+1)*(SH/(rcnt+1))]) 
                    rotate([0,0,-1*(((360*TW)/(rcnt+1))*(rnum+1))])
                        rotate([90,0,0])
                            translate([-1*X1,-1*(X2+(RD/2)),0])
                                rotate([0,0,247.5])
                                    rotate_extrude(convexity=10, angle=45, $fn=(quality*2))
                                        translate([X2,0,0])
                                            circle(r=RD,$fn=(quality*2));
        }
    }

}

DOTEST = 0;
DOALL = 1;
module dicetower() {
    scale(1)
        if(DOTEST==1) {
            
            rotate([0,0,-45])
                translate ([0,0,13]) 
                    translate ([0,0,-10]) {
                        tube();
                    }
        } else {
            //  
            // Main tower
            rotate([0,0,-45])
                union() {
                    translate ([0,0,13]) 
                        difference() {
                            difference() {
                                cylinder(h=20, r=6.5, center=true, $fn=(quality*2));
                                translate ([0,0,-1*(SH/2)])
                                    tube();
                            }
                            resize([6,0,0])
                                rotate([90,0,0]) 
                                    translate([5,-10,-6.5]) 
                                        cylinder(h=10, r=5, center=true, $fn=(quality*2));
                        }
                        
                    if(DOALL==1) {
                        cylinder(h=3, r2=6.5, r1=10, $fn=(quality*2));
                    }
                }
            
             // Upper Ring
             translate ([0,0,22])
                 union() {
                     difference() {
                        cylinder(h=2, r1=6.5, r2=7.5, center=true, $fn=(quality*2));
                        cylinder(h=3, r=6.5, center=true, $fn=(quality*2));
                     }
                     translate ([0,0,1.5])
                         difference() {
                            cylinder(h=1, r=7.5, center=true, $fn=(quality*2));
                            cylinder(h=2, r=6.5, center=true, $fn=(quality*2));
                         }
                     translate ([0,0,2.5])
                         battlement(radius=7.5, width=1, bgaps = gaps);
                 }
            if(DOALL==1) {
                // courtyard
                translate([6,6,.5]) {
                     union() {
                        scale([1,1,3]) translate ([0,0,0.5]) battlement(radius=15, width=1, bgaps = gaps*2);
                        battlement(radius=15, width=1, bgaps = 0);
                     }
                }
            }
        }
}

difference(){
    dicetower();
    if(DOALL==0) {
        translate ([0,0,22])
            cylinder(h=20, r=10, center=true, $fn=(quality*2));
    }
}
