function swap_meta(ncfilename)
% corrects meta data for the 'b' versions of some MyrtleBeach sc and mc
% files- assumes taking the meta data from the a.nc version and inserting
% the C_51, T_28, S_40 and STH_71 from the B
% usage swap_meta('7222sc-b.nc')

% etm 5/23/06

perloc=findstr('.',ncfilename);
new_nm=[ncfilename(1:perloc-1) '_old.nc'];
a_nm=[ncfilename(1:perloc-2) 'a.nc'];

%extract the variables you want from the b file
ncload(ncfilename,'T_28','C_51','S_40','STH_71')
 bt=T_28; bc=C_51; bsal=S_40; bd=STH_71;
 clear T_28 C_51 S_40 STH_71 time time2

result=fcopy(ncfilename,new_nm);  % save the b file
result=fcopy(a_nm,ncfilename);      % start with the "a" version meta data
nc = netcdf(ncfilename, 'write');   % open the a (file named b)
if isempty(nc), return, end
 
%% Global attributes:
lfeed = char(10);
nc.CREATION_DATE = ncchar(datestr(now,0));
history = ['metadata swaped:' nc.history(:)];
ifeed = findstr(history,lfeed);
history(ifeed) = ':';
nc.history = ncchar(history);
% insert the variables from b
nc{'C_51'}(:)=bc;
nc{'T_28'}(:)=bt;
nc{'S_40'}(:)=bsal;
nc{'STH_71'}(:)=bd;
close(nc)
