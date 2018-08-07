clear; 
try nidaqAOPulse('end'); end
try nidaqDIread ('end'); end
try nidaqPulse ('end'); end

nidaqAOPulse('init',LaserRigParameters.nidaqDevice,LaserRigParameters.aoChannels);
nidaqDIread ('init',LaserRigParameters.nidaqDevice,0,0:7) % fix this later (port and channel)
nidaqPulse ('init',LaserRigParameters.nidaqDevice,0,0:7) % fix this later (port and channel)

for ii = 1:10
nidaqAOPulse('aoPulse',[0 0 3 0]);
tic;
while toc<0.005 % enforce 10 ms delay
end
toc;
tic;
data = nidaqDIread('readDI');
t = toc;
if data(2) > 0
    nidaqPulse('ttl',200);
end
pause(0.1)
nidaqAOPulse('aoPulse',[0 0 0 0]);
tic;
while toc<0.2 % enforce 10 ms delay
end
end

