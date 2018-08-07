function lsrobj = computeOuputDataPreSetEphys(lsrobj)

for iLoc = 1:numel(lsrobj.locationSet)
  for iDur = 1:numel(lsrobj.presetLocDur)
    for iPower = 1:numel(lsrobj.Vlsr_preset)
      
      lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoXvec = [];
      lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoYvec = [];
      lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec    = [];
      
      % if one location, just do square waveform, if more than leave laser on
      % to compensate
      if numel(lsrobj.locationSet{iLoc}) == 1
        
        % laser
        szl = ((1000*lsrobj.presetLocDur(iDur))/lsrobj.freq)*(LaserRigParameters.rate/(1000*lsrobj.presetLocDur(iDur)));
        lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec =  ...
          [lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec; repmat([ones(floor(szl*lsrobj.dutyCycle),1); ...
          zeros(ceil(szl*(1-lsrobj.dutyCycle)),1)],lsrobj.freq,1).*lsrobj.Vlsr_preset(iPower)];
        lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec =  ...
          repmat(lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec,[ceil(lsrobj.presetLocDur(iDur)) 1]);
        lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec =  ...
            lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec(1:round(lsrobj.presetLocDur(iDur)*LaserRigParameters.rate));
        if iLoc == 1
          vL = numel(lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec);
        end
        
        % galvo
        if iscell(lsrobj.grid)
          [vx,vy] = convertToGalvoVoltage(lsrobj.grid{iLoc}(lsrobj.locationSet{iLoc},:),'mm');
        else
          [vx,vy] = convertToGalvoVoltage(lsrobj.grid(lsrobj.locationSet{iLoc},:),'mm');
        end
        lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoXvec = [lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoXvec; ones(vL,1).*vx];
        lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoYvec = [lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoYvec; ones(vL,1).*vy];
      else
        
        % galvo
        szg = ((1000*lsrobj.presetLocDur(iDur))/lsrobj.galvofreq)*(LaserRigParameters.rate/(1000*lsrobj.presetLocDur(iDur)));
        x = []; y =[];
        for jj = 1:numel(lsrobj.locationSet{iLoc})
          [vx,vy] = convertToGalvoVoltage(lsrobj.grid{iLoc}(lsrobj.locationSet{iLoc}(jj),:),'mm');
          x = [x; ones(szg,1)*vx];
          y = [y; ones(szg,1)*vy];
          %             % rounding here is to reduce galvo travel. due to affine
          %             % transformation locations that are theoretically the same
          %             % voltage have slightly different ones
          %             x = [x; ones(szg,1)*(round(vx*100))/100];
          %             y = [y; ones(szg,1)*(round(vy*100))/100];
        end
        % in case the division of data rate by number of locations is not
        % exact, generate slightly longer vector to ensure all locations
        % get hit equally
        lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoXvec = [lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoXvec; repmat(x,[ceil(LaserRigParameters.rate/numel(lsrobj.locationSet{iLoc})) 1])];
        lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoYvec = [lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoYvec; repmat(y,[ceil(LaserRigParameters.rate/numel(lsrobj.locationSet{iLoc})) 1])];
        
        if iLoc == 1
          vL = numel(lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoXvec);
        end
        
        % laser
        lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec    = ...
          [lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec; ones(vL,1).*lsrobj.Vlsr_preset(iPower)];
        
      end
      
      % add power ramp down
      if lsrobj.presetRampDown
        rampDownVals  = linspace(1,0,LaserRigParameters.rate*lsrobj.rampDownDur)'; 
        lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec(end-numel(rampDownVals)+1:end) ...
                      = lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec(end-numel(rampDownVals)+1:end).*rampDownVals;
      end
      
      % fill rest of trial with zeros
      fillinsz  = (lsrobj.presetCycleDur(iDur)-lsrobj.presetLocDur(iDur))*LaserRigParameters.rate;
      
      lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec    = [lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec; -ones(fillinsz,1)];
      lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoXvec = [lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoXvec; zeros(fillinsz,1)];
      lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoYvec = [lsrobj.dataout_preset{iLoc,iDur,iPower}.galvoYvec; zeros(fillinsz,1)];
      lsrobj.dataout_preset{iLoc,iDur,iPower}.vecLength = numel(lsrobj.dataout_preset{iLoc,iDur,iPower}.lsrVec);
      
    end
  end
end