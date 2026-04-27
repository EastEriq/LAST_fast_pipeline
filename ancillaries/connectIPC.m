function [HeaderQueue,RingBuffer]=connectIPC(telescopeId,dim,imsize) 
% open headers queue and shared ringbuffer, or create them if not present

arguments
    telescopeId char
    dim double =[];  % ringbuffer dim
    imsize double =[]; % provide explicitly for creation
end

HeaderQueue=POSIXipc.mqueue(['/Camera' telescopeId '_Header']);
RingBuffer=POSIXipc.shm.empty;

% connect to all existing /Camera shared segments
if isempty(dim)
    s=dir(fullfile('/dev','shm',['C' telescopeId '_image_ringbuffer_*']));
    dim=length(s);
    bname={s.name};
else
    bname=cell(1,dim);
    for i=1:dim
        bname{i}=sprintf('C%s_image_ringbuffer_%d',telescopeId,i);
    end
end

for i=1:dim
    if ~isempty(imsize)
        % to create anew, or to change imsize
        RingBuffer(i)=POSIXipc.shm(bname(i),imsize);
    else
        % to connect to existing ones
        RingBuffer(i)=POSIXipc.shm(bname(i));
    end
end