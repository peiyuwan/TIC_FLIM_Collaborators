%read ref file from FLIM acquisition

%read lifetime ref file (from Christoph Gohlke)
%Five 256x256 float32 images are stored consecutively:
%    0) dc - intensity
%    1) ph1 - phase of 1st harmonic
%    2) md1 - modulation of 1st harmonic
%    3) ph2 - phase of 2nd harmonic
%    4) md2 - modulation of 2nd harmonic



function [ref_int, G, S, ref_ph1, ref_md1] = ref_read(ref_file)
f = fopen(ref_file);

ref_matrix = fread(f,'float32');
ref_matrix = reshape(ref_matrix,[256,256,5]);

ref_int = reshape(ref_matrix(:,:,1),[256,256]);
ref_ph1 = reshape(ref_matrix(:,:,2),[256,256]);
ref_md1 = reshape(ref_matrix(:,:,3),[256,256]);

%convert from degrees to radian
ref_ph1 = 0.0174532925*ref_ph1;

G = ref_md1.*cos(ref_ph1);
S = ref_md1.*sin(ref_ph1);


