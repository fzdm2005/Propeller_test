function s = NI_CounterSet(device,ch,type,ActiveEdge)

if nargin < 4 
    ActiveEdge = 'Falling'; 
end

if nargin < 3   
    type = 'EdgeCount'; 
end

if nargin < 2  
    ch = 'ctr0'; 
end

if nargin < 1  
    device = 'Dev1'; 
end

s = daq("ni");
ch = addinput(s,device,ch,type);
ch.ActiveEdge = ActiveEdge;