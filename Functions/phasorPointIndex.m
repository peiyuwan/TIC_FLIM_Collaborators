%% Function: phasorPointIndex;
% Given the phasor coordinates, calculate the phaosr point indexes based on
% the phasor plot map resolution. 

function [G_index,S_index] = phasorPointIndex(G,S,map_res)

if nargin == 2
    map_res = 1024;
end

G_index = floor((G-1.526e-05)*map_res/2+map_res/2+1);
S_index = map_res/2 - floor((S-1.526e-05)*map_res/2);

end