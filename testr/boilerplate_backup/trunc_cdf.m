function trunc_cdf(infile, outfile, indxs)
% function to truncate a .cdf file by cutting off initial
% and final records or otherwise outside a designated "good" range of values.
%   usage : trunc_cdf('8173sc-cal.cdf','8173sc-trm.nc',[1129 22764])
%        Fran Hotchkiss April 8, 1998
%        mod. etm 8/1/06

% open input file
   rawc = netcdf(infile);
% and the output file to take trimmed data
   outc = netcdf(outfile,'noclobber');
% set the bounds to keep
   start=indxs(1); stop=indxs(end);

   % Call nctrim.
   outc = nctrim(rawc,outc, start:stop);


% Update global attributes.
history =['Trimmed using truncate.m to select records in the range '];  
history =[history num2str(start) ' to ' num2str(stop) '.  :' outc.history(:)];  

outc.history = history;
time = outc{'time'}(:);
time2 = outc{'time2'}(:);
stime = ep_datenum([time(1) time2(1)]);
n = length(time);
ltime = ep_datenum([time(n) time2(n)]);
outc.start_time = datestr(stime,0);
outc.stop_time = datestr(ltime,0);
outc.CREATION_DATE = ncchar(datestr(now,0));

% Update minima and maxima of truncated variables.
theVars = var(outc);
theRecdim = recdim(outc);
for i = 1:length(theVars)
   theDims = dim(theVars{i});
   if length(theDims) > 1
      if isequal(name(theDims{1}),name(theRecdim))
         data = outc{name(theVars{i})}(:);
         outc{name(theVars{i})}.minimum = ncfloat(min(data));
         outc{name(theVars{i})}.maximum = ncfloat(max(data));
      end
   end
end
        
ncclose
