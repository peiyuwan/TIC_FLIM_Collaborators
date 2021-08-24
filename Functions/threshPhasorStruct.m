%% Function: threshPhasorStruct
% 08/23/2021
% Peiyu Wang

% Masks the struct based on the mask image provided;
% All the regions inside the mask are zero. 

function thresh_struct = threshPhasorStruct(org_struct,thresh_val)
thresh_struct = org_struct;
thresh_struct.int(org_struct.int < thresh_val) = 0;
thresh_struct.G((org_struct.int < thresh_val)) = 0;
thresh_struct.S((org_struct.int < thresh_val)) = 0;
end