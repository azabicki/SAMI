function feat = calcFeatures(c3dData, featureType, userOptions, fileNameSufix)
% 
% 
% 
% 
%__________________________________________________________________________
% A. Zabicki (azabicki@posteo.de)
% v1: 08/2020

disp(['*** calculate _' featureType '_ features ***']); 

%% define default behavior
if ~exist('featureType','var') || isempty(featureType), featureType = 'idv'; end
if ~exist('fileNameSufix','var') || isempty(fileNameSufix), fileNameSufix = ''; end
    
%% init vars
nFiles = size(c3dData,2);
stb = what('sami_toolbox');
feat = struct('fSet',[]);
nActFeat = 0;               % need to know how many features are already calculated

%% fetch all functions for feature calculation
switch featureType
    case 'idv'
        import sami.feat.idv.*        
        fcn = dir(fullfile(stb.path,'+sami','+feat','+idv','*.m'));
    case 'itx'
        import sami.feat.itx.*        
        fcn = dir(fullfile(stb.path,'+sami','+feat','+itx','*.m'));
    otherwise
        error('*** sami:error *** "featureType" unknown.');
end
fcn = {fcn(:).name}';

% ignore all functions containing "NOT" in filename
fcn(contains(fcn,'NOT')) = [];

%% loop feature-functions
dur = nan(nFiles,numel(fcn));
% fprintf('   ... computing features (of %d): 1',numel(fcn));
for fcnI = 1:numel(fcn)
    % display progress
    fprintf('   ... loading function #%d (of %d) ... processing stimulus (of %d): 0',fcnI,numel(fcn),nFiles);
    
    % loop stimulus_files
    for fileI = 1:nFiles
     	fprintf([repmat('\b',1,numel(num2str(fileI-1))) '%d'],fileI);
        
        tic;
        tmp_feat = feval(fcn{fcnI}(1:end-2), c3dData(fileI));
        dur(fileI,fcnI) = toc;
        
        % save each calculated feature_sets
        for i = 1:numel(tmp_feat)
            feat(nActFeat+i).fSet(:,fileI) = tmp_feat(i).feat;
        end
    end
    
    % get meta_data
    for i = 1:numel(tmp_feat)
        feat(nActFeat+i).name = tmp_feat(i).name;
        feat(nActFeat+i).color = tmp_feat(i).color;
        feat(nActFeat+i).unit = tmp_feat(i).unit;
        if isfield(tmp_feat,'fisherZ4paramTesting') && ~isempty(tmp_feat(i).fisherZ4paramTesting)
            feat(nActFeat+i).fisherZ4paramTesting = tmp_feat(i).fisherZ4paramTesting;
        else
            feat(nActFeat+i).fisherZ4paramTesting = false;            
        end
    end
    
    % updating variable: how many features are already calculated
    nActFeat = nActFeat  + numel(tmp_feat);
    fprintf(' ... ok\n');
end

%% rename feature variable and saving it
feat_filename = ['features_' featureType fileNameSufix '.mat'];
feat_varname = ['feat_' featureType fileNameSufix];
eval([feat_varname '= feat;']);            
save(fullfile(userOptions.rootPath,feat_filename),feat_varname);

%% finishing
fprintf([' ... features saved in rootPath as "' feat_filename '" \n']);
fprintf(' ... DONE calculating features\n\n');

%% some debug/information
if isfield(userOptions,'debug') &&  userOptions.debug == true
    dur_info = [fcn, num2cell(sum(dur)')];
    save(fullfile(userOptions.rootPath,['dur_calc_feat_' featureType fileNameSufix '.mat']),'dur','dur_info');
end

