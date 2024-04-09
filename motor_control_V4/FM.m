classdef FM < handle
    % A class to store specific length data, FIFO
   properties 
      space_r = 10; % number of rows
      space_l = 1; % number of colums (data channel)
      val_set = zeros(10,1); %new data add in row. 
      count = 0;
      fullFlag;
      ref; % reference from calibration
   end
   
   
   methods
      function self = FM(row,clm)
        if nargin == 1
            self.val_set = zeros(row,1);
            self.space_r = row;
            self.space_l = 1;
            self.fullFlag = 0;
            self.ref = zeros(1,clm);
        end
        if nargin == 2
            self.val_set = zeros(row,clm);
            self.space_r = row;
            self.space_l = clm;
            self.fullFlag = 0;
            self.ref = zeros(1,clm);
        end
      end
   end
   
   
   methods (Access = private)
       
     function self = addOneVal(self,newVal) 
         [row,clm]=size(newVal);
         if clm ~= self.space_l
             return
         end
         temp = self.val_set;
         temp(row+1:end,:) = temp(1:end-1,:);
         temp(1,:) = newVal;
         self.val_set = temp;
         if self.fullFlag == 0
             self.count = self.count + 1;
             if self.count == self.space_r
                 self.fullFlag = 1;
             end
         end
             end
   end
   
   
   methods
       
      function self = clearData(self)
          self.val_set = zeros(self.space_r,self.space_l);
          self.count = 0;
          self.fullFlag = 0;
      end
      
      
      function self = reset(self)
          self.val_set = zeros(self.space_r,self.space_l);
          self.count = 0;
          self.fullFlag = 0;
          self.ref = zeros(1,self.space_l);
      end
      
      
      function self = setRef(self,rf)
          self.ref = rf;
      end
      
      
      function addVal(self,newVal)
         [row,clm]=size(newVal);
         if clm ~= self.space_l
             return
         end
         for i = 1: row
             val = newVal(i,:);
             addOneVal(self,val);
         end
      end
      
      
      function mVal = getMean(self)
         if self.fullFlag == 1
             mVal = mean(self.val_set,1);
         else
             mVal = mean(self.val_set(1:self.count,:),1);
         end
      end
      
      
      function mVal = getSum(self)
         if self.fullFlag == 1
             mVal = sum(self.val_set,1);
         else
             mVal = sum(self.val_set(1:self.count,:),1);
         end
      end
      
      
      function rst = ATI_FT17575(self,data) % data [Fx,Fy,Fz,Mx,My,Mz] in 6x1
          A = bsxfun(@rdivide, ...
           [   -0.44466,     0.09131,    2.57554,  -33.30710,   -1.30491,   32.19461   ; ...   % ATI's normalized matrix
                -3.55651,    37.92238,    1.22075,  -19.07415,    1.31887,  -18.71861   ; ...   
                19.53546,     1.52970,   18.71796,    1.52568,   20.05759,    1.25940   ; ...   
                 0.22712,     0.00492,  -32.63088,   -3.11539,   32.85949,    2.61680   ; ...   
                37.79040,     3.39047,  -19.05152,   -1.76939,  -18.98191,   -1.51688   ; ...     
                 1.69206,   -19.47906,    1.43377,  -19.33620,    1.15611,   -18.75208  ],...
           [0.71148766928985; 0.71148766928985; 0.284161093731415; 30.2244329849085; 30.2244329849085; 27.6681745691041]); %ATI's scalefactors
          rst=(A*data)'; %output 1X6 
      end
      
      
      function rst = ATI_FT29120(self,data) % data [Fx,Fy,Fz,Mx,My,Mz] in 6x1
            A = bsxfun(@rdivide, ...
               [   -0.24785   0.03397   5.31140 -33.28407  -5.92100  31.55431   ; ...   % ATI's normalized matrix
                    -6.75924  37.78141   0.87810 -19.39566   3.46922 -18.36995   ; ...   
                    19.16430   0.88168  19.23899   1.58761  18.86613   1.11670   ; ...   
                     -0.44726   0.20823 -33.08197  -3.10330  32.43949   2.06123   ; ...   
                    37.30667   1.80182 -20.18877  -1.51032 -17.74846  -1.27246   ; ...     
                     4.72850 -18.79684   1.74560 -19.10138   2.41363 -18.14594  ],...
               [0.71148766928985; 0.71148766928985; 0.284161093731415; 30.2244329849085; 30.2244329849085; 27.6681745691041]); %ATI's scalefactors
            rst=(A*data)'; %output 1X6 
      end
      
      
      function I=current_cal(self,I_read) %I_read, double
          offset=0;
          slope=10;
          I=(I_read-offset)*slope;
      end 
      
      
      function Fval = getCurrent(self)
          data = self.getMean() - self.ref;
          if isempty(data)
              Fval =[];
              return
          else
              data = data(:,7);
              Fval=self.current_cal(data);
              rf = self.ref(7);
              Fval = Fval - rf;
          end
      end  
      
      
      function Fval = getFx(self)
          data = self.getMean() - self.ref;
          if isempty(data)
              Fval = [];
              return
          else
              data = data(:,1:6);
              Fval=self.ATI_FT29120(data');
              Fval = Fval(1);
          end
      end
      
      
      function Ival = getI(self)
          data = self.getMean();
          if isempty(data)
              Ival =[];
              return
          else
              data = data(:,7);
              Ival=current_cal(data);
              Ival = Ival(1);
          end
      end
      
      
      function Valset = getValset(self)
          Valset = self.val_set;
      end
      
      
      function fullFlag = isFull(self)
          fullFlag = self.fullFlag;
      end
      
   end
end