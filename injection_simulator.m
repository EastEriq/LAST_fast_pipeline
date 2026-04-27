% simulate a telescope Id or build it from the host (for a specific
%  telescope with argument to buildTelescopeId)
[Tid,Uid,Cid]=buildTelescopeId();

% choose a directory of raw images
imdir=chooseSampleImDir(Uid,Cid);

% open queue and shared ringbuffer
% connect to the headers queue
imsize=2*9600*6422;
[HeaderQueue,RingBuffer]=connectIPC(Tid,10,imsize);

% periodically enqueue the contents of one of the files
%  to be exact in times I could better use a timed function
f=dir(fullfile(imdir,'*.fits'));
i=1;
dt=2; %sec
while true
    imfile=f(mod(i-1,length(f))+1).name;
    fprintf('enqueuing %s\n',imfile)
    AI=AstroImage(fullfile(imdir,imfile));
    i=i+1;
    % first write flattened image data in buffer
    RingBufferIndex=mod(i-1,length(RingBuffer))+1;
    RingBuffer(RingBufferIndex).Data= typecast(reshape(AI.Image,1,[]),'uint8');
     % prepend buffer index like done by unitCS.treatNewImage
    HeaderCell=[{'RINGBUFI',RingBufferIndex,''}; AI.HeaderData.Data];
    % enqueue the header
    HeaderQueue.send(jsonencode(HeaderCell));
    pause(dt);
end