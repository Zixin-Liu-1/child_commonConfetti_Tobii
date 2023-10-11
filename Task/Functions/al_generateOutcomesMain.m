function taskData = al_generateOutcomesMain(taskParam, haz, concentration, condition)
%AL_GENERATEOUTCOMESMAIN This function generates the outcomes for the standard cannon task
%
%   Input
%       taskParam: Task-parameter-object instance
%       haz: Hazard-rate parameter
%       concentration: Concentration parameter
%       condition: Task condition
%
%   Output
%       taskData: Task-data-object instance


% Ensure that no more than 4 blocks are included since code currently
% doesn't support this. Update at some point, if necessary.
if length(taskParam.gParam.blockIndices) > 4
    error('Too many blocks specified');
end

% Select task- and block-specific number of trials
% ------------------------------------------------

% Todo: get rid of condition and use trialflow
%   also hier könnte man main, practice und control, shield haben .... entweder
%   condition oder anderer name... trialflow passt vielleicht nicht ganz
%   als name  oder kann man trials als argument rein geben? dass man das
%   garnicht hier braucht?

if isequal(condition, 'main')
    % Take specified number of trials from AdaptiveLearning script
    trials = taskParam.gParam.trials;

elseif isequal(condition, 'mainPractice') || isequal(condition, 'practiceNoOddball') || isequal(condition, 'oddballPractice')...
        || isequal(condition, 'followOutcomePractice') || isequal(condition, 'followCannonPractice') || isequal(condition, 'asymRewardPractice') %|| isequal(condition, 'reversalPractice')...

    % Take specified number of practice trials from AdaptiveLearning script
    trials = taskParam.gParam.practTrials;

    % Take condition-specific number of trials from AdaptiveLearning script
elseif isequal(condition, 'shield')
    trials = taskParam.gParam.shieldTrials;
elseif isequal(condition, 'followCannon') || isequal(condition, 'followOutcome') %|| isequal(condition, 'ARC_controlSpeed') || isequal(condition, 'ARC_controlAccuracy')
    trials = taskParam.gParam.controlTrials;
end

% wenn instanz kreiert wird dann muss das erstellt werden

% dann kann man wie in baukasten bestimmen, was man nimmt

% Initialize variables
% --------------------

ID = cell(trials, 1); % participant ID
age = nan(trials, 1); % participant age
sex = cell(trials, 1); % participant sex
rew = nan(trials, 1); % current reward
testDay = nan(trials, 1);
currTrial = nan(trials, 1);
group = nan(trials, 1);
actRew = nan(trials, 1); % actual reward
Date = cell(trials, 1); % date
cond = cell(trials, 1); % current condition
outcome = nan(trials, 1); % current outcome
distMean = nan(trials, 1); % current mean of the distribution
TAC = nan(trials, 1); % trials after change point
catchTrial = zeros(trials, 1); % catch trials
triggers = zeros(trials, 8); % triggers
pred = nan(trials, 1); % current prediction
predErr = nan(trials, 1); % current prediction error
estErr = nan(trials, 1); % current estimation error (previously memErr)
cannonDev = nan(trials, 1); % current estimation error (previously memErr)
UP = nan(trials, 1); % current update
hit = nan(trials, 1); % current hit
cBal = nan(trials, 1); % current counterbalancing condition
perf = nan(trials, 1); % current performance
accPerf = nan(trials, 1); % accumulated performance
startingBudget = nan(trials, 1); % initial amount of money
timestampOnset = nan(trials, 1); % timestamp trial onset
timestampPrediction = nan(trials, 1); % timestamp prediction
timestampFixCross2 = nan(trials, 1); % timestamp fixation cross 2
timestampFixCross3 = nan(trials, 1); % timestamp fixation cross 3
timestampOutcome = nan(trials, 1); % timestamp outcome
timestampShield = nan(trials, 1); % timestamp shield
timestampReward = nan(trials, 1); % timestamp reward
timestampOffset = nan(trials, 1); % timestamp trial offset
initiationRT = nan(trials, 1); % initiation reaction time
RT = nan(trials, 1); % reaction time
initialTendency = nan(trials, 1); % initial prediction tendency (when mouse is used for prediction)
block = nan(trials, 1); % current block
actJitter = nan(trials, 1); % current jitter
allASS = nan(trials, 1); % all angular shield size
z = nan(trials, 1); % default bucket location
y = nan(trials, 1); % push magnitude
mu = 15; % mean of shield
minASS = 10; % minimum angular shield size
maxASS = 180; % maximium angular shiled size
cp = nan(trials, 1); % current change point
cp_rew = nan(trials, 1); % current reward-distribution change point
latentState = nan(trials, 1); % latent state / todo: remove
nParticles = nan(trials, 1); % number of confetti particles in Hamburg version
nParticlesCaught = nan(trials, 1); % number of confetti particles caught on a trial in Hamburg version
greenCaught = nan(trials, 1); % number of confetti particles caught on a trial in Hamburg version
redCaught = nan(trials, 1); % number of confetti particles caught on a trial in Hamburg version
confettiStd = nan(trials, 1); % standard deviation of confetti particles
asymRewardSign = nan(trials, 1); % sign determining reward distribution in Hamburg asymReward version
nGreenParticles = nan(trials, 1); % number of green particles
rpe = nan(trials, 1); % reward prediction error
dotCol = struct;

