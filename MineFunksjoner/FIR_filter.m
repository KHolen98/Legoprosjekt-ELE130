function [FilteredValue] = FIR_filter(Measurement, M)
    k = length(Measurement);

    % Justerer M hvis nødvendig (når k < M)
    if k < M
        M = k;
    end

    % Beregner gjennomsnittet av de siste 'M' målingene
    FilteredValue = sum(Measurement(end-M+1:end)) / M;
end