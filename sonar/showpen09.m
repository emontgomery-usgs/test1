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

    % imi is what wants to become the output sonar_image
    % find the elevations using the max return in each bin
    zz=max(imi);
    for ik=1:length(zz)
        if ~isnan(zz(ik))
            nn=find(imi(:,ik)==zz(ik),1,'first');
        else
            nn=1;
        end
        ly(ik)=nn;
    end

    % use the contiguous middle of the plot to select the x range
    % figure(2); plot(diff(intrp_dims.y(ly)))
    jmps=find(abs(diff(intrp_dims.y(ly))) >.2);
    if(jmps(end-1)-jmps(2) < range_config.*100)
        strt_idx=1; end_idx=jmps(end);
    else
        strt_idx=jmps(2)+1;
        end_idx=jmps(end-1)-1;
    end
    x_gd=intrp_dims.x(strt_idx:end_idx);
    y_gd=-intrp_dims.y(ly(strt_idx:end_idx));
    z_gd=zz(ly(strt_idx:end_idx));

    %now remove everything greater than 3 std_devs of the mean
    mn_el=mean(y_gd);
    std_el=std(y_gd);
    gdvals=[mn_el-(3*std_el) mn_el+(3*std_el)];
    ng_idx=find(y_gd < gdvals(1) | y_gd > gdvals(2));
    y_gd(ng_idx)=NaN;
    figure
    plot(x_gd,y_gd,'.')
    tt=ncr{'time'}(:)+(ncr{'time2'}(:)./86400000);
    title([datestr(gregorian(tt(idnum))) '; range setting= ' num2str(range_config)])
    xlabel('horizontal distance along seafloor(m)')
    ylabel('depth(m)')
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