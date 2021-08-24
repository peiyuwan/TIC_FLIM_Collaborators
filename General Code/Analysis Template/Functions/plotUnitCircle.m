% Function Plot the Unit Circle on the current map.
% 03/31/2019
% Peiyu Wang

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