classdef MotorDaq < handle
    properties

        s    % ni daq class
        daqFrequency % sample frequency
        data % original data from daq
        rollSpeed % rotational speed
        timestamps %original time from daq
        unit_data;
        unit_time;
        t_start; %time mark of start(ni daq process cannot reset time during daq)
        ref_data;% whole reference data from caliberation
        ref; % reference value from caliberation
        r % ni daq class, counter, get rpm
        count = 0;
        isDaq; %flag indicating the daq process is running or not(right now it is same with Running)
        
        FMque % force quene
        target % control target
        swtc  % switch of pid
        P    % class of motor pid

        Running  % indicater of PID output running
        ard   % arduino interface
        ard_com % arduino interface by serial
        so  % arduino servo lib
        so_pin = 'D5' % output pin(need update)
        arduConnected; % indicater of arduino connecting
        realTimeFig; % figure handle of reatime plot
        isApp; % if plot on app panel
        App;

    end
    
    
    methods
        function self = MotorDaq(Kp,Ki,Kd,daqFrequency,ChnNum,SampleNum)
           if nargin < 6 
               SampleNum = 500; 
           end
           
           if nargin < 5
               ChnNum = 7; 
           end
                      
           if nargin < 4 
               daqFrequency = 5000; 
           end
           if nargin < 3 
               Kp = 0; 
           end
           if nargin < 2 
               Ki = 0; 
           end
           if nargin < 1 
               Kd = 0; 
           end
            self.data = [];
            self.timestamps=[];
            self.unit_data = [];
            self.unit_time = [];
            self.swtc = false;
            self.P = MotorPID(Kp,Ki,Kd);
%             self.FMque = FM(SampleNum,ChnNum);
%             self.s = NI_DaqSet(ChnNum,daqFrequency);
%             self.s.ScansAvailableFcn = @(src,evt) self.computFx(src,evt);
%             self.s.ScansAvailableFcnCount = daqFrequency/10;
            self.r = NI_CounterSet();
            self.daqFrequency = daqFrequency;
            self.target = 0;
%             self.arduConnected = false;
            self.isApp = 0;
            self.ref = zeros(1,ChnNum);
            self.count = 0;
            self.t_start = 0;
            %self.so = arduino();
        end
        
        
        function self = setDaq(self,ch_num,Frequency,ch0,range,config,device,type,SampleNum)
            if nargin < 9 
                SampleNum = 500; 
            end
            if nargin < 8 
                type = 'Voltage'; 
            end

            if nargin < 7 
                device = 'Dev1'; 
            end

            if nargin < 6   
                config = 'SingleEnded'; 
            end

            if nargin < 5  
                range = [-10,10]; 
            end

            if nargin < 4 
                ch0 = 0; 
            end
            self.s = NI_DaqSet(ch_num,Frequency,ch0,range,config,device,type);
            self.s.ScansAvailableFcn = @(src,evt) self.computFx(src,evt);
            self.s.ScansAvailableFcnCount = Frequency/10;
            self.daqFrequency = Frequency;
            self.FMque = FM(SampleNum,ch_num);
            self.ref = zeros(1,ch_num);
        end

        function self = setRealTimeFig(self,h)
            self.realTimeFig = h;
        end
        
        function self = changeDir(self)
            self.P.dir = self.P.dir*-1;
        end
        
        function self = openApp(self,app)
            self.isApp = true;
            if nargin == 2
                self.App = app;
            end
        end
        
        
        function self = startMotorControl(self)  % use for Daq and PID control
            self.swtc = true;
            self.Running = true;
            self.isDaq = true;
            start(self.s,"Continuous");
            while self.swtc == true && self.arduConnected == true
                pause(0.01)
                Fx = self.FMque.getFx;
                if isnan(Fx)
                    Fx = 0;
                end
                outVal = 800 + self.P.PID_out(Fx);
                outVal_s = rescale(outVal,'InputMin',800,'InputMax',2300);
                writePosition(self.so, outVal_s);
%                write(self.ard_com, num2str(outVal), 'char');
                self.displayApp('OutputGauge.Value',outVal,1);
            end
            writePosition(self.so, 0);
            %write(self.ard_com, num2str(0), 'char');
            self.displayApp('OutputGauge.Value',0,1);

        end 
        
        
        function self = startDaq(self)  % use for Daq only
            self.swtc = true;
            self.Running = true;
            self.isDaq = true;
            start(self.s,"Continuous");
            while self.swtc == true
                pause(0.01);
                %Fx = self.FMque.getFx;
                %outVal = self.P.PID_out(Fx);
            end
            self.s.stop;
            self.Running = false;
            self.isDaq = false;
        end
        
        
        function self = endMotorControl(self)
            self.swtc = false;
            if self.isApp
                for i = 1:length(self.realTimeFig)
                    hold(self.realTimeFig{i},'off');
                end
            else
                set(0,'CurrentFigure',self.realTimeFig);               
                hold off;
            end
            self.reloadData();
            if self.arduConnected == true
                writePosition(self.so, 0);
                %write(self.ard_com, num2str(0), 'char');
                self.displayApp('OutputGauge.Value',0,1);
            end
            self.s.stop
            self.Running = false;
            self.isDaq = false;
        end
        
        
        function self = setSoPin(self,pin)
            self.so_pin = pin;
        end
        
        
        function self = setTarget(self,tar)
            self.P.setTarget(tar);
        end
        
        
        function calibration(self,dur)
            if nargin < 2
               dur = 10; 
            end
            self.clearData();
            self.Running = true;
            self.isDaq = true;
            start(self.s,"Duration", seconds(dur));
            while self.s.Running == 1 % lock matlab while calibration
                pause(0.5)
            end
            self.Running = false;
            self.isDaq = false;
            self.reloadData();
            self.ref_data = self.data;
            rf = mean(self.data);
            self.ref = rf;
            self.FMque.setRef(rf);
            self.clearData();
            self.FMque.clearData();
        end
        
        
        function dataReset(self)
            self.clearData();
