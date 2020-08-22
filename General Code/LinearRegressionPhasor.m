%% Linear Regression for Phasor Plot
% 06/15/2020
% Peiyu Wang

% Code for Jason
% File format: Leica exported ImageJTiff for phasor.
% Mulitpage Tiff File collected with one detector, having int, G,S three channels for each z stack 
% Image Processing: 
%        Thresholding:  upper and lower bound
%        Filtering: Chose between median filter, nlm filter, wavelet filter
%        Regression of the phasor cluster to a line, that crosses 0.4;
%        Plotting the projection of all phasors to that line. 



close all; clear all;
addpath(fullfile(pwd,'Functions'))
%% Data Readin
channel_No = 1;                              % Specify how many channels here
filename = "TileScan4.tif";                % Specify the file name here

tiff_info = imfinfo(filename);
z_stacks = numel(tiff_info)/(channel_No * 3);

ref_stack = cell(z_stacks,channel_No);  % ref_stack is a cell structure that every z has a row, with channel information as columns. 

for z = 1:z_stacks
    
    for ch = 1:channel_No
        int = imread(filename,(z-1)*3*channel_No+(ch-1)*3+1); 
        G = imread(filename,(z-1)*channel_No+(ch-1)*3+2);
        S = imread(filename,(z-1)*channel_No+(ch-1)*3+3);        
        current_ref = struct('int',int,'G', standardPhase(G), 'S', standardPhase(S));
        ref_stack{z,ch} = current_ref;
    end   
end

%% Imaging a z slice of the data for preview. 
%% Change the number to the layer that you want to image;
current_z = 2;                            
figure
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,1); imagesc(ref_stack{current_z,1}.int); axis image; colorbar; colormap jet;title('Intensity')
subplot(2,2,2); plotPhasorFast(ref_stack{current_z,1}); caxis([0 30]);title('Phasor Plot')
subplot(2,2,3); imagesc(ref_stack{current_z,1}.G); axis image; colorbar; colormap jet; title('G');
subplot(2,2,4); imagesc(ref_stack{current_z,1}.S); axis image; colorbar; colormap jet; title('S');

sgtitle(["Original Image, Z = "+ num2str(current_z)])





%% Filtering the samples. 
disp("Doing Filtering for the phasors")
for z = 1: z_stacks
%    ref_stack{z,1} = medfiltPhasor(ref_stack{z,1});
   ref_stack{z,1} = medfiltPhasorFast(ref_stack{z,1});  % Fast median
%   ref_stack{z,1} = nlmfiltPhasor(ref_stack{z,1});  % Non local Mean
%   ref_stack{z,1} = wavefiltPhasor(ref_stack{z,1}); % wavelet Filter
end

%% Creating a upper and lower threshold for the image
figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

while 1
   up_thresh = input("Please input upper threshold: ");
   low_thresh = input("Please input lower threshold: ");
   current_struct = ref_stack{current_z,1};
   current_struct.int((current_struct.int < low_thresh) | (current_struct.int > up_thresh)) = 0;
   current_struct.G((current_struct.int < low_thresh) | (current_struct.int > up_thresh)) = 0;
   current_struct.S((current_struct.int < low_thresh) | (current_struct.int > up_thresh)) = 0;
   subplot(1,2,1); imagesc(current_struct.int); axis image; colorbar; colormap jet;
   subplot(1,2,2); plotPhasorFast(medfiltPhasorFast(current_struct));
   promptMessage = "Reselect Thresholds?";
   button = questdlg(promptMessage, 'Next?','Yes','No','Yes');
   if strcmp(button, 'No')
      break
   end 
end

%% Whole Stack Analysis: Visuallzing the Data plot
analyzed_ch = 1;    %% Specify the channel you want to analyze

group_vector = cell(1,channel_No);

for ch = 1:size(ref_stack,2) % js is the channel number;
    int = [];G = [];S = [];%
    for z = 1: size(ref_stack,1)  % i is the z number;
        int = cat(1,int,ref_stack{z,ch}.int(:));
        G = cat(1,G,ref_stack{z,ch}.G(:));
        S =  cat(1,S,ref_stack{z,ch}.S(:));
    end
    current_ref = struct('int',int,'G', G,'S', S);
    group_vector{1,ch} = current_ref;   
end

figure
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
plotPhasorFast(group_vector{1,analyzed_ch});caxis([0 10]);
title("Original Phasor Plot For the whole cluster")
%%

