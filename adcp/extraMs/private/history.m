function [theFile] = history(theFile,thecomment)

%function [theFile] = history(theFile,thecomment)
%appends the history with the comment requested
%will work on any netcdf file that has the 'history' attribute


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

 
%Need to make more generic

% Written by Jessica M. Cote
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to jcote@usgs.gov

%version
%updated 10-Aug-1999 16:20:42
% revised to use lower-case "history" and update creation date
%		attribute as well 03-Aug-2000 Fran Hotchkiss
% updated 28-Dec-2000 09:00:47 - changed format for linefeeds put into functions (ALR)

g=netcdf(theFile,'write');

hist=g.history;
if isempty(hist)
   hist=g.History;
   hist=name(hist,'history');
end   
if isempty(hist)
   hist=g.PROG_CMNT1;
   hist=name(hist,'history');
disp(['Global Attribute "PROG_CMNT1" was changed to "history" in file' theFile]);  
end   

g.history=[thecomment hist(:)];
g.CREATION_DATE = datestr(now,0);
close(g)
