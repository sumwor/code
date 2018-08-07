function lsrobj = getCalValues(lsrobj)


% voltage for laser power
load ([lsrobj.rootdir 'calibration\PowerCalibration.mat'],'PowerCalibration')

lsrobj.a_power    = PowerCalibration.ControlVoltageToLaserPower.slope;
lsrobj.b_power    = PowerCalibration.ControlVoltageToLaserPower.constant;
lsrobj.Vlsr       = (lsrobj.power-lsrobj.b_power)/lsrobj.a_power;
lsrobj.maxP       = (5*lsrobj.a_power+lsrobj.b_power); % maximum power (corresponding to 5V)

% voltage for galvo
load ([lsrobj.rootdir '\calibration\galvoCal.mat'],'galvoCal')

lsrobj.a_xGalvo   = galvoCal.linFit.slope_x; 
lsrobj.b_xGalvo   = galvoCal.linFit.constant_x; 
lsrobj.a_yGalvo   = galvoCal.linFit.slope_y;
lsrobj.b_yGalvo   = galvoCal.linFit.constant_y; 
lsrobj.galvoTform = galvoCal.tform;


% try
% load powerCal a b % power = a*voltage+b; 
% lsr.a_power = a;
% lsr.b_power = b;
% 
% load galvoCal a_x b_x a_y b_y beamCenterPxl pxlPerMM % galvo = a*voltage+b; 
% lsr.a_xGalvo = a_x;
% lsr.b_xGalvo = b_x;
% lsr.a_yGalvo = a_y;
% lsr.b_yGalvo = b_y;
% lsr.beamCenterPxl = beamCenterPxl;
% lsr.pxlPerMM = pxlPerMM;
% 
% clear a b a_x b_x a_y b_y beamCenterPxl
% 
% 
% lsr.maxVgalvo = 0.8; % maximum (minimum) voltage allowed for galvos
% lsr.maxGalvoMM_x = maxVgalvo*lsr.a_x+lsr.b_x;
% lsr.maxGalvoMM_y = maxVgalvo*lsr.a_y+lsr.b_y;
% 
% lsr.Vlsr = (lsr.power-lsr.b_power)/lsr.a_power;
% end
% figure out position relative to bregma
% globVars.Vx = (globVars.AP-globVars.b_power)/globVars.a_power;
% globVars.Vy = (globVars.power-globVars.b_power)/globVars.a_power;