
% Copyright (c) 2002, 2017 Jens Keiner, Stefan Kunis, Daniel Potts
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 2 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, write to the Free Software Foundation, Inc., 51
% Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

% Test script of class nfft for spatial dimension d=3.
clear all;

M=65; % number of nodes
N1=24; % number of Fourier coefficients in first direction
N2=32; % number of Fourier coefficients in second direction
N3=30; % number of Fourier coefficients in third direction
N4=10; % number of Fourier coefficients in forth direction
N=[N1;N2;N3;N4];

x=rand(M,4)-0.5; %nodes

% Initialisation
plan=nfft(4,N,M); % create plan of class type nfft
%n=2.^(ceil(log(N)/log(2))+1);
%plan=nfft(4,N,M,n(1),n(2),n(3),n(4),8,bitor(PRE_PHI_HUT,bitor(PRE_PSI,NFFT_OMP_BLOCKWISE_ADJOINT)),FFTW_ESTIMATE); % use of nfft_init_guru

plan.x=x; % set nodes in plan and perform precomputations

% NFFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fhat=rand(N1,N2,N3,N4); % Fourier coefficients
fhatv=fhat(:);

% Compute samples with NFFT
plan.fhat=fhatv; % set Fourier coefficients
nfft_trafo(plan); % compute nonequispaced Fourier transform
f1=plan.f; % get samples

% Compute samples direct
k1=-N1/2:N1/2-1;
k2=-N2/2:N2/2-1;
k3=-N3/2:N3/2-1;
k4=-N4/2:N4/2-1;
[K1,K2,K3,K4]=ndgrid(k1,k2,k3,k4);
k1=K1(:); clear K1;
k2=K2(:); clear K2;
k3=K3(:); clear K3;
k4=K4(:); clear K4;
f2=zeros(M,1);
for j=1:M
	x1j=x(j,1);
	x2j=x(j,2);
	x3j=x(j,3);
	x4j=x(j,4);
	f2(j)=sum( fhatv.*exp(-2*pi*1i*(k1*x1j+k2*x2j+k3*x3j+k4*x4j)) );
end %for

% Compare results
max(abs(f1-f2))

% Adjoint NFFT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Computation with NFFT
nfft_adjoint(plan);
fhat1=plan.fhat;

% Direct computation
fhat2=zeros(N1*N2*N3*N4,1);
for j=1:N1*N2*N3*N4
	k1j=k1(j);
	k2j=k2(j);
	k3j=k3(j);
	k4j=k4(j);
	fhat2(j)=sum( plan.f.*exp(2*pi*1i*(k1j*x(:,1)+k2j*x(:,2)+k3j*x(:,3)+k4j*x(:,4))) );
end %for

% Compare results
max(abs(fhat1-fhat2))
