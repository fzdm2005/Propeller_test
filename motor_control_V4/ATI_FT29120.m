function FM=ATI_FT29120(FM_read) % FM_read [Fx,Fy,Fz,Mx,My,Mz] in 6x1
% Hui's ATI-IA Mini 45 SI-290-10 SN# FT29120
A = bsxfun(@rdivide, ...
           [   -0.24785   0.03397   5.31140 -33.28407  -5.92100  31.55431   ; ...   % ATI's normalized matrix
                -6.75924  37.78141   0.87810 -19.39566   3.46922 -18.36995   ; ...   
                19.16430   0.88168  19.23899   1.58761  18.86613   1.11670   ; ...   
                 -0.44726   0.20823 -33.08197  -3.10330  32.43949   2.06123   ; ...   
                37.30667   1.80182 -20.18877  -1.51032 -17.74846  -1.27246   ; ...     
                 4.72850 -18.79684   1.74560 -19.10138   2.41363 -18.14594  ],...
           [0.71148766928985; 0.71148766928985; 0.284161093731415; 30.2244329849085; 30.2244329849085; 27.6681745691041]); %ATI's scalefactors
FM=(A*FM_read)'; %output 1X6 
end