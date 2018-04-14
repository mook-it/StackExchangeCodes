function [ vX, mX ] = SolveLsL1ComplexPgm( mA, vB, lambdaFctr, numIterations )
% ----------------------------------------------------------------------------------------------- %
%[ vX, mX ] = SolveLsL1ComplexPgm( mA, vB, lambdaFctr, numIterations )
% Solves the 0.5 * || A x - b ||_2 + \lambda || x ||_1 problem using
% Proximal Gradient Method. The model allows A, b and x to be Complex.
% Input:
%   - mA                -   Model Matrix.
%                           The model matrix.
%                           Structure: Matrix (m X n).
%                           Type: 'Single' / 'Double' (Complex).
%                           Range: (-inf, inf).
%   - vB                -   Input Vector.
%                           The model known data.
%                           Structure: Vector (m X 1).
%                           Type: 'Single' / 'Double' (Complex).
%                           Range: (-inf, inf).
%   - paramLambda       -   Parameter Lambda.
%                           The L1 Regularization parameter.
%                           Structure: Scalar.
%                           Type: 'Single' / 'Double'.
%                           Range: (0, inf).
%   - numIterations     -   Number of Iterations.
%                           Number of iterations of the algorithm.
%                           Structure: Scalar.
%                           Type: 'Single' / 'Double'.
%                           Range {1, 2, ...}.
% Output:
%   - vX                -   Output Vector.
%                           Structure: Vector (n X 1).
%                           Type: 'Single' / 'Double'.
%                           Range: (-inf, inf).
% References
%   1.  Wikipedia Proximal Gradient Method - https://en.wikipedia.org/wiki/Proximal_gradient_method.
% Remarks:
%   1.  A
% Known Issues:
%   1.  A
% TODO:
%   1.  B
% Release Notes:
%   -   1.0.000     07/11/2016
%       *   First realease version.
% ----------------------------------------------------------------------------------------------- %

mAA = mA' * mA;
vAb = mA' * vB;
% vX  = mAA \ vAb;
vX  = pinv(mA) * vB; %<! Dealing with "Fat Matrix"

paramAlphaBase = 2 / (1.05 * (norm(mA, 2) ^ 2));

mX = zeros([size(vX, 1), numIterations]);
mX(:, 1) = vX;

for ii = 2:numIterations
    vXGrad      = (mAA * vX) - vAb;
    
    paramAlpha  = paramAlphaBase / sqrt(ii - 1);
    vX          = ProxL1(vX - (paramAlpha * vXGrad), paramAlpha * lambdaFctr);
    
    mX(:, ii) = vX;
end


end


function [ vX ] = ProxL1( vX, lambdaFactor )

% Soft Thresholding - Complex Domain -> Keep Phase, Soft Threshold the
% Modulus

% vXAbs   = abs(vX);
% vXPhase = angle(vX);
% 
% vX = max(vXAbs - lambdaFactor, 0) .* exp(1i * vXPhase);

vXAbs = abs(vX);

vX              = (vX ./ vXAbs) .* max((vXAbs - lambdaFactor), 0);
vX(vXAbs == 0)  = 0;


end

