function drawHeadplate(impath,mouseID)

refpath = dir([impath '*refIm.mat']);
load([impath refpath.name],'frame')

fh = figure;
imshow(fliplr(frame))
headplate        = roipoly;
headplateContour = bwperim(headplate);
close(fh)

save([impath mouseID '_headplate.mat'],'headplateContour','headplate')