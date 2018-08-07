function lsrobj = quickPowerCal(lsrobj)
 
% voltage for laser power
load([lsrobj.rootdir '\calibration\PowerCalibration.mat'],'calDate','PowerCalibration')

today   = datestr(datetime,'yymmdd_HHMMSS');
daydiff = abs(str2double(calDate(1:6))-str2double(today(1:6)));
calDate = today;

% if calibration was done in the last 48 h, skip it
if daydiff <= 2
    lsrobj.powerCalcheckMsg = 'less than 48h since last quick power cal, skipping';
    return
else
    %the relation control Voltage to photodiodeOutput is
    oldSlope    = PowerCalibration.ControlVoltageToPhotodiodeOutput.slope;
    oldConstant = PowerCalibration.ControlVoltageToPhotodiodeOutput.constant;
    old1V       = oldSlope+oldConstant; 
    
    % quickly test a few values
    quickcal          = testPD(lsrobj);
    
    % compare values
    diffPercSlope = abs(oldSlope-quickcal.a)/oldSlope;
    diffPercConst = abs(oldConstant-quickcal.b)/oldConstant;
    diffPerc1V    = abs(old1V-quickcal.pdAt1V)/old1V;
    
    % decide what to do: if less than 10% different than last time, do
    % nothing; if within 20%, auto update values, if greater than that,
    % issue warning and prompt user to recalibrate fully
    if diffPercSlope <= .1 && diffPercConst <= .1 && diffPerc1V <= .1

        save([lsrobj.rootdir '\calibration\PowerCalibration.mat'],'calDate','-append')
        lsrobj.powerCalcheckMsg = 'Quick power cal: values are good';
        
    elseif (diffPercSlope > .1 && diffPercSlope <= .2) || ...
           (diffPercConst > .1 && diffPercConst <= .2) || ...
           (diffPerc1V    > .1 && diffPerc1V    <= .2) 
       
       save([lsrobj.rootdir '\calibration\PowerCalibration.mat'],'calDate','-append')
       
       % automatically update Vlsr for this session, but recommend full calibration 
       lsrobj.Vlsr = lsrobj.Vlsr*(old1V/quickcal.pdAt1V);
       lsrobj      = computeOuputData(lsrobj); % recompute laser/galvo data output
       lsrobj.powerCalcheckMsg = 'Quick power cal: values within 20%, automatically updated. Full calibration recommended';
       
    else
        
        lsrobj.powerCalcheckMsg = 'Quick power cal: values are off, double-check calibration';
        warndlg(lsrobj.powerCalcheckMsg)
        
    end
end
% 
% % update values?
% lsrobj.a_power          = PowerCalibration.ControlVoltageToLaserPower.slope;
% lsrobj.b_power          = PowerCalibration.ControlVoltageToLaserPower.constant;
% lsrobj.Vlsr             = (1/lsrobj.powerAtt).*(lsrobj.power-lsrobj.b_power)/lsrobj.a_power;
% lsrobj.maxP             = (5*lsrobj.a_power+lsrobj.b_power)*lsrobj.powerAtt; % maximum power (corresponding to 5V)

end

% quick calibration with 3 values
function quickcal = testPD(lsr)

dur  = 3;
vmin = 1;
vmax = 3;
vstp = 1;

szl      = (1000/lsr.freq)*(LaserRigParameters.rate/1000);
datafreq = repmat(repmat([ones(floor(szl*lsr.dutyCycle),1); ...
            zeros(ceil(szl*(1-lsr.dutyCycle)),1)],lsr.freq,1),[dur 1]);
dataout  = zeros(1,4);
dataout(LaserRigParameters.lsrSwitchCh) = 5;

vPower                   = vmin:vstp:vmax;
RecordPhotoDiodeVoltages = zeros(length(vPower),1);

% increase voltage progressively and measure input
for ii = 1:length(vPower)
    
    % measure for "dur" sec
    datain = zeros(length(datafreq),1);
    for jj = 1:LaserRigParameters.rate*dur
        tic;
        dataout(LaserRigParameters.lsrWaveCh) = datafreq(jj)*vPower(ii);
        nidaqAOPulse('aoPulse',dataout);
        delay(.001);
        
        temp = nidaqAIread('AIread');
        datain(jj) = temp(LaserRigParameters.pdInCh);
            
        ts = toc;
        delay(1/LaserRigParameters.rate-ts);
    end
    nidaqAOPulse('aoPulse',[0 0 0 0]); 
    RecordPhotoDiodeVoltages(ii,:) = mean(datain);
end

p               = polyfit(vPower',RecordPhotoDiodeVoltages(:,1),1);
quickcal.a      = p(1); 
quickcal.b      = p(2);
quickcal.pdAt1V = p(1)+p(2); % PD voltage at 1V command

end
