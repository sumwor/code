function lsrL = laserLoop

global lsr obj
rng('shuffle')

% initialize parameters
lsrL.loopT              = 1/LaserRigParameters.rate; % skip iteration if longer than this
lsrL.loopTth            = (1+lsr.loopTimeTol)*(1/LaserRigParameters.rate); % skip iteration if longer than this
lsrL.stop               = 0; % received from presentation in triggered mode or GUI button in manual control
lsrL.rampDown           = 0; % boolean to signal rampDown procedure in progress %what's laser rampdown?
lsrL.rampDownCounter    = 1; % to know when to stop
lsrL.rampDownVals       = linspace(1,0,LaserRigParameters.rate*lsr.rampDownDur); % ramp down scaling per iteration
lsrL.ii                 = 1; % iteration number
lsrL.lsrCounter         = 1; % to cycle thorugh galvo/laser "buffered" data
lsrL.lsrON              = false; % boolean to decide if laser is ON or not
lsrL.data               = zeros(1,4); % current data output
lsrL.prevlocationIdx    = 0;  % only change data output if ~= this
lsrL.locationIdx        = 0;
lsrL.dt                 = 0;
lsrL.templog            = [];
lsrL.presentationState  = presentationStateCodes.sessionEnd; % pre-virmen communication
lsrL.prevState          = presentationStateCodes.sessionEnd; % pre-virmen communication
lsrL.currPower          = lsr.power; % for power-varying experiments
lsrL.powerFactor        = 1; % for power-varying experiments
lsrL.powers             = lsr.varyPowerLs; % for power-varying experiments
lsrL.npowers            = numel(lsr.varyPowerLs); % for power-varying experiments

if isempty(lsrL.rampDownVals)
    lsrL.rampDownVals = 0;
else
    lsrL.rampDownVals(1) = []; % first entry is full power
end
lsrL.rampDownMax = numel(lsrL.rampDownVals);

if lsr.preSetOn % for preset experiments (e.g. cfos)
    % update status
    set(obj.statusTxt,'foregroundColor','c')
    set(obj.statusTxt,'String','running preset protocol')
    
    if lsr.ephys
        fprintf('drawing and saving trials\n')
        lsrL.cycleCounter = 1;
        lsrL.ncycles      = numel(lsr.presetCycleDur)*numel(lsr.presetPowers)*lsr.presetNTrials*numel(lsr.grid);
        
        % draw pseudorandom trial order
        ITI               = lsr.presetCycleDur - lsr.presetLocDur;
        trialMat          = [];
        trialIDMat        = [];
        for iLoc = 1:numel(lsr.grid)                
            for iDur = 1:numel(lsr.presetLocDur)
                for iPower = 1:numel(lsr.presetPowers)
                    trialMat(end+1,:)   = [iLoc lsr.presetLocDur(iDur) ITI(iDur) lsr.presetPowers(iPower)];
                    trialIDMat(end+1,:) = [iLoc iDur iDur iPower];
                end
            end
        end
        rng(1) % for consistency
        idx                  = randperm(size(trialMat,1));
        lsrL.trialMat        = repmat(trialMat(idx,:),[lsr.presetNTrials 1]); % blocks
        lsrL.trialIDMat      = repmat(trialIDMat(idx,:),[lsr.presetNTrials 1]); % blocks
        lsrL.trialMatColLbls = {'gridLocation','lsrDur','itiDur','lsrPower'}; % blocks
        
        % save trials for analysis
        savestr     = sprintf('%s%s\\%s_laserLog.mat',lsr.savepathroot,lsr.mouseID,lsr.fn);
        save(savestr,'lsr','lsrL','trialMat','trialIDMat')
        
        % run loop
        commandwindow; clc
        fprintf('starting pre-set experiment\n')
        
        while ~ lsrL.stop
            lsrL = laserLoopFnPreSetEphys(lsrL);
        end
        fprintf('done\n')
        
    else
        lsrL.totalDur     = 0;
        lsrL.maxDur       = lsr.presetMaxDurMin*60;
        lsrL.cycleCounter = 0;
        lsrL.ncycles      = floor(lsrL.maxDur/lsr.presetCycleDur);
        
        commandwindow; clc
        fprintf('starting pre-set experiment\n')
        
        while ~ lsrL.stop
            lsrL = laserLoopFnPreSet(lsrL);
        end
        fprintf('done\n')
    end
    
    set(obj.statusTxt,'String','Idle','foregroundColor',[.3 .3 .3])
    figure(obj.fig)
    
else
    switch lsr.manualTrigger
        case true % manual trigger
            
            % update status
            set(obj.statusTxt,'foregroundColor','b')
            set(obj.statusTxt,'String','manual Laser ON')
            
            while ~ lsrL.stop && sum(lsrL.dt) <= lsr.dur
                lsrL = laserLoopFnManual(lsrL);
            end
            
            set(obj.statusTxt,'String','Idle','foregroundColor',[.3 .3 .3])
        case false % controled by virmen %change to controled by Presentation
            
            % update status
            set(obj.statusTxt,'foregroundColor',[0 .5 0],'String','under Presentation control')
            updateConsole(sprintf('presentation experiment started, mouse %s',lsr.mouseID))
            
            commandwindow; clc
            
            % send experiment parameters to virmen %% we need to change
            % virmen to presentation software
            %sendExptParams;  %seems no need for these parameters
            
            % start log
            lsrL = laserlogger(lsrL,'init');
            
            % wait for presentation to actually start
            fprintf('waiting for presentation to start session...')
            while lsrL.presentationState == 2  %need a specific code for experiment start and end?
                lsrL.prevState   = lsrL.presentationState;
                DIdata           = nidaqDIread('readDI'); % receive 6-bit binary location code 
                if bin2dec(num2str(fliplr(DIdata(1:6))))==61%61 trial start, the code sent by presentation is in reverse order
                    lsrL.presentationState=1;
                elseif bin2dec(num2str(fliplr(DIdata(1:6))))==60 %60 trial end
                    lsrL.presentationState=0;
                end
                %if this is the location of the brain, then no need for this since matlab and this computer will be in charge of this
                %lsrL.virmenState = bin2dec(num2str(DIdata(LaserRigParameters.virmenStateChannels))); % convert to virmen state index
            end
            lsrL.trialCounter = 1;
            
            % let the fun begin!
            fprintf('\nstarting\n\t\ttrial #1\n')
            while ~ lsrL.stop
                if lsr.varyPower
                    lsrL = laserLoopFnTrigVaryPower(lsrL);
                else
                    %lsrL.tempInd=0; %for debug
                    lsrL = laserLoopFnTrig(lsrL);
                end
            end
            
            % save (update status)
            lsrL = laserlogger(lsrL,'cleanup');
            figure(obj.fig)
            
            set(obj.statusTxt,'String','presentation done','foregroundColor','k')
            updateConsole('Presentation experiment ended')
            % send data to virmen through tcpip (update status)
    end
end
