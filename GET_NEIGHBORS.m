function n = GET_NEIGHBORS(list, x)

pos = find(list==x);

if pos == 1
    n = list(pos+1);
elseif pos == length(list)
    n = list(pos-1);
else
    n = [list(pos-1), list(pos+1)];
end

end