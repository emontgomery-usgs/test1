function [Pdiff] = plot_tilt(rpcFile,pitFile,rolFile,rpc2File,pit2File,rol2File,rpc3File,pit3File,rol3File)

%[Pdiff] = plot_tilt(rpcFile,pitFile,rolFile,...
% ...rpc2File,pit2File,rol2File,rpc3File,pit3File,rol3File)
%rpcFile 


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

 [path,fname,ext] = fileparts(rpcFile);

eval(['load ' rpcFile ';'])
eval(['rpcData = ' fname ';'])

%get pitch and roll from first rpc file
%the structure of the rpc file looks like
%pitch	roll
% +	-	+	-
mpit(1:16) = rpcData(:,1);
mpit(17:32) = rpcData(:,2)*-1;
mrol(1:16) = rpcData(:,3);
mrol(17:32) = rpcData(:,4)*-1;

%pitFile 
G = netcdf(pitFile,'nowrite');
whpit = G{'pitch'}(:);
WHsn = G.ADCP_serial_number(:);
for ii = 1:32;
   whpitm(ii) = mean(whpit(:,ii));
end
close(G)

%some stats
Pdiff = whpitm-mpit;
idgood = find(~isnan(Pdiff));
Pdiff = Pdiff(idgood);
whpitm = whpitm(idgood);
pmbias = mean(Pdiff);
prms = sqrt((sum(Pdiff.^2))/length(Pdiff));


%rolFile
F = netcdf(rolFile,'nowrite');
whrol = F{'roll'}(:);
for ii = 1:32;
   whrolm(ii) = mean(whrol(:,ii));
end
close(F)

%some stats
Rdiff = whrolm-mrol;
idgood = find(~isnan(Rdiff));
Rdiff = Rdiff(idgood);
whrolm = whrolm(idgood);

rmbias = mean(Rdiff);
rrms = sqrt((sum(Rdiff.^2))/length(Rdiff));


	if nargin > 3
	%2 set of files
	eval(['load ' rpc2File ';'])
	eval(['rpc2Data = ' fname ';'])
	m2pit(1:16) = rpc2Data(:,1);
	m2pit(17:32) = rpc2Data(:,2)*-1;
	m2rol(1:16) = rpc2Data(:,3);
	m2rol(17:32) = rpc2Data(:,4)*-1;

	G = netcdf(pit2File,'nowrite');
	wh2pit = G{'pitch'}(:);
	WH2sn = G.ADCP_serial_number(:);
	for ii = 1:32;
   	wh2pitm(ii) = mean(wh2pit(:,ii));
	end
	close(G)
   
	%some stats
	P2diff = wh2pitm-m2pit;
	idgood = find(~isnan(P2diff));
	P2diff = P2diff(idgood);
	wh2pitm = wh2pitm(idgood);

	pm2bias = mean(P2diff);
	p2rms = sqrt((sum(P2diff.^2))/length(P2diff));
   
   %rolFile = 'wh136rol.nc';
	H = netcdf(rol2File,'nowrite');
	wh2rol = F{'roll'}(:);
	for ii = 1:32;
   	wh2rolm(ii) = mean(wh2rol(:,ii));
	end
	close(H)
	%some stats
	R2diff = wh2rolm-m2rol;
	idgood = find(~isnan(R2diff));
	R2diff = R2diff(idgood);
	wh2rolm = wh2rolm(idgood);

	rm2bias = mean(R2diff);
	r2rms = sqrt((sum(R2diff.^2))/length(R2diff));

	end

%3rd set of files
if nargin > 6
eval(['load ' rpc3File ';'])
eval(['rpc3Data = ' fname ';'])
m3pit(1:16) = rpc3Data(:,1);
m3pit(17:32) = rpc3Data(:,2)*-1;
m3rol(1:16) = rpc3Data(:,3);
m3rol(17:32) = rpc3Data(:,4)*-1;

K = netcdf(pit3File,'nowrite');
wh3pit = G{'pitch'}(:);
WH3sn = G.ADCP_serial_number(:);
for ii = 1:32;
   wh3pitm(ii) = mean(wh3pit(:,ii));
end
close(K)
%some stats
P3diff = wh3pitm-m3pit;
idgood = find(~isnan(P3diff));
P3diff = P3diff(idgood);
wh3pitm = wh3pitm(idgood);
pm3bias = mean(P3diff);
p3rms = sqrt((sum(P3diff.^2))/length(P3diff));

%rol3File 
M = netcdf(rol3File,'nowrite');
wh3rol = F{'roll'}(:);
for ii = 1:32;
   wh3rolm(ii) = mean(wh3rol(:,ii));
