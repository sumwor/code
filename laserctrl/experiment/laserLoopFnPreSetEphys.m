function lsrL = laserLoopFnPreSetEphys(lsrL)

global lsr

% % skip iteration if last one was too long, except for the GUI check one
% if lsrL.lastdt >= lsrL.loopTth && lsrL.lsrCounter ~= 2
%     % update iteration info
%     tic;
%     if lsrL.lsrCounter==lsr.dataout(1).vecLength; lsrL.lsrCounter = 0; end
%     lsrL.ii = lsrL.ii+1;
%     lsrL.lsrCounter = lsrL.lsrCounter+1;
%     lsrL.lastdt = toc;
%     lsrL.dt(lsrL.ii) = lsrL.lastdt;
%     return
% end

tic;


iLoc = lsrL.trialIDMat(lsrL.cycleCounter,1);
iDur = lsrL.trialIDMat(lsrL.cycleCounter,2);
iPow = lsrL.trialIDMat(lsrL.cycleCounter,4);
dur  = lsrL.trialMat(lsrL.cycleCounter,2);
pow  = lsrL.trialMat(lsrL.cycleCounter,4);

% print to screen
if lsrL.lsrCounter == 1
  fprintf('\ttrial #%03d / %03d (loc: %d, dur:%1.1f, power: %1.1f)\n',...
    lsrL.cycleCounter,lsrL.ncycles,iLoc,dur,pow);
end

% output data
lsrL.data(LaserRigParameters.galvoCh(1))  = lsr.dataout_preset{iLoc,iDur,iPow}.galvoXvec(lsrL.lsrCounter);
lsrL.data(LaserRigParameters.galvoCh(2))  = lsr.dataout_preset{iLoc,iDur,iPow}.galvoYvec(lsrL.lsrCounter);
lsrL.data(LaserRigParameters.lsrWaveCh)   = lsr.dataout_preset{iLoc,iDur,iPow}.lsrVec(lsrL.lsrCounter);

if lsrL.stop
  lsrL.data = [0 0 0 0];
else
  lsrL.data(LaserRigParameters.lsrSwitchCh) = 5;
end

% send AO data with MEX function
nidaqAOPulse('aoPulse',lsrL.data);

% update iteration info
if lsrL.lsrCounter == lsr.dataout_preset{iLoc,iDur,iPow}.vecLength;
  lsrL.lsrCounter   = 0;
  lsrL.cycleCounter = lsrL.cycleCounter+1;
  
end
lsrL.lsrCounter = lsrL.lsrCounter+1;

% wait till iteration time is up for constant data rate
t1 = toc;
if t1 < lsrL.loopT;
  t2=delay(lsrL.loopT-t1);
  lsrL.lastdt = t1+t2;
else
  lsrL.lastdt = t1;
end

if lsrL.cycleCounter > lsrL.ncycles
  lsrL.stop = 1;
end
end