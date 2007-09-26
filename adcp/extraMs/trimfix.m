function trimfix(infile,outfile,rec1,rec2)

% function trimfix(infile,outfile,rec1,rec2)
% Uses the Record number given in rec1 and rec2 to 
% locate the correct indices and then submits the file to nctrim 
% retaining only the records between rec1 and rec2.
%
% If rec1 is not given the first record number will be used.
% Likewise if rec2 is not given, the last record number will be used.
% To trim ensembles at the end of the data set,
% specify only rec2 and default to the first record for rec1, 
% set rec1 = ' ', and give an ensemble number for rec2.
% example: trimfix('564whT.cdf','564whTt.cdf',' ',5678)	
%
% Written by Jessica M. Cote
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to jcote@usgs.gov


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

 
h = netcdf(infile,'nowrite')
if isempty(h),return, end

ftime = h{'TIM'};
jtime = ftime(:);

rec = h{'Rec'}(:);
first = rec(1);
last = rec(end);

if nargin < 3 | isempty(rec1), rec1 = first;, end
if nargin < 4, rec2 = last;, end

%if rec2 given is greater than the last ensembel number you get garbage
if rec2 > last
   error('rec2 is too big')
end

if first > 1
   if rec1 > 2
      beg = rec1-first+1;
   else
      beg = rec1;
   end
   
   Rend = rec2 - first;  
else
   beg = rec1;
   Rend = rec2;
end

ncclose(h)
disp(['trim ' infile ' from index ' num2str(beg) ' to ' num2str(Rend) ';'])

nctrim(infile,outfile,(beg:Rend));

thecomment='additional ensembles were trimmed by trimfix.m';
history(outfile,thecomment);

ncclose