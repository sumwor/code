%function addMidlineToGrid
clear
gridname = 'fullGrid';
load(gridname,'grid')

oldGrid = grid;
grid = [];
APs = unique(oldGrid(:,2),'stable');
for ii = 1:length(APs)
    idx = find(oldGrid(:,2)==APs(ii));
    n = length(idx);
    grid = [grid;oldGrid(idx(1):idx(n/2),:);0 APs(ii);oldGrid(idx(n/2+1):idx(end),:)];
end

save(gridname,'grid','-append')