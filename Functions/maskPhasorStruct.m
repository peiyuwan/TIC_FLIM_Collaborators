%% Function: maskPhasorStruct
% 08/23/2021
% Peiyu Wang

% Masks the struct based on the mask image provided;
% All the regions inside the mask are zero. 

function mask_struct = maskPhasorStruct(org_struct,mask_img)
mask_struct = org_struct;
mask_struct.int(mask_img == 0) = 0;
mask_struct.G(mask_img == 0) = 0;
mask_struct.S(mask_img == 0) = 0;
end