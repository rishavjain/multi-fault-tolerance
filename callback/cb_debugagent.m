function cb_debugagent(~,~)

input = inputdlg('Debug at time :');
input = str2double(input);

if isempty(input)
    return
end

sim_debug(input);

end