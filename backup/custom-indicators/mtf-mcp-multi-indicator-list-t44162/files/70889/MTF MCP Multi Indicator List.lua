-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=44162

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("MTF MCP Multi Indicator List");
    indicator:description("MTF MCP Multi Indicator List");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	
	
	indicator.parameters:addGroup("Time Frame Selector ");
	Parameters (1 , "m1" , false  );
	Parameters (2 , "m15" , false   );
	Parameters (3 , "m30" , false  );
	Parameters (4 , "H1"  , true   );
	Parameters (5 , "H2" , false    );
	Parameters (6 , "H3" , false     );
	Parameters (7 , "H4" , false    );
	Parameters (8 , "H8" , true    );
	Parameters (9 , "D1" , true     );
	Parameters (10 , "W1" , false    );	
	Parameters (11 , "M1" , false    );
	
   
    local iIndiccator={"STOCHASTIC", "RSI",  "CCI", "RLW","BEARSBULLSIMPULS", "MACD", "ADX", "DMI", "STOCHRSI", "MVA" , "MVA", "MVA", "MVA", "MVA", "EMA", "EMA", "EMA", "EMA", "EMA"};
	
	for i= 1 , 19, 1 do
    AddIndicator(i)
	end
	 
	
	indicator.parameters:addGroup("Levels");
	
	
    indicator.parameters:addInteger("SB", "Strong Buy", "", 15); 
    indicator.parameters:addInteger("B", "Buy", "", 12); 
	indicator.parameters:addInteger("S", "Sell", "", 12); 
	indicator.parameters:addInteger("SS", "Strong Sell", "", 15); 
	
	indicator.parameters:addGroup("Common Parameters");
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id .. " Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	
	
	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
 
end

function  AddIndicator(id)
   local Indiccator={"STOCHASTIC", "RSI",  "CCI", "RLW","BEARSBULLSIMPULS", "MACD", "ADX", "DMI", "STOCHRSI", "MVA" , "MVA", "MVA", "MVA", "MVA", "EMA", "EMA", "EMA", "EMA", "EMA"};	 
	indicator.parameters:addGroup(id.. ". Indicator Selector ");
	
	if id > 9 then 
	indicator.parameters:addBoolean("Use"..id , "Use This Indicator", "", false);	
	else
	indicator.parameters:addBoolean("Use"..id , "Use This Indicator", "", true);	
	end
	indicator.parameters:addString("I" ..id,  id .. ". Indicator", "", Indiccator[id]);
    indicator.parameters:setFlag("I"..id ,core.FLAG_INDICATOR);
end

local Use={};
local I={"STOCHASTIC", "RSI", "CCI", "RLW", "BEARSBULLSIMPULS", "MACD", "ADX", "DMI", "STOCHRSI", "MVA", "MVA", "MVA", "MVA", "MVA", "EMA", "EMA", "EMA", "EMA", "EMA"};
local loading={};
local SourceData={};
local Indicator={};
local Pair;
local font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first;
local Test={};
local Count;
local Up, Down, No, LabelColor;
local N={};
local Shift;
local On={};
local Num;
local  iprofile= {};	
local  iparams= {};
local Number={};
local  tprofile= {};	
local  tparams= {};
local SB, SS, S, B;
 
local kMAX;
local Code={};

