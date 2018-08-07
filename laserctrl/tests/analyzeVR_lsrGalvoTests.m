clear
day = '20160202';
mouse = 'k';
cd /Users/lucas/Documents/Princeton/data/laserGalvo
fnbehav = dir(['*VRLaser*' mouse '*' day '*']);
fnbehav = fnbehav.name;
fnlsr = dir([mouse '*' day '*']);
fnlsr = fnlsr.name;

load(fnbehav,'log')
load(fnlsr,'lsrlog')


dtVR = [];

for ii = 1:length(log.block(end).trial)
    % virmen loop timing
    dtVR = [dtVR; 1000*diff(log.block(end).trial(ii).time(double(log.block(end).trial(ii).iCueEntry):log.block(end).trial(ii).iterations))];
    
    % lag between command and laser actually on in virmen
    if log.block(end).trial(ii).laserON
        lsrLag(ii) = find(log.block(end).trial(ii).lsrTrigIn>.5,1,'first')-double(log.block(end).trial(ii).iLaserOn);
    end
    
    % make sure that sent and received galvo locations are always the same
    sentPos(ii)     = max(log.block(end).trial(ii).galvoPosIdx);
    receivedPos(ii) = max(lsrlog.block(end).trial(ii).locationIdx);
end

% laser loop timing
dtLsr = [];
for ii = 1:length(lsrlog.block(end).trial)
    dtLsr = [dtLsr; lsrlog.block(end).trial(ii).dt*1000];
end


% verify that sent and received expt params are always the same
lsrlog.block(end).info.exptParams % print sent params
log.block(end).laserParams %  print received params

% verify probabilities
lsrONp_actual   = sum([log.block(end).trial(:).laserON])./length(log.block(end).trial);
lsrONp_intended = log.block(end).laserParams.P_on;
posAgree        = 100*sum(sentPos==receivedPos)./length(log.block(end).trial);

fprintf('Laser P_on\n\tactual: %1.2f\n\tintended: %1.2f\n',lsrONp_actual,lsrONp_intended)
fprintf('Galvo pos. agreement: %1.2f%%\n',posAgree)

% plot stuff
figure;
subplot(1,3,1); histogram(dtVR,0:.25:15,'norm','probability'); title('virmen dt (ms)')
subplot(1,3,2); histogram(dtLsr,0:.25:5,'norm','probability'); title('lsr dt (ms)')
subplot(1,3,3); histogram(lsrLag,.5:4.5,'norm','probability'); title('lsr lag (# virmen iters)')