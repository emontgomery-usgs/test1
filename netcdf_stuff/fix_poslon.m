function [lon_info, posidx]=fix_poslon(url_dir)
% FIX_POSLON  reads metadata and returns list of files wi. positive longitude
%
% usage :
%   [lon_info, posidx]=fix_poslon(url_dir);
% outputs :
%   lon_info is a structure containing the name, sign of longitude, and
%      whether the lon attribute has the correct sign
%   posidx is the list of indices where lon is positive (and needs changing)
% input arguments:
%   url_dir is URL to read from (as below)
%     url_dir='http://stellwagen.er.usgs.gov/cgi-bin/nph-dods/DATAFILES/PV_SHELF/';
%     use url_dir='.'; to treat files in a local directory

kk=0;k=0;j=0;jk=0;  % initialize bad file counters
posidx=[];

if nargin == 0
    help mfilename; return
end

% selects *nc or *cdf if looking in cwd
if strcmp(url_dir,'.')
    fil=dir(url_dir);
    for ik=1:length(fil)-2
        isnc=~isempty(strfind(fil(ik+2).name, '.nc'));
        iscdf=~isempty(strfind(fil(ik+2).name, '.cdf'));
        if isnc || iscdf
            files{ik}=fil(ik+2).name;
        end
    end
else  % if not, all files have to be .nc or .cdf
    [files]=get_files_from_url(url_dir);
end

% Loop through each NetCDF file, getting metadata, and collecting
% urls where the metadata fails or lon is empty.

% loop through everything
% for i=1:10        % use this to do a subset of the data when testing.
if isempty(files)
    disp ('no files were found, try another location')
    lon_info=[]; return
else
    for i=1:length(files);
        % for i=1:10
        file=char(files{i});
        url=[url_dir '/' file ];
        %
        % open the file and get what you need
        nc=netcdf(url, 'write');
        lon=nc{'lon'}(1);
        lonmeta=nc.longitude(:);

        % see what lon is and fill the structure appropriately
        if ~isempty(lon),
            if lon >= 0
                % see if if the metadata is correct and use that
                if lonmeta == -lon
                    j=j+1;
                    lon_info(j)=struct('name',url,'sign','pos','metaOK',1);
                    jk=jk+1; posidx(jk)=j;
                    nc{'lon'}(1)=-lon;
                    hist=nc.history;
                    nh=['corrected sign of lon using ', mfilename, '.m: ' hist];
                    nc.history = ncchar(nh);
                    nc.CREATION_DATE=ncchar(datestr(now));
                else
                    j=j+1;
                    lon_info(j)=struct('name',url,'sign','pos','metaOK',0);
                    jk=jk+1; posidx(jk)=j;
                    nc{'lon'}(1)=-lon;
                    nc.longitude(:)=lon;
                    hist=nc.history;
                    nh=['corrected sign of lon using ', mfilename, '.m: '  hist];
                    nc.history = ncchar(nh);
                    nc.CREATION_DATE=ncchar(datestr(now));
                end
            else  % lon varible is negative but attribute is pos
                if lonmeta == lon
                    j=j+1;
                    lon_info(j)=struct('name',url,'sign','neg','metaOK',1);
                else
                    j=j+1;
                    lon_info(j)=struct('name',url,'sign','neg','metaOK',0);
                    nc.longitude(:)=lon;
                end
            end
            close (nc)
        else
            k=k+1;url_nolon{k}=url;
        end
    end
end


