function x = cbt(r,y,M,B,F,Ts,l1)
% Design a 1 degree of freedom linear controller so as to match the r(t)
%   to y(t) closed-loop transfer function with the model reference M.
%   
%   INPUTS:
%   r:  column vector (Nx1) that contains the INPUT data collected from the plant.
%   y:  column vector (Nx1) that contains the OUTPUT data collected from the plant.
%   M: tf-object that represents the discrete transfer function of the reference 
%       model. The reference model M(z) describes the desired closed-loop behaviour 
%       from the reference r(t) to the output y(t).
%   B:  column vector of tf-objects. The linear controller has the following structure: 
%       C(z,theta)= B'*theta, where B is a column vector of transfer functions, and 
%       theta is the vector of parameters.
%   F:  tf-object of the weighting function F(z). 
%   Ts: sample time.
%   l1: rw window length.
%            
%   OUTPUTS:
%   x:  controller coefficients (Controller = x' * B).

N = length(r);

% time vector.
t_input = 0 : Ts : (N - 1) * Ts;

%% filter W
% the input signal is a PRBS: its spectrum is constant and it's equal to
% the variance of the PRBS.
W = F * (1 - M) / var(r);

% filtered input.
rw = lsim(W,r,t_input);

%% solution using LS
% problem: find x s.t. Ax = b.

% b vector
yr = lsim(M,r,t_input); % uscita riferimento r
% matrix of instrumental variables.
Rw = zeros(2 * l1 + 1,N);
for j  = 1 : N
    for k = -l1 : l1  
        if j - k >= 1 && j - k <= 2 * l1 + 1
        Rw(k+l1+1,j) = rw(j-k);
        end       
    end
end
b = Rw / N * yr;

% A matrix
Yc=zeros(N,size(B,1));
for j=1:size(B,1)
    Yc(:,j) = lsim(B(j) * (1 - M),y',t_input);
end
A = Rw / N * Yc;

% controller coefficients
x = A \ b;

end

