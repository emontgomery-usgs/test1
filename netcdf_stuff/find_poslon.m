function [lon_info, posidx]=find_poslon(url_dir)
% FIND_POSLON  reads metadata and returns list of files wi. positive longitude
%
% usage :
%   [lon_info, posidx]=find_poslon(url_dir);
% outputs :
%   lon_info is a structure containing the name, sign of longitude, and
%      whether the lon attribute has the correct sign
%   posidx is the list of indices where lon is positive (and needs changing)
% input arguments:
%   url_dir is the URL to read from (as below)
%   url_dir='http://stellwagen.er.usgs.gov/cgi-bin/nph-dods/DATAFILES/PV_SHELF/';
%   url_dir ='.' if you want to work locally

[files]=get_files_from_url(url_dir);
kk=0;k=0;j=0;jk=0; % initialize bad file counters
% Loop through each NetCDF file, getting metadata, and collecting
% urls where the metadata fails or lon is empty.

% loop through everything
% for i=1:10        % use this to do a subset of the data when testing.
for i=1:length(files);
    % for i=1:10
    file=char(files{i});
    url=[url_dir '/' file ];
    %
    % open the file and get what you need
    nc=netcdf(url);
    lon=nc{'lon'}(1);
    lonmeta=nc.longitude(:);
    close (nc)

    % see what the deal is and fill the structure appropriately
    if ~isempty(lon),
        if lon >= 0
            % see if if the metadata is correct and use that
            if lonmeta == -lon
                j=j+1;
                lon_info(j)=struct('name',url,'sign','pos','metaOK',1);
                jk=jk+1; posidx(jk)=j;
            else
                j=j+1;
                lon_info(j)=struct('name',url,'sign','pos','metaOK',0);
                jk=jk+1; posidx(jk)=j;
            end
        else  % lon varible is negative but attribute is pos
            if lonmeta == lon
                j=j+1;
                lon_info(j)=struct('name',url,'sign','neg','metaOK',1);
            else
                j=j+1;
                lon_info(j)=struct('name',url,'sign','neg','metaOK',0);
            end
        end
    else
        k=k+1;url_nolon{k}=url;
    end

end


