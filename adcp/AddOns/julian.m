function [j]=julian(y,m,d,h)

% JULIAN:  Converts Gregorian calendar dates to Julian dates.
%
% USAGE:  [j]=julian([y m d hour min sec])  or   [j]=julian(y,m,d,h) 
% 
% DESCRIPTION:  Converts Gregorian dates to decimal Julian days using the
%               astronomical convension, but with time zero starting
%               at midnight instead of noon.  In this convention,
%               Julian day 2440000 begins at 0000 hours, May 23, 1968.
%               The decimal Julian day, with Matlab's double precision, 
%               yeilds an accuracy of decimal days of about 0.1 milliseconds.
%    
% INPUT:
%        y =  year (e.g., 1979) component
%        m =  month (1-12) component
%        d =  day (1-31) component of Gregorian date
%
%        hour = hours (0-23)
%        min =  minutes (0-59)
%        sec =  decimal seconds 
%          or
%        h =  decimal hours (assumed 0 if absent)
%
% OUTPUT: 
%        j =  decimal Julian day number


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

 
%   last revised 1/3/96 by Rich Signell (rsignell@usgs.gov)

      if nargin==3,
        h=0.;
      elseif nargin==1,
        [m,n]=size(y);
        if n==3, %assume h=m=s=0 if not supplied
           h=zeros(m,1);
        else
           h=hms2h(y(:,4),y(:,5),y(:,6));
        end
        d=y(:,3);
        m=y(:,2);
        y=y(:,1);
      end
      mo=m+9;
      yr=y-1;
      i=find(m>2);
      mo(i)=m(i)-3;
      yr(i)=y(i); 
      c = floor(yr/100);
      yr = yr - c*100;
      j = floor((146097*c)/4) + floor((1461*yr)/4) + ...
           floor((153*mo +2)/5) +d +1721119;

%     If you want julian days to start and end at noon, 
%     replace the following line with:
%     j=j+(h-12)/24;
 
      j=j+h/24;

