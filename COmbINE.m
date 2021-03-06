function [summaryGraph, inputpags, combinedPag] = COmbINE(datasets, fciParams, mpl, fName, outputName, screen)
% FUNCTION [] = COMBINE(DATASETS, FCIPARAMS, MPL) 
% Runs algorithm COmbINE for a set of input data sets.
% In each data set, some variables can be latent and some can be
% manipulated. 
%

% function  [summaryGraph, inputpags, combinedPag] = COmbINE(datasets, fciParams, mpl, fName, outputName, screen) = FCI(DATASET, VARARGIN)
% Runs COmbINE algorithm for a set of input data sets. 
% author: striant@csd.uoc.gr
% =======================================================================
% Inputs
% =======================================================================
% datasets               = a struct of m data sets. each entry of the
%                          struct is a dataset struct with the following
%                          fields:
%    .data                = nSamples x nVars matrix containing the data
%                          (the actual graph for oracle data set)
%    .isLatent            = nVars x 1 boolean vector, true for latent
%                           variables
%    .isManipulated       = nVars x 1 boolean vector, true for manipulated
%                           variables  
%   .type                 = type of data set (discrete, gaussian, oracle)
%   .domain_counts        = nVars x 1 vector # of possible values for each 
%                           variable (discrete variables only)
%   .isAncestor           = nVars x nVars matrix (i, j)=true if i is an
%                           ancestor of j in true graph (oracle dataset only)
% =======================================================================
% =======================================================================
% Output
% =======================================================================
% summaryGraph           = struct describing the output pag, 
%   .graph               = nVars x nVars matrix, graph(i, j) =
%                                                        1 if i*~oj,
%                                                        2 if i*~>j,
%                                                        3 if i*~-j.
%   .direcEdges          = nVars x nVars, true if  i-j is solid in the
%                           output graph.
%   .dashedEdges         = nVars x nVars, true if  i~j is dashed in the
%                           output graph.
%   .ahat                = estimated parameter of teh beta distribution.
%   .pi0                 = estimated proportion of null hypotheses.
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fopen(fName, 'wt');
dlmwrite(fName, '1 REORDER tree', '-append','newline', 'unix', 'delimiter', '');
dlmwrite(fName, '0 LOAD', '-append','newline', 'unix', 'delimiter', '');
inputpags = generateInputPags(datasets, fciParams, screen);
[combinedPag, combine] = combinePagsConsistentOrientations(inputpags, screen);
variables = introduceVariables(combinedPag, combine,screen);
variables  = absentConstraints(fName,combinedPag, variables, combine, mpl, screen);
%fprintf('-------------DashedConstraints-----------\n');
variables = dashedConstraints(fName,combinedPag, variables, combine, mpl, screen);
%fprintf('-------------AncestralConstraints-----------\n');
variables = ancestralConstraints(fName, combinedPag, combine, variables, mpl, screen);
variables =  eColliderConstraints(fName, combinedPag, variables, screen); 
%fprintf('-------------colliderConstraints-----------\n');
%variables = colliderConstraints(fName, variables, comb, screen);

%fprintf('-------------CSstrategy-----------\n');
summaryGraph = sortConstraintsMR(inputpags, fName, outputName, combinedPag, variables, combine, screen);

end