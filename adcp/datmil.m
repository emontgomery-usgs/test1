function [sdate,yyyy,mm,dd] = datmil(ndat)

%function[yyyymmdd] = datmil(ndat)
% ndat is a date number as given in the matlab datenum format
% and is turned into the military date format of yyyy/mm/dd
% Also gives the year, month, and day broken into pieces


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

 
%Jessica M. Cote, March 2000
%US Geological Survey
%Woods Hole, MA

[y,m,d] = datevec(floor(ndat));

yyyy = num2str(y);
if m < 10
   mm = ['0' num2str(m)];
else
   mm = num2str(m);
end

if d < 10
   dd = ['0' num2str(d)];
else
   dd =  num2str(d);
end

sdate = [yyyy '/' mm '/' dd];

