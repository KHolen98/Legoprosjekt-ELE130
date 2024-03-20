clear; close all;

% Konfigurasjonsparametere
filename = 'P02_MeasFiltrering.mat'; % Filnavn for lagring/henting av data
brukFIR = false; % Aktiver/deaktiver FIR-filter
brukIIR = true; % Aktiver/deaktiver IIR-filter
M_verdier = [10, 20, 30]; % Eksempel: bruker flere verdier for M
alfa_verdier = [0.1, 0.5, 0.9]; % Flere verdier for alfa

% Last inn data
load(filename)

% Oppsett for plotting
fig1 = figure;
set(fig1, 'Position', [100, 100, 600, 400]); % Tilpasset størrelse
title('Temperatur og filtrerte signaler');
xlabel('Tid [s]');
ylabel('Temperatur');
hold on;

% Behandle og plott FIR-filterresultater hvis aktivert
if brukFIR
    for M = M_verdier
        y_FIR = zeros(1, length(Lys));
        for k = 1:length(Lys)
            y_FIR(k) = FIR_filter(Lys(1:k), M);
        end
        plot(Tid, y_FIR, 'DisplayName', sprintf('FIR M=%d', M));
    end
end

% Behandle og plott IIR-filterresultater hvis aktivert
if brukIIR
    for alfa = alfa_verdier
        y_IIR = zeros(1, length(Lys));
        for k = 1:length(Lys)
            if k == 1
                y_IIR(k) = Lys(k);
            else
                y_IIR(k) = IIR_filter(y_IIR(k-1), Lys(k), alfa);
            end
        end
        plot(Tid, y_IIR, 'DisplayName', sprintf('IIR a=%.1f', alfa));
    end
end

% Legg til originaldata i plottet
plot(Tid, Lys, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Original');
legend show; % Viser legenden
hold off;