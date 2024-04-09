function computFx(src,event)
global data
global time
global unit_data
global timestamps
global FMque
[d, t, ~] = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");
unit_data=[unit_data;d];
FMque.addVal(d);
timestamps = [timestamps;t];
if abs(mod(t(end),10) - 10)<=0.1
    data = [data;unit_data];
    time = [time;timestamps];
    unit_data = [];
    timestamps = [];
end

data_F_M = d(:,1:6);
F_M=ATI_FT17575(data_F_M');
% set(0,'CurrentFigure',h);
if t(1)-25<0
    x1 = 0;
else
    x1 = t(1)-25;
end
plot(t,F_M(:,1),'-b');
hold on;
if abs(mod(t(end),50) - 50)<=1
    hold off;
end
axis([x1,x1+50,-10,10]);
xlabel("time");
ylabel("F&M");
% legend('Fx','Fy','Fz','Mx','My','Mz');
end