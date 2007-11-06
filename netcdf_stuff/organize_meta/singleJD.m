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

singleJD = time + time2/3600000/24;