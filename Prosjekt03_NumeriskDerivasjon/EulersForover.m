function IntValueNew = EulersForover(IntValueOld, Timestep, FunctionValue)

 % Eulers forovermetode for å beregne neste verdi i en differensiallikning
    %
    % IntValueOld: Nåværende verdi av løsningen
    % Timestep: Tidssteget som brukes i metoden
    % FunctionValue: Verdien av funksjonen (derivert av løsningen) på nåværende tidspunkt

    % Beregn den nye verdien ved å bruke Eulers forovermetode
    IntValueNew = IntValueOld + Timestep * FunctionValue;

end
