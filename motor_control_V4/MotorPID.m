classdef MotorPID < handle
   properties %(Access = private)
       intSpace = 2; % store 2 times err
       Kp = 0;
       Ki = 0;
       Kd = 0;
       dt = 1;
       e_array;
       e_sum;
       target = 0;
%        MAX = Inf;
%        MIN = -Inf;
       MAX = 1500; % 
       MIN = 0;
       dir = 1;
   end
   
   
   methods
       function self = MotorPID (Kp,Ki,Kd,intSpace,dt)
           if nargin < 5 
               dt = 0.1; 
           end
           
           if nargin < 4 
               intSpace = 2; 
           end
           
           if nargin < 3
               Kd = 0;
           end
           if nargin < 2
               Ki = 0;
           end
           if nargin < 1
               Kp = 0;
           end
           self.Kp = Kp;
           self.Ki = Ki;
           self.Kd = Kd;
           self.intSpace = intSpace;
           self.dt = dt;
           self.e_array = FM(intSpace,1);
           self.e_sum = 0;
           self.dir = 1;
       end
       
       
       function self = setTarget(self,tgt)
           self.target = tgt;
       end
       
       
       function self = setKp(self,Kp)
           self.Kp = Kp;
       end
       
       
       function self = setKi(self,Ki)
           self.Ki = Ki;
       end
       
       
       function self = setKd(self,Kd)
           self.Kd = Kd;
       end
       
       
       function self = setdt(self,dt)
           self.dt = dt;
       end
       
       
       function self = setIntSpace(self,space)
           self.intSpace = space;
           self.e_array.clearup;
           self.e_array = FM(space,1);
       end
       
       
       function self = setIMAX(self,val)
           self.MAX= val;
           if self.MAX < self.MIN
               warning('Max value is smaller than Min value');
           end
       end
       
       
       function self = setIMIN(self,val)
           self.MIN= val;
           if self.MAX < self.MIN
               warning('Max value is smaller than Min value');
           end
       end
       
       
       function err = getError(self,inVal)
           err = (self.target - inVal)*self.dir;
       end
       
       
       function self = clear_PID(self)
           self.e_array.reset();
           self.e_sum = 0;
       end
       
       
       function self = updateSum(self,e)
           self.e_sum = self.e_sum+e;
       end
           
           
       function outVal = PID_out(self,inVal)
           err = getError(self,inVal);
           if ~isnan(err)
               updateSum(self,err); % if err is not got, keep last time output
               self.e_array.addVal(err);
           end
           eset = self.e_array.getValset;
           outVal = self.Kp*err + self.Ki*self.e_sum + self. Kd*(eset(1)-eset(2))/self.dt;
           if outVal > self.MAX
               outVal = self.MAX;
           elseif outVal<self.MIN
               outVal = self.MIN;
           end
       end
           
       
   end

end