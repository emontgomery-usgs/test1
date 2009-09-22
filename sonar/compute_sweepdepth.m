function dataStruct=compute_sweep_depth(ncr, idnum, input_params)
%compute_sweepdepth - gets depths from all rotations of an azimuth image
% inputs are the raw.cdf object, the index to work on, and any input params
% the input_params structure contains x, y for the vectors to interpolate
% into, and tilt for number of degrees of head tilt to add.
% output is a structure containing things to put in the _proc.nc file

% works now reading from ncr- sweep separation implemented- looping
% through each frame is handled in do_pen_proc

%doing pcolor(raw_image) produces same orientation as pcolor(imagedata)
%after read in showpwn07, so orientations match.

if nargin~=3; help Mfilename; return; end

[idx, rotno, ns, np]=size(ncr{'raw_image'}(:));
    % pre-allocate the size of the output structure
    dataStruct(1:rotno) = struct( 'proc_im', [], 'range_config', [], 'headangle',[],...
         'xdist',[], 'depth',[],  'sstrn',[] );
    range_config=ncr.Range(:);
    npoints=ncr.DataPoints(:);
    if isempty(range_config)
        range_config=3;     % this is the default for all pencil
    end
    SampPerMeter = npoints/range_config;
for jj=1:rotno
    imagedata=squeeze(ncr{'raw_image'}(idnum,jj,:,:))';
    % hang needs to be (1,884) here
    % select an angle of tilt to make the pencil profile nominally flat at deployment
    hang=((squeeze(ncr{'headangle'}(idnum,jj,:))+input_params.tilt)*pi./180)';
    
    r  = 1:npoints;    %because the last point is already removed from imagedata
    rr = r./SampPerMeter(1);
    Yr = cos(hang)*rr;
    Xr = sin(hang)*rr;
    %   we only have 443 things that aren't NaN, so trim.  If you have NaN in Xr or Yr,
    %   griddata chokes, and if you don't trim, you'll have nans
    Xr=Xr(1:443,:); Yr=Yr(1:443,:);
    
    colorthreshold = 0;
    %colorthreshold = input('Color threshold for black (1:100)? ');  % This is a noise floor
    D = imagedata(1:443,:)-colorthreshold;  	% Trim off header
    Dz = find(D<0);					% Make all values below
    D(Dz) = 0;						% threshold = 0
    
    % interpolate into x,y space
    % xx and input_params.y below are arbitrary numbers for getting the right general shape- they can be tweaked!
    imi=griddata(Xr,Yr,D,input_params.x,input_params.y,'linear');
    %figure
    if (strcmp(input_params.mkplt,'y'))
        pcolor(input_params.x,-input_params.y, imi); shading flat
        title('interpd version')
    end
    [xd, elev, sst]=linfrmimg(input_params.x, input_params.y, imi, range_config);
    
    % now save the values you want
    dataStruct(jj).proc_im = imi;
    dataStruct(jj).range_config = range_config;
    dataStruct(jj).headangle = hang;
    dataStruct(jj).xdist=xd;
    dataStruct(jj).depth=elev;
    dataStruct(jj).sstrn=sst;
    
end
