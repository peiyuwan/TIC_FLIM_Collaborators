%% Median Filter test
% Peiyu Wang
% 04/20/2020

% for this median filter, I'm neglecting everything that has a zero value. 
% the edges are calculated by first doing an expansion with replicated
% edges, then calculation. 

function filt_struct = medfiltPhasor(org_struct, mask_size)

% org_struct: The original struct that needs to be filtered
% filt_struct: Filtered struct. 
% mask_size: How large the mask is. 
if nargin == 1
   mask_size = 3;  
end

edge = (mask_size-1)/2;

new_G = padarray(org_struct.G, [edge edge],'replicate','both');
new_S = padarray(org_struct.S, [edge edge],'replicate','both');
%%
filt_G = zeros(size(org_struct.G));
filt_S = zeros(size(org_struct.S));

for i = 1: size(org_struct.G,1)
    for j = 1: size(org_struct.G,2)
        if org_struct.G(i,j) ~= 0
            mask_G = new_G(i-edge+edge: i+edge+edge,j-edge+edge: j+edge+edge);
            value_G = median(mask_G(mask_G ~= 0),'omitnan');
            filt_G(i,j) = value_G;
        end
        
        if org_struct.S(i,j) ~= 0
            mask_S = new_S(i-edge+edge: i+edge+edge,j-edge+edge: j+edge+edge);
            value_S = median(mask_S(mask_S ~= 0),'omitnan');
            filt_S(i,j) = value_S;
        end
    end
end
filt_G(isnan(filt_G)) = 0; filt_S(isnan(filt_S)) = 0;
filt_struct = struct('int',org_struct.int,'G',filt_G,'S',filt_S);
