function dataStruct=showpen09(ncr, idnum, input_params)
%SHOWPEN09 - displays images from Pencil _raw.cdf
%
% inputs are the raw.cdf object, the index to work on, and any input params
% the input_params structure contains x, y for the vectors to interpolate
% into, and tilt for number of degrees of head tilt to add.
% output is a structure containing things to put in the _proc.nc file

% works now reading from ncr- sweep separation implemented- looping
% through each frame is handled in do_pen_proc

%doing pcolor(raw_image) produces same orientation as pcolor(imagedata)
%after read in showpwn07, so orientations match.

if nargin~=3; help Mfilename; return; end

imagedata=squeeze(ncr{'raw_image'}(idnum,:,:));
% pre-allocate the size of the output structure
 dataStruct(2) = struct( 'proc_im', [], 'range_config', [], 'headangle',[]);
 npoints = ncr.DataPoints(:);
 range_config=ncr.Range(:);
if isempty(range_config)
    range_config=3;     % this is the default for all pencil
end
SampPerMeter = npoints/range_config;
% hang needs to be (1,884) here
% select an angle of tilt to make the pencil profile nominally flat at deployment
hang=((ncr{'headangle'}(:)+input_params.tilt)*pi./180)';  %radians

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
    % xx and input_params.y below are arbitrary numbers for getting the right general shape- they can be tweaked!
       imi=griddata(Xr,Yr,D,input_params.x,input_params.y,'linear');
    %figure
    if (strcmp(input_params.mkplt,'y'))
     pcolor(input_params.x,-input_params.y, imi); shading flat
     title('interpd version')
    end
  
    % now save the values you want
    dataStruct(jj).proc_im = imi;
    dataStruct(jj).range_config = range_config;
    dataStruct(jj).headangle = hangj;
end