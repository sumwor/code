function camLoop

warning off

global obj

stopL   = false; 
% ii      = 1;
vidRate = 20;

axes(obj.camfig)
start(obj.vid)

% timing here is not strictly enforced, roughly 20 Hz
while ~ stopL
    tic;
    
    % get cam data and flush buffer
    trigger(obj.vid);
    delay(0.001);
    dataRead    = getdata(obj.vid, obj.vid.FramesAvailable, 'uint8');
    obj.camData = dataRead(:,:,:,end);
    flushdata(obj.vid)
    if isempty(dataRead); continue; else clear dataRead; end
    
    % plot
    plotGridAndHeadplate(obj.camfig)
    
    % check for other stuff in gui and roughly enforce timing
%     if ii == vidRate*2; drawnow(); ii = 1; else ii = ii + 1; end
    drawnow()
    if get(obj.camON,'Value') == false; stopL = true; end
    if toc < 1/vidRate; delay(1/vidRate-toc); end
end

stop(obj.vid);
flushdata(obj.vid)
delete(obj.vid);
clear obj.vid

warning on