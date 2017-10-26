function [ output_mat ] = tick2tack( input_mat )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if size(input_mat,1)>1
output_mat=input_mat(2:end,:)./input_mat(1:end-1,:)-1;
else
error('Input mat length must be larger then 1') 
end