function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		 core.host:execute ("killTimer", 1);
 end  

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	Shift=instance.parameters.Shift; 
    source = instance.source;
	SS=instance.parameters.SS;
	SB=instance.parameters.SB;
	B=instance.parameters.B;
	S=instance.parameters.S;
	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
    
	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;
	
	
 
			  		  first=0;	              
			          kMAX=0;
					  
			          for j = 1, 19 , 1 do
					         if  instance.parameters:getBoolean ("Use"..j) then
										 assert(core.indicators:findIndicator(I[j]) ~= nil, "Please, download and install ".. I[j] .. " indicator");
										 assert(instance.parameters:getString("I"..j) == I[j], j .. ". Indicator must be " .. I[j]);
								  
										kMAX=kMAX+1;
                                        Code[kMAX]=j;										
										  
										   tprofile[kMAX] = core.indicators:findIndicator(instance.parameters:getString("I"..j));
										   tparams[kMAX] = instance.parameters:getCustomParameters("I"..j);
										   if  tprofile[kMAX]:requiredSource() == core.Tick then
										   Test[kMAX] = tprofile[kMAX]:createInstance(source.close, tparams[kMAX]);
										   else
										   Test[kMAX] = tprofile[kMAX]:createInstance(source, tparams[kMAX]);
										   end  
										   
											Number[kMAX] = Test[kMAX]:getStreamCount ()
											first= math.max( Test[kMAX]:getStream(Number[kMAX]-1):first() , first);	
							   end
					  end
						
						
			 
	 
	 Pair, Count = getInstrumentList();
	  
    local j;
	Num=0;
	  
	for i = 1 , 11 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;	  
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   
	                       

            
	              
	  end
	end	
	
 
		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	
 
	local id=0;	
	
	for j = 1, Count, 1 do
	
	         SourceData[j] = {};
			 
             loading[j] = {};	
			 iprofile[j] = {};	
			 iparams[j] = {};
			 Indicator[j] = {};
			 
			
	   
	   
		 for i = 1, Num, 1 do	
		 
		          id=id+1;
				   
				 iprofile[j][i] = {};	
				 iparams[j][i] = {};
				 Indicator[j][i] = {};         
		 
		 					  
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(300, first*2) , 2000 +id , 1000 +id);
			   loading[j][i] = true;  
			  
			    for k = 1, kMAX , 1 do
			   iprofile[j][i][k] = core.indicators:findIndicator(instance.parameters:getString("I"..k));
			   iparams[j][i][k] = instance.parameters:getCustomParameters("I"..k);			
			   
			   if  iprofile[j][i][k]:requiredSource() == core.Tick then
			   Indicator[j][i][k] = iprofile[j][i][k]:createInstance(SourceData[j][i].close, iparams[j][i][k]);
			   else
			   Indicator[j][i][k] = iprofile[j][i][k]:createInstance(SourceData[j][i], iparams[j][i][k]);
			   end
               end
             			  
			  
		end
	end
    
	
	      core.host:execute ("setTimer", 1, 1);
	 
end




function Update(period, mode)

core.host:execute ("setStatus", "")


 if period < source:size()-1
 
 then
 return
 end
 
    local k;
 
  
    local FLAG=false;
	
	local i,j;
	local id =1;
	local N=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 N=N+1;
				 end
		 
         end  	
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - N) .. " / " .. (Count*Num) );
	return;
	end
	
  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, Size*10+(i-1)*Size*4 ,  core.CR_LEFT, Size*1.1*3  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, Size*5 ,  core.CR_LEFT, Size*1.1*4+(j-1)*Size*1.1+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	 
	       -- for i = 1, Num, 1  do
 

                        
           --             for k = 1, kMAX, 1 do
						 
                        -- Indicator[j][i][k]:update(core.UpdateLast);
						 
						 
								

                     --   end						

			--	end
				
		for i = 1, Num, 1  do		
		
		local Score = 0;	
		
				for k = 1, kMAX, 1 do
				
				
				
						local Color =No;			
						
						local Font=font;
						
						
				
				      if  Indicator[j][i][k]:getStream( Number[k]-1):hasData(Indicator[j][i][k]:getStream(Number[k]-1):size()-1) then
								 
								 
                                Score=Score+ Logic (j,i,k);								 
					end	
						
					  
					       local Style= "";
						 if k == kMAX then
						 
							if Score > SB then
							Style="STRONG BUY";
							Color=Up;
							elseif  Score > B then
							Style="BUY";
							Color=Up;
							elseif  Score < -SS then
							Style="STRONG SELL";
							Color=Down;
							elseif  Score < -S then
							Style="SELL";
							Color=Down;
							else
							Color=No;
							Style="NEUTRAL";
							end
						
							core.host:execute("drawLabel1", id, Size*10+(i-1)*Size*4,  core.CR_LEFT, Size*1.1*4+(j-1)*Size*1.1 +Shift , core.CR_TOP, core.H_Left, core.V_Center, Font, Color,  tostring( Style) );			  
							id = id+1;
							
						end

				end
				end
         
       end
