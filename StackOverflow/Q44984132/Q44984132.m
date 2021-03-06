% StackOverflow Q44984132
% https://stackoverflow.com/questions/44984132
% How to calculate weight to minimize variance?
% Remarks:
%   1.  sa
% TODO:
% 	1.  ds
% Release Notes
% - 1.0.000     08/07/2017
%   *   First release.


%% General Parameters

run('InitScript.m');

figureIdx           = 0; %<! Continue from Question 1
figureCounterSpec   = '%04d';

generateFigures = OFF;


%% Simulation Parameters

dimOrder    = 3;
numSamples  = 4;

mX = randi([1, 10], [dimOrder, numSamples]);
vE = ones([dimOrder, 1]);


%% Solve Using CVX

cvx_begin('quiet')
    cvx_precision('best');
    variable vW(numSamples)
    minimize( (0.5 * sum_square_abs( mX * vW - (1 / numSamples) * (vE.' * mX * vW) * vE )) )
    subject to
        sum(vW) == 1;
        vW >= 0;
cvx_end

disp([' ']);
disp(['CVX Solution -                           [ ', num2str(vW.'), ' ]']);


%% Solve Using Projected Sub Gradient 001

numIterations   = 20000;
stepSize        = 0.001;
simplexRadius   = 1; %<! Unit Simplex Radius
stopThr         = 1e-6;

hKernelFun  = @(vW) ((mX * vW) - ((1 / numSamples) * ((vE.' * mX * vW) * vE)));
hObjFun     = @(vW) 0.5 * sum(hKernelFun(vW) .^ 2);
% hGradFun    = @(vW) (mX.' * hKernelFun(vW)) - ((1 / numSamples) * vE.' * (hKernelFun(vW)) * mX.' * vE); %<! From http://www.matrixcalculus.org/
% hGradFun    = @(vW) (mX.' * hKernelFun(vW)) - ((1 / numSamples) * (mX.' * (vE * vE.')) * hKernelFun(vW)); %<! By Hand
hGradFun   = @(vW) (mX.' - ( (1 / numSamples) * mX.' * (vE * vE.') )) * hKernelFun(vW); %<! By Hand (Same as above)

vW = rand([numSamples, 1]);
vW = vW(:) / sum(vW);

for ii = 1:numIterations
    vGradW = hGradFun(vW);
    vW = vW - (stepSize * vGradW);
    
    % Projecting onto the Unit Simplex
    % sum(vW) == 1, vW >= 0.
    vW = ProjectSimplex(vW, simplexRadius, stopThr);
end

disp([' ']);
disp(['Projected Sub Gradient 001 Solution -    [ ', num2str(vW.'), ' ]']);


%% Solve Using Projected Sub Gradient 002

numIterations   = 1000000;
stepSize        = 0.00005;

hKernelFun  = @(vW) ((mX * vW) - ((1 / numSamples) * ((vE.' * mX * vW) * vE)));
hObjFun     = @(vW) 0.5 * sum(hKernelFun(vW) .^ 2);
% hGradFun    = @(vW) (mX.' * hKernelFun(vW)) - ((1 / numSamples) * vE.' * (hKernelFun(vW)) * mX.' * vE); %<! From http://www.matrixcalculus.org/
% hGradFun    = @(vW) (mX.' * hKernelFun(vW)) - ((1 / numSamples) * (mX.' * (vE * vE.')) * hKernelFun(vW)); %<! By Hand
hGradFun   = @(vW) (mX.' - ( (1 / numSamples) * mX.' * (vE * vE.') )) * hKernelFun(vW); %<! By Hand (Same as above)

hProjFun1 = @(vW) max(vW, 0); %<! Projection onto Non Negative Half Space
hProjFun2 = @(vW) vW - ((sum(vW) - 1) / size(vW, 1)); %<! Projection onto Set of Normalized Sum Vectors

vW = rand([numSamples, 1]);
vW = vW(:) / sum(vW);

for ii = 1:numIterations
    vGradW = hGradFun(vW);
    vW = vW - (stepSize * vGradW);
    
    % Projecting onto the Unit Simplex
    % sum(vW) == 1, vW >= 0.
    vW = hProjFun2(hProjFun1(vW));
end

disp([' ']);
disp(['Projected Sub Gradient 002 Solution -    [ ', num2str(vW.'), ' ]']);


%% Restore Defaults

% set(0, 'DefaultFigureWindowStyle', 'normal');
% set(0, 'DefaultAxesLooseInset', defaultLoosInset);

