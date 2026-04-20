[~,hostname]=system('hostname');
if strcmp(hostname(1:4),'last')
    Uid=hostname((end-3):(end-2)); %(trailing \n...)
    if strcmpi(hostname(end),'w')
        Cid='1'; % TODO, parameter 1:4
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

% connect to all existing /Camera shared segments
s=dir(fullfile('/dev','shm',['C' Tid '_image_ringbuffer_*']));
RingBuffer(1)=POSIXipc.shm(strrep(s(1).name,'/dev/shm',''));
for i=2:length(s)
    RingBuffer(i)=POSIXipc.shm(strrep(s(i).name,'/dev/shm',''));
end
    
while true
    if HeaderQueue.NumMessages>0
        jh=HeaderQueue.receive;
        try
            hc=jsondecode(jh);
        catch
            fprintf('invalid header in retrieved from queue\n')
            hc={};
        end
        hc=reshape(hc,numel(hc)/3,3); % serializing with json flattens the cell
        AI=AstroImage;
        AI.HeaderData.Data=hc; % something to fill it with hc
        RingBufferIndex=AI.HeaderData.getVal('RINGBUFI');
        w=AI.HeaderData.getVal('NAXIS1');
        h=AI.HeaderData.getVal('NAXIS2');
        if contains(AI.HeaderData.getVal('CAMNAME'),'QHY')
            % cast QHY buffer to image. See inst.QHYccd.unpackImgBuffer
            AI.Image=reshape(typecast(RingBuffer(RingBufferIndex).Data,'uint16'),w,h);
        end
        fprintf('read image ... at time ... Ra,Dec ...\n')
        if AI.HeaderData.getVal('COUNTER')==1
            % do full astrometry and set up scenes
        else
            % do fast analysis
            % if <some condition>, push a notification
        end
    else
        pause(0.1)
    end
end