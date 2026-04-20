% simulate a telescope Id:
%  from the host
[~,hostname]=system('hostname');

if strcmp(hostname(1:4),'last')
    Uid=eval(hostname((end-2):(end-1)));
    if strcmpi(hostname(end),'w')
        Cid='1';
    else
        Cid='3';
    end
    Tid=sprintf('%02d_1_%d', Uid, Cid);
else
    % invent it
    Tid='04_1_2';
end

% choose a directory of raw images: E.g:
%  - those of the latest night of observations with enough images
%  - those from a sample directory
switch hostname(1:4)
    case 'last'
        imdir=fullfile('/',hostname, sprintf('data%d',mod(Cid-1,2)+1),...
                       'archive', sprintf('LAST.01.%2d.%2d',Uid,Cid));
        % descend according to today's date, go backward till a dir with
        %  at least 20 files is found
    case 'CFEN'
        imdir='testimages'; %whatever
    otherwise
        error('I don''t know where to take images from')
end

% open queue and shared ringbuffer
% connect to the headers queue
HeaderQueue=POSIXipc.mqueue(['/Camera' Tid '_Header']);

imsize=2*9600*6422;

% connect to all existing /Camera shared segments
s=dir(fullfile('/dev','shm',['C' Tid '_image_ringbuffer_*']));
RingBuffer(1)=POSIXipc.shm(strrep(s(1).name,'/dev/shm',''),imsize);
for i=2:length(s)
    RingBuffer(i)=POSIXipc.shm(strrep(s(i).name,'/dev/shm',''),imsize);
end


% periodically enqueue the contents of one of the files
%  to be exact in times I could better use a timed function
f=dir(imdir);
i=1;
dt=2; %sec
while true
    AI=Astroimage(f(mod(i-1,length(f))+1));
    i=i+1;
    % first write flattened image data in buffer
    RingBufferIndex=mod(i-1,length(RingBuffer)+1);
    RingBuffer(RingBufferIndex).Data=...
               typecast(AI.Image.Data,'uint8',1,imsize);
    HeaderCell=AstroImage.HeaderData;
    % prepend buffer index like done by unitCS.treatNewImage
    HeaderCell=[{'RINGBUFI',RingBufferIndex,''};HeaderCell];
    HeaderQueue.send(jsonencode(HeaderCell));
    pause(dt);
end