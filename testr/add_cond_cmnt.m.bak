 function add_cond_cmnt(ncfilename)
%  for MB mc data, some had drift attributable to bio-fouling, so
%  added a comment to the C_51, S_40 and STH_71 fields to draw attention.

perloc=findstr('.',ncfilename);
new_nm=[ncfilename(1:perloc-1) '_old.nc'];

result=fcopy(ncfilename,new_nm);    % save the original
nc = netcdf(ncfilename, 'write');   % open the a (file named b)
if isempty(nc), return, end
 
%% Global attributes:
lfeed = char(10);
nc.CREATION_DATE = ncchar(datestr(now,0));
history = ['made 0 in hght_18 NaN & added comment.:' nc.history(:)];
ifeed = findstr(history,lfeed);
history(ifeed) = ':';
nc.history = ncchar(history);
nc.history = ncchar(history);
nc{'hght_18'}.note= ncchar('tops of excursions clipped')
close(nc)
