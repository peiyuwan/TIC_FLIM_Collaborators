%% Function lsmToStruct
% Peiyu Wang
% 08/03/2020

% Converts an Zeiss lsm file to struct with int, G and S. 
% input: lsm_file: the lsm_file after read in
% output: ref_struct


function ref_struct = lsmToStruct(lsm_file)
ch_num = size(lsm_file,3);
omega = 2*pi/ch_num;
harmonic = 2; 
lambda = [1:ch_num];

G_nom = zeros(size(lsm_file,1),size(lsm_file,2));
S_nom = zeros(size(lsm_file,1),size(lsm_file,2));
denom = zeros(size(lsm_file,1),size(lsm_file,2));


for k = 1:size(lsm_file,3)
    current_img = lsm_file(:,:,k);
    G_nom = G_nom + double(current_img).*cos(harmonic*omega*lambda(k));
    S_nom = S_nom + double(current_img).*sin(harmonic*omega*lambda(k));
    denom = denom+double(current_img);
end
G_map = G_nom./denom;
S_map = S_nom./denom;

G_map(isnan(G_map)) = 0;
S_map(isnan(S_map)) = 0;

ref_struct = struct('int',denom,'G',G_map,'S',S_map);
end