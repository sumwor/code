function obj = createVideoObject(obj)

if isfield(obj,'vid'); delete(obj.vid); end

% imaqreset;

obj.vid                   = videoinput('pointgrey', 1, 'F7_Mono16_1920x1200_Mode7');
src                       = getselectedsource(obj.vid);
src.ExposureMode          = 'Auto';
src.FrameRatePercentage   = 50;
obj.vid.FramesPerTrigger  = 1;
obj.vidRes                = get(obj.vid, 'VideoResolution');
nBands                    = get(obj.vid, 'NumberOfBands');
obj.hImage                = image(zeros(obj.vidRes(2),obj.vidRes(1), nBands),'Parent',obj.camfig);
set(obj.camfig,'visible','on')

obj.vid.TriggerRepeat     = Inf;
obj.vid.FrameGrabInterval = 1;
triggerconfig(obj.vid, 'manual');