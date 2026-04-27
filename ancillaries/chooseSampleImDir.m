function imdir=chooseSampleImDir(Uid,Cid)
% choose a directory of raw images: E.g:
%  - those of the latest night of observations with enough images
%  - those from a sample directory
arguments
    Uid
    Cid
end
[~,hostname]=system('hostname');
hostname=strrep(hostname,newline,'');
switch hostname(1:4)
    case 'last'
        % TODO
        % descend according to today's date, go backward till a dir with
        %  at least 20 files is found
        imdir=fullfile('/',hostname, sprintf('data%d',mod(Cid-1,2)+1),...
                       'archive', sprintf('LAST.01.%2d.%2d',Uid,Cid));
    case 'CFEN'
        imdir='~/Eran/testimages/OutOfFocus'; %whatever
    otherwise
        error('I don''t know where to take images from')
end
