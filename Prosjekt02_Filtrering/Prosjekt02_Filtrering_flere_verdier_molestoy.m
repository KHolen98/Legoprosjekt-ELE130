% Prosjekt02_Filtrering
%
% Hensikten med programmet er å illustrere effekten av å justere M og alpha-verdier
% i henholdsvis FIR og IIR filter på simulerte temperaturmålinger med støy.

clear; close all;

% Konfigurasjonsparametere
online = false; % Antar at dette kjøres med forhåndslastede data
filename = 'P02_MeasFiltrering_filt.mat'; % Datafilnavn, om nødvendig
M_verdier = [5, 10, 20]; % Forskjellige M-verdier å teste for FIR-filter
alfa_verdier = [0.1, 0.5, 0.9]; % Forskjellige alpha-verdier å teste for IIR-filter
stoySkalering = 0.5; % Skalering av støy

% Last inn måledata hvis online=false
if ~online
    if exist(filename, 'file')
        load(filename); % Forutsetter at dette laster 'Tid' og 'Lys'
    else
        disp('Datafilen finnes ikke.');
        return;
    end
end

% Anta 'Tid' og 'Lys' er lastet inn her. For demo, generer eksempeldata:
Tid = 1:100;
Lys = sin(2 * pi * Tid / 50) + randn(1, 100) * stoySkalering; % Simulert signal med støy

% Fir-filtereffekt
figure;
hold on;
title('Effekt av M-verdi i FIR-filter');
xlabel('Tid');
ylabel('Signalverdi');
plot(Tid, Lys, 'k--', 'DisplayName', 'Original med støy');
for M = M_verdier
    y_FIR = filter(ones(1, M)/M, 1, Lys); % Enkel implementering av FIR-filter
    plot(Tid, y_FIR, 'DisplayName', ['FIR M=', num2str(M)]);
end
legend show;

% IIR-filtereffekt
figure;
hold on;
title('Effekt av \alpha-verdi i IIR-filter');
xlabel('Tid');
ylabel('Signalverdi');
plot(Tid, Lys, 'k--', 'DisplayName', 'Original med støy');
for alpha = alfa_verdier
    y_IIR = filter(alpha, [1, alpha-1], Lys); % Enkel implementering av IIR-filter
    plot(Tid, y_IIR, 'DisplayName', ['IIR \alpha=', num2str(alpha)]);
end
legend show;

