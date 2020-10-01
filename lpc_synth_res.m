function [lpc_output] = lpc_synth_res(excitation, coeff)

    [lpc_output] = filter(1, [1; coeff] , excitation);

      
end