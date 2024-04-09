global data
global timestamps
global FMque
data = [];
timestamps=[];
FMque = FM(500,7);
%% set daq
s = NI_DaqSet(7,5000);
h = figure;
% axis([0,50,-10,10]);
hold on
s.ScansAvailableFcn = @(src,evt) computFx(src,evt,h);
s.ScansAvailableFcnCount = 500;
% start(s,"Duration", seconds(5));
pause(0.5);
app1;
% so = arduino();
%% set PID
tar = -3;
P = MotorPID(0.05,0.15,0);
P.setTarget(tar);
while s.Running
    pause(0.01)
    Fx = FMque.getFx;
    outVal = P.PID_out(Fx);
%     writePWMDutyCycle(a,'D5',0.33);
end