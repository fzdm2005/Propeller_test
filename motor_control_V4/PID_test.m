clear
clc
P = MotorPID(0.05,0.15,0);
% P.setIntSpace(10000);
P.setTarget(1000);
for i=1:500
    out(1) = 0;
    out(i+1) = 3*P.PID_out(out(i));
    if i == 200
        out(i+1) = 1100;
    end
end
plot(out);