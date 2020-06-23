%% Basic_Analysis

% 10/21/2019
% Peiyu Wang

% Read in with mulitpage Tiff File. Assuming having int, G,S 

close all;
clear all;
%% Read in Data
channel_No = 3;                              % Specify how many channels here
filename = "kshv_12H gs.tif";                % Specify the file name here

tiff_info = imfinfo(filename);
z_stacks = numel(tiff_info)/(channel_No * 3);

ref_stack = cell(z_stacks,channel_No);  % ref_stack is a cell structure that every z has a row, with channel information as columns. 

for z = 1:z_stacks
    
    for i = 1:channel_No
        int = imread(filename,(z-1)*9+(i-1)*3+1); 
        G = imread(filename,(z-1)*9+(i-1)*3+2);
        S = imread(filename,(z-1)*9+(i-1)*3+3);        
        current_ref = struct('int',int,'G', standardPhase(G), 'S', standardPhase(S));
        ref_stack{z,i} = current_ref;
    end   
end

% z = 1;                                  %% Change the number to the layer that you want to image;
% figure
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% imagesc(ref_stack{z,1}.int)
% axis image; colorbar; colormap jet;
% title(["Original NADH Image, Z = "+ num2str(z)])


%% Imaging all three channels 

% figure;
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% for z = 1:z_stacks
%     subplot(1,3,1)
%     imagesc(ref_stack{z,1}.int)
%     axis image; colorbar; colormap jet;
%     title(["Int Image, Z = " + num2str(z) + '/' +  num2str(z_stacks)])
%     
%     subplot(1,3,2)
%     imagesc(ref_stack{z,2}.int)
%     axis image; colorbar; colormap jet;
%     title(["Int Image, Z = " + num2str(z) + '/' +  num2str(z_stacks)])
%     
%     subplot(1,3,3)
%     imagesc(ref_stack{z,3}.int)
%     axis image; colorbar; colormap jet;
%     title(["Int Image, Z = " + num2str(z) + '/' +  num2str(z_stacks)])
%     
%     pause
% end



%% Whole Stack Analysis: Visuallzing the Data plot
analyzed_ch = 2;    %% Specify the channel you want to analyze

group_vector = cell(1,channel_No);

for j = 1:size(ref_stack,2) % js is the channel number;
    int = [];G = [];S = [];%
    for i = 1: size(ref_stack,1)  % i is the z number;
        int = cat(1,int,ref_stack{i,j}.int(:));
        G = cat(1,G,ref_stack{i,j}.G(:));
        S =  cat(1,S,ref_stack{i,j}.S(:));
    end
    current_ref = struct('int',int,'G', G,'S', S);
    group_vector{1,j} = current_ref;   
end

figure
subplot(1,2,1)
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
plotPhasorFast(group_vector{1,analyzed_ch});
title("Original Phasor Plot For the whole cluster")

%%Phsor Center Analysis
disp("For whole cluster: ")
[G_cen_org,S_cen_org] = findCenPhasor(group_vector{1,analyzed_ch})

G_precentile_org = quantile(group_vector{1,analyzed_ch}.G(group_vector{1,analyzed_ch}.G>1.53e-5),3);
G_25_org = G_precentile_org(1)
G_75_org = G_precentile_org(3)


S_precentile_org = quantile(group_vector{1,analyzed_ch}.S(group_vector{1,analyzed_ch}.S>1.53e-5),3);
S_25_org = S_precentile_org(1)
S_75_org = S_precentile_org(3)

subplot(1,2,2)
errorbar(G_cen_org,S_cen_org,S_cen_org - S_25_org,S_cen_org - S_75_org, ...
                G_cen_org - G_25_org,G_cen_org - G_75_org,'ro');
title("Whole Data Phasor Distribution Percentile")
hold on;
plotUnitCircle
%%Gausian Fitting: On the G axis

bin_vect = [1/512:1/512:1-1/512];
[org_counts,org_centers] = hist(group_vector{1,analyzed_ch}.G,bin_vect);
figure
subplot(1,2,1)
title('Bar Plot of G')
bar(org_centers(2:end),org_counts(2:end)); xlabel('G'); ylabel('Counts')

f_org = fit(org_centers(2:end)',org_counts(2:end)', 'gauss2')

cen_org1 = f_org.b1;%First Center of fit   
cen_org2 = f_org.b2;%Second Center of fit
subplot(1,2,2)
title('Gaussian Fitting of G, Please see command window for details')
plot(f_org,org_centers(2:end),org_counts(2:end));

%% Visualling single z stacks

