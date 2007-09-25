function wrt_cf(fileroot)
% fill the netcdf container defined by tst7581.cdf (that has a time_cf) 
% with data from theoriginal file
%  outputs _cf.cdf file 

    tmplfile = ['tst7581.cdf'];  % it always looks for the same template
    ofile = [ fileroot '_cf.cdf'];
    infile = [fileroot '.nc'];
    
%now open the cdf files
 outc = netcdf(ofile,'noclobber');
nci=netcdf(tmplfile,'r');
  copy(nci{'time_cf'},outc,1,1);  % get this from the template
   close(nci)
   
nc=netcdf(infile,'r');
 ingatts=att(nc);
  copy (ingatts,outc)

 %copy the existing ones
copy(nc{'time'},outc,1,1);
copy(nc{'time2'},outc,1,1);
copy(nc{'depth'},outc,1,1);
copy(nc{'lon'},outc,1,1);
copy(nc{'lat'},outc,1,1);

% compute the time_cf
tt=(nc{'time'}*86400)+(nc{'time2'}/1000);

% now create the epic compliant time
outc{'time_cf'}(1:length(tt))=tt;
outc{'time_cf'}.units='seconds from 1 Jan -4712';
outc{'time_cf'}.axis='T';
outc{'time_cf'}.type='EVEN';
outc{'time_cf'}.note='same time as EPIC, but as one variable in seconds';
outc{'time_cf'}.units='seconds from 1 Jan -4712';

%copy the variables over too
epname=ncnames(var(nc));
for i=6:length(epname)
    disp (['creating output variable ' epname{i}]);
    ivar = nc{epname{i}};
    copy(ivar,outc,1,1);
    nc{epname{i}}.coordinates=ncchar('time_cf lat lon depth');
end
% add a couple lame comments
outc.conventions='cf-1.0';
outc.note='test for cf compliance';

close (outc)
close (nc)

