function cvt_vpv(fname)
%
% converts an epic format ADCP data file to the format needed as input to
% vpv, a velocity profile display program.

% which write_vpv
ncload(fname,'u_1205');
ncload(fname,'v_1206');
ncload(fname,'time');
ncload(fname,'time2');
% convert epic time to matlab time
  % EPIC time in netcdf files stored as Julian Day in 2 parts
    tt=(time)+time2/(86400000);
  % Julian day 2440000 begins at 0000 hours, May 23, 1968
    mdnt=tt-2440000+datenum('23-May-1968');
    
    %now use write_vpv to create the outputs
    oname=[fname(1:5) '_vpv.txt'];
    write_vpv(oname, mdnt, u_1205, v_1206);
  