function userOptions = initSAMI(userOptions,do)
% userOptions = initSAMI(userOptions[,do])
% 
% Needs to be called at the very beginning. This function:
%   - checks if necessary 'userOptions' are set
%   - checks if rootPath exists and asks what the user want to do if it does
%   - loads 'stimuli_settings' file, if provided by user and set in userOptions 
%   - creates folder 'rootPath', where everything will be saved to
% 
%   input: 
%       - userOptions:  struct, containing all the options set by user beforehand
% 
%   optional input:      
%       - do: a string, specifying behavior in case of an existing rootPath folder:
%               'a' = abort
%               'd' = delete everything and start over
%               'c' = continue and use existing data/files, which can (and will) be overwritten
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 10/2020

%% check for needed userOptions to be set
if ~isfield(userOptions, 'analysisName'), error('*** sami:error *** analysisName must be set. See help'); end%if

%% define default behavior
if ~exist('do','var') || isempty(do), do = 'ask'; end

disp('*** initializing sami_toolbox ... ');

%% set root directory of the project, if not set yet
if ~isfield(userOptions, 'rootPath')
    userOptions.rootPath = fullfile(pwd,userOptions.analysisName);
end

%% check for existing folder/data
if exist(userOptions.rootPath,'dir')
    % ask what to do
    while strcmp(do,'ask') || ~(strcmp(do,'a') || strcmp(do,'d') || strcmp(do,'c'))
        do = input(['??? "rootPath" folder already exists ??? Please choose: \n',...
                    '     [a]: abort \n',...
                    '      d : delete everything and start over \n',...
                    '      c : continue and use existing data/files \n',...
                    '   >> '],'s');
        if isempty(do), do = 'a'; end
    end
    
    % do the right thing
    switch do
        case 'a'
            disp(' ');
            error('... abort. doing nothing.');
        case 'd'
            disp('   -> deleting existing data/files.');
            rmdir(fullfile(userOptions.rootPath), 's');
            init_folder(userOptions);
        case 'c'
            disp('   -> continue using existing files. Be aware: data/files will be overwritten!!!');
    end
    
else
    disp('   -> creating "rootPath" folder.');
    init_folder(userOptions);
end

%% if 'userOptions.stimuli_settings_filename' is set, load this file into 'userOptions.stimuli_settings'
if ~isempty(userOptions.stimuli_settings_filename)
	fprintf('   -> loading ''stimuli_settings'' file...');
    T = readtable(userOptions.stimuli_settings_filename);
    userOptions.stimuli_settings = [T.Properties.VariableNames; table2cell(T)];
    fprintf(' done\n');
end

end


%% sub_function -> create folder and save userOptions
function init_folder(userOptions)
    mkdir(userOptions.rootPath);
    save(fullfile(userOptions.rootPath,'userOptions.mat'),'userOptions');
end