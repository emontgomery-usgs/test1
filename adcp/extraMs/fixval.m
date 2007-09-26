function fixval(filename, threshold)  


%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. Côté, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andrée L. Ramsey, Stephen Ruane
% U.S. Geological Survey Open File Report 00-458 
% Check for later versions of this Open-File, it is a living document.
%
% Program written in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%
%%% END USGS BOILERPLATE --------------

 
if nargin < 2, threshold=1e30;, end

h = netcdf(filename,'write')
if isempty(h),return, end

names={'vel1','vel2','vel3','vel4','cor1','cor2','cor3','cor4',...
      'AGC1','AGC2','AGC3','AGC4','PGd1','PGd2','PGd3','PGd4',...
      'Hdg','Ptch','Roll','Tx'};

for i=1:length(names)
   disp(names{i})
   v = h{names{i}};
   data = v(:);
   fill = fillval(v)
   
   k = find(abs(data) > threshold);
   disp(int2str(length(k)))
   data(k) = fill;
   v(:) = data;
end

close(h)