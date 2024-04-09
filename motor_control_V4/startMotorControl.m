function startMotorControl()

global FMque
global swtc
global P
global s
global loopCount
global data
global time
global unit_data
global timestamps

swtc = true;
start(s,"Continuous");
while swtc == true
    pause(0.01)
    Fx = FMque.getFx;
    outVal = P.PID_out(Fx);
    loopCount = loopCount + 1;
%     writePWMDutyCycle(a,'D5',0.33);
end
outVal = 0;
s.stop
data = [data;unit_data];
time = [time;timestamps];
unit_data = [];
timestamps = [];
% writePWMDutyCycle(a,'D5',0.33);