% figure
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% for z = 1: z_stacks
%     subplot(2,2,1)
%     imagesc(ref_stack{z,analyzed_ch}.int)
%     axis image; colorbar; colormap jet;
%     title(["Int Image, Z = " + num2str(z) + '/' +  num2str(z_stacks)])
%     
%     subplot(2,2,2)
%     plotPhasorFast(ref_stack{z,analyzed_ch});
%     title("Phasor Plot")
%     
%     [G_cen_org,S_cen_org] = findCenPhasor(ref_stack{z,analyzed_ch});
%     
%     G_precentile_org = quantile(ref_stack{z,analyzed_ch}.G(ref_stack{z,analyzed_ch}.G>1.53e-5),3);
%     G_25_org = G_precentile_org(1);
%     G_75_org = G_precentile_org(3);
%     
%     
%     S_precentile_org = quantile(ref_stack{z,analyzed_ch}.S(ref_stack{z,analyzed_ch}.S>1.53e-5),3);
%     S_25_org = S_precentile_org(1);
%     S_75_org = S_precentile_org(3);
%     
%     subplot(2,2,3)
%     errorbar(G_cen_org,S_cen_org,S_cen_org - S_25_org,S_cen_org - S_75_org, ...
%         G_cen_org - G_25_org,G_cen_org - G_75_org,'ro');
%     title("Whole Data Phasor Distribution Percentile")
%     hold on
%     plotUnitCircle
%     hold off
%      
%     [org_counts,org_centers] = hist(ref_stack{z,analyzed_ch}.G(:),bin_vect);
%     subplot(2,4,7)
%     title('Bar Plot of G')
%     bar(org_centers(2:end),org_counts(2:end));xlabel('G'); ylabel('Counts')
%     
%     f_org = fit(org_centers(2:end)',org_counts(2:end)', 'gauss2')
%     
%     cen_org1 = f_org.b1;%First Center of fit
%     cen_org2 = f_org.b2;%Second Center of fit
%     subplot(2,4,8)
%     title('Gaussian Fitting of G, Please see command window for details')
%     plot(f_org,org_centers(2:end),org_counts(2:end));
%     
%     pause
% end

%% Analysis on the z_stacks selected. 
z_start = input("Please input the starting z: ");
z_end = input("Please input the ending z: ");

group_vector = cell(1,channel_No);

for j = 1:size(ref_stack,2) % js is the channel number;
    int = [];G = [];S = [];%
    for i = z_start: z_end  % i is the z number;
        int = cat(1,int,ref_stack{i,j}.int(:));
        G = cat(1,G,ref_stack{i,j}.G(:));
        S =  cat(1,S,ref_stack{i,j}.S(:));
    end
    current_ref = struct('int',int,'G', G,'S', S);
    group_vector{1,j} = current_ref;   
end

figure
subplot(1,2,1)
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
plotPhasorFast(group_vector{1,analyzed_ch});
title(["Original Phasor Plot For z: " + num2str(z_start) + ' to ' + num2str(z_end)])

%%
disp(["For selected z stacks: z = " + num2str(z_start) + ' to ' + num2str(z_end)])
[G_cen_org,S_cen_org] = findCenPhasor(group_vector{1,analyzed_ch})

G_precentile_org = quantile(group_vector{1,analyzed_ch}.G(group_vector{1,analyzed_ch}.G>1.53e-5),3);
G_25_org = G_precentile_org(1)
G_75_org = G_precentile_org(3)

S_precentile_org = quantile(group_vector{1,analyzed_ch}.S(group_vector{1,analyzed_ch}.S>1.53e-5),3);
S_25_org = S_precentile_org(1)
S_75_org = S_precentile_org(3)

subplot(1,2,2)
errorbar(G_cen_org,S_cen_org,S_cen_org - S_25_org,S_cen_org - S_75_org, ...
                G_cen_org - G_25_org,G_cen_org - G_75_org,'ro');
title(["Phasor Precentile For z: " + num2str(z_start) + ' to '+  num2str(z_end)])
hold on;
plotUnitCircle

%%Gausian Fitting: On the G axis
bin_vect = [1/512:1/512:1-1/512];
[org_counts,org_centers] = hist(group_vector{1,analyzed_ch}.G,bin_vect);
figure
subplot(1,2,1)
title('Bar Plot of G')
bar(org_centers(2:end),org_counts(2:end));xlabel('G'); ylabel('Counts')

G_f_org = fit(org_centers(2:end)',org_counts(2:end)', 'gauss2')

G_cen_org1 = G_f_org.b1;%First Center of fit   
G_cen_org2 = G_f_org.b2;%Second Center of fit
subplot(1,2,2)
title(["Gaussian Fitting for z: " + num2str(z_start) + ' to ' +  num2str(z_end)])
plot(f_org,org_centers(2:end),org_counts(2:end));


%% For plotting the two term gaussian fit clustors. 






%% Functions:

%% Function: Plot Phasor Map, First Harmonic.
%Peiyu Wang
% 03/20/2019