end


function Logic ( j,i,k )

	 if Code[k] >= 10 then
		 if  Indicator[j][i][k].DATA[Indicator[j][i][k].DATA:size()-1] >  SourceData[j][i].close[ SourceData[j][i]:size()-1] then
		 return 1;
		 elseif Indicator[j][i][k].DATA[Indicator[j][i][k].DATA:size()-1] <  SourceData[j][i].close[ SourceData[j][i]:size()-1] then
		 return -1;
		 else
		 return 0;
		 end
	elseif Code[k] == 3 or Code[k] == 5 or Code[k] == 6 then	
	
	      if  Indicator[j][i][k].DATA[Indicator[j][i][k].DATA:size()-1] >  0 then
		 return 1;
		 elseif Indicator[j][i][k].DATA[Indicator[j][i][k].DATA:size()-1] < 0 then
		 return -1;
		 else
		 return 0;
		 end
	elseif Code[k] == 2 then
	
	        if  Indicator[j][i][k].DATA[Indicator[j][i][k].DATA:size()-1] >  50 then
		 return 1;
		 elseif Indicator[j][i][k].DATA[Indicator[j][i][k].DATA:size()-1] < 50 then
		 return -1;
		 else
		 return 0;
		 end
	elseif Code[k] == 1 then
	

         if  Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1] >  Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1]
		 and Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1]< 80
		 then
		 return 1;
		 elseif Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1] <  Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1]
		  and Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1] > 20
		 then
		 return -1;
		 else
		 return 0;
		 end


	elseif Code[k] == 4 then
	

	  if  Indicator[j][i][k].DATA[Indicator[j][i][k].DATA:size()-1] >  - 50
		 and Indicator[j][i][k].DATA[Indicator[j][i][k].DATA:size()-1]< -20
		 then
		 return 1;
		 elseif Indicator[j][i][k].DATA[Indicator[j][i][k].DATA:size()-1] <  - 50
		  and Indicator[j][i][k].DATA[Indicator[j][i][k].DATA:size()-1] > -80
		 then
		 return -1;
		 else
		 return 0;
		 end
	
	elseif Code[k] == 8 then


         if Indicator[j][i][7].DATA[Indicator[j][i][7].DATA:size()-1] >  25
		 and Indicator[j][i][k].DIP[Indicator[j][i][k].DIP:size()-1] > Indicator[j][i][k].DIM[Indicator[j][i][k].DIM:size()-1]
		 then
		 return 1;
		 elseif Indicator[j][i][7].DATA[Indicator[j][i][7].DATA:size()-1] > 25
		  and Indicator[j][i][k].DIP[Indicator[j][i][k].DIP:size()-1] < Indicator[j][i][k].DIM[Indicator[j][i][k].DIM:size()-1]
		 then
		 return -1;
		 else
		 return 0;
		 end
	
	
	
	
	elseif  Code[k] == 9 then
	
        if  Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1] >  Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1]
		 and Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1]< 80
		 then
		 return 1;
		 elseif Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1] <  Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1]
		  and Indicator[j][i][k].K[Indicator[j][i][k].K:size()-1] > 20
		 then
		 return -1;
		 else
		 return 0;
		 end


	else
	return 0;
	end
	
	
 
end



function getInstrumentList()
    local list={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

    local Master = false;  
	local id=0;
	
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		      id=id+1;
			  
			  if cookie == (1000 + id) then
			  loading[j][i] = true;
			  Master=true;
		      elseif  cookie == (2000 + id) then
			  loading[j][i] = false; 			  
			  end
		       
          end
	end    
	
	
	
	if not Master and cookie==1 then
 

	    for j = 1, Count, 1 do
	
	             for i = 1, Num, 1  do
 

                        
                      for k = 1, kMAX, 1 do
						 
                         Indicator[j][i][k]:update(core.UpdateLast);
						 
						 
								

                        end						

			 	end
	
          end
		  
			 
	 
   	end
	
	 if not Master then
	 instance:updateFrom(0);
	 end
	
 
      return core.ASYNC_REDRAW ;
end



