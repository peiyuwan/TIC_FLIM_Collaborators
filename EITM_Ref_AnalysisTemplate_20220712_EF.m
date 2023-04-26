%% EITM FLIM analysis for NAD(P)H, ref files aquired through VistaVision software
% 07/13/2022
% Original code provided by: Peiyu Wang (Fraser lab)
% Code customization by Mathias Bigger and Emma Fong
% For any troubleshooting questions, please contact Mathias (mbigger@eitm.org)

close all; clear all;
addpath("Functions")



% % Data folder name. 
prompt = {'Please enter the name of your data set:','Please enter the intensity threshold value:','Please enter the number of z stacks (1 for 2D images):'};
answer = inputdlg(prompt);
nameofdata = string(answer(1));
thresh_val=str2double(answer(2));
zStackAmount = str2double(answer(3));
ref_folder = fullfile(pwd,nameofdata);
cond_folder = dir(ref_folder);

save_fig_folder = fullfile(pwd, nameofdata+ "_Output");
if ~exist(save_fig_folder,'dir')
    mkdir(save_fig_folder)
end

%% Thresholding 
G_sum = [];
S_sum = [];
cond = [];
name = [];
figures = [];
figuresg = [];
cur_G_Average = zeros(256,256);
cur_Int_Average = zeros(256,256);
numel(cond_folder);
for i = zStackAmount:numel(cond_folder)  % Looping through condition. 
    disp(["Analysis beginning for " + string(cond_folder(i).name)]);
   ref_files = dir(fullfile(cond_folder(i).folder,cond_folder(i).name,"*.ref"));  % reads the ref file in the condition folder.
   if rem(numel(ref_files),zStackAmount) ~= 0
       remainders = zStackAmount - rem(numel(ref_files),zStackAmount);
       disp("You are missing a file or inputted the wrong number of z stacks. " + remainders + " files are missing." );
   end 
   for j = 1:numel(ref_files)/zStackAmount  % looping through z slices. 
      G = []; S = []; int = [];
      figures_folder = fullfile(nameofdata, cond_folder(i).name);
        if ~exist(figures_folder,'dir')
          mkdir(figures_folder) 
        end
       fig_folder = fullfile(save_fig_folder,cond_folder(i).name);
       if ~exist(fig_folder,'dir')
          mkdir(fig_folder) 
       end
       
       for z = 1:zStackAmount   %% Groups all the z stacks together. 
           [cur_int,cur_G,cur_S] = ref_read(fullfile(ref_files((j-1)*zStackAmount+z).folder,ref_files((j-1)*zStackAmount+z).name));
           figure;
            
           G = cat(2,G,cur_G(:));
           S = cat(2,S,cur_S(:));
           int = cat(2,int,cur_int(:));
          
           [cur_int,cur_G,cur_S] = ref_read(fullfile(ref_files((j-1)*zStackAmount+z).folder,ref_files((j-1)*zStackAmount+z).name));
           figure;

           for q = 1:256 % Removing background below thresh value
               for x = 1:256
                   if cur_int(q,x) < thresh_val 
                       cur_int(q,x) = 0;
                       cur_G(q,x) = 0;
                   end
                   cur_G_Average(q,x) = cur_G_Average(q,x) + cur_G(q,x);
                   cur_Int_Average(q,x) = cur_Int_Average(q,x) + cur_int(q,x);
               end
           end
           cur_int(cur_int<thresh_val) = 0;
            
            set(0,'DefaultFigureVisible','off');
            figures(z) = imagesc(cur_int); axis image; colormap(gca, jet); colorbar; axis image; title('Intensity'); set(gca,'XTick',[], 'YTick', []);
            saveas(figures(z), fullfile(fig_folder,[strcat("Intensity_Image_",string(j),"_ZStack_",string(z),".tif")]));
            mycolormap = customcolormap(linspace(0,1,14), {'#f01114','#ff36c9','#d336ff','#8336ff','#5260ff','#6aa3f7','#76c9f5','#76f1f5','#76f5d1','#76f59e','#b1ff85','#e7ffb0','#e7ffb0','#000000'});
            set(0,'DefaultFigureVisible','off');
            figuresg(z) = imagesc(cur_G); axis image; colormap(mycolormap); colorbar; caxis([0.35,0.8]); axis image; title('G'); set(gca,'XTick',[], 'YTick', []);
            saveas(figuresg(z), fullfile(fig_folder,[strcat("GCoordinate_Image_",string(j),"_ZStack_",string(z),".tif")]));
       end
       current_struct = struct('int',int,'G',G,'S',S);  % Struct: data structure to store the int, G, and S. 
                                                        % Basic input structure for all of my functions.
                                                     
       
       % Applying a threshold for the phasor plot: 
       current_struct = threshphasor(current_struct, thresh_val); 
        % Applying median filter for the phasor plot: 
       current_struct = medfiltPhasor(current_struct,3);

       [G1,S1] = findCenPhasor(current_struct);  % finding the mean of G and S. 
       fig_name = string(ref_files(j).name(1:end-4));
  
        cur_G_Average = cur_G_Average/zStackAmount;
        cur_Int_Average = cur_Int_Average/zStackAmount;
        set(0,'DefaultFigureVisible','off');
       figure; 
       % Custom colorbar for phasor plot and FLIM images
        mycolormap = customcolormap(linspace(0,1,14), {'#f01114','#ff36c9','#d336ff','#8336ff','#5260ff','#6aa3f7','#76c9f5','#76f1f5','#76f5d1','#76f59e','#b1ff85','#e7ffb0','#e7ffb0','#000000'});
       subplot(1,3,2); imagesc(cur_G_Average); colormap(mycolormap); colorbar; caxis([0.35,0.8]); axis image; title('G'); set(gca,'XTick',[], 'YTick', []);
       subplot(1,3,1); imagesc(cur_Int_Average); colormap(gca,jet); colorbar; axis image; title('Intensity'); set(gca,'XTick',[], 'YTick', []);
       subplot(1,3,3); plotPhasorFast(current_struct); title('Phasor Plot'); set(gca,'XTick',[0,0.5,1], 'YTick', [0,0.25,0.5])
       plotPhasorFast(current_struct);  
       G_sum = [G_sum;G1];
       S_sum = [S_sum;S1];
       cond = [cond;string(cond_folder(i).name)];
       name = [name;string(ref_files(j).name)];
       

       saveas(gcf,fullfile(fig_folder,[fig_name + ".tif"]))
       close all;  
       
       cur_G_Average = zeros(256,256);
       cur_Int_Average = zeros(256,256);
   end
   disp(["Analysis finished for " + string(cond_folder(i).name)]);
end

[Mode_LEXT,G_int,S_int,tao] = lineExtensionMetabolism(G_sum, S_sum);
Mode_LR = LinearRegression_Analysis(G_sum, S_sum);

%%
DataTable=table(cond,name,G_sum, S_sum, Mode_LEXT,G_int,S_int,tao,Mode_LR);
filefolder = fullfile(string(ref_folder) + '.xlsx');   % Name of the excel file. 
writetable(DataTable,filefolder,'Sheet',1)
movefile(filefolder, save_fig_folder)

disp(["All analysis finished for " + string(nameofdata)]);

%% Functions: 
function new_struct = threshphasor(org_struct, thresh)

new_struct = org_struct;
new_struct.G(new_struct.int<thresh) = 0;
new_struct.S(new_struct.int<thresh) = 0;
new_struct.int(new_struct.int<thresh) = 0;
end