function plotPhasorFast(org_ref)

map_res = 1024; 
phasor_his = zeros(map_res,map_res);

for i = 1:size(org_ref.int,1)
    for j = 1:size(org_ref.int,2)
        G_index = floor((org_ref.G(i,j)-1.526e-05)*map_res/2+map_res/2+1); %function floor is doing the binning for you. 
        S_index = floor((org_ref.S(i,j)-1.526e-05)*map_res/2+map_res/2+1);
        if G_index < 1; G_index = 1; end
        if S_index < 1; S_index = 1; end
        if G_index > map_res; G_index = map_res; end
        if S_index > map_res; S_index = map_res; end
        
        phasor_his(S_index,G_index) = phasor_his(S_index,G_index)+1;
    end
end

% because the pixel value at (0,0) is too high, we change that to 0;
[max_val,max_Idx] = max(phasor_his(:));
phasor_his(max_Idx) = 0;
phasor_his = flip(phasor_his);
imagesc(phasor_his); 
colormap jet;
colorbar; axis image; caxis([0 max(phasor_his(:))])


x_circle     = [map_res/2:map_res];
y_circle_pos = map_res/2-floor(sqrt((map_res/4)^2-((x_circle-map_res/2)-map_res/4).^2));
y_circle_neg = map_res/2+floor(sqrt((map_res/4)^2-((x_circle-map_res/2)-map_res/4).^2));
hold on; plot(x_circle,[y_circle_pos;y_circle_neg],'k','LineWidth',1)
axis([map_res/2 map_res  map_res/5  map_res/2])
d
xticks([map_res/2:map_res/2^4:map_res]);
xticklabels({'0','0.125','0.25','0.375','0.5','0.625','0.75','0.875','1'});

yticks([0:map_res/2^4:map_res/2]);
yticklabels({'1','0.875','0.75','0.625','0.5','0.375','0.25','0.125','0'});
end


%% Function: Surfing the histogram: 

function plotPhasorSurf(org_ref)

map_res = 1024; 
phasor_his = zeros(map_res,map_res);

for i = 1:size(org_ref.int,1)
    for j = 1:size(org_ref.int,2)
        G_index = floor((org_ref.G(i,j)-1.526e-05)*map_res/2+map_res/2+1); %function floor is doing the binning for you. 
        S_index = floor((org_ref.S(i,j)-1.526e-05)*map_res/2+map_res/2+1);
        if G_index < 1; G_index = 1; end
        if S_index < 1; S_index = 1; end
        if G_index > map_res; G_index = map_res; end
        if S_index > map_res; S_index = map_res; end
        
        phasor_his(S_index,G_index) = phasor_his(S_index,G_index)+1;
    end
end

% because the pixel value at (0,0) is too high, we change that to 0;
[max_val,max_Idx] = max(phasor_his(:));
phasor_his(max_Idx) = 0;
phasor_his = flip(phasor_his);
surf(phasor_his); 
colormap jet;
colorbar; axis image; caxis([0 max(phasor_his(:))])


x_circle     = [map_res/2:map_res];
y_circle_pos = map_res/2-floor(sqrt((map_res/4)^2-((x_circle-map_res/2)-map_res/4).^2));
y_circle_neg = map_res/2+floor(sqrt((map_res/4)^2-((x_circle-map_res/2)-map_res/4).^2));
hold on; plot(x_circle,[y_circle_pos;y_circle_neg],'k','LineWidth',1)
axis([map_res/2 map_res  map_res/5  map_res/2])

xticks([map_res/2:map_res/2^4:map_res]);
xticklabels({'0','0.125','0.25','0.375','0.5','0.625','0.75','0.875','1'});

yticks([0:map_res/2^4:map_res/2]);
yticklabels({'1','0.875','0.75','0.625','0.5','0.375','0.25','0.125','0'});
end


%% Function: Finding the center plot of the phaosrs

function [G_cen, S_cen] = findCenPhasor(org_ref)
G_cen = mean(org_ref.G( org_ref.G >= 1.53e-04));
S_cen = mean(org_ref.S( org_ref.S >= 1.53e-04));
end

%% Functions
function sta_phase = standardPhase(org_phase)
%G and S vales were scaled from -1 ~ +1 to 0 ~ (2^16-1), 32767.5 is 0;
sta_phase = (double(org_phase)-32767.5)/32767.5;
end

%% Function: Plot Unit Circle

function plotUnitCircle
uni_x = [0:1/255:1];
uni_y1 = sqrt(0.25-(uni_x-0.5).^2);
uni_y2 = -uni_y1;
plot(uni_x,uni_y1,'k',uni_x,uni_y2,'k','HandleVisibility','off');
axis image
axis([0 1 0 0.7])
grid on
xlabel('G')
ylabel('S')
end





