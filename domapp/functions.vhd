LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

PACKAGE functions IS

	FUNCTION log2( input:INTEGER ) RETURN INTEGER;

END functions;



PACKAGE BODY functions IS 

	FUNCTION log2( input:INTEGER ) RETURN INTEGER IS
		VARIABLE	temp	: INTEGER;
		VARIABLE	log		: INTEGER;
	BEGIN
		temp	:= input;
		log		:= 0;
		WHILE (temp /= 0) LOOP
			temp	:= temp/2;
			log		:= log+1;
		END LOOP;
		RETURN log;
	END FUNCTION log2;

END functions;
