function [FilteredValue] = IIR_filter(OldFilteredValue, Measurement, Parameter)

    % Beregner den nye filtrerte verdien
    FilteredValue = (1 - Parameter) * OldFilteredValue + Parameter * Measurement;
    
end