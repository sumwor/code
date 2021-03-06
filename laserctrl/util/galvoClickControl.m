function galvoClickControl(mode,fh)


% galvoClickControl(mode,fh)
% moves the laser beam to where a cursor is clicked on the image
global obj lsr

if nargin < 1
    mode = 'experiment';
    fh   = obj.hImage;
elseif nargin == 1
    fh   = obj.hImage;
end

vlsr = lsr.Vlsr;

% switch mode
%     case 'experiment'
%         vlsr = lsr.Vlsr;
%     case 'calibration'
%         vlsr = 0.1;
% end

ClickedPosition = round(ginput(1));

if      ClickedPosition(1)>= 1             && ...
        ClickedPosition(1)<= obj.vidRes(1) && ...
        ClickedPosition(2)>= 1             && ...
        ClickedPosition(2)<= obj.vidRes(2)
    
    %coordinate transformation
    newPos=[ClickedPosition(2), 1200-ClickedPosition(1)];
    NewGalvoVoltage = transformPointsInverse(lsr.galvoTform,ClickedPosition);
    NewGalvoVoltage_exp = transformPointsInverse(lsr.galvoTform,newPos);
    switch mode
        case 'experiment'
            lsr.galvoManualVx = NewGalvoVoltage_exp(1);
            lsr.galvoManualVy = NewGalvoVoltage_exp(2);
            lsr.dataout_manual.galvoXvec = ones(lsr.dataout_manual.vecLength,1).*lsr.galvoManualVx;
            lsr.dataout_manual.galvoYvec = ones(lsr.dataout_manual.vecLength,1).*lsr.galvoManualVy;
            
            dataout = zeros(1,4);
            dataout(LaserRigParameters.lsrSwitchCh) = 5;
            dataout(LaserRigParameters.lsrWaveCh)   = vlsr;
            dataout(LaserRigParameters.galvoCh(1)) = NewGalvoVoltage_exp(1);
            dataout(LaserRigParameters.galvoCh(2)) = NewGalvoVoltage_exp(2);
            nidaqAOPulse('aoPulse',dataout);
        case 'calibration'
            dataout = zeros(1,4);
            dataout(LaserRigParameters.lsrSwitchCh) = 5;
            dataout(LaserRigParameters.lsrWaveCh)   = vlsr;
            nidaqAOPulse('aoPulse',dataout);

            dataout(LaserRigParameters.galvoCh(1)) = NewGalvoVoltage(1);
            dataout(LaserRigParameters.galvoCh(2)) = NewGalvoVoltage(2);
            nidaqAOPulse('aoPulse',dataout);
            pause(0.10);
            trigger(obj.vid);
            pause(0.05);
            dataRead = getdata(obj.vid, obj.vid.FramesAvailable, 'uint16');
            figure(fh);
            imagesc(dataRead(:,:,:,1)); colormap gray; 
    end
    
    axis image; hold on; set(gca,'XDir','reverse');
    plot(ClickedPosition(1),ClickedPosition(2),'x');
    
end