% For this data, there is a huge set of data where G is at -1; 
% We excluded all the pixels that have at least one of the G,S or intensity
% to be not over zero. 

group_struct = group_vector{1,1};
solid_int = group_struct.int((group_struct.int>0)&(group_struct.G>0)&(group_struct.S>0));
solid_G = group_struct.G((group_struct.int>0)&(group_struct.G>0)&(group_struct.S>0));
solid_S = group_struct.S((group_struct.int>0)&(group_struct.G>0)&(group_struct.S>0));
group_struct = struct('int',solid_int,'G',solid_G,'S',solid_S);

%% Ploting the data without a fixed point. 

P = polyfit(group_struct.G,group_struct.S,1);  % P is the linear fit for the the given values.
X = [0:0.002:1];
Y = P(2)+P(1)*X;

figure;
plotUnitCircle;
hold on;
f = polyval(P,group_struct.G(group_struct.int>0));
plot(X,Y,'r-')
legend('linear fit')
title('Linear Fit without fixed point')

%% Calculating the lifetime of the intersections. 
uni_y1 = sqrt(0.25-(X-0.5).^2);
plot(X,uni_y1,'r')
[G_inter,S_inter] = intersections(X,Y,X,uni_y1,0);
[G_inter,S_order] = sort(G_inter);
S_inter = S_inter(S_order);
plot(G_inter,S_inter,'ro')

tao = zeros(1,2);

f = 80e6;
omega = 2*f*pi;

tao(2) = 1e9/omega*sqrt((1-G_inter(1))/G_inter(1)); 
tao(1) = 1e9/omega*sqrt((1-G_inter(2))/G_inter(2));
% 
%% Linear regression over a certain Lifetime. 

NADH_free_LT = 0.4; % Set the designed Lifetime here. 

G_free_LT = 1/(1+(omega*NADH_free_LT/1e9)^2);
S_free_LT = sqrt(0.25-(G_free_LT-0.5).^2);
plot(G_free_LT,S_free_LT,'bx','markersize',10);

G_new = group_struct.G - G_free_LT;
S_New = group_struct.S - S_free_LT;

b1 = G_new\S_New;
b0 = S_free_LT- b1*G_free_LT;

figure; plotUnitCircle; hold on;
P1 = [b1,b0];
f = polyval(P1,group_struct.G);
Y1 = P1(2)+P1(1)*X;
plot(X,Y1,'b-')
legend('linear fit through fixed point')

[G1_inter,S1_inter] = intersections(X,Y1,X,uni_y1,0);

[G1_inter,S1_order] = sort(G1_inter);  % Sorting in accending order First G is waht we want
S1_inter = S1_inter(S_order);
plot(G1_inter(1),S1_inter(1),'bo')

tao1 = zeros(1,2);

tao1(2) = 1e9/omega*sqrt((1-G1_inter(1))/G1_inter(1)); 
tao1(1) = 1e9/omega*sqrt((1-G1_inter(2))/G1_inter(2));
title(["Intersection Lifetime: " + num2str(tao(1)) + ' , ' + num2str(tao(2)), ...
    " Fixed Intersection Lifetime: " + num2str(tao1(1)) + ' , ' + num2str(tao1(2))])

%%
P1_pro = -1/P1(1);  %To calculate the vertical intersection, the negetive inverse as a slope

G1_pro = (group_struct.S + 1/P1(1) * group_struct.G - P1(2))/(P1(1)+ 1/P1(1)); %The G values of the intersection
S1_pro = polyval(P1,G1_pro);

plot(G1_pro,S1_pro,'x');

Free_portion_1 = (G1_pro-G1_inter(1))/(G1_inter(2)-G1_inter(1));

