s=serial('COM3');
fopen(s);
set(s,'Terminator','CR');
fprintf(s,'SYSTem:CDRH OFF'); %get rid of the delay then turn on/off the laser immediately

fprintf(s,'SOURce:AM:STATe ON')