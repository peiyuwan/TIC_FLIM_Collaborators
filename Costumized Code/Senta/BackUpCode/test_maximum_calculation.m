%% 

close all
clear all
%%
load('test_struct.mat');

org_ref = test_struct;

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

[max_val,max_Idx] = max(phasor_his(:));


G_max_index = ceil(max_Idx/map_res);
S_max_index = rem(max_Idx,map_res);


imagesc(phasor_his)
colormap(gca,jet); ax = gca; ax.Colormap(1,:)= [1 1 1]; caxis('auto');
colorbar; axis image;

x_circle     = [map_res/2:map_res];
y_circle_pos = map_res/2-floor(sqrt((map_res/4)^2-((x_circle-map_res/2)-map_res/4).^2));
y_circle_neg = map_res/2+floor(sqrt((map_res/4)^2-((x_circle-map_res/2)-map_res/4).^2));
hold on; plot(x_circle,[y_circle_pos;y_circle_neg],'k','LineWidth',1)
axis([map_res/2 map_res  map_res/5  map_res/2])

xticks([map_res/2:map_res/2^4:map_res]);
xticklabels({'0','0.125','0.25','0.375','0.5','0.625','0.75','0.875','1'});

yticks([0:map_res/2^4:map_res/2]);
yticklabels({'1','0.875','0.75','0.625','0.5','0.375','0.25','0.125','0'});
xlabel('G');ylabel('S')


plot(G_max_index,S_max_index,'mx','MarkerSize',5,'Linewidth',3);

G_max_1 = -1+G_max_index/map_res*2 - 1/map_res*2;
S_max_1 = 1-S_max_index/map_res*2;


div_interval = 500;
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
G_max_2 = values(floor(mean(max_Idx)));

[max_val,max_Idx] = max(medfilt1(S_bin,5));
if numel(max_Idx)> 1; disp(["Number of Modes in S:" + num2str(numel(max_Idx))]); end
S_max_2 = values(floor(mean(max_Idx)));


%%

[phasor_his_sorted,phasor_his_index] = sort(phasor_his(:));

G_max_3 = 0;
S_max_3 = 0;
total_num = 0;
for i = 1:10
    G_cur_index = ceil(phasor_his_index(end-i+1)/map_res);
    S_cur_index = rem(phasor_his_index(end-i+1),map_res);
    G_max_3 = G_max_3 + phasor_his_sorted(end-i+1) * (-1+G_cur_index/map_res*2 - 1/map_res*2);
    S_max_3 = S_max_3 + phasor_his_sorted(end-i+1) * (1-S_cur_index/map_res*2);
    total_num = total_num + phasor_his_sorted(end-i+1);
end

G_max_3 = G_max_3/total_num;
S_max_3 = S_max_3/total_num;

G_index = floor((G_max_3-1.526e-05)*map_res/2)+map_res/2+1; %function floor is doing the binning for you. 
S_index = map_res/2 - floor((S_max_3-1.526e-05)*map_res/2);

plot(G_index,S_index,'cx','MarkerSize',5,'Linewidth',3);