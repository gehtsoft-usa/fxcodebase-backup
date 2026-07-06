-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3054
 
--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+


  function Init()
       indicator:name("Tic Tac Toe");
       indicator:requiredSource(core.Bar);
       indicator:type(core.Oscillator);
	   
	indicator.parameters:addColor("Color", "Color", "", core.COLOR_LABEL );
	 
   end
 
   local font;
   local font2;
   local source;
   
   local PLAY="X";  
   local NEW = true;
   local WIN=nil;   
   local Player={true,false};
   
   local Text="Normal"
   
   local Level = 75;
   
 
	local TEMP=nil;	
   
    local TEST=false;
  -- local timer;
   
    local Value ={3,2,3,2,4,2,3,2,3};
   local Label ={"1","2","3","4","5","6","7","8","9"};
   local X ={-100,0,100,-100,0,100,-100,0,100};
   local Y ={-100,-100,-100,0,0,0,100,100,100}
 
   function Prepare(nameOnly)
       source = instance.source;
	   instance:name(profile:id());
	   if nameOnly then
		return;
	   end
	   
	   
	    Color= instance.parameters.Color;   
       font = core.host:execute("createFont", "Courier", 20, true, false);
       font2 = core.host:execute("createFont", "Wingdings", 20, false, false);
	   
	        core.host:execute("addCommand", 1, "New Game", "New Game");
	 
	    local i;
	   
	   for i = 1 , 9 , 1 do 
	     
		
		-- if Player[1] then 
	      core.host:execute("addCommand", i*10+1, i  .. "X",  i  .. "X");
		
		
		-- if Player[2] then 
		  core.host:execute("addCommand", i*10+2, i  .. "O",  i  .. "O");
		 -- end
		
		end  
		
		core.host:execute("addCommand", 101, "First Player Change Type",  "First Player Change Type");
		core.host:execute("addCommand", 102, "Second Player Change Type",  "Second Player Change Type");
		
		--if   Level ~= 1 then
		core.host:execute("addCommand",201, "Set Difficulty to Easy",  "Set Difficulty to Easy");
		--end
		--if   Level ~=2 then
		core.host:execute("addCommand",202, "Set Difficulty to Normal",  "Set Difficulty to Normal");
		--end
		--if  Level ~=3 then
		core.host:execute("addCommand",203, "Set Difficulty to Hard",  "Set Difficulty to Hard");
	--	end
   
	   
	 
	   
	
		
   end
 
   function Update(period, mode)
      
   
		 if NEW then
						 core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Select New Game");		
		end				  
	
   end
 
   function ReleaseInstance()
       core.host:execute("deleteFont", font);
       core.host:execute("deleteFont", font2);
   end
  

