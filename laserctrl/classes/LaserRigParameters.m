classdef LaserRigParameters

  properties (Constant)
    
    rig                         =   'LaserGalvo1'
    hasDAQ                      =   true              % false for testing on laptop
    %laserIP                     =   '128.112.218.25'  % this IP
    %virmenIP                    =   '128.112.217.208' % virmen IP
    
    laserPort                   =   'COM3';           % for serial communication with laser
    nidaqDevice                 =   1;                % NI-DAQ device identifier; if more than one use cell array
    
    aoChannels                  =   0:3;              % analog output Channels (use cell if more than one device)
    galvoCh                     =   [1 2];            % index of channels controlling galvos (attention for device mounting order!)
    lsrSwitchCh                 =   3;                % channel index for turning laser on and off 
    lsrWaveCh                   =   4;                % channel index for laser waveform (frequency and power)
    
    aiChannels                  =   0:3;              % analog input Channels for virmen control (use cell if mpre than one device)
    galvoInCh                   =   [3 4];            % channel index for x and y galvo position feedback
    pdInCh                      =   2;                % channel index for PD measuring laser power
    
    diPort                      =   0;                % port for digital input from virmen
    diChannels                  =   0:15;             % digital input channels
    locationChannels            =   1:6;              % indices of di channels used for galvo location
    %virmenStateChannels         =   9:12;             % indices of di channel used to communicate virmen state (trial epoch)
    doPort                      =   1;                % port for digital output to virmen
    doChannels                  =   1;                % digital output channels
    doPortLED                   =   2;                % port for digital control of LED
    doChannelsLED               =   [2 3];            % port for digital control of LED
    LEDIdxGreen                 =   1;                % index for green LED
    LEDIdxIR                    =   2;                % index for green LED
    
    rate                        =   400;              % DAQ rate in Hz
    galvoTravelTime             =   0.5;              % in ms, approximate from multiple measurements, travel to and from combined
    
  end
   
end