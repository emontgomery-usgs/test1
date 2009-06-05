function nc = definepenprocnc(fn, settings, ncds)
% definepenprocnc - Set up netCDF file for processed pen sonar data
% nc = definepenprocnc(outFileRoot, settings, ncds);
%
% fn - name of the netcdf file to be created
% settings - contains parameters
% ncds - dimensions of the variables in the output .cdf files
%             .x, .y, .intpl and .sweep are required

% emontgomery from mmartini
% csherwood@usgs.gov 28 May 2008

nc = netcdf(fn,'clobber');
% Global attributes:
if isfield(settings,'dxy')
   nc.dxy = settings.dxy;
end
nc.sweep = ncshort(1);
% write metadata attributes based on the settings passed
metaFields = fieldnames(settings);
for i = 1:length(metaFields)
   theField = metaFields{i};
   theFieldDef = getfield(settings,theField);
   nRows = size(theFieldDef,1);
   nCols = size(theFieldDef,2);
   temp = [];
   if ischar(theFieldDef)
      if nRows>1
         for ii = 1:nRows
            temp = [temp,' ',theFieldDef(ii,1:nCols)];
         end
         theFieldDef = temp;
      end
      eval(['nc.',theField,' = ncchar(theFieldDef);'])
   else
      eval(['nc.',theField,'= ncfloat(theFieldDef);'])
   end
end
% set dimensions
nc('time') = 0; %unlimited dimension
nc('sweep')= ncds.sweep;
nc('x') = ncds.x;
nc('y') = ncds.y;
nc{'xdist'} = ncds.xdist;
% add coordinate variables in all data
nc{'time'} = nclong('time');
nc{'time'}.units = ncchar('EPIC Julian Day');
nc{'time'}.type = ncchar('EVEN');
nc{'time'}.epic_code = ncint(624);
nc{'time2'} = nclong('time') ;
nc{'time2'}.units = ncchar('msec since 0:00 GMT');
nc{'time2'}.type = ncchar('EVEN');
nc{'time2'}.epic_code = ncint(624);
% x and y are the grid values onto which the interploation is made
nc{'x'} = ncfloat('x') ;
nc{'x'}.long_name = ncchar('interpolated horizontal distance from sonar');
nc{'x'}.valid_range = ncfloat([-5 5]);
nc{'x'}.units = ncchar('m');
nc{'x'}.type = ncchar('EVEN');
nc{'y'} = ncfloat('y') ;
nc{'y'}.long_name = ncchar('interpolated horizontal distance from sonar');
nc{'y'}.valid_range = ncfloat([-5 5]);
nc{'y'}.units = ncchar('m');
nc{'y'}.type = ncchar('EVEN');
nc{'xdist'} = ncfloat('time','sweep','xdist');
nc{'xdist'}.long_name = ncchar('profile horizontal distance');
nc{'xdist'}.units = ncchar('m');
nc{'xdist'}.valid_range = ncfloat([0 5]);
nc{'xdist'}.FillValue_ = ncfloat(1e35);
nc{'xdist'}.scale_factor = ncfloat(1);
% sweep is the index for possible multiple sweeps in one burst
nc{'sweep'} = ncshort('sweep');
nc{'sweep'}.long_name = ncchar('integer sweep number');
nc{'sweep'}.valid_range = ncfloat([1 12]);
nc{'sweep'}.units = ncchar('counts');
nc{'sweep'}.type = ncchar('EVEN');
% a scale factor is applied to the variable 'sonar_image' in order to store
% the image data as an integer rather than a float.
nc{'sonar_image'} = ncshort('time','sweep','y','x');
nc{'sonar_image'}.long_name = ncchar('Imagenex Pencil Sonar Image');
nc{'sonar_image'}.units = ncchar('?');
nc{'sonar_image'}.valid_range = ncshort([0 30000]);
nc{'sonar_image'}.FillValue_ = ncshort(-32767);
nc{'sonar_image'}.scale_factor = ncfloat(10000);
% a scale factor is applied to the variable 'sonar_image' in order to store
% the image data as an integer rather than a float.
nc{'brange'} = ncfloat('time','sweep','y');
nc{'brange'}.long_name = ncchar('range to bottom from sonar_image');
nc{'brange'}.units = ncchar('m');
nc{'brange'}.valid_range = ncfloat([0 5]);
nc{'brange'}.FillValue_ = ncfloat(1e35);
nc{'brange'}.scale_factor = ncfloat(1);
%
nc{'sstrength'} = ncshort('time','sweep','y');
nc{'sstrength'}.long_name = ncchar('strength of reflection from sonar_image');
nc{'sstrength'}.units = ncchar('?');
nc{'sstrength'}.valid_range = ncshort([0 30000]);
nc{'sstrength'}.FillValue_ = ncshort(-32767);
nc{'sstrength'}.scale_factor = ncfloat(10000);
nc.VAR_DESC=ncchar('x:y:xdist:sweep:sonar_image:brange:sstrength');
