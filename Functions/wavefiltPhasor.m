%% Wavelet Filtering of the structure. 
function filt_struct = wavefiltPhasor(org_struct)
filt_G = wdenoise2(org_struct.G);
filt_S = wdenoise2(org_struct.S);

filt_struct = struct('int',org_struct.int,'G',filt_G,'S',filt_S);
end 