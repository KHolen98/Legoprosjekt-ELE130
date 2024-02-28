%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt04_PID_Regulering
%
% Hensikten med programmet er å tune er regulator
% for styring av hastigheten til en motor
%
% Følgende  motorer brukes: 
%  - motor A
%
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME 
%
% Alltid lurt å rydde workspace opp først
clear; close all
% Skal prosjektet gjennomfoeres online mot EV3 eller mot lagrede data?
online = false;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P04_tekst.mat'; % Navnet på datafilen når online=0.
%--------------------------------------------------------------------------



% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                 INITIALIZE EQUIPMENT AND FIGURES
% Initialiser styrestikke, sensorer og motorer.

if online  
   mylego = legoev3('USB');
   joystick = vrjoystick(1);
   [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

   % motorer
   motorA = motor(mylego,'A');
   motorA.resetRotation;

else
    % Dersom online=false lastes datafil.
    load(filename)
end

disp('Equipment initialized.')
%----------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1=figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1, 1, 0.4*screen(3), 0.8*screen(4)])
%----------------------------------------------------------------------

% setter skyteknapp til 0, og initialiserer tellevariabel k
JoyMainSwitch=0;
k=0;

while ~JoyMainSwitch
    % oppdater tellevariabel
    k=k+1;

    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Faa tid og maalinger fra sensorer, motorer og joystick
    
    if online
        if k==1
            tic
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end
        
        % motorer
        VinkelPosMotorA(k) = double(motorA.readRotation);
           
        % Data fra styrestikke. Utvid selv med andre knapper og akser
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyPot(k) = JoyAxes(4);   
    else
        % online=false
        % Når k er like stor som antall elementer i datavektpren Tid,
        % simuleres det at bryter på styrestikke trykkes inn.
        if k==length(Tid)
            JoyMainSwitch=1;
        end
        
        % simulerer EV3-Matlab kommunikasjon i online=false
        pause(0.001)
    end
    %--------------------------------------------------------------
    

    
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER

    % parametre
    u0 = 0;
    Kp = 0;
    Ki = 0;
    Kd = 0;
    alfa = 1;
    
    if k==1
        % Initialverdier
        Ts(1) = 0.01;      % nominell verdi

        % Motorens tilstander
        x1(1) = VinkelPosMotorA(1);   % vinkelposisjon motor
        x2(1) = 0;                    % vinkelhastighet motor

        % Reguleringsavvik
        y(1) = x2(1);           % måling vinkelhastighet
        r(1) = 10*JoyPot(1);    % referanse
        e(1) = r(1)-y(1);       % reguleringsavvik
        e_f(1) = e(1);          % filtrert reg.avvik

        % Initialverdi PID-regulatorens deler
        P(1) = 0;       % P-del
        I(1) = 0;       % I-del
        D(1) = 0;       % D-del

    else 
        % Beregninger av tidsskritt
        Ts(k) = Tid(k)-Tid(k-1);

        % Motorens tilstander
        x1(k) = VinkelPosMotorA(k);
        x2(k) = BakoverDerivasjon(x1(k-1:k), Ts(k));

        % Beregning av reguleringsavvik
        y(k) = x2(k);          % måling vinkelhastighet
        r(k) = 10*JoyPot(k);   % referanse
        e(k) = r(k)-y(k);      % reguleringssavvik 

        % Lag kode for bidragene P(k), I(k) og D(k)
        P(k) = 0;
        I(k) = 0;
        e_f(k) = 0;
        D(k) = 0;
    end
    
    % -------------------------------------------------------------
    % Integratorbegrensing
    % -------------------------------------------------------------
    I_max(k) = 100;
    I_min(k) = -100;
    % if ... 

    u_A(k) = u0 + P(k) + I(k) + D(k);


    if online
        motorA.Speed = u_A(k);        
        start(motorA)
    end

    %--------------------------------------------------------------

  
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    % Denne plasseres enten i while-lokka eller rett etterpaa. 
    % Dette kan enkelt gjoeres ved aa skrive 'end' rett over her, 
    % og samtidig kommentere bort 'end' nedenfor. 
    %
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % for gir samme opplevelse i online=0 og online=1 siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila
    %
    figure(fig1)
    subplot(3,2,1)
    plot(Tid(1:k),r(1:k),'r-');
    hold on
    plot(Tid(1:k),y(1:k),'b-');
    hold off
    grid
    ylabel('[$^{\circ}$/s]')
    text(Tid(k),r(k),['$',sprintf('%1.0f',r(k)),'^{\circ}$/s']);
    text(Tid(k),y(k),['$',sprintf('%1.0f',y(k)),'^{\circ}$/s']);
    title('Vinkelhastighet $y(t)$ og referanse $r(t)$')

    subplot(3,2,3)
    plot(Tid(1:k),e(1:k),'b-');
    hold on
    plot(Tid(1:k),e_f(1:k),'b--');
    hold off
    grid
    title('Reguleringsavvik $e(t)$',...
        ['og $e_f$(t) med $\alpha=',num2str(alfa),'$'])    
    
    subplot(3,2,5)
    plot(Tid(1:k),I_max(1:k),'r-');
    hold on
    plot(Tid(1:k),I_min(1:k),'r-');
    plot(Tid(1:k),u_A(1:k),'b-');
    hold off
    grid
    title('P{\aa}drag $u(t)$ og max/min-grensene.')
    ylim([min(-110,min(u_A)),max(110,max(u_A))])
    xlabel('Tid [sek]')

    subplot(3,2,2)
    plot(Tid(1:k),P(1:k),'b-');
    grid
    title(['P-del, $K_p=',num2str(Kp),'$'])

    subplot(3,2,4)
    plot(Tid(1:k),I(1:k),'b-');
    grid
    title(['I-del, $K_i=',num2str(Ki),'$'])

    subplot(3,2,6)
    plot(Tid(1:k),D(1:k),'b-');
    grid
    title(['D-del, $K_d=',num2str(Kd),'$'])
    xlabel('Tid [sek]')


    % tegn naa (viktig kommando)
    drawnow
    %--------------------------------------------------------------
        
end



% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%           STOP MOTORS

if online
    stop(motorA);           
end
subplot(3,2,1)
legend('$r(t)$','$y(t)$')
subplot(3,2,3)
legend('$e(t)$','$e_f(t)$')
subplot(3,2,5)
legend('$u_{max}$','$u_{min}$','$u(t)$')

%------------------------------------------------------------------





