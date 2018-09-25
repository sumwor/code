function lsrL = savelog(lsrL)

%global lsrL
global lsr

info.rigParams            = class2struct(LaserRigParameters);
info.exptParams           = class2struct(lsr);
%info.exptParams.startTime = datestr(datetime,'HHMMSS');
info.exptParams.endTime = datestr(datetime,'HHMMSS');
log.info = info;

log.trial = lsrL.templog;
save(lsrL.savestr, 'log');

end