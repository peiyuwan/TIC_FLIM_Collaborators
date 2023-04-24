
function [Free_precentage,P,G1_pro,S1_pro] = LinearRegression_Analysis(G_sum,S_sum)
%% Linear Regression: with fixed point.
NADH_free_LT = 0.4; % Set the designed Lifetime here.
f = 80e6;omega = 2*f*pi;
G_free_LT = 1/(1+(omega*NADH_free_LT/1e9)^2);
S_free_LT = sqrt(0.25-(G_free_LT-0.5).^2);

plot(G_free_LT,S_free_LT,'bx','markersize',10,'HandleVisibility','off');

G_New = G_sum - G_free_LT;
S_New = S_sum - S_free_LT;

b1 = G_New\S_New;
b0 = S_free_LT- b1*G_free_LT;

P = [b1,b0];

c = sqrt(-4*P(2).^2 - 4 * P(1) .* P(2) + 1);
G_int = (1 - 2*P(1).*P(2) - c)./(2*P(1).^2 + 2);

%% Calculating the Free Portions
P1_pro = -1/P(1);  %To calculate the vertical intersection, the negetive inverse as a slope
G1_pro = (S_sum + 1/P(1) * G_sum - P(2))/(P(1)+ 1/P(1)); %The G values of the intersection
S1_pro = polyval(P,G1_pro); % The S values of the intersections
% plot(G1_pro,S1_pro,'x');
Free_precentage = (G_int - G1_pro)/(G_int - G_free_LT); % The portion of free calculated portion.

end

