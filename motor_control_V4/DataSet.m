classdef DataSet < handle
    properties 
        data     % dataset for save
        unitdata  % current unit dataset 
        unit_space  % length of unit dataset
        clm % number of colums(data channel)
    end
    
    methods
        
        function  self = appenddata(self,d)
            
            
    