function I=current_cal(I_read)
offset=0;
slope=10;
I=(I_read-offset)*slope;
end