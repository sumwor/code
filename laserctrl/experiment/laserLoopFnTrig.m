function lsrL = laserLoopFnTrig(lsrL)

%test fetch
%get rid of the lsrCounter  -> the function is moved to pulsepal
global lsr 

% % skip iteration if last one was too long
% if lsrL.dt >= lsrL.loopTth
%     % update iteration info
%     tic;
%     if lsrL.lsrCounter==lsrL.vecLength; lsrL.lsrCounter = 0; end
%     lsrL.ii = lsrL.ii+1;
%     lsrL.lsrCounter = lsrL.lsrCounter+1;
%     lsrL.dt = toc;
%     return
% end
tic;

lsrL.prevlocationIdx = lsrL.locationIdx;
lsrL.prevState       = lsrL.presentationState;
lsrL.prevDI          = lsrL.DIdata;
% receive laser and galvo info from presentation computer
%these are not needed, we only want a trigger signal
DItemp           = nidaqDIread('readDI');

lsrL.DIdata      = num2str(fliplr(DItemp(LaserRigParameters.locationChannels))); % receive 6-bit binary location code
% if ~strcmp(lsrL.prevDI, lsrL.DIdata)
%     lsrL.prevDI
%     lsrL.DIdata
% end
curTime=clock;
lsrL.time = curTime(4)*3600+curTime(5)*60+curTime(6)-lsrL.timestart;  %get current time, unit is s;

lsrL.DICode=bin2dec(lsrL.DIdata);
%if AllIndex ~= lsrL.tempInd
%    AllIndex
%end
%lsrL.tempInd=AllIndex;

%for debugging
%get laser and trial code
if lsrL.DICode==63 %laser on
    lsrL.lsrON = true;
    lsrL.blueLED = 1;
elseif lsrL.DICode==62  %laser off
    lsrL.lsrON =  false;
    lsrL.blueLED = 1;  %blue LED will always on when it is in the laser period
elseif lsrL.DICode==61 %session start
    lsrL.blueLED = 0;
    lsrL.lsrON =  false;
elseif lsrL.DICode==60  %session end
    lsrL.presentationState = 2;
    lsrL.blueLED = 0;
    lsrL.lsrON =  false;
% elseif lsrL.DICode==58  %intertrial interval
%     lsrL.presentationState =3;
%     lsrL.blueLED = 0;
%     lsrL.lsrON =  false;
else
    lsrL.locationIdx = lsrL.DICode;
    lsrL.lsrON =  false;
    lsrL.blueLED = 0;
end
%presentation state code:
%0: trial end
%1: trial start
%2: session end
%3: intertrial interval (consider remove trial end?)


% if setup of the first trial is done, shut down "OK" for the
% sake of the following trials
if lsrL.presentationState ~= presentationStateCodes.sessionEnd %lsrL.trialCounter == 1 && 
    nidaqPulse('off')
end

% experiment end?
if lsrL.presentationState == presentationStateCodes.sessionEnd
    lsrL.stop = 1; % stop signal from virmen
end

%no need to add the laser counter right now.. Hongli
%and no need to do ramp down for now... XD
% if lsrL.locationIdx ~= lsrL.prevlocationIdx  
%     if lsrL.locationIdx == 0 && lsrL.prevlocationIdx ~= 0 % start rampdown?
%         lsrL.rampDown = 1; 
%     else
%         lsrL.lsrCounter = 1; 
%     end 
% end

% if ramp down lock galvo positions
%get rid of the rampdown
% if lsrL.rampDown && lsrL.rampDownCounter == 1 
%     lsrL.rampDownlocationIdx = lsrL.prevlocationIdx; 
% end 


%changed the condition
if ~strcmp(lsrL.prevDI, lsrL.DIdata)
    if lsrL.lsrON %&& lsrL.prevlocationIdx == 0 && lsrL.rampDown == 0
        fprintf('\t\t\tLaser ON, Galvo location %d\n',lsrL.locationIdx)
    end
end

% turn on the blue LED (masking light)
if lsrL.blueLED == 1
    %obj.LEDdataout = 1;
    %nidaqDOwrite('writeDO',obj.LEDdataout);
    nidaqDOwrite('writeDO',1);
else
    %obj.LEDdataout = 0;
    %nidaqDOwrite('writeDO',obj.LEDdataout);
    nidaqDOwrite('writeDO',0);
end

