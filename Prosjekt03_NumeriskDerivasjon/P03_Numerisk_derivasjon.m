
%-----------------------------------------------------------------------

while not skyteknapp
% GET TIME AND MEASUREMENT
registrer måletidspunkt Tid(k)
registrer måling Avstand(k)
registrer måling Bryter(k)
% CONDITIONS, CALCULATIONS AND SET MOTOR POWER
spesifiser "alfa", parameteren i IIR-filter
definer nominell initialverdi for Ts
definer initialverdi for u_f
definer initialverdi for v
definer initialverdi for v_f
la u(k) tilsvare Avstand(k)
beregn filtrert avstand u_f(k)
beregn Ts(k)
hvis Bryter(k) er inntrykket
beregn farten v(k) basert på u(k)
beregn farten v_f(k) basert på u_f(k)
ellers
v(k)=v_f(k)=0
% PLOT DATA
plot u(k) og u_f(k) i samme delfigur
plot Bryter(k) i neste delfigur
plot v(k) i neste delfigur
plot v_f(k) i nederste delfigur
legg på xlabel og ylabel og tittel
end


%% e) Numerisk derivasjon som Matlab-funksjon
clear;close all;clc

% Diskret tids- og signalvektor t(k) og u(k).
% Kopier tilsvarende kode fra deloppgave b).
T_s =0.4; %Samplingstid
t_slutt = 3;
t = 0:T_s:t_slutt; % Diskret tid
u = 2 * t.^2; % Diskret versjon av u(t)

%initialverdi
v(1) = 0;
for k = 2:length(t)
    % Bruker BakoverDerivasjon for å finne den tilnærmede deriverte av u
    v(k) = BakoverDerivasjon([u(k-1), u(k)], T_s);
end

figure
subplot(2,1,1)
plot(t, u,'k:o')
grid
title('Signal $u_{k}$')

subplot(2,1,2)
plot(t, v, 'r:o')
grid
title('$v_{k}$, numerisk derivert av $u_{k}$')
legend('Bakoverderivasjon')



