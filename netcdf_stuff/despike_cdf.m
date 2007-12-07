function despike_cdf(dsfile, settings)
% function to truncate a .cdf file by cutting off initial
% and final records or otherwise outside a designated "good" range of values.
%   usage : copy 6903rcm-trm.cdf 6903rcm-ds.cdf
%           despike_cdf('8173sc-ds.nc',settings)
%     settings.nsd=2.5 (set the number of standard deviations to allow)
%     settings.rvalue=1e35 (or 'mean', median', 'interp' or another constant)
%        Ellyn Montgomery 12/7/07

% copy the input file to something safe first
 
% and open the output file to take trimmed data
   outc = netcdf(dsfile,'write');
% set the bounds to keep
   % Call nctrim.


% Update global attributes.
history =['despike_cdf replaced spikes'];  
history =[history '.  :' outc.history(:)];  

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
vname=ncnames(var(outc));
for i = 6:length(theVars)
   theDims = dim(theVars{i});
   mm=char(vname(i));
   eval(['plot(outc{''' mm '''}(:))'])
   eval(['[outc{''' mm '''}(:),qa]=rmspikes(outc{''' mm '''}(:),settings);'])
   if length(theDims) > 1
      if isequal(name(theDims{1}),name(theRecdim))
         data = outc{name(theVars{i})}(:);
         outc{name(theVars{i})}.minimum = ncfloat(min(data));
         outc{name(theVars{i})}.maximum = ncfloat(max(data));
      end
   end
end
        
ncclose