figure
histogram(Free_portion_1);
%% N: The histogram counts of the pixels projected onto the regression
edges_vect = [0:0.01:1];
N= histcounts(Free_portion_1,edges_vect);
%%
% 
% %%Phsor Center Analysis
% disp("For whole cluster: ")
% [G_cen_org,S_cen_org] = findCenPhasor(group_vector{1,analyzed_ch})
% 
% G_precentile_org = quantile(group_vector{1,analyzed_ch}.G(group_vector{1,analyzed_ch}.G>1.53e-5),3);
% G_25_org = G_precentile_org(1)
% G_75_org = G_precentile_org(3)
% 
% 
% S_precentile_org = quantile(group_vector{1,analyzed_ch}.S(group_vector{1,analyzed_ch}.S>1.53e-5),3);
% S_25_org = S_precentile_org(1)
% S_75_org = S_precentile_org(3)
% 
% subplot(1,2,2)
% errorbar(G_cen_org,S_cen_org,S_cen_org - S_25_org,S_cen_org - S_75_org, ...
%                 G_cen_org - G_25_org,G_cen_org - G_75_org,'ro');
% title("Whole Data Phasor Distribution Percentile")
% hold on;
% plotUnitCircle
% %%Gausian Fitting: On the G axis
% 
% bin_vect = [1/512:1/512:1-1/512];
% [org_counts,org_centers] = hist(group_vector{1,analyzed_ch}.G,bin_vect);
% figure
% subplot(1,2,1)
% title('Bar Plot of G')
% bar(org_centers(2:end),org_counts(2:end)); xlabel('G'); ylabel('Counts')
% 
% f_org = fit(org_centers(2:end)',org_counts(2:end)', 'gauss2')
% 
% cen_org1 = f_org.b1;%First Center of fit   
% cen_org2 = f_org.b2;%Second Center of fit
% subplot(1,2,2)
% title('Gaussian Fitting of G, Please see command window for details')
% plot(f_org,org_centers(2:end),org_counts(2:end));
% 
% %% Visualling single z stacks
% 
% %% Analysis on the z_stacks selected. 
% z_start = input("Please input the starting z: ");
% z_end = input("Please input the ending z: ");
% 
% group_vector = cell(1,channel_No);
% 
% for j = 1:size(ref_stack,2) % js is the channel number;
%     int = [];G = [];S = [];%
%     for i = z_start: z_end  % i is the z number;
%         int = cat(1,int,ref_stack{i,j}.int(:));
%         G = cat(1,G,ref_stack{i,j}.G(:));
%         S =  cat(1,S,ref_stack{i,j}.S(:));
%     end
%     current_ref = struct('int',int,'G', G,'S', S);
%     group_vector{1,j} = current_ref;   
% end
% 
% figure
% subplot(1,2,1)
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% plotPhasorFast(group_vector{1,analyzed_ch});
% title(["Original Phasor Plot For z: " + num2str(z_start) + ' to ' + num2str(z_end)])
% 
% %%
% disp(["For selected z stacks: z = " + num2str(z_start) + ' to ' + num2str(z_end)])
% [G_cen_org,S_cen_org] = findCenPhasor(group_vector{1,analyzed_ch})
% 
% G_precentile_org = quantile(group_vector{1,analyzed_ch}.G(group_vector{1,analyzed_ch}.G>1.53e-5),3);
% G_25_org = G_precentile_org(1)
% G_75_org = G_precentile_org(3)
% 
% S_precentile_org = quantile(group_vector{1,analyzed_ch}.S(group_vector{1,analyzed_ch}.S>1.53e-5),3);
% S_25_org = S_precentile_org(1)
% S_75_org = S_precentile_org(3)
% 
% subplot(1,2,2)
% errorbar(G_cen_org,S_cen_org,S_cen_org - S_25_org,S_cen_org - S_75_org, ...
%                 G_cen_org - G_25_org,G_cen_org - G_75_org,'ro');
% title(["Phasor Precentile For z: " + num2str(z_start) + ' to '+  num2str(z_end)])
% hold on;
% plotUnitCircle
% 
% %%Gausian Fitting: On the G axis
% bin_vect = [1/512:1/512:1-1/512];
% [org_counts,org_centers] = hist(group_vector{1,analyzed_ch}.G,bin_vect);
% figure
% subplot(1,2,1)
% title('Bar Plot of G')
% bar(org_centers(2:end),org_counts(2:end));xlabel('G'); ylabel('Counts')
% 
% G_f_org = fit(org_centers(2:end)',org_counts(2:end)', 'gauss2')
% 
% G_cen_org1 = G_f_org.b1;%First Center of fit   
% G_cen_org2 = G_f_org.b2;%Second Center of fit
% subplot(1,2,2)
% title(["Gaussian Fitting for z: " + num2str(z_start) + ' to ' +  num2str(z_end)])
% plot(f_org,org_centers(2:end),org_counts(2:end));


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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function 

