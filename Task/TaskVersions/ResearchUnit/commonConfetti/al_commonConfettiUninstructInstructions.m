function al_commonConfettiUninstructInstructions(taskParam)
%AL_COMMONCONFETTIUNINSTRUCTINSTRUCTIONS This function runs the instructions
% for the uninstruct version of the Hamburg confetti-cannon task
%
%   Minimal instruction flow: one welcome screen explaining the task,
%   one short practice block mimicking the structure of step 11 in
%   al_commonConfettiInstructions, and one start-experiment screen.
%
%   Practice data is loaded from hidCannonPracticeHamburgUninstruct.mat,
%   which defines the trial count and changepoint schedule. During practice,
%   outcomes are fixed to distMean (no variance). One catch trial is
%   included so the participant experiences the peek (outcome shown before
%   prediction).
%
%   Input
%       taskParam: Task-parameter-object instance
%
%   Output
%       None

% 1. Welcome and task explanation
% --------------------------------
% 

% 1a. Welcome and task explanation
% ---------------------------------


txt1 = ['Herzlich Willkommen zur Konfetti-Aufgabe!\n\n'...
    'Sie werden gleich einen Kreis sehen. Auf dem Kreisrand wird Konfetti erscheinen. '...
    'Ihre Aufgabe ist es, soviel Konfetti wie möglich mit einem Eimer zu fangen. '...
    'Dazu müssen Sie vorhersagen, wo das Konfetti auf dem Kreisrand erscheinen wird, ' ...
    'und dort einen Eimer platzieren.\n\n'...
    'Um den Eimer zu platzieren, führen Sie den rosafarbenen Punkt mit der Maus an die Stelle, '...
    'wo Sie erwarten, das Maximum an Konfetti zu fangen. '...
    'Drücken Sie dann die linke Maustaste um ihre Vorhersage abzugeben. \n\n'...
    'Nach jeder Vorhersage sehen Sie, wo das Konfetti gelandet ist, ' ...
    'und ob Sie es mit dem Eimer gefangen haben. '...
    'Auf die Größe der Eimer haben Sie keinen Einfluss. ' ...
    'Im ersten Durchgang jedes Blocks können Sie einfach raten'];

header = '';
feedback = true;
al_bigScreen(taskParam, header, txt1, feedback);


txt2 = ['Ab dem zweiten Durchgang sehen Sie zwei Striche auf dem Kreis. '...
    'Der pinke Strich zeigt an, wo der Eimer das letzte Mal positioniert war '...
    'Der schwarze Strich zeigt an, wo das Konfetti das letzte Mal gelandet ist. ' ...
    'In manchen Durchgängen ist der Ort, an dem das Konfetti landen wird, schon zu sehen. ' ...
    'Platzieren Sie dann einfach dort den Eimer.\n\n'...
    'Bitte fixieren Sie nach jeder Vorhersage Ihren Blick auf den Punkt in der Mitte des Kreises ' ...
    'und vermeiden Sie Augenbewegungen. Vermeiden Sie es während eines Durchganges zu blinzeln. ' ...
    'Wenn der Punkt in der Mitte am Ende des Durchgangs weiß ist, dürfen Sie blinzeln.\n\n'...
    'Fangen Sie so viel Konfetti wie möglich! Dafür erhalten Sie Punkte. ' ...
    'Ihr Ziel ist es, möglichst viele Punkte zu erhalten. '...
    'Es folgt zunächst ein kurzer Übungsdurchgang.'];

header = '';
feedback = true;
al_bigScreen(taskParam, header, txt2, feedback);

% 2. Practice block
% ------------------
% Mimics the structure of step 11 in al_commonConfettiInstructions:
% set condition, configure trialflow, load data from .mat, run loop.

% Update condition
condition = 'main';
taskParam.trialflow.condition = 'uninstruct';

% Update trial flow (same as step 11)
taskParam.trialflow.colors = 'dark';
taskParam.trialflow.shot = 'static';
taskParam.trialflow.exp = 'practHid';
taskParam.trialflow.shieldAppearance = 'lines';
taskParam.trialflow.cannon = 'hide cannon';
taskParam.trialflow.confetti = 'show confetti cloud';
taskParam.trialflow.currentTickmarks = 'show';
taskParam.trialflow.push = 'practiceNoPush';
taskParam.trialflow.saveData = 'true';
taskParam.trialflow.saveEtData = 'false';
taskParam.cannon = taskParam.cannon.al_staticConfettiCloud(taskParam.trialflow.colors, taskParam.display);

% Set text size and font
Screen('TextSize', taskParam.display.window.onScreen, taskParam.strings.textSize);
Screen('TextFont', taskParam.display.window.onScreen, 'Arial');

% Load practice data
% The .mat file contains a fully populated taskData object with
% distMean, outcome, catchTrial, etc. already generated.
% No need to call al_cannonData — just load and override outcome.
taskData = load('hidCannonPracticeHamburgUninstruct.mat');
taskData = taskData.taskData;
taskData.saveAsStruct = true;

% Fix outcomes to distMean (no variance during practice)
taskData.outcome = taskData.distMean;

% Determine trial count from loaded data
nTrials = length(taskData.distMean);

% Update unit test predictions
taskParam.unitTest.pred = zeros(nTrials, 1);

% Run practice
al_confettiLoop(taskParam, condition, taskData, nTrials);

% Wait until keys released
KbReleaseWait();

% 3. Start experiment
% --------------------
% Parallel to Step 12 in al_commonConfettiInstructions

header = 'Jetzt kommen wir zum Experiment';
txt3 = ['Sie haben die Übungsphase abgeschlossen. ' ...
    'Jetzt beginnt die Konfetti-Aufgabe. \n\n'...
    'Versuchen Sie einzuschätzen, ' ...
    'wo das nächste Konfetti landen wird. Fangen Sie immer so viel Konfetti wie möglich!.\n\n'...
    'Es gibt sechs Aufgabenblöcke, und Sie können zwischen den Blöcken eine Pause machen, ' ...
    'wenn nötig.\n\n'...
    'Achten Sie bitte auf Ihre Augenbewegungen und vermeiden Sie es während ' ...
    'eines Durchganges zu blinzeln. Wenn der Punkt in der Mitte am Ende des Durchgangs weiß ist, ' ...
    'dürfen Sie blinzeln.\n\n' ...
    ' Viel Erfolg!'];

feedback = false;
al_bigScreen(taskParam, header, txt3, feedback);

end
