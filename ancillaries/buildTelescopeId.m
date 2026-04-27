function [Tid,Uid,Cid]=buildTelescopeId(Cid)
% simulate a telescope Id:
%  from the host
arguments
    Cid='';
end

[~,hostname]=system('hostname');
hostname=strrep(hostname,newline,'');

if strcmp(hostname(1:4),'last')
    Uid=eval(hostname((end-2):(end-1)));
    switch hostname(end)
        case 'w'
            if isempty(Cid)
                Cid='1';
            end
        case 'e'
            if isempty(Cid)
                Cid='3';
            end
        otherwise
    end
else
    % invent it
    Uid='04';
    Cid='2';
end

Tid=sprintf('%s_1_%s', Uid, Cid);