function [x0,y0,iout,jout] = intersections(x1,y1,x2,y2,robust)
%INTERSECTIONS Intersections of curves.
%   Computes the (x,y) locations where two curves intersect.  The curves
%   can be broken with NaNs or have vertical segments.
%
% Example:
%   [X0,Y0] = intersections(X1,Y1,X2,Y2,ROBUST);
%
% where X1 and Y1 are equal-length vectors of at least two points and
% represent curve 1.  Similarly, X2 and Y2 represent curve 2.
% X0 and Y0 are column vectors containing the points at which the two
% curves intersect.
%
% ROBUST (optional) set to 1 or true means to use a slight variation of the
% algorithm that might return duplicates of some intersection points, and
% then remove those duplicates.  The default is true, but since the
% algorithm is slightly slower you can set it to false if you know that
% your curves don't intersect at any segment boundaries.  Also, the robust
% version properly handles parallel and overlapping segments.
%
% The algorithm can return two additional vectors that indicate which
% segment pairs contain intersections and where they are:
%
%   [X0,Y0,I,J] = intersections(X1,Y1,X2,Y2,ROBUST);
%
% For each element of the vector I, I(k) = (segment number of (X1,Y1)) +
% (how far along this segment the intersection is).  For example, if I(k) =
% 45.25 then the intersection lies a quarter of the way between the line
% segment connecting (X1(45),Y1(45)) and (X1(46),Y1(46)).  Similarly for
% the vector J and the segments in (X2,Y2).
%
% You can also get intersections of a curve with itself.  Simply pass in
% only one curve, i.e.,
%
%   [X0,Y0] = intersections(X1,Y1,ROBUST);
%
% where, as before, ROBUST is optional.

% Version: 2.0, 25 May 2017
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})


% Theory of operation:
%
% Given two line segments, L1 and L2,
%
%   L1 endpoints:  (x1(1),y1(1)) and (x1(2),y1(2))
%   L2 endpoints:  (x2(1),y2(1)) and (x2(2),y2(2))
%
% we can write four equations with four unknowns and then solve them.  The
% four unknowns are t1, t2, x0 and y0, where (x0,y0) is the intersection of
% L1 and L2, t1 is the distance from the starting point of L1 to the
% intersection relative to the length of L1 and t2 is the distance from the
% starting point of L2 to the intersection relative to the length of L2.
%
% So, the four equations are
%
%    (x1(2) - x1(1))*t1 = x0 - x1(1)
%    (x2(2) - x2(1))*t2 = x0 - x2(1)
%    (y1(2) - y1(1))*t1 = y0 - y1(1)
%    (y2(2) - y2(1))*t2 = y0 - y2(1)
%
% Rearranging and writing in matrix form,
%
%  [x1(2)-x1(1)       0       -1   0;      [t1;      [-x1(1);
%        0       x2(2)-x2(1)  -1   0;   *   t2;   =   -x2(1);
%   y1(2)-y1(1)       0        0  -1;       x0;       -y1(1);
%        0       y2(2)-y2(1)   0  -1]       y0]       -y2(1)]
%
% Let's call that A*T = B.  We can solve for T with T = A\B.
%
% Once we have our solution we just have to look at t1 and t2 to determine
% whether L1 and L2 intersect.  If 0 <= t1 < 1 and 0 <= t2 < 1 then the two
% line segments cross and we can include (x0,y0) in the output.
%
% In principle, we have to perform this computation on every pair of line
% segments in the input data.  This can be quite a large number of pairs so
% we will reduce it by doing a simple preliminary check to eliminate line
% segment pairs that could not possibly cross.  The check is to look at the
% smallest enclosing rectangles (with sides parallel to the axes) for each
% line segment pair and see if they overlap.  If they do then we have to
% compute t1 and t2 (via the A\B computation) to see if the line segments
% cross, but if they don't then the line segments cannot cross.  In a
% typical application, this technique will eliminate most of the potential
% line segment pairs.


% Input checks.
if verLessThan('matlab','7.13')
	error(nargchk(2,5,nargin)) %#ok<NCHKN>
else
	narginchk(2,5)
end

% Adjustments based on number of arguments.
switch nargin
	case 2
		robust = true;
		x2 = x1;
		y2 = y1;
		self_intersect = true;
	case 3
		robust = x2;
		x2 = x1;
		y2 = y1;
		self_intersect = true;
	case 4
		robust = true;
		self_intersect = false;
	case 5
		self_intersect = false;
end

% x1 and y1 must be vectors with same number of points (at least 2).
if sum(size(x1) > 1) ~= 1 || sum(size(y1) > 1) ~= 1 || ...
		length(x1) ~= length(y1)
	error('X1 and Y1 must be equal-length vectors of at least 2 points.')
end
% x2 and y2 must be vectors with same number of points (at least 2).
if sum(size(x2) > 1) ~= 1 || sum(size(y2) > 1) ~= 1 || ...
		length(x2) ~= length(y2)
	error('X2 and Y2 must be equal-length vectors of at least 2 points.')
