function [values_short,histogram_short] = short_his(values,histogram,div_interval)

div_interval = 250;
histogram_short = zeros(div_interval,1);
values_short = [1/div_interval/2:1/div_interval:1-1/div_interval/2];
for i = 1:numel(values)
   index = floor(values(i)*div_interval)+1;
   histogram_short(index) = histogram_short(index)+histogram(i); 
end
end