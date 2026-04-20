% simulate a telescope Id:
%  from the host
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

% choose a directory of raw images: E.g:
%  - those of the latest night of observations with enough images
%  - those from a sample directory
switch hostname(1:4)
    case 'last'
        imdir=''
    case 'CFEN'
        imdir=fullfile(hostname,
    otherwise
        error('I don''t know where to take images from')
end