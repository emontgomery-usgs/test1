function nc = definefanprocNc(outFileRoot, settings, ncdims);
%  called by do_fan_rots.m to create the netcdf files
%
% usage: nc = defineSonarNcFile(outFileRoot, settings, ncdims, whichFlag);
%  outFileRoot is the second argument to procsonarMM, ie. 'MVCOfantst'
%  settings containg parameters gleaned from th metadata.txt file, again an
%    argument to procsonarMM
%  ncdims defines the dimensions of the variables in the .nc files
%  whichFlag sayw whether to create the raw ('r') or processed format
%
% emontgomery from mmartini

nc = netcdf([outFileRoot,'.cdf'],'clobber');
%% Global attributes:
nc.dxy = ncfloat(0.05); 
nc.sweep = ncshort(1);
nc.fanadcp_off= ncshort(0);

% write metadata
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


% do different things with creating the file depending on whether you're
% making a raw or processed file
  % set dimensions
  if strmatch('fan',lower(settings.SonartoAnimate))  
    nc('time') = 0; %unlimited dimension
    nc('sweep')= ncdims.sweep;
    nc('x') = ncdims.x;
    nc('y') = ncdims.y;
  end

% write additional metadata
 
  % add coordinate variables in all data 
    nc{'time'} = nclong('time');
    nc{'time'}.units = ncchar('EPIC Julian Day');
    nc{'time'}.type = ncchar('EVEN');
    nc{'time'}.epic_code = ncint(624);

    nc{'time2'} = nclong('time') ;
    nc{'time2'}.units = ncchar('msec since 0:00 GMT');
    nc{'time2'}.type = ncchar('EVEN');
    nc{'time2'}.epic_code = ncint(624);

      if strmatch('fan',lower(settings.SonartoAnimate)) 
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
          
       % sweep is the index for possible multiple sweeps in one burst       
          nc{'sweep'} = ncshort('sweep') ;
          nc{'sweep'}.long_name = ncchar('integer sweep number');
          nc{'sweep'}.valid_range = ncfloat([1 12]);
          nc{'sweep'}.units = ncchar('counts');
          nc{'sweep'}.type = ncchar('EVEN');
         % a scale factor is applied to the variable 'sonar_image' in order to store
          % the image data as an integer rather than a float.
           nc{'sonar_image'} = ncshort('time','sweep','x','y');
           nc{'sonar_image'}.long_name = ncchar('Imagenex Sonar Image');
           nc{'sonar_image'}.units = ncchar('?');
           nc{'sonar_image'}.valid_range = ncshort([0 30000]);
           nc{'sonar_image'}.FillValue_ = -1;
           nc{'sonar_image'}.scale_factor = ncfloat(10000);
          % add this after the attributes are transferred.
          %  nc{'sonar_image'}.sensor_type = nc.INST_TYPE(:);
          %  old settings to use if variable is kept as a float
          % nc{'sonar_image'}.valid_range = ncfloat([0 log10(256)*1000]);
        % adding the notes below makes a ncdim error occur, so
           % commenting out for now
           % nc('sonar_image').note1 = ncchar('made polar and rotated so +y is North');
           % nc('sonar_image').note2 = ncchar('the interpolated onto an x-y grid');
           nc.VAR_DESC=ncchar('x:y:sweep:sonar_image');
     else
          disp('does not match existing categories - not processing')
          exit
      end  
