function lsrobj = computeOuputData(lsrobj)

% calculate 1 sec of galvo and laser data for each possible set of
% locations
for ii = 1:length(lsrobj.locationSet)
    % if one location, just do square waveform, if more than leave laser on
    % to compensate
    
    %get rid of the frequency control at Matlab level: leave this to the
    %Pulsepal, Hongli 9/7/2018
    
    %get rid of this file.....
    if numel(lsrobj.locationSet{ii}) == 1
        % laser
        %szl = (1000/lsrobj.freq)*(LaserRigParameters.rate/1000);
        lsrobj.dataout(ii).lsrVec = lsrobj.Vlsr;
        lsrobj.dataout(ii).vecLength = 1;  
        
        % galvo
        
        [vx,vy] = convertToGalvoVoltage(lsrobj.grid(lsrobj.locationSet{ii},:),'mm');
        lsrobj.dataout(ii).galvoXvec = ones(lsrobj.dataout(ii).vecLength,1).*vx;
        lsrobj.dataout(ii).galvoYvec = ones(lsrobj.dataout(ii).vecLength,1).*vy;
    else
        % galvo  %this is for stimulate different site (almost)
        % simutaneously?
        szg = 1;
        x = []; y =[];
        for jj = 1:numel(lsrobj.locationSet{ii})   
            [vx,vy] = convertToGalvoVoltage(lsrobj.grid{ii}(lsrobj.locationSet{ii}(jj),:),'mm');
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
        lsrobj.dataout(ii).galvoXvec = repmat(x,[ceil(LaserRigParameters.rate/numel(lsrobj.locationSet{ii})) 1]);
        lsrobj.dataout(ii).galvoYvec = repmat(y,[ceil(LaserRigParameters.rate/numel(lsrobj.locationSet{ii})) 1]);
        lsrobj.dataout(ii).vecLength = numel(lsrobj.dataout(ii).galvoXvec);
        
        % laser
        lsrobj.dataout(ii).lsrVec = ones(lsrobj.dataout(ii).vecLength,1).*lsrobj.Vlsr;
        
    end
end

% calculate 1 sec of manually set galvo / laser data
szl = 1;
lsrobj.dataout_manual.lsrVec = lsrobj.Vlsr;
lsrobj.dataout_manual.vecLength = numel(lsrobj.dataout_manual.lsrVec);

% galvo
lsrobj.dataout_manual.galvoXvec = ones(lsrobj.dataout_manual.vecLength,1).*lsrobj.galvoManualVx;
lsrobj.dataout_manual.galvoYvec = ones(lsrobj.dataout_manual.vecLength,1).*lsrobj.galvoManualVy;