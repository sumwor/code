function lsrL = savelog(lsrL)

global lsrL


info.rigParams            = class2struct(LaserRigParameters);
info.exptParams           = class2struct(lsr);
%info.exptParams.startTime = datestr(datetime,'HHMMSS');
info.exptParams.endTime = datestr(datetime,'HHMMSS');
save(lsrL.savestr,'info');

log = lsrL.temp;
save(lsrL.savestr, 'log');

end