if ~ lsrL.lsrON && lsrL.locationIdx ~= 0 %galvo move even laser is off for control
    
    %lsrL.data = zeros(1,4);
    lsrL.data(LaserRigParameters.galvoCh(1))  = lsr.dataout(lsrL.locationIdx).galvoXvec;
    lsrL.data(LaserRigParameters.galvoCh(2))  = lsr.dataout(lsrL.locationIdx).galvoYvec;
    lsrL.data(LaserRigParameters.lsrWaveCh)   = lsr.dataout(lsrL.locationIdx).lsrVec;
    lsrL.data(LaserRigParameters.lsrSwitchCh) = 0;
elseif lsrL.locationIdx == 0
    lsrL.data = zeros(1,4);       
else
    lsrL.data(LaserRigParameters.lsrSwitchCh) = 5;
    
    if lsrL.rampDown % ramp down laser power according to rampDownVals
        lsrL.data(LaserRigParameters.galvoCh(1))  = lsr.dataout(lsrL.rampDownlocationIdx).galvoXvec;
        lsrL.data(LaserRigParameters.galvoCh(2))  = lsr.dataout(lsrL.rampDownlocationIdx).galvoYvec;
        lsrL.data(LaserRigParameters.lsrWaveCh)   = ...
            lsr.dataout(lsrL.rampDownlocationIdx).lsrVec(lsrL.lsrCounter)*lsrL.rampDownVals;
    else
        lsrL.data(LaserRigParameters.galvoCh(1))  = lsr.dataout(lsrL.locationIdx).galvoXvec;
        lsrL.data(LaserRigParameters.galvoCh(2))  = lsr.dataout(lsrL.locationIdx).galvoYvec;
        lsrL.data(LaserRigParameters.lsrWaveCh)   = lsr.dataout(lsrL.locationIdx).lsrVec;
    end
end

% send AO data with MEX function
nidaqAOPulse('aoPulse',lsrL.data); % laser switch channel also goes to virmen


% lsrL = updateCounters(lsrL); % update iteration info

%add code to make sure only add log entries when the DI input has changed:
%Done! 09/24/18

% lsrL = laserlogger(lsrL,'log'); % handle data and save if appropriate trial epoch
% end

t1=toc; %this tic & toc is to set the iteration frequency
% wait till iteration time is up for constant data rate, write dt
% t1 = toc;
if t1< lsrL.loopT
    t2=delay(lsrL.loopT-t1);
    lsrL.dt = t1+t2;

else
    lsrL.dt = t1;
end


%add one entry to lsrL.templog if digital code changes
if ~strcmp(lsrL.prevDI, lsrL.DIdata)
    for jj = 1:length(lsrL.varlist)
        eval(sprintf('lsrL.templog(lsrL.saveCount, jj) = {lsrL.%s};', lsrL.varlist{jj}))
    end
    lsrL.saveCount = lsrL.saveCount +1;
end

end
%no need to do counters
% function lsrL = updateCounters(lsrL)
% % 
% global lsr 
% % 
% % if lsrL.lsrCounter==lsr.dataout(1).vecLength; lsrL.lsrCounter = 0; end
% % if lsrL.rampDownCounter==lsrL.rampDownMax 
% %     lsrL.rampDownCounter = 1; 
% %     lsrL.rampDown = 0; 
% %     lsrL.lsrCounter = 1;
% % end
% % 
% % if lsrL.rampDown; lsrL.rampDownCounter = lsrL.rampDownCounter+1; end 
% % if lsrL.lsrON;    lsrL.lsrCounter = lsrL.lsrCounter+1;           end
% 
% % new trial?
% % if lsrL.prevState == presentationStateCodes.intertrialInt ...
% %     && lsrL.presentationState == presentationStateCodes.trialStart
% %     
% %     lsrL.trialCounter = lsrL.trialCounter + 1;
% %     fprintf('\t\ttrial #%d\n',lsrL.trialCounter);
% %     lsrL.ii           = 1;
% %     lsrL.save         = 1; % flag to save previous trial's log
% %     % 1.  for cfos experiment, the startexpt event should last for at least 50
% %     % ms to make sure matlab can receive the position code following the
% %     % save
% %     % 2. for behavior tasks, the saving should occur at intertrial interval
% %     % (should we add more presentation state code? perhaps at least add an 
% %     % intertrial interval code)
% %     % Hongli 9/21/18
% % else
% %     %if lsrL.prevDI ~= lsrL.DIdata
% %     if ~strcmp(lsrL.prevDI, lsrL.DIdata)
% %         lsrL.ii           = lsrL.ii+1;
% %     end 
% %     lsrL.save         = 0;
% % end
% %     
% end