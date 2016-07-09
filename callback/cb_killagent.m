function cb_killagent(source,callbackdata)

input = inputdlg('Agent(s) to kill :');

if isempty(input)
    return
end

input = str2num(cell2mat(input));

if isempty(input)
    return
end

sim_agents_to_kill(input);

end