function AsyncOperationFinished(cookie, success, message)

   
	   
	
	
	
	 if cookie == 201 then	
	 Level=50;
	 Text="Easy"
	 end
	 
	  if cookie == 202 then	
	   Level=75;
	    Text="Normal"
	 end
	 
	  if cookie == 203 then	
	   Level=90;
	    Text="Hard"
	 end
	 
	 
	 
	
	 
				
	 if cookie == 1 then	
	Label ={"1","2","3","4","5","6","7","8","9"};
	Value ={3,2,3,2,4,2,3,2,3};
	PLAY="X";
	NEW = false;
	WIN=nil
	TEST=false;
	   Player={true,false};
	  
	  core.host:execute ("removeAll");
		

        for i=1,9,1 do
		 core.host:execute("drawLabel1", i,X[i], core.CR_CENTER,Y[i], core.CR_CENTER, core.H_Center, core.V_Center,
                          font,Color,  Label[i]);
		end			
		
		
		if Player[1] then
		
		 core.host:execute("drawLabel1", 20, 300, core.CR_CENTER, -100, core.CR_CENTER, core.H_Center, core.V_Center,
                          font,Color,  "X (Human)" );	
		else
		core.host:execute("drawLabel1", 20, 300, core.CR_CENTER, -100, core.CR_CENTER, core.H_Center, core.V_Center,
                          font, Color,  "X (Computer)" );	
		end
		
		
       if Player[2] then		
		core.host:execute("drawLabel1", 30, 300, core.CR_CENTER, 0, core.CR_CENTER, core.H_Center, core.V_Center,
                          font, Color,  "O (Human)" );		
       else						  
	   core.host:execute("drawLabel1", 30, 300, core.CR_CENTER, 0, core.CR_CENTER, core.H_Center, core.V_Center,
                          font, Color,  "O (Computer)" );		
		end				  
	
    end
	
		
		
	
	
	
	local i;
	
	if   cookie == 101 then
	
			if Player[1] then
			Player[1] = false;
			else
			Player[1] = true;
			end
			
	elseif cookie == 102 then
	
	        if Player[2] then
			Player[2] = false;
			else
			Player[2] = true;
			end
	end
	

	if not Player[1] and  not Player[2] then
	
	core.host:execute ("removeAll");
	
	core.host:execute("drawLabel1", 500,-300, core.CR_CENTER,200, core.CR_CENTER, core.H_Center, core.V_Center,
                          font, Color,  " Is Not allowed to Have Both AI Players" );	
    core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,-200, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Select New Game");							  
   		
	
	end
 	
	  core.host:execute("drawLabel1", 300, 300, core.CR_CENTER,100, core.CR_CENTER, core.H_Center, core.V_Center,
                                    font, Color,  " Difficulty ( "..  Text.. ") " );	 
	          
	
	if not NEW  then
	
	
				
	
	
			for i= 1 , 9 , 1 do			 
			
			
			
			   if  cookie == 10*i + 1   or   cookie == 10*i + 2 then  
			    if  Label[i]=="X" or Label[i]=="O"  then
				
				core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Already selected");	 
				break;			  
				end
			   end
			   
			      if cookie == 10*i + 1  and  PLAY=="O" and   Player[1]   then
				 core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "It's not your turn");
			  break;
			   end
			   
			   
			     if   cookie == 10*i + 2  and PLAY=="X" and  Player[2] then
				 core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "It's not your turn");
			 break;
			   end
			
			   
			
				if cookie == 10*i + 1 and  PLAY=="X"  and Player[1] then	
				Label[i]= "X";	  
                PLAY="O";		
				core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "");	
              -- break;			
                end
				
				if cookie == 10*i + 2   and  PLAY=="O"   and Player[2]then	
				Label[i]= "O";	
                PLAY="X";  
				core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "");	
               --break;				
                end				
				
					
			
				
						  
				end
			
			end
			
			  Check ();
			
			if TEST then
		
	  
		
		    if  WIN == "O" or WIN == "X"  then
		    core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  tostring(WIN) .. " won the game.");	 
								  
			core.host:execute("drawLabel1", 10,-300, core.CR_CENTER,-200, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Select New Game");							  
			--NEW = true;		
            PLAY=nil;			
			elseif WIN == nil then
			core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Draw");
			core.host:execute("drawLabel1", 10,-300, core.CR_CENTER,-200, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Select New Game");	
			--NEW = true;	
             PLAY=nil;	 			
            end			
          						  
		end
			
			TEMP= nil;
			
			--Block
			
				  if math.random(1,100) < Level  then
			  
			   if PLAY == "X" and  not Player[1] and  Player[1]  ~= Player[2] and TEMP == nil then 
			   
			    
			    if   Link ("X", "O")==nil then
				
				         TEMP= Link ("O", "X"); 
						 if TEMP~=nil   then 	
						 Label[TEMP]= "X";
						 PLAY="O";	
						 end
               end
			   end
			   
			   
               if PLAY == "O" and  not Player[2]  and  Player[1]  ~= Player[2]  and TEMP == nil then	
			   
               
			    if Link ("O", "X") ==nil then
				          TEMP=  Link ("X", "O");
						 if TEMP~=nil   then 							 
						 Label[TEMP]= "O";
						 PLAY="X";	
				         end
 			   end
			   end
			   
			   
			 end
			
			--Link
			
			   if  math.random(1,100) < Level    then
			  
			   if PLAY == "X" and  not Player[1] and  Player[1]  ~= Player[2] and TEMP == nil then 
			   
			   			   
			   TEMP= Link ("X", "O");  			   
			    if TEMP~=nil then 	
				 Label[TEMP]= "X";
				 PLAY="O";	
				 end
               end
			   
			 
			   
			  
			   
               if PLAY == "O" and  not Player[2]  and  Player[1]  ~= Player[2]  and TEMP == nil then			
               TEMP=  Link ("O", "X"); 
                 if TEMP~=nil then 	
				 Label[TEMP]= "O";
				 PLAY="X";	
				 end
 			   
			  
			   end
			   
			 end
		
			
			
			 if math.random(1,100) < Level  then
			
			    if PLAY == "X" and  not Player[1] and  Player[1]  ~= Player[2] and TEMP == nil then				
				TEMP=AI (true,"O");	
                if TEMP~=nil then 				
				Label[TEMP]= "X";
				end
				PLAY="O";	
				end
				
				if PLAY == "O" and  not Player[2]  and  Player[1]  ~= Player[2]  and TEMP == nil then
		    	 TEMP=  AI (true,"X");
				 if TEMP~=nil then 	
				 Label[TEMP]= "O";
				 PLAY="X";	
				 end
	            end
				
			end

             
			    if PLAY == "X" and  not Player[1] and  Player[1]  ~= Player[2] and TEMP == nil then				
				TEMP=AI (false, "O");	
                if TEMP~=nil then 				
				Label[TEMP]= "X";
				end
				PLAY="O";	
				end
				
				if PLAY == "O" and  not Player[2]  and  Player[1]  ~= Player[2]  and TEMP == nil then
		    	 TEMP=  AI (false, "X");
				 if TEMP~=nil then 	
				 Label[TEMP]= "O";
				 PLAY="X";	
				 end
	            end

			 
		     
			
			 Check ();
				  
       
		
		
		if TEST then
		
	
		
		    if  WIN == "O" or WIN == "X"  then
		    core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  tostring(WIN) .. " won the game.");	 
								  
			core.host:execute("drawLabel1", 10,-300, core.CR_CENTER,-200, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Select New Game");							  
			--NEW = true;		
            PLAY=nil;			
			elseif WIN == nil then
			core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Draw");
			core.host:execute("drawLabel1", 10,-300, core.CR_CENTER,-200, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Select New Game");	
			--NEW = true;	
             PLAY=nil;	 			
            end			
          						  
		end
		
		 
		
		
		for i=1,9,1 do
		 core.host:execute("drawLabel1", i,X[i], core.CR_CENTER,Y[i], core.CR_CENTER, core.H_Center, core.V_Center,
                          font, Color,  Label[i]);
		end					 
		
		
		
		
   			
        if not NEW and PLAY~=nil  and  ( Player[1] or Player[2] ) then 			
		 core.host:execute("drawLabel1", 10,-300, core.CR_CENTER,-100, core.CR_CENTER, core.H_Center, core.V_Center,
                          font, Color,  PLAY .. " It's your turn" );	
       			
        end 
		
		
		if Player[1] then
		
		 core.host:execute("drawLabel1", 20, 300, core.CR_CENTER, -100, core.CR_CENTER, core.H_Center, core.V_Center,
                          font, Color,  "X (Human)" );	
		else
		core.host:execute("drawLabel1", 20, 300, core.CR_CENTER, -100, core.CR_CENTER, core.H_Center, core.V_Center,
                          font, Color,  "X (Computer)" );	
		end
		
		
       if Player[2] then		
		core.host:execute("drawLabel1", 30, 300, core.CR_CENTER, 0, core.CR_CENTER, core.H_Center, core.V_Center,
                          font, Color,  "O (Human)" );		
       else						  
	   core.host:execute("drawLabel1", 30, 300, core.CR_CENTER, 0, core.CR_CENTER, core.H_Center, core.V_Center,
                          font, Color,  "O (Computer)" );		
		end				  
		
		
		if TEST then
		
	
		
		    if  WIN == "O" or WIN == "X"  then
		    core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  tostring(WIN) .. " won the game.");	 
								  
			core.host:execute("drawLabel1", 10,-300, core.CR_CENTER,-200, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Select New Game");							  
			--NEW = true;		
            PLAY=nil;			
			elseif WIN == nil then
			core.host:execute("drawLabel1", 11,-300, core.CR_CENTER,0, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Draw");
			core.host:execute("drawLabel1", 10,-300, core.CR_CENTER,-200, core.CR_CENTER, core.H_Center, core.V_Center,
								  font, Color,  "Select New Game");	
			--NEW = true;	
             PLAY=nil;	 			
            end			
          						  
		end		
			
	end

function Check ()

   if  Label [1]==   Label [2] and  Label [2]  ==  Label [3] then
   WIN= Label [1];
  TEST= true;    
   elseif  Label [4]==   Label [5] and  Label [5]  ==  Label [6] then
    WIN= Label [4];
   TEST= true;  
   elseif  Label [7]==   Label [8] and  Label [8]  ==  Label [9] then
    WIN= Label [7];
  TEST= true;    
   
   elseif  Label [1]==   Label [4] and  Label [4]  ==  Label [7] then
    WIN= Label [1];
   TEST= true;    
   elseif  Label [2]==   Label [5] and  Label [5]  ==  Label [8] then
    WIN= Label [2];
   TEST= true;  
   elseif  Label [3]==   Label [6] and  Label [6]  ==  Label [9] then
    WIN= Label [3];
   TEST= true;   
   
   elseif  Label [1]==   Label [5] and  Label [5]  ==  Label [9] then
    WIN= Label [1];
  TEST= true;   
   elseif  Label [7]==   Label [5] and  Label [5]  ==  Label [3] then
    WIN= Label [7];
   TEST= true;  
   
   elseif   (Label [1] ~= "1" and Label [2] ~= "2" and Label [3] ~= "3" and Label [4] ~= "4" and Label [5] ~= "5" ) and  (Label [6] ~= "6" and Label [7] ~= "7" and Label [8] ~= "8" and Label [9] ~= "9") then
    WIN= nil;
   TEST= true; 
   
   else
   TEST= false;   
   end
   
   
end

function AI (ON, GAME) 
local i;
local MAX=0
Value ={3,2,3,2,4,2,3,2,3};

Evaluation (GAME);

  	local VALUE;

	for  i = 1 , 9 , 1 do
	
	        if ON then 
			
			      
				  
					if  Label[i]~= "X" and  Label[i]~= "O" then
					
					if   MAX == 0 then 
	                MAX = Value[i];
					VALUE= i;
				    end
					
					  if MAX < Value[i]  then
							 MAX = Value[i];
							 VALUE= i;
					  end
					end 
					
			
			
			else
			
			if  Label[i]~= "X" and  Label[i]~= "O" then
					
					VALUE=i;
					  break;
					end 
			
			end
	end
	
	 return VALUE;

end
  
  
  function Link (TAG,FLAG)
  
  --123
   if  Label [1]== TAG  and   Label [2] == TAG and   Label [3] ~= FLAG then
   return 3;
   elseif  Label [1] == TAG  and   Label [3] == TAG and   Label [2] ~= FLAG then
   return 2;
   elseif  Label [2] == TAG  and   Label [3] == TAG  and   Label [1] ~= FLAG then
   return 1;
   elseif  Label [4]== TAG  and   Label [5] == TAG  and   Label [6] ~= FLAG  then
   return 6;
   elseif  Label [4] == TAG  and   Label [6] == TAG and   Label [5] ~= FLAG then
   return 5;
   elseif  Label [5] == TAG  and   Label [6] == TAG and   Label [4] ~= FLAG then
   return 4;
   elseif   Label [7]== TAG  and   Label [8] == TAG  and   Label [9] ~= FLAG  then
   return 9;
   elseif  Label [7] == TAG  and   Label [9] == TAG and   Label [8] ~= FLAG  then
   return 8;
   elseif  Label [8] == TAG  and   Label [9] == TAG  and   Label [7] ~= FLAG then
   return 7;
   elseif Label [1]== TAG  and   Label [4] == TAG   and   Label [7] ~= FLAG then
   return 7;
   elseif  Label [1] == TAG  and   Label [7] == TAG  and   Label [4] ~= FLAG then
   return 4;
   elseif  Label [4] == TAG  and   Label [7] == TAG  and   Label [1] ~= FLAG then
   return 1;
   elseif  Label [2]== TAG  and   Label [5] == TAG   and   Label [8] ~= FLAG then
   return 8;
   elseif  Label [2] == TAG  and   Label [8] == TAG  and   Label [5] ~= FLAG then
   return 5;
   elseif  Label [5] == TAG  and   Label [8] == TAG and   Label [2] ~= FLAG then
   return 2;
  elseif  Label [3]== TAG  and   Label [6] == TAG and   Label [9] ~= FLAG  then
   return 9;
   elseif  Label [3] == TAG  and   Label [9] == TAG  and   Label [6] ~= FLAG then
   return 6;
   elseif  Label [6] == TAG  and   Label [9] == TAG  and   Label [3] ~= FLAG then
   return 3;
   elseif  Label [1]== TAG  and   Label [5] == TAG and   Label [9] ~= FLAG  then
   return 9;
   elseif  Label [1] == TAG  and   Label [9] == TAG and   Label [5] ~= FLAG then
   return 5;
   elseif  Label [5] == TAG  and   Label [9] == TAG and   Label [1] ~= FLAG then
   return 1;
  elseif  Label [3]== TAG  and   Label [5] == TAG  and   Label [7] ~= FLAG then
   return 7;
   elseif  Label [3] == TAG  and   Label [7] == TAG and   Label [5] ~= FLAG then
   return 5;
   elseif  Label [5] == TAG  and   Label [7] == TAG and   Label [3] ~= FLAG then
   return 3;
   else   
   return nil ;
   end
   
end

function Evaluation (TAG)


if Label [1]== TAG  or Label [2]== TAG or Label [2]== TAG then
Value[1]=Value[1]-1;
Value[2]=Value[1]-1;
Value[3]=Value[1]-1;
end



if Label [4]== TAG  or Label [5]== TAG or Label [6]== TAG then
Value[4]=Value[4]-1;
Value[5]=Value[5]-1;
Value[6]=Value[6]-1;
end


if Label [7]== TAG  or Label [8]== TAG or Label [9]== TAG then
Value[7]=Value[7]-1;
Value[8]=Value[8]-1;
Value[9]=Value[9]-1;
end

if Label [1]== TAG  or Label [4]== TAG or Label [7]== TAG then
Value[1]=Value[1]-1;
Value[4]=Value[4]-1;
Value[7]=Value[7]-1;
end

if Label [2]== TAG  or Label [5]== TAG or Label [8]== TAG then
Value[2]=Value[2]-1;
Value[5]=Value[5]-1;
Value[8]=Value[8]-1;
end

if Label [3]== TAG  or Label [6]== TAG or Label [9]== TAG then
Value[3]=Value[3]-1;
Value[6]=Value[6]-1;
Value[9]=Value[9]-1;
end

if Label [1]== TAG  or Label [5]== TAG or Label [9]== TAG then
Value[1]=Value[1]-1;
Value[5]=Value[5]-1;
Value[9]=Value[9]-1;
end

if Label [3]== TAG  or Label [5]== TAG or Label [7]== TAG then
Value[3]=Value[3]-1;
Value[5]=Value[5]-1;
Value[7]=Value[7]-1;
end


end


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+