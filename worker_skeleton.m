[~,hostname]=system('hostname');
if strcmp(hostname(1:4),'last')
    Uid=hostname((end-2):(end-1));
    if strcmpi(hostname(end),'w')
        Cid='1';
    else
        Cid='3';
    end
    Tid=[Uid '_1_' Cid];
else
    % invent it
    Tid='04_1_2';
end

% connect to the headers queue
HeaderQueue=POSIXipc.mqueue(['/Camera' Tid '_Header']);
    
while true
    if HeaderQueue.NumMessages>0
        jh=HeaderQueue.receive;
        try
            hc=jsondecode(jh);
        catch
            fprintf('invalid header in retrieved from queue\n')
            hc={};
        end
        hc=reshape(hc,numel(hc)/3,3);
        cell2struct(hc)
    else
        pause(0.1)
    end
end