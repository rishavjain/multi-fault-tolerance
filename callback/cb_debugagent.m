function cb_debugagent(source,callbackdata)

input = inputdlg('Debug at time :');
input = str2double(input);

if isempty(input)
    return
end

sim_debug(input);

end