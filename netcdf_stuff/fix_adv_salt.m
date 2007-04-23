function fix_adv_salt(ncfilename)
% computes correct salinity for adv's with ctd attached.  Current method
% generates something obviously NOT salinity
% usage fix_adv_salt('adv7282vp-cal2')
% etm 6/30/06

perloc=findstr('.',ncfilename);
new_nm=[ncfilename(1:perloc-1) '_old.nc'];

result=fcopy(ncfilename,new_nm);
nc = netcdf(ncfilename, 'write');
if isempty(nc), return, end
 
%% Global attributes:
lfeed = char(10);
nc.CREATION_DATE = ncchar(datestr(now,0));
history = ['recomputed salinity from T&C.:' nc.history(:) ':' nc.history(:)];
ifeed = findstr(history,lfeed);
history(ifeed) = ':';
nc.history = ncchar(history);
nc.history = ncchar(history);
% have to make cond into cond. ratio and adjust units
zz=sw_salt((nc{'CTDCON_4218'}(:)*10/sw_c3515),....
    nc{'CTDTMP_4211'}(:),sw_pres(nc{'depth'}(:),nc{'lat'}(:)));
nc{'CTDSAL_4214'}(:)=zz;
close(nc)
