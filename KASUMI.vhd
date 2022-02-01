LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY KASUMI IS 
    PORT (clk, nrst   : IN    std_logic;
          input       : IN    std_logic_vector(63 DOWNTO 0);
		  key         : IN    std_logic_vector(127 DOWNTO 0);
		  output      : OUT   std_logic_vector(63 DOWNTO 0));
END KASUMI; 
ARCHITECTURE behavioral OF KASUMI IS
	
	
	-- ************************************** functions *****************************************
	
	--******************* FL Function ****************
	subtype FL_typeOne is std_logic_vector(31 downto 0);
	subtype FL_typeTwo is std_logic_vector(15 downto 0);
	
	FUNCTION FL_Function(I 			: FL_typeOne;
						 KLOne	 	: FL_typeTwo;
						 KLTwo	 	: FL_typeTwo) return FL_typeOne is
        variable KL, answer 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
		variable L, R, Lprime, Rprime		: STD_LOGIC_VECTOR(15 DOWNTO 0);
    begin
        L  := I(31 DOWNTO 16);
		R  := I(15 DOWNTO 0 );
		
		Rprime := R XOR (STD_LOGIC_VECTOR(rotate_left(unsigned((L AND KLOne)), 1)));
		Lprime := L XOR (STD_LOGIC_VECTOR(rotate_left(unsigned((Rprime OR KLTwo)), 1)));
		
		answer := Lprime & Rprime;
		--answer := (L XOR (STD_LOGIC_VECTOR(rotate_left(unsigned((Rprime OR KLTwo)), 1)))) & (R XOR (STD_LOGIC_VECTOR(rotate_left(unsigned((L AND KLOne)), 1))));
		
		return answer;
    end function;
	
	
	
	--******************* FI Function ****************
	subtype FI_typeOne is std_logic_vector(15 downto 0);
	
	FUNCTION FI_Function(I 			: FI_typeOne;
						 KI_key	 	: FI_typeOne) return FI_typeOne is
		type Array_Four  is array (0 to 127) of INTEGER;
		type Array_Five  is array (0 to 511) of INTEGER;	
		
        variable answer 			: STD_LOGIC_VECTOR(15 DOWNTO 0);
		variable LZero	 : STD_LOGIC_VECTOR(8 DOWNTO 0);
		variable LOne	 : STD_LOGIC_VECTOR(6 DOWNTO 0);
		variable LTwo    : STD_LOGIC_VECTOR(8 DOWNTO 0);
		variable LThree  : STD_LOGIC_VECTOR(6 DOWNTO 0);
		variable LFour   : STD_LOGIC_VECTOR(6 DOWNTO 0);
		variable RZero	 : STD_LOGIC_VECTOR(6 DOWNTO 0);
		variable ROne	 : STD_LOGIC_VECTOR(8 DOWNTO 0);
		variable RTwo    : STD_LOGIC_VECTOR(6 DOWNTO 0);
		variable RThree  : STD_LOGIC_VECTOR(8 DOWNTO 0);
		variable RFour   : STD_LOGIC_VECTOR(8 DOWNTO 0);
		
		variable KIOne							  : STD_LOGIC_VECTOR(6 DOWNTO 0);
		variable KITwo							  : STD_LOGIC_VECTOR(8 DOWNTO 0);
		--S Boxes Decimal table
		variable S_Seven_DecimalTable			  : Array_Four := (54, 50, 62, 56, 22, 34, 94, 96, 38,  6, 63, 93, 2,  18,123, 33,
																   55,113, 39,114, 21, 67, 65, 12, 47, 73, 46, 27, 25,111,124, 81,
																   53,  9,121, 79, 52, 60, 58, 48,101,127, 40,120,104, 70, 71, 43,
																   20,122, 72, 61, 23,109, 13,100, 77,  1, 16,  7, 82, 10,105, 98,
																   117,116, 76, 11, 89,106,  0,125,118, 99, 86, 69, 30, 57,126, 87,
																   112, 51, 17,  5, 95, 14, 90, 84, 91,  8, 35,103, 32, 97, 28, 66,
																   102, 31, 26, 45, 75,  4, 85, 92, 37, 74, 80, 49, 68, 29,115, 44,
																   64,107,108, 24,110, 83, 36, 78, 42, 19, 15, 41, 88,119, 59,  3);
																   	
		--S Boxes Decimal table
		variable S_Nine_DecimalTable			  : Array_Five := (167,239,161,379,391,334,  9,338, 38,226, 48,358,452,385, 90,397,
																  183,253,147,331,415,340, 51,362,306,500,262, 82,216,159,356,177,
																  175,241,489, 37,206, 17,  0,333, 44,254,378, 58,143,220, 81,400,
																  95,  3,315,245, 54,235,218,405,472,264,172,494,371,290,399, 76,
																  165,197,395,121,257,480,423,212,240, 28,462,176,406,507,288,223,
																  501,407,249,265, 89,186,221,428,164, 74,440,196,458,421,350,163,
																  232,158,134,354, 13,250,491,142,191, 69,193,425,152,227,366,135,
																  344,300,276,242,437,320,113,278, 11,243, 87,317, 36, 93,496, 27,
																  487,446,482, 41, 68,156,457,131,326,403,339, 20, 39,115,442,124,
																  475,384,508, 53,112,170,479,151,126,169, 73,268,279,321,168,364,
																  363,292, 46,499,393,327,324, 24,456,267,157,460,488,426,309,229,
																  439,506,208,271,349,401,434,236, 16,209,359, 52, 56,120,199,277,
																  465,416,252,287,246,  6, 83,305,420,345,153,502, 65, 61,244,282,
																  173,222,418, 67,386,368,261,101,476,291,195,430, 49, 79,166,330,
																  280,383,373,128,382,408,155,495,367,388,274,107,459,417, 62,454,
																  132,225,203,316,234, 14,301, 91,503,286,424,211,347,307,140,374,
																  35,103,125,427, 19,214,453,146,498,314,444,230,256,329,198,285,
																  50,116, 78,410, 10,205,510,171,231, 45,139,467, 29, 86,505, 32,
																  72, 26,342,150,313,490,431,238,411,325,149,473, 40,119,174,355,
																  185,233,389, 71,448,273,372, 55,110,178,322, 12,469,392,369,190,
																  1,109,375,137,181, 88, 75,308,260,484, 98,272,370,275,412,111,
																  336,318,  4,504,492,259,304, 77,337,435, 21,357,303,332,483, 18,
																  47, 85, 25,497,474,289,100,269,296,478,270,106, 31,104,433, 84,
																  414,486,394, 96, 99,154,511,148,413,361,409,255,162,215,302,201,
																  266,351,343,144,441,365,108,298,251, 34,182,509,138,210,335,133,
																  311,352,328,141,396,346,123,319,450,281,429,228,443,481, 92,404,
																  485,422,248,297, 23,213,130,466, 22,217,283, 70,294,360,419,127,
																  312,377,  7,468,194,  2,117,295,463,258,224,447,247,187, 80,398,
																  284,353,105,390,299,471,470,184, 57,200,348, 63,204,188, 33,451,
																  97, 30,310,219, 94,160,129,493, 64,179,263,102,189,207,114,402,
																  438,477,387,122,192, 42,381,  5,145,118,180,449,293,323,136,380,
																  43, 66, 60,455,341,445,202,432,  8,237, 15,376,436,464, 59,461);
		--variable S_Seven_input, S_Seven_output	:integer;
		--variable S_Nine_input, S_Nine_output	:integer;
		--variable S_Seven_input_STD, S_Seven_output_STD				:STD_LOGIC_VECTOR(6 DOWNTO 0);
		--variable S_Nine_input_STD, S_Nine_output_STD				:STD_LOGIC_VECTOR(8 DOWNTO 0);
		begin
		
        KIOne  := KI_key(15 DOWNTO 9);
		KITwo  := KI_key( 8 DOWNTO 0 );
		
		LZero := I(15 DOWNTO 7);
		RZero := I(6 DOWNTO 0);
		
		LOne := RZero;
		ROne := (STD_LOGIC_VECTOR(TO_UNSIGNED(S_Nine_DecimalTable(CONV_INTEGER(LZero)), 9))) XOR ("00" & RZero);
		
		LTwo := ROne XOR KITwo;
		RTwo := (STD_LOGIC_VECTOR(TO_UNSIGNED(S_Seven_DecimalTable(CONV_INTEGER(LOne)), 7))) XOR ROne(6 DOWNTO 0) XOR KIOne;
		
		LThree := RTwo;
		RThree := (STD_LOGIC_VECTOR(TO_UNSIGNED(S_Nine_DecimalTable(CONV_INTEGER(LTwo)), 9))) XOR ("00" & RTwo);
		
		LFour := (STD_LOGIC_VECTOR(TO_UNSIGNED(S_Seven_DecimalTable(CONV_INTEGER(LThree)), 7))) XOR RThree(6 DOWNTO 0);
		RFour := RThree;
		
		answer := LFour & RFour;
		--answer := ((STD_LOGIC_VECTOR(TO_UNSIGNED(S_Seven_DecimalTable(CONV_INTEGER(LThree)), 7))) XOR RThree(6 DOWNTO 0)) & RThree; 
		
		return answer;
    end function;
	
	
	--******************* FO Function ****************
	subtype FO_typeOne is std_logic_vector(31 downto 0);
	subtype FO_typeTwo is std_logic_vector(15 downto 0);
	
	FUNCTION FO_Function(I 			: FO_typeOne;
						 KOOne	 	: FO_typeTwo;
						 KOTwo	 	: FO_typeTwo;
						 KOThree	: FO_typeTwo;
						 KIOne	 	: FO_typeTwo;
						 KITwo	 	: FO_typeTwo;
						 KIThree	: FO_typeTwo) return FO_typeOne is
		variable LZero, LOne, LTwo, LThree, RZero, ROne, RTwo, RThree, Lprime, Rprime, tempOne, tempTwo, tempThree	: STD_LOGIC_VECTOR(15 DOWNTO 0);
		variable answer : std_logic_vector(31 DOWNTO 0);
    begin
        LZero := I(31 DOWNTO 16);
		RZero := I(15 DOWNTO 0 );
		
		tempOne := LZero XOR KOOne;
		ROne := RZero XOR (FI_Function(I => tempOne, KI_key => KIOne));
		LOne := RZero;
		
		tempTwo := LOne XOR KOTwo;
		RTwo := ROne XOR (FI_Function(I => tempTwo, KI_key => KITwo));
		LTwo := ROne;
		
		tempThree := LTwo XOR KOThree;
		RThree := RTwo XOR (FI_Function(I => tempThree, KI_key => KIThree));
		LThree := RTwo;
		
		answer := LThree & RThree;
		--answer := RTwo & (RTwo XOR (FI_Function(I => tempThree, KI_key => KIThree)));
		
		return answer;
    end function;
	
	
	
	--***************** defining types ****************

    TYPE state IS (S0, S1, S2, S3, S4, S5, S6, S7, S8);
	
	type Array_Zero  is array (0 to 8) of std_logic_vector(31 DOWNTO 0);
	type Array_One   is array (1 to 8) of std_logic_vector(15 DOWNTO 0);
	type Array_Two   is array (1 to 8) of std_logic_vector(31 DOWNTO 0);
	type Array_Three is array (1 to 8) of std_logic_vector(47 DOWNTO 0);
	
	
	

