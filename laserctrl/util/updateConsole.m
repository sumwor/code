function updateConsole(addstr)

global obj

newstr = sprintf('%s: %s',datestr(datetime,'HH:MM:SS'),addstr);
currstr = cellstr(get(obj.outputTxt,'String'));
set(obj.outputTxt,'String',[currstr;{newstr}]);
set(obj.outputTxt,'Value',numel([currstr;{newstr}]));
drawnow expose