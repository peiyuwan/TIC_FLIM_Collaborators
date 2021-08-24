%% Function lineExtensionMetablism
% Peiyu Wang
% 02/17/2021

%% Extend from 0.4ns to the point, and connect to the circle, then calculate the precentage. 


function [Free_precentage,G_int,S_int,tao] = lineExtensionMetabolism(G,S)


NADH_free_LT = 0.4; % Set the designed Lifetime here. 
f = 80e6;omega = 2*f*pi;

G_free_LT = 1/(1+(omega*NADH_free_LT/1e9)^2);
S_free_LT = sqrt(0.25-(G_free_LT-0.5).^2);



k = (S - S_free_LT)./(G - G_free_LT);
b = (G*S_free_LT - G_free_LT*S)./(G - G_free_LT);
c = sqrt(-4*b.^2 - 4 * k .* b + 1);

G_int = (1 - 2*k.*b - c)./(2*k.^2 + 2);
S_int = sqrt(0.25-(G_int-0.5).^2);
tao = 1e9/omega*sqrt((1-G_int)./G_int);
Free_precentage = (G_int - G)./ (G_int - G_free_LT);

end