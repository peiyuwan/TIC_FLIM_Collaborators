function filt_struct = medfiltPhasorFast(org_struct)
filt_struct = org_struct;
filt_struct.G =medfilt2(filt_struct.G);
filt_struct.S =medfilt2(filt_struct.S);
end