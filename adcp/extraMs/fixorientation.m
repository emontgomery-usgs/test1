function fixorientation(filename, new_orientation)
%FIXORIENTATION change an uplooking ADCP to a downlooker by flipping the depths
%
%function fixorientation(filename)  
%corrects orientation to user specified UP or DOWN, as the value determined
%in rdi2cdf.m can be incorrect due to instrument being tilted the opposite
%direction at the time of first ping.
%
% filename = name of netcdf file
% new_orientation = the orientation you know the ADCP was in UP | DOWN


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

 
%
% Written by Stephen Ruane
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to sruane@usgs.gov
%
% 
% 24-jan-07 MM fix the inputs
% 19-dec-06 MM have this fundtion fix the depths, too

if ~exist('filename', 'var'),
    [theFile, thePath] = uigetfile({'*.cdf','*.cdf, raw ADCP data from rdi2cdf.m'},...
        'Select Binary ADCP File:');
      if ~any(theFile), return, end
      filename = fullfile(thePath, theFile);
end
if ~exist('new_orientation','var'), new_orientation = []; end

h = netcdf(filename,'write');
if isempty(h),
    disp(sprintf('%s is unable to open %s',mfilename, filename))
    return, 
end

old_orientation = h.orientation(:);
buf = sprintf('The ADCP thinks is was %slooking',old_orientation);
if isempty(new_orientation), 
    new_orientation = questdlg({buf;'What was the actual deployed orientation?'},...
        'Orientation Checker','UP','DOWN',old_orientation);
    close(h);
    return,
end

if ~strcmp(old_orientation, new_orientation),
    h.orientation(:) = new_orientation;
    % fix the depths, too, recalculate from scratch.
    % need to find the NOTE in the attributes for D
    aobjs = att(h{'D'});
    for iobj = 1:length(aobjs), 
        % find a note
        if findstr('NOTE',char(ncnames(aobjs{iobj}))),
            % make sure it's the orientation note
            theattname = char(ncnames(aobjs{iobj}));
            eval(sprintf('theattdata = h{''D''}.%s(:);',theattname))
            if findstr('bin depths are relative to the',theattdata),
                % it's the one we need, stop looking
                break;
            end
        end
    end
    % compute bin locations from scratch
    bin1 = h{'D'}.center_first_bin(1);
    binsize = h{'D'}.bin_size(1);
    bincnt = h{'D'}.bin_count(1);
    depths = bin1:binsize:(((bincnt-1)*binsize)+bin1);
    xducer_offset = h{'D'}.xducer_offset_from_bottom(1);
    switch h.orientation(:)
        case 'UP'
            theattdata = 'bin depths are relative to the seabed';
            % adjust for ADCP position 
            depths = depths+xducer_offset;
        case 'down'
            theattdata = 'bin depths are relative to the transducer head';
            % flip the bins
            depths = depths * -1;
    end
    eval(sprintf('h{''D''}.%s(:) = theattdata;',theattname))
    h{'D'}(:) = depths;
    close(h);
    thecomment=sprintf('%s\n',' The orientation byte and depth bins were corrected by fixorientation.m');
    history(filename,thecomment);
else
    close(h)
end

