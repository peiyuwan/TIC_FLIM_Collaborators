% Phasor Map Free Precentage
% Peiyu Wang
% 02/17/2021

%% Do a histogram map, and represent the whole idea. 
%% 
map_res = 512; 
NADH_free_LT = 0.4; % Set the designed Lifetime here. 
tao = zeros(1,2);f = 80e6;omega = 2*f*pi;

G_free_LT = 1/(1+(omega*NADH_free_LT/1e9)^2);
S_free_LT = sqrt(0.25-(G_free_LT-0.5).^2);

LT_lower_bound = 1.5; G_lower_bound = 1/(1+(omega*LT_lower_bound/1e9)^2);
LT_upper_bound = 5.8; G_upper_bound = 1/(1+(omega*LT_upper_bound/1e9)^2);


X = [0:0.002:1];
uni_y1 = sqrt(0.25-(X-0.5).^2);

precentage_map = zeros(map_res,map_res);
for i = 1 : map_res/2
    for j = map_res/2 : map_res
        G_current = -1 + j/map_res*2; S_current = 1 - i/map_res*2;
        
        k = (S_current - S_free_LT)/(G_current - G_free_LT);
        b = (G_current*S_free_LT - G_free_LT*S_current)/(G_current - G_free_LT);
        c = sqrt(-4*b^2 - 4 * k *b + 1);
        
        if  c > 0
            G_int = (1 - 2*k*b - c)/(2*k^2 + 2);
            if (G_int <G_lower_bound) & (G_int > G_upper_bound) & (G_current > G_int)...
                    & (G_current < G_free_LT) & (b > 0) 
                Free = (G_int - G_current)/ (G_int - G_free_LT);
                precentage_map(i,j) = Free;
            end
        end
    end
end

figure;
imagesc(precentage_map); axis image; colorbar; caxis([0 1]);
axis([map_res/2 map_res  map_res/5  map_res/2])
%%

%%  
org_ref = filtered_struct{1};

phasor_his = zeros(map_res,map_res);

for i = 1:size(org_ref.int,1)
    for j = 1:size(org_ref.int,2)
        G_index = floor((org_ref.G(i,j)-1.526e-05)*map_res/2+map_res/2+1); %function floor is doing the binning for you. 
        S_index = floor((org_ref.S(i,j)-1.526e-05)*map_res/2+map_res/2+1);
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
phasor_his = flip(phasor_his);
figure
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

%%
figure;
subplot(1,2,1); imagesc(precentage_map); axis image; colorbar; caxis([0 1])
ax = gca; ax.Colormap(1,:) = [0,0,0];

subplot(1,2,2); imagesc(phasor_his);colormap(gca,jet); axis image;
ax = gca; ax.Colormap(1,:)= [1 1 1]; caxis('auto');

phasor_his(precentage_map ==0) = 0;
phasor_total = sum(phasor_his(:));

phasor_average = sum(phasor_his(:).*precentage_map(:))/phasor_total;


precentage_values = unique(precentage_map);
precentage_histogram = zeros(1,numel(precentage_values));
for i = 2 : numel(precentage_values)
    index = find(precentage_map == precentage_values(i));
    precentage_histogram(i) = sum(phasor_his(index))/phasor_total;
end

figure;
bar(precentage_values,precentage_histogram,'hist');

div_interval = 250;
precentage_histogram_short = zeros(div_interval,1);
precentage_values_short = [1/div_interval/2:1/div_interval:1-1/div_interval/2];
for i = 1:numel(precentage_values)
   index = floor(precentage_values(i)*div_interval)+1;
   precentage_histogram_short(index) = precentage_histogram_short(index)+precentage_histogram(i); 
end

figure;
 plot(precentage_values_short,precentage_histogram_short);
%%