end


% Force all inputs to be column vectors.
x1 = x1(:);
y1 = y1(:);
x2 = x2(:);
y2 = y2(:);

% Compute number of line segments in each curve and some differences we'll
% need later.
n1 = length(x1) - 1;
n2 = length(x2) - 1;
xy1 = [x1 y1];
xy2 = [x2 y2];
dxy1 = diff(xy1);
dxy2 = diff(xy2);


% Determine the combinations of i and j where the rectangle enclosing the
% i'th line segment of curve 1 overlaps with the rectangle enclosing the
% j'th line segment of curve 2.

% Original method that works in old MATLAB versions, but is slower than
% using binary singleton expansion (explicit or implicit).
% [i,j] = find( ...
% 	repmat(mvmin(x1),1,n2) <= repmat(mvmax(x2).',n1,1) & ...
% 	repmat(mvmax(x1),1,n2) >= repmat(mvmin(x2).',n1,1) & ...
% 	repmat(mvmin(y1),1,n2) <= repmat(mvmax(y2).',n1,1) & ...
% 	repmat(mvmax(y1),1,n2) >= repmat(mvmin(y2).',n1,1));

% Select an algorithm based on MATLAB version and number of line
% segments in each curve.  We want to avoid forming large matrices for
% large numbers of line segments.  If the matrices are not too large,
% choose the best method available for the MATLAB version.
if n1 > 1000 || n2 > 1000 || verLessThan('matlab','7.4')
	% Determine which curve has the most line segments.
	if n1 >= n2
		% Curve 1 has more segments, loop over segments of curve 2.
		ijc = cell(1,n2);
		min_x1 = mvmin(x1);
		max_x1 = mvmax(x1);
		min_y1 = mvmin(y1);
		max_y1 = mvmax(y1);
		for k = 1:n2
			k1 = k + 1;
			ijc{k} = find( ...
				min_x1 <= max(x2(k),x2(k1)) & max_x1 >= min(x2(k),x2(k1)) & ...
				min_y1 <= max(y2(k),y2(k1)) & max_y1 >= min(y2(k),y2(k1)));
			ijc{k}(:,2) = k;
		end
		ij = vertcat(ijc{:});
		i = ij(:,1);
		j = ij(:,2);
	else
		% Curve 2 has more segments, loop over segments of curve 1.
		ijc = cell(1,n1);
		min_x2 = mvmin(x2);
		max_x2 = mvmax(x2);
		min_y2 = mvmin(y2);
		max_y2 = mvmax(y2);
		for k = 1:n1
			k1 = k + 1;
			ijc{k}(:,2) = find( ...
				min_x2 <= max(x1(k),x1(k1)) & max_x2 >= min(x1(k),x1(k1)) & ...
				min_y2 <= max(y1(k),y1(k1)) & max_y2 >= min(y1(k),y1(k1)));
			ijc{k}(:,1) = k;
		end
		ij = vertcat(ijc{:});
		i = ij(:,1);
		j = ij(:,2);
	end
	
elseif verLessThan('matlab','9.1')
	% Use bsxfun.
	[i,j] = find( ...
		bsxfun(@le,mvmin(x1),mvmax(x2).') & ...
		bsxfun(@ge,mvmax(x1),mvmin(x2).') & ...
		bsxfun(@le,mvmin(y1),mvmax(y2).') & ...
		bsxfun(@ge,mvmax(y1),mvmin(y2).'));
	
else
	% Use implicit expansion.
	[i,j] = find( ...
		mvmin(x1) <= mvmax(x2).' & mvmax(x1) >= mvmin(x2).' & ...
		mvmin(y1) <= mvmax(y2).' & mvmax(y1) >= mvmin(y2).');
	
end


% Find segments pairs which have at least one vertex = NaN and remove them.
% This line is a fast way of finding such segment pairs.  We take
% advantage of the fact that NaNs propagate through calculations, in
% particular subtraction (in the calculation of dxy1 and dxy2, which we
% need anyway) and addition.
% At the same time we can remove redundant combinations of i and j in the
% case of finding intersections of a line with itself.
if self_intersect
	remove = isnan(sum(dxy1(i,:) + dxy2(j,:),2)) | j <= i + 1;
else
	remove = isnan(sum(dxy1(i,:) + dxy2(j,:),2));
end
i(remove) = [];
j(remove) = [];

% Initialize matrices.  We'll put the T's and B's in matrices and use them
% one column at a time.  AA is a 3-D extension of A where we'll use one
% plane at a time.
n = length(i);
T = zeros(4,n);
AA = zeros(4,4,n);
AA([1 2],3,:) = -1;
AA([3 4],4,:) = -1;
AA([1 3],1,:) = dxy1(i,:).';
AA([2 4],2,:) = dxy2(j,:).';
B = -[x1(i) x2(j) y1(i) y2(j)].';

% Loop through possibilities.  Trap singularity warning and then use
% lastwarn to see if that plane of AA is near singular.  Process any such
% segment pairs to determine if they are colinear (overlap) or merely
% parallel.  That test consists of checking to see if one of the endpoints
% of the curve 2 segment lies on the curve 1 segment.  This is done by
% checking the cross product
%
%   (x1(2),y1(2)) - (x1(1),y1(1)) x (x2(2),y2(2)) - (x1(1),y1(1)).
%
% If this is close to zero then the segments overlap.

% If the robust option is false then we assume no two segment pairs are
% parallel and just go ahead and do the computation.  If A is ever singular
% a warning will appear.  This is faster and obviously you should use it
% only when you know you will never have overlapping or parallel segment
% pairs.

if robust
	overlap = false(n,1);
	warning_state = warning('off','MATLAB:singularMatrix');
	% Use try-catch to guarantee original warning state is restored.
	try
		lastwarn('')
		for k = 1:n
			T(:,k) = AA(:,:,k)\B(:,k);
			[unused,last_warn] = lastwarn; %#ok<ASGLU>
			lastwarn('')
			if strcmp(last_warn,'MATLAB:singularMatrix')
				% Force in_range(k) to be false.
				T(1,k) = NaN;
				% Determine if these segments overlap or are just parallel.
				overlap(k) = rcond([dxy1(i(k),:);xy2(j(k),:) - xy1(i(k),:)]) < eps;
			end
		end
		warning(warning_state)
	catch err
		warning(warning_state)
		rethrow(err)
	end
	% Find where t1 and t2 are between 0 and 1 and return the corresponding
	% x0 and y0 values.
	in_range = (T(1,:) >= 0 & T(2,:) >= 0 & T(1,:) <= 1 & T(2,:) <= 1).';
	% For overlapping segment pairs the algorithm will return an
	% intersection point that is at the center of the overlapping region.
	if any(overlap)
		ia = i(overlap);
		ja = j(overlap);
		% set x0 and y0 to middle of overlapping region.
		T(3,overlap) = (max(min(x1(ia),x1(ia+1)),min(x2(ja),x2(ja+1))) + ...
			min(max(x1(ia),x1(ia+1)),max(x2(ja),x2(ja+1)))).'/2;
		T(4,overlap) = (max(min(y1(ia),y1(ia+1)),min(y2(ja),y2(ja+1))) + ...
			min(max(y1(ia),y1(ia+1)),max(y2(ja),y2(ja+1)))).'/2;
		selected = in_range | overlap;
	else
		selected = in_range;
	end
	xy0 = T(3:4,selected).';
	
	% Remove duplicate intersection points.
	[xy0,index] = unique(xy0,'rows');
	x0 = xy0(:,1);
	y0 = xy0(:,2);
	
	% Compute how far along each line segment the intersections are.
	if nargout > 2
		sel_index = find(selected);
		sel = sel_index(index);
		iout = i(sel) + T(1,sel).';
		jout = j(sel) + T(2,sel).';
	end
else % non-robust option
	for k = 1:n
		[L,U] = lu(AA(:,:,k));
		T(:,k) = U\(L\B(:,k));
	end
	
	% Find where t1 and t2 are between 0 and 1 and return the corresponding
	% x0 and y0 values.
	in_range = (T(1,:) >= 0 & T(2,:) >= 0 & T(1,:) < 1 & T(2,:) < 1).';
	x0 = T(3,in_range).';
	y0 = T(4,in_range).';
	
	% Compute how far along each line segment the intersections are.
	if nargout > 2
		iout = i(in_range) + T(1,in_range).';
		jout = j(in_range) + T(2,in_range).';
	end
end
end

% Plot the results (useful for debugging).
% plot(x1,y1,x2,y2,x0,y0,'ok');

function y = mvmin(x)
% Faster implementation of movmin(x,k) when k = 1.
y = min(x(1:end-1),x(2:end));
end

function y = mvmax(x)
% Faster implementation of movmax(x,k) when k = 1.
y = max(x(1:end-1),x(2:end));
end