% % Safe for all other conditions except chinese condition
% if isequal(condition,'shield') || isequal(condition,'ARC_controlSpeed') || isequal(condition,'ARC_controlAccuracy') || isequal(condition,'ARC_controlPractice')
%     s = taskParam.gParam.safe(2);
% else
%     s = taskParam.gParam.safe(1);
% end

s = taskParam.gParam.safe(1);
s_rew = taskParam.gParam.safe(1);

% Generate outcomes for CP condition
% ----------------------------------

% todo: auch hier gine main, control

% if isequal(condition, 'main') || isequal(condition, 'followOutcome') || isequal(condition, 'mainPractice') || isequal(condition, 'followCannon') ||...
%         isequal(condition, 'shield') || isequal(condition, 'ARC_controlSpeed') || isequal(condition, 'ARC_controlAccuracy') || isequal(condition, 'ARC_controlPractice') ||...
%         isequal(condition, 'followOutcomePractice') || isequal(condition, 'followCannonPractice') || isequal(condition, 'asymRewardPractice')

for i = 1:trials

    block(i) = al_indicateBlock(i, taskParam.gParam.blockIndices);

    % Generate changepoints
    if (rand < haz && s == 0) || i == taskParam.gParam.blockIndices(1) || i == taskParam.gParam.blockIndices(2) || i == taskParam.gParam.blockIndices(3) || i == taskParam.gParam.blockIndices(4)

        % Indicate current change point
        cp(i) = 1;

        % Draw mean of current distribution
        mean = round(rand(1).*359);

        % Take into account that in some conditions change points can only occur after a few trials
        % trial flow
        if isequal(condition,'shield') || isequal(condition, 'ARC_controlSpeed') || isequal(condition, 'ARC_controlAccuracy') || isequal(condition, 'ARC_controlPractice')
            s = taskParam.gParam.safe(2);
        else
            s = taskParam.gParam.safe(1);
        end

        % Reset trials after change point
        TAC(i) = 0;
    else

        % Increase trials after change point
        TAC(i) = TAC(i-1) + 1;

        % Update "safe criterion"
        s = max([s-1, 0]);

        % Set changepoint to false
        cp(i) = 0;

    end

    % Draw outcome
    outcome(i) = al_sampleOutcome(mean, concentration);

    % Save actual mean
    distMean(i) = mean;

    % Todo: get rid of this
    if taskParam.gParam.useCatchTrials
        if isequal('condition', 'onlinePractice')  % todo: kann raus
            if rand <= .2 && cp(i) == 0
                catchTrial(i:i+2) = 1;
            else
                catchTrial(i:i+2) = 0;
            end
        else
            catchTrial(i) = al_generateCatchTrial(taskParam, cp(i));
        end
    end

    % todo: hier anpassen... aber wie??

    % trialflow: variable vs. fixed shield size
    % Generate angular shield size depending on concentration
    if isequal(taskParam.gParam.taskType, 'HamburgEEG')
        allASS(i) = al_getShieldSize(minASS, maxASS, mu); % todo: in circle class so that it can be changed in main function
    else
        allASS(i) = rad2deg(taskParam.circle.shieldFixedSizeFactor*sqrt(1/concentration)); % al_getShieldSize(minASS, maxASS, mu); % todo: in circle class so that it can be changed in main function
    end
    % TODO: this should ultimately be removed
    % Set latent state to 0, as it is not used in changepoint task or shield practice
    latentState(i) = 0;

    % todo: hier über trial flow erst check ob confetti cannon 

    % todo: hier überlegen, ob ich extra funktion will oder so.. 
    % todo: oder soll das hier klasse werden und die anderen, z.b. oddball
    % kriegen ihre eigene funktion...
    

    % If confetti-cannon is used, determine reward magnitude (number of particles)
    if isequal(taskParam.gParam.taskType, 'Hamburg') || isequal(taskParam.gParam.taskType, 'HamburgEEG') ||isequal(taskParam.gParam.taskType, 'asymReward')

        if isequal(taskParam.trialflow.reward, 'asymmetric')

            % Generate reward-distribution changepoints
            if (rand < haz && s_rew == 0) || i == taskParam.gParam.blockIndices(1) || i == taskParam.gParam.blockIndices(2) || i == taskParam.gParam.blockIndices(3) || i == taskParam.gParam.blockIndices(4)

                % Indicate current reward-distribution changepoint
                cp_rew(i) = 1;

                % Change reward distribution
                if i == taskParam.gParam.blockIndices(1) || i == taskParam.gParam.blockIndices(2) || i == taskParam.gParam.blockIndices(3) || i == taskParam.gParam.blockIndices(4)

                    % At beginning of new block, randomly sample sign of distribution
                    asymRewardSign(i) = (-1)^randi([1,2]);

                else
                    % Otherwise, flip sign deterministically
                    asymRewardSign(i) = -asymRewardSign(i-1);

                end

                % Reset safe variable for reward distribution
                s_rew = taskParam.gParam.safe(1);

            else

                % Update "safe criterion"
                s_rew = max([s_rew-1, 0]);

                % Set reward-distribution changepoint to false...
                cp_rew(i) = 0;

                % ... and take same distribution
                asymRewardSign(i) = asymRewardSign(i-1);

            end

            % Determine particle color
            nParticles(i) = taskParam.cannon.nParticles;  % todo: if we keep this version, set nParticles at once as before
            outcomeDeviation = outcome(i) - distMean(i);
            nGreenParticles(i) = al_getParticleColor(taskParam.cannon.nParticles, outcomeDeviation, concentration, asymRewardSign(i));
            dotCol(i).rgb = [repmat(taskParam.colors.green, 1,nGreenParticles(i)), repmat(taskParam.colors.red, 1,taskParam.cannon.nParticles-nGreenParticles(i))];
        else

            % Take common number of particles...
            nParticles(i) = taskParam.cannon.nParticles;

            % ... and random colors
            dotCol(i).rgb = uint8(round(rand(3, taskParam.cannon.nParticles)*255));

        end
    end
