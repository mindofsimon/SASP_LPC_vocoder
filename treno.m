function sig =treno(t,T) 
sig = zeros(1, length(t));
sig(1: 1/T : length(t)) = 1;
end

