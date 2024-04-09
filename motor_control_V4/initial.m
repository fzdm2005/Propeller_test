clc
clear
close all
%%
global data
global time
global unit_data
global timestamps
global FMque
global swtc
global P
global s
global loopCount

data = [];
time = [];
unit_data = [];
timestamps=[];
FMque = FM(500,7);
swtc = false;
P = MotorPID(0.05,0.15,0);
loopCount = 0;
%% set daq
s = NI_DaqSet(7,5000);
s.ScansAvailableFcn = @(src,evt) computFx(src,evt);
s.ScansAvailableFcnCount = 500;
% start(s,"Duration", seconds(5));
pause(0.5);
app1;
% so = arduino();