end


%end

% % Generate shield types
% if isequal(taskParam.gParam.taskType, 'ARC') || isequal(taskParam.gParam.taskType, 'chinese')
% %
% %     % Here all shields have the same color
%      shieldType = ones(trials,1);
% else
% %
%     %warning('ShieldType nicht spezifiziert')
%     shieldType = ones(trials,1);%Shuffle([zeros((trials/2),1); ones((trials/2),1)]);
% end

shieldType = ones(trials,1);


% Save data
% https://de.mathworks.com/help/matlab/matlab_oop/example-representing-structured-data.html

taskData = al_taskDataMain();
taskData.actJitter = actJitter;
taskData.block = block;
taskData.initiationRTs = initiationRT;
taskData.currTrial = currTrial;
taskData.cannonDev = cannonDev;
taskData.haz = repmat(haz, length(ID), 1);
taskData.safe = repmat(taskParam.gParam.safe, length(ID), 1);
taskData.concentration = repmat(concentration, length(ID), 1);
taskData.pushConcentration = repmat(taskParam.gParam.pushConcentration, length(ID), 1);
taskData.timestampOnset = timestampOnset;
taskData.timestampFixCross2 = timestampFixCross2;
taskData.timestampFixCross3 = timestampFixCross3;
taskData.timestampPrediction = timestampPrediction;
taskData.timestampOutcome = timestampOutcome;
taskData.timestampShield = timestampShield;
taskData.timestampReward = timestampReward;
taskData.timestampOffset = timestampOffset;
taskData.allASS = allASS;
taskData.ID = ID;
taskData.age = age;
taskData.rew = rew;
taskData.actRew = actRew;
taskData.sex = sex;
taskData.outcome = outcome;
taskData.distMean = distMean;
taskData.cp = cp;
taskData.cp_rew = cp_rew;
taskData.cBal = cBal;
taskData.TAC = TAC;
taskData.shieldType = shieldType;
taskData.catchTrial = catchTrial;
taskData.triggers = triggers;
taskData.pred = pred;
taskData.predErr = predErr;
taskData.estErr = estErr;
taskData.cannonDev;
taskData.UP = UP;
taskData.hit = hit;
taskData.perf = perf;
taskData.accPerf = accPerf;
taskData.startingBudget = startingBudget;
taskData.Date = Date;
taskData.cond = cond;
taskData.initialTendency = initialTendency;
taskData.RT = RT;
taskData.latentState = latentState;
taskData.nParticles = nParticles;
taskData.nParticlesCaught = nParticlesCaught;
taskData.greenCaught = greenCaught;
taskData.redCaught = redCaught;
taskData.confettiStd = confettiStd;
taskData.asymRewardSign = asymRewardSign;
taskData.testDay = testDay;
taskData.group = group;
taskData.z = z;
taskData.y = y;
taskData.nGreenParticles = nGreenParticles;
taskData.rpe = rpe;
taskData.dotCol = dotCol;

end


