function [singleJD] = singleJD(time,time2);
%
%   [singleJD] = single_jd(time,time2);
%
%Function to take the two inputs time and time2 (standard in the hydrodynamic
%data) and convert to one single julian day (for the purpose, say, of using
%gregorian.m to convert to calender days)
%
%Soupy Alexander, 11/01/2001
%
%Requires no add'l m-files


%%% START USGS BOILERPLATE -------------% Program written in Matlab v6x
% Program works in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
% program ran on Redhat Enterprise Linux 4
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%%% END USGS BOILERPLATE --------------

 
singleJD = time + time2/3600000/24;