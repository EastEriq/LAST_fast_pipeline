function imdir=chooseSampleImDir(Uid,Cid)
% choose a directory of raw images: E.g:
%  - those of the latest night of observations with enough images
%  - those from a sample directory
arguments
    Uid char;
    Cid char;
end
[~,hostname]=system('hostname');
hostname=strrep(hostname,newline,'');
switch hostname(1:4)
    case 'last'
        % descend according to today's date, go backward till a dir with
        %  at least 20 files is found
        basedir=fullfile('/',hostname, sprintf('data%d',mod(str2double(Cid)-1,2)+1),...
                       'archive', sprintf('LAST.01.%s.%02d',Uid,str2double(Cid)));
        nfiles=0;
        currentday=today;
        while nfiles<20 && today-currentday<100
            currentday=currentday-1;
            [year,month,day]=datevec(currentday);
            imdir=fullfile(basedir,sprintf('%d',year),sprintf('%02d',month),...
                                    sprintf('%02d',day),'raw');
            nfiles=numel(dir(fullfile(imdir,'*sci_raw_Image_1.fits*')));
        end
    case 'CFEN'
        imdir='~/Eran/testimages/OutOfFocus'; %whatever
    otherwise
        error('I don''t know where to take images from')
end
