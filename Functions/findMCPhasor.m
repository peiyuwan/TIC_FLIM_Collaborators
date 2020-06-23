%% Find Masked Centroid
% Peiyu Wang
% 09/09/2019

% Finding the phasor centers of the ref stack org_ref where we have a mask
% Positions not wishing to be considered should be 0 in the mask.

% Mask input is an image, not a ref. 
function [G_cen, S_cen] = findMCPhasor(org_ref,mask_img);
G_cen = mean(org_ref.G(mask_img~=0));
S_cen = mean(org_ref.S(mask_img~=0));
end