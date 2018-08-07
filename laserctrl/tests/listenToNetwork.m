
% stopscan = 0;
% while ~stopscan
%     tic
%     fprintf(tserver,'hello\n');
%     resp = fscanf(tserver);
%     ts = toc;
%     if strcmpi(resp,'hi')
%         stopscan = 1;
%     end
% end

function listenToNetwork(src,event)
fprintf('i have data\n')
end