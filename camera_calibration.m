function [C] = camera_calibration(N)
C(1).K = [1221.2270770  0.0000000       479.5000000
          0.0000000     1221.2270770	269.5000000
          0.0000000     0.0000000       1.0000000];

C(1).R = [1.0000000000	0.0000000000	0.0000000000
          0.0000000000	1.0000000000	0.0000000000
          0.0000000000	0.0000000000	1.0000000000];

C(1).T = [0.0000000000
          0.0000000000
          0.000000000];

C(2).K = [1221.2270770	0.0000000       479.5000000
          0.0000000     1221.2270770	269.5000000
          0.0000000     0.0000000       1.0000000];

C(2).R = [0.9998813487	0.0148994942	0.0039106989
         -0.0148907594	0.9998865876   -0.0022532664
         -0.0039438279	0.0021947658	0.9999898146];

C(2).T = [-9.9909793759
           0.2451742154
           0.165083267];
       
C = C(N);

return