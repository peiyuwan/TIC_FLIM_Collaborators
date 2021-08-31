%% Function: Plot Intensity, First and Second Harmonic.
%Peiyu Wang
% % 03/20/2019
% 
% function [G_mode,S_mode] = findModePhasor(org_ref)


div_interval = 1200;
G_bin = zeros(div_interval,1);
S_bin = zeros(div_interval,1);
values = [1/div_interval/2:1/div_interval:1-1/div_interval/2];

for i = 1:size(org_ref.int,1)
    for j = 1:size(org_ref.int,2)
        if (org_ref.G(i,j) > 0) & (org_ref.S(i,j) > 0)
            G_index = floor(org_ref.G(i,j)*div_interval); %function floor is doing the binning for you. 
            S_index = floor(org_ref.S(i,j)*div_interval);
            if (G_index ~= 0) & (S_index ~= 0)
                G_bin(G_index) = G_bin(G_index)+1;
                S_bin(S_index) = S_bin(S_index)+1;
            end
        end
        
    end
end

% because the pixel value at (0,0) is too high, we change that to 0;
[max_val,max_Idx] = max(medfilt1(G_bin,5));
if numel(max_Idx)> 1; disp(["Number of Modes in G:" + num2str(numel(max_Idx))]); end
G_mode = values(floor(mean(max_Idx)));

[max_val,max_Idx] = max(medfilt1(S_bin,5));
if numel(max_Idx)> 1; disp(["Number of Modes in S:" + num2str(numel(max_Idx))]); end
S_mode = values(floor(mean(max_Idx)));
% end
