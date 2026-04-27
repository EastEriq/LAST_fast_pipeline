% simulate a telescope Id or build it from the host (for a specific
% telescope with argument to buildTelescopeId)
[Tid,Uid,Cid]=buildTelescopeId();

% connect to the headers queue
% connect to all existing /Camera shared segments
[HeaderQueue,RingBuffer]=connectIPC(Tid);


% single threaded processing loop. See later on if that should be upgraded
% to a parallel pool of workers, and in case, work out how they report and
% reassemble the analysis results

while true % or add a stopping signal or condition
    if HeaderQueue.NumMessages>0
        jh=HeaderQueue.receive;
        try
            hc=jsondecode(jh);
            hc=reshape(hc,numel(hc)/3,3); % serializing with json flattens the cell
            AI=AstroImage;
            AI.HeaderData.Data=hc; % something to fill it with hc
            RingBufferIndex=AI.HeaderData.getVal('RINGBUFI');
            w=AI.HeaderData.getVal('NAXIS1');
            h=AI.HeaderData.getVal('NAXIS2');
            if contains(AI.HeaderData.getVal('CAMNAME'),'QHY')
                % cast QHY buffer to image. See inst.QHYccd.unpackImgBuffer
                if RingBuffer(RingBufferIndex).Size > 2*w*h
                    reshape(RingBuffer(RingBufferIndex).Pointer,1,2*w*h);
                end
                AI.Image=reshape(typecast(RingBuffer(RingBufferIndex).Data,'uint16'),w,h);
            end
            fprintf('read image %#4d at JD %10.5f Ra,Dec (%.3f,%.3f)\n',...
                AI.HeaderData.getVal('COUNTER'),AI.HeaderData.getVal('JD'),...
                AI.HeaderData.getVal('RA'),AI.HeaderData.getVal('DEC'))
            if AI.HeaderData.getVal('COUNTER')==1
                % do full astrometry and set up scenes
                % FILL WITH ANALYSIS
            else
                % do fast analysis
                % FILL WITH ANALYSIS
                % store results somewhere (e.g. file)
                % if <some condition>, push a notification somewhere
            end
        catch
            fprintf('invalid header retrieved from queue:\n,  %s\n skipping\n',jh);
        end
    else
        pause(0.1)
    end
end