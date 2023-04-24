%% Function: Find Centroid of Plots;
% Peiyu Wang 
% 10/19/2018

%Pixel which have zeros phasor values are not included here. 

function [G_cen, S_cen] = findMedianPhasor(org_ref)
G_cen = median(org_ref.G(abs(org_ref.G)>=1.53e-05));
S_cen = median(org_ref.S(abs(org_ref.S)>=1.53e-05));
end