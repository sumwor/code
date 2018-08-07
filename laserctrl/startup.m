lsrDir = fileparts(mfilename('fullpath'));

addpath(genpath(lsrDir));
rmpath(genpath(fullfile(lsrDir, '.git')));

clear('lsrDir');
