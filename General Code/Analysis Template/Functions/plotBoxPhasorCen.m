%% Function: plotPhasorCenter Box
% Peiyu Wang
% 1/6/2020

% Plotting the phasor center and the 25th and 75th precentile;

function plotBoxPhasorCen(org_ref)

G_cen_org = mean(org_ref.G(abs(org_ref.G)>=1.53e-05));
S_cen_org = mean(org_ref.S(abs(org_ref.S)>=1.53e-05));

G_precentile_org = quantile(org_ref.G(org_ref.G>1.53e-5),3);
G_25_org = G_precentile_org(1);
G_75_org = G_precentile_org(3);


S_precentile_org = quantile(org_ref.S(org_ref.S>1.53e-5),3);
S_25_org = S_precentile_org(1);
S_75_org = S_precentile_org(3);

errorbar(G_cen_org,S_cen_org,S_cen_org - S_25_org,S_cen_org - S_75_org, ...
    G_cen_org - G_25_org,G_cen_org - G_75_org,'o');

end