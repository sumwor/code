clear
rootdir = 'C:\Users\kwanlab\Data\';
cd(rootdir)
DAQs = DAQctrlLsr([],'init');

mmPerVolt  = 10;
posit      = [-15 15]; %mm
altFreq    = 200; % Hz alternating between positions

lsr.dutyCycle = .5;
lsr.freq = 40;
lsr.Vlsr = .5;

posx = [ones(LaserRigParameters.rate/altFreq,1)/mmPerVolt*posit(1); ones(LaserRigParameters.rate/altFreq,1)/mmPerVolt*posit(2)];
posx = repmat(posx,[LaserRigParameters.rate/(LaserRigParameters.rate/altFreq*2) 1]);
posy = zeros(LaserRigParameters.rate,1);

%posx(end-1000:end) = 0; % unique identifier for delay tests

% data
sz = (1000/lsr.freq)*(LaserRigParameters.rate/1000);
datafreq = repmat([zeros(ceil(sz*(1-lsr.dutyCycle)),1); ...
    5.*ones(floor(sz*lsr.dutyCycle),1)],lsr.freq,1);

% data mat for DAQ w/ 4 cols: [GalvoX GalvoY Power Freq] or whatever order
% is in params. 
data = zeros(LaserRigParameters.rate,4);
data(:,LaserRigParameters.galvoCh(1)) = posx;%ones(LaserRigParameters.rate,1)*lsr.Vx;
data(:,LaserRigParameters.galvoCh(2)) = posx;%ones(LaserRigParameters.rate,1)*lsr.Vy;
data(:,LaserRigParameters.lsrPowerCh) = ones(LaserRigParameters.rate,1)*lsr.Vlsr;
data(:,LaserRigParameters.lsrFreqCh)  = datafreq;

DAQs.ai.IsContinuous = false;
DAQs.ai.DurationInSeconds = 2;

tic; [DAQs,~,lsr] = DAQctrlLsr(DAQs,'aoPrepareCont',data); tPrep = toc*1000
tic; DAQs = DAQctrlLsr(DAQs,'aoStartCont'); tStart = toc*1000
tic; dataai = DAQs.ai.startForeground(); tai = toc*1000
tic; DAQs = DAQctrlLsr(DAQs,'aoStopCont',[],lsr); tstop = toc*1000
DAQctrlLsr(DAQs,'end');

commandV = dataai(:,1);
PD = dataai(:,2);
GalvoXpos = dataai(:,3);
GalvoYpos = dataai(:,4);

dataRate = LaserRigParameters.rate;

clear data dataai DAQs

% temp = datetime;
% calDate = datestr(temp,'yymmdd');
% fn = sprintf('galvoTimingTest_%s_posRange%dmm_galvoFreq%d',calDate,sum(abs(posit)),altFreq);
% save(fn)
% 
figure; 
subplot(1,2,1); hold on
plot(commandV(dataRate-2500:dataRate))
plot(posx(dataRate-2500:dataRate),'r-')
xlim([1000 1500])

subplot(1,2,2); 

figure;
subplot(1,2,1); hold on
plot(.8*commandV(dataRate-2500:dataRate),'k-')
plot(GalvoXpos(dataRate-2500:dataRate),'r-')
plot(GalvoYpos(dataRate-2500:dataRate),'b-')
xlim([1116 1135])

subplot(1,2,2); hold on
plot(.8*commandV(dataRate-2500:dataRate),'k-')
plot(GalvoXpos(dataRate-2500:dataRate),'r-')
plot(GalvoYpos(dataRate-2500:dataRate),'b-')
xlim([1241 1260])

figure; plot([1 20 30],[110 240 280],'k.-','markersize',25); %set(gca,'xscale','log'); 
ylabel('delay (\mus)','fontsize',12)
xlabel('displacement (mm)','fontsize',12)
box off
set(gca,'xtick',[1 20 30],'fontsize',10)