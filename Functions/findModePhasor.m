%% Function: Plot Intensity, First and Second Harmonic.
%Peiyu Wang
% 03/20/2019

function [G_mode,S_mode] = findModePhasor(org_ref)


map_res = 1024; 
phasor_his = zeros(map_res,map_res);

for i = 1:size(org_ref.int,1)
    for j = 1:size(org_ref.int,2)
        G_index = floor((org_ref.G(i,j)-1.526e-05)*map_res/2)+map_res/2+1; %function floor is doing the binning for you. 
        S_index = map_res/2 - floor((org_ref.S(i,j)-1.526e-05)*map_res/2);
        if G_index < 1; G_index = 1; end
        if S_index < 1; S_index = 1; end
        if G_index > map_res; G_index = map_res; end
        if S_index > map_res; S_index = map_res; end
        if G_index && S_index; phasor_his(S_index,G_index) = phasor_his(S_index,G_index)+1;end
    end
end

% because the pixel value at (0,0) is too high, we change that to 0;
[max_val,max_Idx] = max(phasor_his(:));
phasor_his(max_Idx) = 0;


[phasor_his_sorted,phasor_his_index] = sort(phasor_his(:));

G_mode = 0;
S_mode = 0;
total_num = 0;
for i = 1:10
    G_cur_index = ceil(phasor_his_index(end-i+1)/map_res);
    S_cur_index = rem(phasor_his_index(end-i+1),map_res);
    G_mode = G_mode + phasor_his_sorted(end-i+1) * (-1+G_cur_index/map_res*2 - 1/map_res*2);
    S_mode = S_mode + phasor_his_sorted(end-i+1) * (1-S_cur_index/map_res*2);
    total_num = total_num + phasor_his_sorted(end-i+1);
end

G_mode = G_mode/total_num;
S_mode = S_mode/total_num;

end
