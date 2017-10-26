function [ output_mat ] = tack2tick( input_mat )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
input_mat = [ones(1,size(input_mat,2)) ;input_mat+1];
output_mat = ones(size(input_mat));
if size(input_mat,1)>1
   for i=2:size(input_mat,1)
       output_mat(i,:)=output_mat(i-1,:).*input_mat(i,:);
   end
else
error('Input mat length must be larger then 1') 
end

