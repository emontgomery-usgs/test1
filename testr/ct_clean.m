function [T,Cnew,Snew,STHnew,time_julian]=ct_clean(filename);
% ct_clean.m  A function to clean spikes and offsets in temperature,
%             conductivity, salinity, and sigma-theta data from
%             conductivity-temperature (CT) instruments.
%
%    usage: ct_clean(filename);
%
%         where: filename is the name of the CT netCDF data file in
%                         single quotes
%                Tnew is the cleaned temperature data
%                Cnew is the cleaned conductivity data
%                Snew is the cleaned salinity data
%                STHnew is the cleaned sigma-theta data


%%% START USGS BOILERPLATE -------------%%
% This program was written to modify a netCDF file in some way.
% It is self documenting- there is currently no other publication 
% describing the use of this software.
%
% Program written in Matlab v7.4,0.287 (R2007a)
% Program ran on PC with Windows XP Professional OS.
% The software requires the netcdf toolbox and mexnc, both available
% from SourceForge (http://www.sourceforge.net)
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%%% END USGS BOILERPLATE --------------

 
% csullivan, 09/16/04

%For each CT netCDF file I have identified the indices of spikes and
%offsets in the data.  With both spikes and offsets I first adjust the
%conductivity data, then I re-calcualate salinity and density.  Spikes
%are lineraly interpolated over, wheras offsets are adjusted by linearly
%adding a correction factor to the conductivity data.  The adjusted 
%data is then written to a new netCDF file with '-b.nc' in the file
%name.

%load the data and plot it
dataDirectory='c:\Charlene\SOUTH_CAROLINA\DATAFILES';
theFile=netcdf(fullfile(dataDirectory,filename), 'nowrite');
jday=theFile{'time'}(:);
msec=theFile{'time2'}(:);
time_julian=jday+(msec/3600000/24);
time_datenum=julian2datenum(time_julian);
T=theFile{'T_28'}(:);
C=theFile{'C_51'}(:);
S=theFile{'S_40'}(:);
STH=theFile{'STH_71'}(:);
depth=theFile{'depth'}(:);
lat=theFile{'lat'}(:);
lon=theFile{'lon'}(:);
theFile=close(theFile);

figure
orient landscape
subplot(4,1,1,'align'), plot(T)
hold on
title('Temperature')
ylabel('^oC')
ylim([5 25])
grid on
subplot(4,1,2,'align'), plot(C)
hold on
title('Conductivity')
ylabel('S/m')
ylim([3 5])
grid on
subplot(4,1,3,'align'), plot(S)
hold on
title('Salinity')
ylabel('psu')
ylim([33 36])
grid on
subplot(4,1,4,'align'), plot(STH)
hold on
title('Sigma-Theta')
ylabel('kg/m^3')
ylim([22 28])
xlabel('Index')
grid on

%adjust conductivity
if strcmp(filename,'7222sc-a.nc');
     bad_indices={[6455:6467]';
                  [7614:7825]';
                  [7826:7844]';
                  [7845:7930]';
                  [8673:8986]';
                  [8992];
                  [10373:12335]';
                  [12336:12355]';
                  [12381:12384]';
                  [24332:24351]'};
     corr_fac={nan;.05;nan;.06;.05;nan;.1;nan;nan;nan};
elseif strcmp(filename,'7251mc-a.nc');
     bad_indices={[16385:16388]'};
     corr_fac={nan};
elseif strcmp(filename,'7242sc-a.nc');
     bad_indices={[13199:13450]'...
                  [23214]'...
                  [23499:23501]'};
     corr_fac={nan;nan;nan};
elseif strcmp(filename,'7442sc-a.nc');
     bad_indices={[114:156]'};
     corr_fac={0.04};
end

if exist('bad_indices','var')==1
     for i=1:length(bad_indices)
          C(bad_indices{i}(:))=C(bad_indices{i}(:))+corr_fac{i};
     end

     %linearly interpolate over nan's (spikes)
     Cnew=dfilljd(time_julian,C);

     %call ct2sal.exe to calculate salinity.
     junk=[Cnew.*10 T]; %units of conductivity are milliS/cm
     save sal.inn junk -ascii -tabs
     !c:\Charlene\SOUTH_CAROLINA\MFILES\OTHERS\ct2sal
     Snew=load('sal.out');

     %call density.m to calculate density (kg/m^3)
     STHnew=density(Snew,T,0);
     %plot the results
     subplot(4,1,2,'align'), plot(Cnew,'r')
     subplot(4,1,3,'align'), plot(Snew,'r')
     subplot(4,1,4,'align'), plot(STHnew,'r')
else
     Cnew=C;
     Snew=S;
     STHnew=STH;
end

suptitle(filename)

%get data ready to write to a new netCDF file
C_51=Cnew;
S_40=Snew;
STH_71=STHnew;
T_28=T;

save data4nc.mat T_28 C_51 S_40 STH_71 time_julian depth lat lon

vars={'T_28','C_51','S_40','STH_71','depth','lat','lon'};

%call mat2netcdf.m to write adjusted data to a new netCDF file
ct2netcdf(vars,'time_julian','data4nc.mat',[filename(1:7),'b.nc']);


                  


