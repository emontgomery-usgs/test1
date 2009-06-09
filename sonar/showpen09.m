function dataStruct=showpen09(ncr,idnum, intrp_dims)
%SHOWPEN09 - displays images from Pencil _raw.cdf
%
% inputs are the raw.cdf object, and the index to work on
% output is a structure containing things to put in the _proc.nc file

% works now reading from ncr- sweep separation implemented- looping
% through eadh frame is handled in do_pen_proc

%doing pcolor(raw_image) produces same orientation as pcolor(imagedata)
%after read in showpwn07, so orientations match.

if nargin~=3; help MFILENAME; return; end

imagedata=squeeze(ncr{'raw_image'}(idnum,:,:));

npoints = ncr.DataPoints(:);
range_config=ncr.Range(:);
SampPerMeter = npoints/range_config;
% hang needs to be (1,884) here
hang=(ncr{'headangle'}(:)*pi./180)';  %radians

if (hang(1)==hang(end))
    nsweeps=2;
else 
    nsweeps=1;
end

loc=length(hang)/2;

for jj=1:nsweeps
    if jj==1
        hangj=hang(1:loc);
        imj=imagedata(:,1:loc);
    else
        hangj=hang(loc+1:end);
        imj=imagedata(:,loc+1:end);
    end

    r  = 1:npoints;    %because the last point is already removed from imagedata
    rr = r./SampPerMeter(1);
    Yr = rr'*cos(hangj);
    Xr = rr'*sin(hangj);

    colorthreshold = 0;
    %colorthreshold = input('Color threshold for black (1:100)? ');  % This is a noise floor
    D = imj-colorthreshold;  	% Trim off header
    Dz = find(D<0);									% Make all values below
    D(Dz) = 0;											% threshold = 0
    %figure
    %axhan = pcolor(Xr,-Yr,D); shading interp	% you can use surf or mesh if desired here
    %axis ([-3 3 -.9 -.7])
    %title('raw version, plotted against sin and cos')

    % interpolate into x,y space
    % xx and intrp_dims.y below are arbitrary numbers for getting the right general shape- they can be tweaked!
       imi=griddata(Xr,Yr,D,intrp_dims.x,intrp_dims.y,'linear');
    %figure
    pcolor(intrp_dims.x,-intrp_dims.y, imi); shading flat
    % title('interpd version')

    % compute the line from the image based on highest signal strength in each bin
    [x_gd, y_gd, z_gd]=linfrmimg(intrp_dims.x,intrp_dims.y, imi,range_config)
    % now save the values you want
    dataStruct(jj).proc_im = imi;
    dataStruct(jj).xmat = Xr;
    dataStruct(jj).ymat = Yr;
    dataStruct(jj).range_config = range_config;
    dataStruct(jj).headangle = hangj;
    dataStruct(jj).intrpx = x_gd;
    dataStruct(jj).intrpy = y_gd;
    dataStruct(jj).intrpz = z_gd;
end