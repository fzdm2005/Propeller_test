s = NI_DaqSet(7,5000);
s.ScansAvailableFcn = @(src,evt) plot_F_M(src, evt);
start(s,'continuous');