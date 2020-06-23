%% Function: Plot pixel in phasor plot generated with plot Phasor Fast;
% Peiyu Wang
% 07/25/2019

% open the phasor plot before using this; defalt map resolution is
% 1024(corrinate with plotPhasor Fast);
function plotPhasorPixel(G,S);
map_res = 1024;

G_index = floor((G-1.526e-05)*map_res/2+map_res/2); %function floor is doing the binning for you.
S_index = floor((S-1.526e-05)*map_res/2+map_res/2);
if G_index < 1; G_index = 1; end
if S_index < 1; S_index = 1; end
if G_index > map_res; G_index = map_res; end
if S_index > map_res; S_index = map_res; end

plot(G_index,S_index,'wx','MarkerSize',150);
end