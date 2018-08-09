function lsrL = laserLoopFn(lsrL)

% skip iteration if last one was too long
if lsrL.lastdt >= lsrL.loopTth
    % update iteration info
    tic;
    if lsrL.lsrCounter==lsrL.vecLength; lsrL.lsrCounter = 0; end
    lsrL.ii = lsrL.ii+1;
    lsrL.lsrCounter = lsrL.lsrCounter+1;
    lsrL.lastdt = toc;
    lsrL.dt(lsrL.ii) = lsrL.lastdt;
    return
end
tic;

% receive laser and galvo info from ViRMEn computer
lsrL.DIdata = nidaqDIread('readDI');
lsrL.galvoX = lsrL.galvoXinit;
lsrL.galvoY = lsrL.galvoYinit;
%lsrL.trigIn = lsrL.DIdata(2); %this is going to change
%may be like these, not sure the conditioning is right or not for now....
if lsrL.DIdata=='111110'
    lsrL.trigIn=0;
elseif lsrL.DIdata=='111111'
    lsrL.trigIn=1;
end
      
lsrL.lsrAna = lsrL.lsrVec(lsrL.lsrCounter)*lsrL.lsr.Vlsr; % from "buffer"

% output data
lsrL.data(LaserRigParameters.galvoCh(1))  = lsrL.galvoX;
lsrL.data(LaserRigParameters.galvoCh(2))  = lsrL.galvoY;
lsrL.data(LaserRigParameters.lsrSwitchCh) = lsrL.trigIn*3;
lsrL.data(LaserRigParameters.lsrWaveCh)   = lsrL.lsrAna;

% send pulse with MEX function
%nidaqAOPulse('aoPulse',lsrL.data);
if lsrL.trigIn>0; nidaqPulse('on'); else nidaqPulse('off'); end

% update iteration info
if lsrL.lsrCounter==lsrL.vecLength; lsrL.lsrCounter = 0; end
lsrL.lsrCounter = lsrL.lsrCounter+1;
lsrL.ii = lsrL.ii+1;

% wait till iteration time is up for constant data rate
t1 = toc;
if t1 < lsrL.loopT;
    t2=delay(lsrL.loopT-t1);
    lsrL.lastdt = t1+t2;
else
    lsrL.lastdt = t1;
end
lsrL.dt(lsrL.ii) = lsrL.lastdt; % write time stamp (actually, dT)
end