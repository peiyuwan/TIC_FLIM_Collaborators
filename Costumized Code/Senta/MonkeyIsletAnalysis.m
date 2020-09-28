%% Monkey Islet analysis
% 09/27/2020
% Peiyu Wang

% Please put the Functions folder in the same folder as this script
% Read in with mulitpage Tiff File in imagestack. Imagestack contains only
% G,S, different channels are stacked together.

close all; clear all;
%% Read in Data
%%
addpath("D:\Scotts Lab\FLIM\Leica SP8\Leica Program\Collaborations\Codes\TIC_FLIM_Collaborators\Functions");                              % Specify how many channels here

% Master Folder is the folder that you put the data folders in;
% Please don't put the script in the same folder, as the script creates a
% folder to save the images, which should be seperated.
% The images in here should only contain the imagestack that you
% pre-processed with ImageJ.
MasterFolder = "D:\Scotts Lab\FLIM\Leica SP8\Leica Program\Collaborations\For Senta\20200924\RawData";                % Specify the file name here
% channel_No is how many channel numbers you have in here.
channel_No = 2;

% cuurrent_folder contain  subfolders in which the image stacks are stored
current_folder = dir(MasterFolder);
current_folder = current_folder([current_folder.isdir]);
current_folder = current_folder(3:end);

%%
% FP_stats stores the G_cen, S_cen of each folder
FP_stats = zeros(numel(current_folder),3,channel_No);
% D1: name of folder; D2: G,S; D3, channel number. 
% FP_stats_sub = zeros(numel(current_folder),numel(tif_files),3,channel_No);

FP_stats_sub = zeros(numel(current_folder),5,3,channel_No);
% D1: name of folder; D2: name of tif image; D3: G,S,number of pixels in folder; D4, channel number. 
class_name = [];
for i =1:numel(current_folder)
    splitStr = regexp(current_folder(i).name,'_','split');
    class_name = cat(1,class_name,string(splitStr{1}));
    tif_files = dir(fullfile(current_folder(i).folder,current_folder(i).name,"*.tif"));
    
    
    
    for j = 1:numel(tif_files)
        filename = fullfile(tif_files(j).folder,tif_files(j).name);
        
        for k = 1:channel_No
            mask = imread(filename,(k-1)*2+1);
            mask(mask~=0)=1;
            
            G = standardPhase(imread(filename,(k-1)*2+1));
            S = standardPhase(imread(filename,(k-1)*2+2));
            
            G_cen = findCenPhasor(G,mask);
            S_cen = findCenPhasor(S,mask);
            
            if G_cen<S_cen
               temp=G; G=S; S=temp;
               G_cen = findCenPhasor(G,mask);
               S_cen = findCenPhasor(S,mask);
            end
            
            FP_stats_sub(i,j,:,k)=[G_cen,S_cen,numel(find(mask))];
            
            figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            subplot(2,2,2);plotPhasorFast(G,S)
            
            
            
            
            
            
            
            
            
            sgtitle(tif_files(j).name);
        end
    end
    
    for k = 1:channel_No
        mask_sum = 0; G_sum = 0; S_sum = 0;
       for j = 1:numel(tif_files)
           mask_sum = mask_sum+FP_stats_sub(i,j,3,k);
           G_sum = G_sum+FP_stats_sub(i,j,1,k)*FP_stats_sub(i,j,3,k);
           S_sum = S_sum+FP_stats_sub(i,j,2,k)*FP_stats_sub(i,j,3,k);
       end
       FP_stats(i,1,k) = G_sum/mask_sum;
       FP_stats(i,2,k) = S_sum/mask_sum;
       FP_stats(i,3,k) = mask_sum;
    end
end
%% Creating the plotted figure. 
figure;
subplot(2,1,1);plotUnitCircle;hold on;
for i = 1:numel(current_folder)
plot(FP_stats(i,1,1),FP_stats(i,2,1),'+','MarkerSize',10,'Linewidth',2)
end
title(["Channel 1"]);axis([0.4 0.6 0.28 0.35]);legend(class_name)

subplot(2,1,2);plotUnitCircle;hold on;
for i = 1:numel(current_folder)
plot(FP_stats(i,1,2),FP_stats(i,2,2),'+','MarkerSize',10,'Linewidth',2)
end
title(["Channel 2"]);axis([0.4 0.6 0.28 0.35]);legend(class_name)



%% Whole Stack Analysis: Catalizing the z axis Visuallzing the Data plot


%% Functions:

%% standardPhase: convert 32bit G and S to standard Phase.
% Somehow, the images are stored in a wired format.
function sta_phase = standardPhase(org_phase);
P = [1/2^23,-1];
sta_phase = double(org_phase)*P(1)+P(2);
end

%% Function: Finding the center plot of the phaosrs
function phase_cen = findCenPhasor(org_phase,mask)
phase_cen = mean(org_phase(mask~=0));
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





