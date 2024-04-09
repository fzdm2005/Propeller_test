% s = NI_DaqSet(7,5000);
% d = daq("ni");
% ch = addinput(d,"dev1","ctr0","EdgeCount");
% ch.ActiveEdge = 'Falling';
% get(ch)
% pause(5);
% resetcounters(d);
d = NI_CounterSet();
count = read(d,"OutputFormat","Matrix");