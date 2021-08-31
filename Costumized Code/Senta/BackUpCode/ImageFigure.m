%% Image Drawing 20210621 
% Peiyu Wang
% 2021/06/21

close all;
addpath("Functions");
%%
map_res = 1024; 
NADH_free_LT = 0.4; % Set the designed Lifetime here. 
f = 80e6;omega = 2*f*pi;

G_free_LT = 1/(1+(omega*NADH_free_LT/1e9)^2);
S_free_LT = sqrt(0.25-(G_free_LT-0.5).^2);

G_index_free = floor((G_free_LT-1.526e-05)*map_res/2+map_res/2+1); %function floor is doing the binning for you. 
S_index_free = map_res - floor((S_free_LT-1.526e-05)*map_res/2+map_res/2+1);




lifetimes = [1.24:0.02: 6];

G_LT = 1./(1+(omega.*lifetimes/1e9).^2);
S_LT = sqrt(0.25-(G_LT-0.5).^2);

G_index = floor((G_LT-1.526e-05)*map_res/2+map_res/2+1); %function floor is doing the binning for you. 
S_index = map_res - floor((S_LT-1.526e-05)*map_res/2+map_res/2+1);
%%




%%
% load("filtered_data_new.mat");
islet_name = "7344_5";
%%
name_idx = 0;
for i = 1:numel(condition)
    if strcmp(islet_name,islet_No(i))
        name_idx = i;
        break
    end
end

%%
current_struct = filtered_struct{name_idx};
figure;
plotPhasorFast(current_struct);
% set(gcf,"FontSize",21);
hold on; 
%%
plot(G_index_free,S_index_free,'bx','MarkerSize',15,'LineWidth',3)
plot(G_index,S_index,'r.','MarkerSize',20,'LineWidth',2)