BEGIN

    PROCESS (clk)
	
	-- **************** defining variables ******************
	VARIABLE cur_state 	: state := S0;
	VARIABLE nxt_state 	: state := S1;
	
	variable input_save   : STD_LOGIC_VECTOR(63 DOWNTO  0) := (OTHERS => 'Z');
	
	variable key_save     : STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => 'Z');
	
	variable L			: Array_Zero:= (others => (others => 'Z'));
	variable R			: Array_Zero:= (others => (others => 'Z'));
	

	
	variable k 		    : Array_One := (others => (OTHERS => 'Z'));
	variable c	: Array_One := (X"0123", X"4567", X"89AB", X"CDEF", X"FEDC", X"BA98", X"7654", X"3210");
	variable kPrim        : Array_One := (others => (OTHERS => 'Z'));
	
	variable KL_one       : Array_One := (others => (OTHERS => 'Z'));
	variable KL_two       : Array_One := (others => (OTHERS => 'Z'));
	
	variable KO_one       : Array_One := (others => (OTHERS => 'Z'));
	variable KO_two		: Array_One := (others => (OTHERS => 'Z'));
	variable KO_three		: Array_One := (others => (OTHERS => 'Z'));
	
	variable KI_one       : Array_One := (others => (OTHERS => 'Z'));
	variable KI_two		: Array_One := (others => (OTHERS => 'Z'));
	variable KI_three		: Array_One := (others => (OTHERS => 'Z'));
	
	variable FI 			: STD_LOGIC_VECTOR(31 DOWNTO 0) :=(others => 'Z');
	variable FL			: STD_LOGIC_VECTOR(31 DOWNTO 0) :=(others => 'Z');
	variable FO			: STD_LOGIC_VECTOR(31 DOWNTO 0) :=(others => 'Z');
	
	
    BEGIN
        IF nrst = '0' THEN
			output <= (OTHERS => 'Z');
			cur_state := S0;
			nxt_state := S1;
		ELSIF RISING_EDGE(clk) THEN
			IF (input_save /= input) OR (key_save /= key) THEN
				cur_state := S0;
			END IF;
			
			IF cur_state = S0 THEN
				nxt_state := S1;
	
				input_save := input;
				key_save   := key;
				
				-- making array of the input key
				--FOR item IN 8 DOWNTO 1 LOOP
				--	K(9 - item) := key((item * 16) - 1 DOWNTO (item * 16) - 16);
				--END LOOP;
				K(1) := key(127 DOWNTO 112);
				K(2) := key(111 DOWNTO 96);
				K(3) := key(95 DOWNTO 80);
				K(4) := key(79 DOWNTO 64);
				K(5) := key(63 DOWNTO 48);
				K(6) := key(47 DOWNTO 32);
				K(7) := key(31 DOWNTO 16);
				K(8) := key(15 DOWNTO 0);
				
				
				--making the k' array
				--FOR item IN 8 DOWNTO 1 LOOP
				--	kPrim(item) := K(item) XOR c(item);
				--END LOOP;
				kPrim(1) := K(1) XOR c(1);
				kPrim(2) := K(2) XOR c(2);
				kPrim(3) := K(3) XOR c(3);
				kPrim(4) := K(4) XOR c(4);
				kPrim(5) := K(5) XOR c(5);
				kPrim(6) := K(6) XOR c(6);
				kPrim(7) := K(7) XOR c(7);
				kPrim(8) := K(8) XOR c(8);
				
				--making KL1 array
				--FOR item IN 8 DOWNTO 1 LOOP
				--	KL_one(item) := STD_LOGIC_VECTOR(shift_left(unsigned(K(item)) , 1));
				--END LOOP;
				KL_one(1) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(1)) , 1));
				KL_one(2) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(2)) , 1));
				KL_one(3) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(3)) , 1));
				KL_one(4) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(4)) , 1));
				KL_one(5) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(5)) , 1));
				KL_one(6) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(6)) , 1));
				KL_one(7) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(7)) , 1));
				KL_one(8) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(8)) , 1));
				
				--making KL2 array
				KL_two(1) := kPrim(3);
				KL_two(2) := kPrim(4);
				KL_two(3) := kPrim(5);
				KL_two(4) := kPrim(6);
				KL_two(5) := kPrim(7);
				KL_two(6) := kPrim(8);
				KL_two(7) := kPrim(1);
				KL_two(8) := kPrim(2);
				
				
				--making KO1 array
				--FOR item IN 1 TO 7 LOOP
				--	KO_one(item) := STD_LOGIC_VECTOR(shift_left(unsigned(K(item + 1)) , 5));
				--END LOOP;
				
				KO_one(1) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(2)) , 5));
				KO_one(2) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(3)) , 5));
				KO_one(3) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(4)) , 5));
				KO_one(4) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(5)) , 5));
				KO_one(5) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(6)) , 5));
				KO_one(6) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(7)) , 5));
				KO_one(7) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(8)) , 5));
				KO_one(8) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(1)) , 5));
											  
				--making KO2 array            
				KO_two(1) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(6)) , 8));
				KO_two(2) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(7)) , 8));
				KO_two(3) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(8)) , 8));
				KO_two(4) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(1)) , 8));
				KO_two(5) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(2)) , 8));
				KO_two(6) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(3)) , 8));
				KO_two(7) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(4)) , 8));
				KO_two(8) := STD_LOGIC_VECTOR(rotate_left(unsigned(K(5)) , 8));
				
				--making KO3 array
				--FOR item IN 3 TO 8 LOOP
				--	KO_three(item) := STD_LOGIC_VECTOR(shift_left(unsigned(K(item - 2)) , 13));
				--END LOOP;
				
				KO_three(1) := STD_LOGIC_VECTOR(rotate_Left(unsigned(K(7)) , 13));
				KO_three(2) := STD_LOGIC_VECTOR(rotate_Left(unsigned(K(8)) , 13));
				KO_three(3) := STD_LOGIC_VECTOR(rotate_Left(unsigned(K(1)) , 13));
				KO_three(4) := STD_LOGIC_VECTOR(rotate_Left(unsigned(K(2)) , 13));
				KO_three(5) := STD_LOGIC_VECTOR(rotate_Left(unsigned(K(3)) , 13));
				KO_three(6) := STD_LOGIC_VECTOR(rotate_Left(unsigned(K(4)) , 13));
				KO_three(7) := STD_LOGIC_VECTOR(rotate_Left(unsigned(K(5)) , 13));
				KO_three(8) := STD_LOGIC_VECTOR(rotate_Left(unsigned(K(6)) , 13));
				
				--making KI_one array
				KI_one(1) := kPrim(5);
				KI_one(2) := kPrim(6);
				KI_one(3) := kPrim(7);
				KI_one(4) := kPrim(8);
				KI_one(5) := kPrim(1);
				KI_one(6) := kPrim(2);
				KI_one(7) := kPrim(3);
				KI_one(8) := kPrim(4);
				
				--making KI_two array
				KI_two(1) := kPrim(4);
				KI_two(2) := kPrim(5);
				KI_two(3) := kPrim(6);
				KI_two(4) := kPrim(7);
				KI_two(5) := kPrim(8);
				KI_two(6) := kPrim(1);
				KI_two(7) := kPrim(2);
				KI_two(8) := kPrim(3);
				
				--making KI_three array
				--FOR item IN 2 TO 8 LOOP
				--	KI_three(item) := kPrim(item - 1);
				--END LOOP;
				
				KI_three(1) := kPrim(8);
				KI_Three(2) := kPrim(1);
				KI_Three(3) := kPrim(2);
				KI_Three(4) := kPrim(3);
				KI_Three(5) := kPrim(4);
				KI_Three(6) := kPrim(5);
				KI_Three(7) := kPrim(6);
				KI_Three(8) := kPrim(7);
				
				
				L(0) := input(63 DOWNTO 32);
				R(0) := input (31 DOWNTO 0);
				
					
			ELSIF cur_state = S1 THEN
				nxt_state := S2;
				
				--fi(I, RKi) = FO( FL( I, KLi), KOi, KIi )
				--which I is actually L(i-1)
				
				--first we need to find FL
				FL := FL_Function(I => L(0), KLOne => KL_one(1), KLTwo => KL_two(1));
				
				--now we find FO
				--which I is FL
				FI := FO_Function(I =>  FL, KOOne => KO_one(1), KOTwo => KO_two(1), KOThree => KO_three(1), KIOne => KI_one(1), KITwo => KI_two(1), KIThree => KI_three(1));
				
				R(1) := L(0);
				L(1) := R(0) XOR FI;
				
				--output(63 DOWNTO 32) <= FO_Function(I =>  FL_Function(I => L(0), KLOne => KL_one(1), KLTwo => KL_two(1)), KOOne => KO_one(1), KOTwo => KO_two(1), KOThree => KO_three(1), KIOne => KI_one(1), KITwo => KI_two(1), KIThree => KI_three(1));
				
			ELSIF cur_state = S2 THEN
				nxt_state := S3;
				
				--fi(I, RKi) = FL( FO( I, KOi, KIi ), KLi )
				--which I is actually L(i-1)
				
				--first we need to find FO
				FO := FO_Function(I =>  L(1), KOOne => KO_one(2), KOTwo => KO_two(2), KOThree => KO_three(2), KIOne => KI_one(2), KITwo => KI_two(2), KIThree => KI_three(2));
				
				--now we find FL
				--which I is FO
				FI := FL_Function(I => FO, KLOne => KL_one(2), KLTwo => KL_two(2));

				R(2) := L(1);
				L(2) := R(1) XOR FI;
				
				
				
			ELSIF cur_state = S3 THEN
				nxt_state := S4;
				
				--fi(I, RKi) = FO( FL( I, KLi), KOi, KIi )
				--which I is actually L(i-1)
				
				--first we need to find FL
				FL := FL_Function(I => L(2), KLOne => KL_one(3), KLTwo => KL_two(3));
				
				--now we find FO
				--which I is FL
				FI := FO_Function(I =>  FL, KOOne => KO_one(3), KOTwo => KO_two(3), KOThree => KO_three(3), KIOne => KI_one(3), KITwo => KI_two(3), KIThree => KI_three(3));
				
				R(3) := L(2);
				L(3) := R(2) XOR FI;
				
				
					
			ELSIF cur_state = S4 THEN
				nxt_state := S5;
				
				--fi(I, RKi) = FL( FO( I, KOi, KIi ), KLi )
				--which I is actually L(i-1)
				
				--first we need to find FO
				FO := FO_Function(I =>  L(3), KOOne => KO_one(4), KOTwo => KO_two(4), KOThree => KO_three(4), KIOne => KI_one(4), KITwo => KI_two(4), KIThree => KI_three(4));
				
				--now we find FL
				--which I is FO
				FI := FL_Function(I => FO, KLOne => KL_one(4), KLTwo => KL_two(4));
				
				R(4) := L(3);
				L(4) := R(3) XOR FI;
				
				
				
			ELSIF cur_state = S5 THEN
				nxt_state := S6;
				
				--fi(I, RKi) = FO( FL( I, KLi), KOi, KIi )
				--which I is actually L(i-1)
				
				--first we need to find FL
				FL := FL_Function(I => L(4), KLOne => KL_one(5), KLTwo => KL_two(5));
				
				--now we find FO
				--which I is FL
				FI := FO_Function(I =>  FL, KOOne => KO_one(5), KOTwo => KO_two(5), KOThree => KO_three(5), KIOne => KI_one(5), KITwo => KI_two(5), KIThree => KI_three(5));
				
				R(5) := L(4);
				L(5) := R(4) XOR FI;
				
				
			ELSIF cur_state = S6 THEN
				nxt_state := S7;
				
				--fi(I, RKi) = FL( FO( I, KOi, KIi ), KLi )
				--which I is actually L(i-1)
				
				--first we need to find FO
				FO := FO_Function(I =>  L(5), KOOne => KO_one(6), KOTwo => KO_two(6), KOThree => KO_three(6), KIOne => KI_one(6), KITwo => KI_two(6), KIThree => KI_three(6));
				
				--now we find FL
				--which I is FO
				FI := FL_Function(I => FO, KLOne => KL_one(6), KLTwo => KL_two(6));
				
				R(6) := L(5);
				L(6) := R(5) XOR FI;
				
				
			ELSIF cur_state = S7 THEN
				nxt_state := S8;
				
				--fi(I, RKi) = FO( FL( I, KLi), KOi, KIi )
				--which I is actually L(i-1)
				
				--first we need to find FL
				FL := FL_Function(I => L(6), KLOne => KL_one(7), KLTwo => KL_two(7));
				
				--now we find FO
				--which I is FL
				FI := FO_Function(I =>  FL, KOOne => KO_one(7), KOTwo => KO_two(7), KOThree => KO_three(7), KIOne => KI_one(7), KITwo => KI_two(7), KIThree => KI_three(7));
				
				R(7) := L(6);
				L(7) := R(6) XOR FI;
				
			ELSIF cur_state = S8 THEN
			--ELSE
				nxt_state := S0;
				
				--fi(I, RKi) = FL( FO( I, KOi, KIi ), KLi )
				--which I is actually L(i-1)
				
				--first we need to find FO
				FO := FO_Function(I =>  L(7), KOOne => KO_one(8), KOTwo => KO_two(8), KOThree => KO_three(8), KIOne => KI_one(8), KITwo => KI_two(8), KIThree => KI_three(8));
				
				--now we find FL
				--which I is FO
				FI := FL_Function(I => FO, KLOne => KL_one(8), KLTwo => KL_two(8));
				
				R(8) := L(7);
				L(8) := R(7) XOR FI;
				
				
				--output(63 DOWNTO 32) <= L(8);
				--output(31 DOWNTO  0) <= R(8);
				output <= L(8) & R(8);
				--output <= (R(7) XOR FL_Function(I => FO_Function(I =>  L(7), KOOne => KO_one(8), KOTwo => KO_two(8), KOThree => KO_three(8), KIOne => KI_one(8), KITwo => KI_two(8), KIThree => KI_three(8)), KLOne => KL_one(8), KLTwo => KL_two(8))) & L(7);
					
			END IF;
			
			cur_state := nxt_state;
			
			
		END IF;
    END PROCESS;

