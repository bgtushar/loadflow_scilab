function runpf(alg, varargin)


 report=0;
 if(argn(2)> 2)
	disp('Error: The number of arguments must be less than 2');
 elseif(argn(2)==2)
	if(varargin(1)=='report')
		report=1;
	else
	 disp('Error: The 2nd argument is incorrect, type a valid argument');
	end
 end


if(alg == 'nr')
	 nrlf(report);


elseif ( alg == 'gs')
	gauss(report);

else
	disp('Error: The keyword is not correct');

end


endfunction 
