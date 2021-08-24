function filt_struct = medfiltPhasorFast(org_struct,val)
filt_struct = org_struct;
filt_struct.G =medfilt2(filt_struct.G,[val val]);
filt_struct.S =medfilt2(filt_struct.S,[val val]);
end