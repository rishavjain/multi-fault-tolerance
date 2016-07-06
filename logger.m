function logger( params, logLevel, logStr )

if params.log.level <= logLevel
    fprintf(params.log.fileId, '%s\n', logStr);
end

end
