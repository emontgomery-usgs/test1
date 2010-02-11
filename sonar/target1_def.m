% defines elements of the targets used in arrangement 1
%% Location of stuff on all target arrangements

% Baseline for tank measurements- grid established parallel to tripod
% m(1:4) are already corrected for the offset, so shouldn't be adjusted again
% tank y axis- had 4 bolts used for measurement reference
m(1).n = 'A';
m(1).ln = 'Bolt A';
m(1).xm = .10;
m(1).ym = 2.-.32;
m(1).zm = 0.0;

% bolt B is (-.1, -.32) from tripod origin under ADCP
m(2).n = 'B';
m(2).ln = 'Bolt B';
m(2).xm = .10;
m(2).ym = -.32;
m(2).zm = 0.0;

m(3).n = 'C';
m(3).ln = 'Bolt C';
m(3).xm = .10;
m(3).ym = -2-.32;
m(3).zm = 0.0;

m(4).n = 'D';
m(4).ln = 'Bolt D';
m(4).xm = .10;
m(4).ym = -4.-.32;
m(4).zm = 0.0;

% shorthand names for reference bolt locations.  These are corected into
% tripod cooordinates already!  Don't need the (.1, .32) adjustment.
XA = m(1).xm; YA = m(1).ym;
XB = m(2).xm; YB = m(2).ym;
XC = m(3).xm; YC = m(3).ym;
XD = m(4).xm; YD = m(4).ym;

%% Target 1 items
% 5 - 8 are big longer wavelength panels in NW quadrant
im = 5;
[m(im).xm, m(im).ym]= range_range(XA,YA,XB,YB,2.6,3.04,'w');
im = 6;
[m(im).xm, m(im).ym]= range_range(XA,YA,XB,YB,3.22,2.33,'w');
im = 7;
[m(im).xm, m(im).ym]= range_range(XA,YA,XB,YB,6.52,5.97,'w');
im = 8;
[m(im).xm, m(im).ym]= range_range(XA,YA,XB,YB,6.26,6.29,'w');

% 9-12 are big shorter wavelength panels in SW quadrant
im = 9;
[m(im).xm, m(im).ym]= range_range(XB,YB,XC,YC,1.256,1.54,'w')
im = 10;
[m(im).xm, m(im).ym]= range_range(XB,YB,XC,YC,2.23,.97,'w');
im = 11;
[m(im).xm, m(im).ym]= range_range(XC,YC,XD,YD,2.415,3.08,'w');
im = 12;
[m(im).xm, m(im).ym]= range_range(XC,YC,XD,YD,3.08,2.40,'w');

im = 13;  % bottom on y
m(im).xm = XD;, m(im).ym = YD+.146;
im=14;   % at direction change on y
m(im).xm = XC;, m(im).ym = YC;
im=15;   % top of nearest sheet at y axis
m(im).xm = XC;, m(im).ym = m(9).ym;

% 16-19 are points associated with the dead zone marker bricks
% not sure where the measurement mis-match is, but these need .32 added
im = 16;    %apex of brick line defining angle nearest A
m(im).xm=XA;
m(im).ym= YA+.23;   % 23 cm beyond bolt A

% % fabricated by eyeball ! never measured
% im = 17;    %point at end of line where initial bricks are
% [m(im).xm, m(im).ym]= range_range(XA,YA,XC,YC,3.0,2.05,'e');

% as measured at MOF on 31 Dec
im = 17;    %point at end of line where initial bricks are
[m(im).xm, m(im).ym]= range_range(XB,YB,XC,YC,2.24,2.018,'e');

% mid-dead zone where the two pieces of angle meet
im = 18;    % should be the junction of the two lines
[m(im).xm, m(im).ym]= range_range(m(16).xm,m(16).ym,XB,YB,1.933,1.09,'e');

% mid-dead zone where the two pieces of angle meet
im = 18;    % should be the junction of the two lines
[m(im).xm, m(im).ym]= range_range(XA,YA,XB,YB,1.76,1.07,'e');

im = 19;    % mid-dead zone where lead brick v is
[m(im).xm, m(im).ym]= range_range(XA,YA,XB,YB,1.972,1.876,'e');

% Brick pile
% SW corner of brick pile (only have the one measurement)
im = 20;
[m(im).xm, m(im).ym]= range_range(XB,YB,XC,YC,1.86,.2,'e');

% brick square: individual bricks are 10 x 20 x 6 cm
outer_square = [0 2*.10+3*.20; 3*.20 2*.10+3*.20; 3*.20 0;];
im = 21;
for i=1:3
   m(im).xm = m(20).xm+outer_square(i,1);
   m(im).ym = m(20).ym+outer_square(i,2);
   im = im+1;
end
inner_square = [.1 .1; .1 .1+3*.20; 3*.20-.1 .1+3*.20; 3*.20-.1 .1;];
for i=1:4
   m(im).xm = m(20).xm+inner_square(i,1);
   m(im).ym = m(20).ym+inner_square(i,2);
   im = im+1;
end
% after this code we're at im=27
% % three newly measured corners of the brick oval
% im = 21;
% [m(im).xm, m(im).ym]= range_range(XB,YB,XC,YC,1.065,0.96,'e');
% plot(m(im).xm,m(im).ym,'rh')
% im = 22;
% [m(im).xm, m(im).ym]= range_range(XB,YB,XC,YC,1.27,1.21,'e');
% plot(m(im).xm,m(im).ym,'rh')
% im = 23;
% [m(im).xm, m(im).ym]= range_range(XB,YB,XC,YC,1.99,.745,'e');
% plot(m(im).xm,m(im).ym,'rh')
% plot([m([20:23]).xm],[m([20:23]).ym],'-m')

% these are the points measured to the corners of the inner bricks marking 
% the dead xone
im = 28;
[m(im).xm, m(im).ym]= range_range(XA,YA,XB,YB,.535,1.56,'e');
im = 29;
[m(im).xm, m(im).ym]= range_range(XA,YA,XB,YB,0.74,1.41,'e');

im = 30;
[m(im).xm, m(im).ym]= range_range(XA,YA,XB,YB,1.35,1.06,'e');
im = 31;
[m(im).xm, m(im).ym]= range_range(XA,YA,XB,YB,1.545,.995,'e');

im = 32;
[m(im).xm, m(im).ym]= range_range(XA,YA,XC,YC,1.935,2.49,'e');
im = 33;
[m(im).xm, m(im).ym]= range_range(XB,YB,XC,YC,1.045,2.37,'e');

im = 34;
[m(im).xm, m(im).ym]= range_range(XB,YB,XC,YC,1.38,2.07,'e');
im = 35;
[m(im).xm, m(im).ym]= range_range(XB,YB,XC,YC,1.52,2.005,'e');

