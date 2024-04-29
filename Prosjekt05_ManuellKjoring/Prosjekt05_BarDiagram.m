clear; close all; clc


load("P05_MeasManuellKjoring_MF.mat")
subplot(2,2,1)
k = length(Lys);
middelverdi = mean(Lys(1:k-1));
standardavvik = std(Lys(1:k-1));
histogram(Lys(1:k-1),20)
title(['Mikal, mean =  ', num2str(middelverdi, 4),' std = ', num2str(standardavvik, 4)])
axis([0 70 0 25])
xline(middelverdi, 'Color', 'red', 'LineWidth', 2, 'Label', 'Middelverdi');
xline(middelverdi - standardavvik, 'Color', 'green', 'LineWidth', 2, 'LineStyle', '--', 'Label', 'Middelverdi - Std');
xline(middelverdi + standardavvik, 'Color', 'green', 'LineWidth', 2, 'LineStyle', '--', 'Label', 'Middelverdi + Std');
xlabel('Lysverdier');
ylabel('Antall m{\aa}linger');
clear

load("P05_MeasManuellKjoring_Marie2.mat")
subplot(2,2,2)
k = length(Lys);
middelverdi = mean(Lys(1:k-1));
standardavvik = std(Lys(1:k-1));
histogram(Lys(1:k-1),20)
title(['Marie, mean =  ', num2str(middelverdi, 4),' std = ', num2str(standardavvik, 4)])
axis([0 70 0 25])
xline(middelverdi, 'Color', 'red', 'LineWidth', 2, 'Label', 'Middelverdi');
xline(middelverdi - standardavvik, 'Color', 'green', 'LineWidth', 2, 'LineStyle', '--', 'Label', 'Middelverdi - Std');
xline(middelverdi + standardavvik, 'Color', 'green', 'LineWidth', 2, 'LineStyle', '--', 'Label', 'Middelverdi + Std');
xlabel('Lysverdier');
ylabel('Antall m{\aa}linger');
clear

load("P05_MeasManuellKjoring_KH.mat")
subplot(2,2,3)
k = length(Lys);
middelverdi = mean(Lys(1:k-1));
standardavvik = std(Lys(1:k-1));
histogram(Lys(1:k-1),20)
title(['Kristoffer, mean =  ', num2str(middelverdi, 4),' std = ', num2str(standardavvik, 4)])
axis([0 70 0 25])
xline(middelverdi, 'Color', 'red', 'LineWidth', 2, 'Label', 'Middelverdi');
xline(middelverdi - standardavvik, 'Color', 'green', 'LineWidth', 2, 'LineStyle', '--', 'Label', 'Middelverdi - Std');
xline(middelverdi + standardavvik, 'Color', 'green', 'LineWidth', 2, 'LineStyle', '--', 'Label', 'Middelverdi + Std');
xlabel('Lysverdier');
ylabel('Antall m{\aa}linger');
clear

load("P05_MeasManuellKjoring_OMV.mat")
subplot(2,2,4)
k = length(Lys);
middelverdi = mean(Lys(1:k-2));
standardavvik = std(Lys(1:k-2));
histogram(Lys(1:k-1),20)
title(['Ole Martin, mean =  ', num2str(middelverdi, 4),' std = ', num2str(standardavvik, 4)])
axis([0 70 0 25])
xline(middelverdi, 'Color', 'red', 'LineWidth', 2, 'Label', 'Middelverdi');
xline(middelverdi - standardavvik, 'Color', 'green', 'LineWidth', 2, 'LineStyle', '--', 'Label', 'Middelverdi - Std');
xline(middelverdi + standardavvik, 'Color', 'green', 'LineWidth', 2, 'LineStyle', '--', 'Label', 'Middelverdi + Std');
xlabel('Lysverdier');
ylabel('Antall m{\aa}linger');