%             self.FMque.clearData();
        end
        
        
        function self = arduConnect(self,portNum,pin)
            if nargin < 3
                pin = 'D5';
            end
            if nargin < 2
                port = serialportlist("available");
                portNum = port{1};
            end
            self.ard = arduino(portNum);
            self.so_pin = pin;
            self.so = servo(self.ard, pin, ...
                'MinPulseDuration', 800*10^-6, ...
                'MaxPulseDuration', 2300*10^-6);
            writePosition(self.so, 0);
            self.arduConnected = true;
        end
        
        function self = arduConnect_com(self,portNum)
            if nargin < 2
                port = serialportlist("available");
                portNum = port{1};
            end
            self.ard_com =serialport(portNum,9600);
            self.arduConnected = true;
        end
        
        
        function self = arduClear(self)
            %clear self.so;
            self.so = [];
            self.ard = [];
            clear self.ard;
            self.arduConnected = 0;
        end
        
        
        function saveData(self)
            if self.s.Running == 0
                self.reloadData();
                [filename,save_path] = uiputfile('.mat','Saving result','Data_Time');
                if length(filename) < 2 || length(save_path) < 2
                    return
                end
                data = self.data;
                timestamps = self.timestamps;
                ref = self.ref;
                ref_data = self.ref_data;
                save([save_path,filename],'data','timestamps','ref','ref_data');
            end
        end
        
        
        function displayApp(self,name_app,val,flag)
            % flag = 1, output is number
            % flag = 2, output is string(number)
            if nargin < 3
                flag = 1;
            end
            if flag == 1
                eval(strcat('self.App.',name_app,'= val;'));
            
            else
                eval(strcat('self.App.',name_app,'= num2str(val,''%.2f'');'));
            end
        end
            
    end
    
    
    methods (Access = private)
        
        
        function self = computFx(self,src,event)
            [d, t, ~] = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");
            ct = read(self.r,"OutputFormat","Matrix");
            %resetcounters(self.r);  %reset does not work,don not know why
            rpm = 60*(ct-self.count)/(t(end)-t(1));
            self.count = ct;
            self.unit_data=[self.unit_data;d];
            self.FMque.addVal(d);
            self.unit_time = [self.unit_time;t];
            if length(self.unit_time) > 10 * self.daqFrequency % reload data every 10s
                self.reloadData();
            end
            if self.isApp
                self.realTimePlotApp(d,t - self.t_start);
            else
                self.realTimePlot(d,t);
            end
                self.displayApp('timer.Text',t(end) - self.t_start, 2);
        end
        
        
        function self = reloadData(self)
            self.data = [self.data;self.unit_data];
            self.timestamps = [self.timestamps;self.unit_time];
            self.unit_data = [];
            self.unit_time = [];
        end
        
        
        function self = clearData(self)
            if self.Running
                self.t_start = self.unit_time(end);
            else
                self.t_start = 0;
            end
            self.data = [];
            self.timestamps=[];
            self.unit_data = [];
            self.unit_time = [];
        end
        
        
        function self = realTimePlot(self,d,t)
            data_F_M = d(:,1:6);
            F_M=self.FMque.ATI_FT29120(data_F_M');
            
            if t(1)-25<0
                x1 = 0;
            else
                x1 = t(1)-25;
            end
            
            plot(t,F_M(:,1),'-b');    
            hold on;
            if abs(mod(t(end),50) - 50)<= 0.1
                hold off;
            end
            axis([x1,x1+50,-10,10]);
            xlabel("time");
            ylabel("F&M");
        end
             
        
        function self = realTimePlotApp(self,d,t)
            d = d - self.ref;
            data_F_M = d(:,1:6);
            data_I = d(:,7);
            F_M=self.FMque.ATI_FT29120(data_F_M');
            Fx_ave = movmean(F_M(:,1),100);
            I = self.FMque.current_cal(data_I);
            
            if t(1)-25<0
                x1 = 0;
            else
                x1 = t(1)-25;
            end

            plot(self.realTimeFig{1},t,Fx_ave,'-b');
            plot(self.realTimeFig{2},t,I,'-r');
            for i = 1:length(self.realTimeFig)
                hold (self.realTimeFig{i},'on');
            end
            if abs(mod(t(end),50) - 50)<= 0.1
                for i = 1:length(self.realTimeFig)
                    hold (self.realTimeFig{i},'off');
                end
            end
            axis(self.realTimeFig{1},[x1,x1+50,-1.5,1.5]);
            axis(self.realTimeFig{2},[x1,x1+50,0,20]);

            
%             xlabel(self.realTimeFig,"time");
%             ylabel(self.realTimeFig,"F&M");
        end

            
        
    end
        
end