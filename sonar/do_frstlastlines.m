% script do_firslastlines.m
% opens an azimuth file and extracts the lines for the first and last
% rotations of the azimuth drive.  The idea is to select those days with ripples 
% perpendicular to the pencil sweeps to see if ripple movement can be
% captured.
% emontgomery@usgs.gov  10/16/09

nc=netcdf('az2009-01-28_raw.cdf');
seta.tidx=1;seta.thold=12; seta.rot2compass=10;seta.Pencil_tilt=0;
[x128_1,y128_1,elev128_1,sstr128_1]=linfrm_rawimg_frstlast(nc,seta);
[x128_2,y128_2,elev128_2,sstr128_2]=linfrm_rawimg_frstlast(nc,seta);
[x128_3,y128_3,elev128_3,sstr128_3]=linfrm_rawimg_frstlast(nc,seta);
[x128_4,y128_4,elev128_4,sstr128_4]=linfrm_rawimg_frstlast(nc,seta);
close(nc)
