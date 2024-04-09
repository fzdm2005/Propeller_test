
function s = NI_DaqSet(ch_num,Frequency,ch0,range,config,device,type)

if nargin < 7 
    type = 'Voltage'; 
end

if nargin < 6 
    device = 'Dev1'; 
end

if nargin < 5   
    config = 'SingleEnded'; 
end

if nargin < 4  
    range = [-10,10]; 
end

if nargin < 3  
    ch0 = 0; 
end

s = daq('ni');
s.Rate = Frequency;

for i =ch0+1:ch_num
    channel = ['ai',num2str(i-1)];
    ch(i) = addinput(s, device, channel,type);
    ch(i).Range = range;
    ch(i).TerminalConfig = config;
end