END behavioral;


-- ************************* test bench **************************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

ENTITY KASUMI_tb IS  
END KASUMI_tb;
ARCHITECTURE Test OF KASUMI_tb IS
	COMPONENT KASUMI IS 
		PORT (clk, nrst   : IN    std_logic;
			  input       : IN    std_logic_vector(63 DOWNTO 0);
			  key         : IN    std_logic_vector(127 DOWNTO 0);
			  output      : OUT   std_logic_vector(63 DOWNTO 0));
	END COMPONENT; 
	SIGNAL clk_t, nrst_t    :    std_logic;
	SIGNAL  input_t         :    std_logic_vector(63 DOWNTO 0);
	SIGNAL  key_t           :    std_logic_vector(127 DOWNTO 0);
	SIGNAL  output_t        :    std_logic_vector(63 DOWNTO 0);
	constant clk_period : time := 10 ns;
	
	
	
BEGIN

	cut: KASUMI PORT MAP (clk_t, nrst_t, input_t, key_t, output_t);


	clk_proc : process is
		begin
			clk_t <= '0';
			wait for clk_period/2;
			clk_t <= '1';
			wait for clk_period/2;
		end process clk_proc;
		
	Main_Process : process is
	begin
		
		input_t <= X"0000000000000000";
		key_t   <= X"00000000000000000000000000000000";
		nrst_t  <= '0', '1' after 5 ns;
		
		-- correct output : f54cfbf75f3b5699
		
		wait for 100 ns;
		input_t <= X"ABCDFEFD47837543";
		key_t   <= X"EEEEEEEEBBBBBDFDEAAAD34654123427";
		
		--correct output : f0cc3936ebd057aa
		
		wait for 100 ns;
		input_t <= X"ABCDEDCBADE26534";
		key_t   <= X"AB163427345384563BCDCDEA73957467";
		
		--correct output : 6ef29c1f75d98666
		
		wait for 100 ns;
		input_t <= X"647237236BCDAE27";
		key_t   <= X"ABCDAEDAEBACBE632785387545843536";
		
		--correct output : b0671fe3cf16116f
		
		wait;
		
	end process Main_Process;
END Test;	