end
close(M)
%some stats
R3diff = wh3rolm-m3rol;
idgood = find(~isnan(R3diff));
R3diff = R3diff(idgood);
wh3rolm = wh3rolm(idgood);
rm3bias = mean(R3diff);
r3rms = sqrt((sum(R3diff.^2))/length(R3diff));
end


figure
subplot(211)
plot(mpit,whpitm,'b*')
hold on
da = axis;
ttext = sprintf('Bias_1 = %1.2f',pmbias);
text(10,4,ttext)
ttext2 = sprintf('RMS error_1 = %1.2f',prms);
text(10,0,ttext2)
if nargin > 3
plot(m2pit,wh2pit,'g*')
da = axis;
ttext = sprintf('Bias_2 = %1.2f',pm2bias);
text(10,-4,ttext)
ttext2 = sprintf('RMS error_2 = %1.2f',p2rms);
text(10,-8,ttext2)
end
if nargin > 6
plot(m3pit,wh3pit,'y*')
ttext = sprintf('Bias_3 = %1.2f',pm3bias);
text(10,-12,ttext)
ttext2 = sprintf('RMS error_3 = %1.2f',p3rms);
text(10,-16,ttext2)
end

plot([-20:1:20],[-20:1:20],'r')
ylabel('ADCP pitch ^o','Fontsize',[12])
xlabel('Measured pitch ^o','Fontsize',[12])
if nargin < 4
   prompt={'Enter information for Data 1'};
	header='Text for the legend'
   lineNo=1;
   DefAns={'Globec'};
   dlgresult=inputdlg(prompt,header,lineNo,DefAns);
   legend(dlgresult{1});   
elseif nargin > 3 & nargin < 7
	prompt={'Enter information for Data 1','Enter information for Data 2'};
	header='Text for the legend'
   lineNo=1;
   DefAns={'Globec','NYB'};
   dlgresult=inputdlg(prompt,header,lineNo,DefAns);
   legend(dlgresult{1},dlgresult{2});
elseif nargin > 6
	prompt={'Enter information for Data 1','Enter information for Data 2','Enter information at Data 3'};
	header='Text for the legend'
   lineNo=1;
   DefAns={'Globec','NYB','Boston'};
   dlgresult=inputdlg(prompt,header,lineNo,DefAns);
   legend(dlgresult{1},dlgresult{2},dlgresult{3});
end   
titext = ['ADCP ' num2str(WHsn)]
title(titext,'Fontsize',[10])


%psuedo calibration curve
subplot(212)
plot(whpitm,Pdiff,'b*')
if nargin > 3
hold on
plot(wh2pitm,P2diff,'g*')
end
if nargin > 6
plot(wh3pitm,P3diff,'y*')
%plot([-20:1:20],[-20:1:20],'r')
end
xlabel('ADCP pitch ^o','Fontsize',[12])
ylabel('bias ^o','Fontsize',[12])
%legend('1-March 1999','2-October 1999')
titext = ['ADCP ' num2str(WHsn)]
%title(titext)

figure
subplot(211)
plot(mrol,whrolm,'b*')
hold on
da = axis;
ttext = sprintf('Bias = %1.2f',rmbias);
text(10,4,ttext)
ttext2 = sprintf('RMS error = %1.2f',rrms);
text(10,0,ttext2)

if nargin > 3
plot(m2rol,wh2rol,'g*')
da = axis;
ttext = sprintf('Bias_2 = %1.2f',rm2bias);
text(10,-4,ttext)
ttext2 = sprintf('RMS error_2 = %1.2f',r2rms);
text(10,-8,ttext2)
end
if nargin > 6
plot(m3rol,wh3rol,'y*')
ttext = sprintf('Bias_3 = %1.2f',rm3bias);
text(10,-12,ttext)
ttext2 = sprintf('RMS error_3 = %1.2f',r3rms);
text(10,-16,ttext2)
end
plot([-20:1:20],[-20:1:20],'r')
ylabel('ADCP roll ^o','Fontsize',[12])
xlabel('Measured roll ^o','Fontsize',[12])

if nargin < 4
   legend(dlgresult{1});   
elseif nargin > 3 & nargin < 7
   legend(dlgresult{1},dlgresult{2});
elseif nargin > 6
   legend(dlgresult{1},dlgresult{2},dlgresult{3});
end   
titext = ['ADCP ' num2str(WHsn)]
title(titext,'Fontsize',[10])



%psuedo calibration curve
subplot(212)
plot(whrolm,Rdiff,'b*')
if nargin > 3
hold on
plot(wh2rolm,R2diff,'g*')
end
if nargin > 6
plot(wh3rolm,R3diff,'y*')
end
xlabel('ADCP roll ^o','Fontsize',[12])
ylabel('bias ^o','Fontsize',[12])
%legend('1-March 1999','2-October 1999')
titext = ['ADCP ' num2str(WHsn)]
%title(titext)



