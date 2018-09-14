%script to save grid


savePath='C:\Users\kwanlab\Documents\code\laserctrl\grid';
filename='cFosKwan.mat'; %change to desired file name


%seems that we only need these two so far
P_on = 1.0;
grid = [ 0.5, 1.5;     ...
         0.5, -0.5;    ...
         2.5, 2];

cd(savePath);
save(filename,'P_on','grid');