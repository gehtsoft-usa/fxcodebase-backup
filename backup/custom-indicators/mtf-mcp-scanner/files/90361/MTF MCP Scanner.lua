 

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59736

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+



function Init()
    indicator:name("Multi Time Frame, Multi Currency Pair Scanner");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Filter Selector");
	indicator.parameters:addBoolean("Use" .. 1 , "Use DMI", "", true);	
	indicator.parameters:addBoolean("Use" .. 2 , "Use STOCHASTIC", "", true);
	indicator.parameters:addBoolean("Use" .. 3 , "Use STOCHASTIC RSI", "", true);
	indicator.parameters:addBoolean("Use" .. 4 , "Use RLW", "", true);
	
	indicator.parameters:addGroup("Time Frame Selector");
	indicator.parameters:addBoolean("On".. 1 , "Show (m1) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 2 , "Show (m5) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 3 , "Show (m15) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 4 , "Show (m30) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 5 , "Show (H1) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 6 , "Show (H2) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 7 , "Show (H3) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 8 , "Show (H4) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 9 , "Show (H6)Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 10 , "Show (H8) Time Frame", "", false);	
	indicator.parameters:addBoolean("On".. 11 , "Show (D1) Time Frame", "", true);	
	indicator.parameters:addBoolean("On".. 12 , "Show (W1) Time Frame", "", true);	
	indicator.parameters:addBoolean("On".. 13 , "Show (M1) Time Frame", "", true);	

	Parameters (1 , "m1", false  );
	Parameters (2 , "m5", false  );
	Parameters (3 , "m15", false   );
	Parameters (4 , "m30", false  );
	Parameters (5 , "H1", false    );
	Parameters (6 , "H2", false    );
	Parameters (7 , "H3", false    );
	Parameters (8 , "H4", false    );
	Parameters (9 , "H6", false    );
    Parameters (10 , "H8", false  );
	Parameters (11 , "D1", true   );
	Parameters (12 , "W1", true  );
	Parameters (13 , "M1", true    );
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME, flag )
    indicator.parameters:addGroup(id ..". Time Frame");
	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Price"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	
	
	
   indicator.parameters:addGroup(id ..". Time Frame DMI");	
   indicator.parameters:addInteger("DmiPeriod"..id, "DmiPeriod", "", 14);
   
   
     indicator.parameters:addGroup(id ..". Time Frame STOCHASTIC");	
    indicator.parameters:addInteger("K"..id, "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD"..id, "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D"..id, "The number of periods for %D.", "", 3, 2, 1000);

    indicator.parameters:addString("KS"..id, "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS"..id, "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS"..id, "MT4","", "MT");
    
    indicator.parameters:addString("DS"..id, "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("DS"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS"..id, "EMA", "", "EMA"); 
	
	indicator.parameters:addDouble("STOCHASTIC_OB"..id, "OVER BOUGHT Level", "", 80);
    indicator.parameters:addDouble("STOCHASTIC_OS"..id, "OVER SOLD Level", "", 20);
	
	 indicator.parameters:addGroup(id ..". Time Frame STOCHASTIC RSI");	
	indicator.parameters:addInteger("SR1"..id, "Number of periods for RSI", "", 14, 1, 200);
    indicator.parameters:addInteger("SR2"..id, "%K Stochastic Periods", "", 14, 1, 200);
    indicator.parameters:addInteger("SR3"..id, "%K Slowing Periods", "", 5, 1, 200);
	indicator.parameters:addInteger("SR6"..id, "%D Slowing Stochastic Periods", "", 3, 1, 200);
 
	indicator.parameters:addDouble("SR4"..id, "OVER BOUGHT Level", "", 90);
    indicator.parameters:addDouble("SR5"..id, "OVER SOLD Level", "", 10);
	
	 indicator.parameters:addGroup(id ..". Time Frame RLW");
    indicator.parameters:addDouble("P0"..id, "Period", "", 14);
    indicator.parameters:addDouble("P1"..id, "OVER BOUGHT Level", "", -20);
    indicator.parameters:addDouble("P2"..id, "OVER SOLD Level", "", -80);	 
 
	
end

local loading={};
local SourceData={};
local DMI={};
local Pair;
local Font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first={};
local Test;
local Count;
local Up, Down, No, LabelColor;
local N={};
local Shift;
local On={};
local Num;
local  SIZE ;
local Type;
local Price={}; 
local Id,id;

local DS={};
local KS={};
local K={};
local SD={};
local D={};
local STOCHASTIC_OB={};
local STOCHASTIC_OS={};
local Indication={};
local DmiPeriod={};
local dmi={};
local  STOCHASTIC={};
local  stochastic = {};
local Use={};
local SR1={};
local SR2={};
local SR3={};
local SR4={};
local SR5={};
local SR6={};
local P0={};
local P1={};
local P2={};
local RLW={};
local rlw={};
local  STOCHASTIC_RSI={};
local  stochastic_rsi = {};
function ReleaseInstance()
       core.host:execute("deleteFont", Font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		 
		 core.host:execute ("killTimer", 1);
 end  
 
function Prepare(nameOnly)   
    Type=instance.parameters.Type;   
	Shift=instance.parameters.Shift; 
	Level=instance.parameters.Level;
	Use[1]=  instance.parameters:getBoolean ("Use" .. 1);
	Use[2]=  instance.parameters:getBoolean ("Use" .. 2);
	Use[3]=  instance.parameters:getBoolean ("Use" .. 3);
	Use[4]=  instance.parameters:getBoolean ("Use" .. 4);
	 
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
	
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end	
	
	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;
	
	
	 assert(core.indicators:findIndicator("STOCHRSI") ~= nil, "Please, download and install STOCHRSI.LUA indicator"); 
	 
	 
	 Pair, Count = getInstrumentList();
	 getPointSize();    

	Num=0;
	
	
	
	
	for i = 1 , 13 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   Price[Num]=  instance.parameters:getString ("Price"..i);
       DmiPeriod[Num]=  instance.parameters:getInteger ("DmiPeriod"..i);
	   
		DS[Num]=instance.parameters:getString ("DS"..i);
		KS[Num]=instance.parameters:getString ("KS"..i);
		K[Num]=instance.parameters:getInteger ("K"..i);
		SD[Num]=instance.parameters:getInteger ("SD"..i);
		D[Num]=instance.parameters:getInteger ("D"..i);
	   STOCHASTIC_OB[Num]=instance.parameters:getDouble ("STOCHASTIC_OB"..i);
	   STOCHASTIC_OS[Num]=instance.parameters:getDouble ("STOCHASTIC_OS"..i); 
	   SR1[Num]=instance.parameters:getInteger ("SR1"..i);
	   SR2[Num]=instance.parameters:getInteger ("SR2"..i); 
	    SR3[Num]=instance.parameters:getInteger ("SR3"..i); 
		SR4[Num]=instance.parameters:getDouble ("SR4"..i); 
	    SR5[Num]=instance.parameters:getDouble ("SR5"..i); 
		SR6[Num]=instance.parameters:getInteger ("SR6"..i); 
		
		P1[Num]=instance.parameters:getDouble ("P1"..i); 
	    P2[Num]=instance.parameters:getDouble ("P2"..i); 
		P0[Num]=instance.parameters:getInteger ("P0"..i); 
	   
	 	
	  end
	end	
	
	
   	
	Font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
 

for i = 1, Num, 1 do	
		first[i]=1; 
		      if Use[1] then
		      Test = core.indicators:create("DMI", source , DmiPeriod[i]);   			  
	          first[i]= math.max (first[i], Test.DATA:first()+1 );	
			  end
			  
			  
			  if Use[2] then
		      Test = core.indicators:create("STOCHASTIC", source , K[i], SD[i],D[i],KS[i] , DS[i]);   			  
	          first[i]= math.max (first[i], Test.D:first()+1 );	
			  end
			  
			  if Use[3] then
		      Test = core.indicators:create("STOCHRSI", source[Price[i]] ,  SR1[i],  SR2[i], SR3[i], SR6[i]);   			  
	          first[i]= math.max (first[i], Test.D:first()+1 );	
			  end
			  
			  
			    if Use[4] then
		      Test = core.indicators:create("RLW", source ,  P0[i]);   			  
	          first[i]= math.max (first[i], Test.DATA:first()+1 );	
			  end
end	

 
Id=0;	
	for j = 1, Count, 1 do
	
	
	
	         SourceData[j] = {};
			 DMI[j] = {};	
			 dmi[j] = {};
			 STOCHASTIC[j] = {};
			 stochastic[j] = {};
			 STOCHASTIC_RSI[j] = {};
			 stochastic_rsi[j] = {};
			 
			 RLW[j] = {};
			 rlw[j] = {};
			 
             loading[j] = {};	
			 
             Indication[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		       
              Indication[j][i]=0;	
	         
		       Id = Id+1;
		 				 
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), first[i], 2000 +Id , 1000 + Id);
			   loading[j][i] = true;  
			  
			  
			   if Use[1] then
			   DMI[j][i] = core.indicators:create("DMI", SourceData[j][i] ,DmiPeriod[i]);
               end  
             			  
			  if Use[2] then
			   STOCHASTIC[j][i] = core.indicators:create("STOCHASTIC", SourceData[j][i] , K[i], SD[i],D[i],KS[i] , DS[i]);
               end  
			   
			   if Use[3] then
			   STOCHASTIC_RSI[j][i] = core.indicators:create("STOCHRSI", SourceData[j][i][Price[i]] ,  SR1[i],  SR2[i], SR3[i], SR6[i]   );
               end  
			   
			    
			   if Use[4] then
			   RLW[j][i] = core.indicators:create("RLW", SourceData[j][i]  ,  P0[i]   );
               end  
			  
		end
	end
    
	
	
	 core.host:execute("setTimer", 1, 1);
	 
end




function Update(period, mode)

core.host:execute ("setStatus", "")


 if period < source:size()-1 then
 return
 end
 
	local i,j;
	 id =1;
	local FLAG=false; 
	local Number=0;
	local font;
 	
	
	

	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	if FLAG then
	return;
	end
 
  

  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, Size*5+(i)*Size*5 ,  core.CR_LEFT, Size*2  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, Size*5 ,  core.CR_LEFT, Size*2+(j)*Size+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	           for i = 1, Num, 1  do

				
			  
			   Logic(j,i, mode)
			
				end
        end
    
end

function Logic (j,i, mode)


              dmi[j][i]= nil; 
			  stochastic[j][i]= nil; 
			  stochastic_rsi[j][i]= nil; 
			  rlw[j][i]= nil;

              if Use[1] then
			  
			  
			   -- DMI[j][i]:update(mode);	
			  
				
				if  
				 ( DMI[j][i].DATA:size()-1)  < first[i]
				then				
				
				     	core.host:execute("drawLabel1", id, Size*5+(i)*Size*5,  core.CR_LEFT, Size*2+(j)*Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, Bold, No,  "*" );			  
						id = id+1;
                return;

                end	
				
				
				if  DMI[j][i].DIP[DMI[j][i].DATA:size()-1]> DMI[j][i].DIM[DMI[j][i].DATA:size()-1] then
				dmi[j][i]= 1;
				else
				dmi[j][i]= -1;
				end 

             end
			 
			 
			     if Use[2] then
			  
			  
			 --     STOCHASTIC[j][i]:update(mode);	
			  
				
				if  
				 ( STOCHASTIC[j][i].D:size()-1)  < first[i]
				then				
				
				     	core.host:execute("drawLabel1", id, Size*5+(i)*Size*5,  core.CR_LEFT, Size*2+(j)*Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, Bold, No,  "*" );			  
						id = id+1;
                return;

                end	
				
				
				
				if  STOCHASTIC[j][i].K[STOCHASTIC[j][i].K:size()-1]> STOCHASTIC[j][i].D[STOCHASTIC[j][i].D:size()-1] 
				and  STOCHASTIC[j][i].D[STOCHASTIC[j][i].D:size()-1]< STOCHASTIC_OB[i] 
				then
				stochastic[j][i]= 1;
				elseif  STOCHASTIC[j][i].K[STOCHASTIC[j][i].K:size()-1]< STOCHASTIC[j][i].D[STOCHASTIC[j][i].D:size()-1] 
				and  STOCHASTIC[j][i].D[STOCHASTIC[j][i].D:size()-1]> STOCHASTIC_OS[i] 
				then
				stochastic[j][i]= -1;
				else
				stochastic[j][i]= 0;
				end 

             end
			 
			 
			 --////////////////////////////////////////////////////////////////////
			 
			    if Use[3] then
			  
			  
			  --   STOCHASTIC_RSI[j][i]:update(mode);	
			  
				
				if  
				 ( STOCHASTIC_RSI[j][i].D:size()-1)  < first[i]
				then				
				
				     	core.host:execute("drawLabel1", id, Size*5+(i)*Size*5,  core.CR_LEFT, Size*2+(j)*Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, Bold, No,  "*" );			  
						id = id+1;
                return;

                end	
				
				
				
				if   STOCHASTIC_RSI[j][i].D[STOCHASTIC_RSI[j][i].D:size()-1]> SR4[i] 
				then
				stochastic_rsi[j][i]= -1;
				elseif    STOCHASTIC_RSI[j][i].D[STOCHASTIC_RSI[j][i].D:size()-1]< SR5[i] 
				then
				stochastic_rsi[j][i]= 1;
				else
				stochastic_rsi[j][i]= 0;
				end 

             end
			 ---*/*
			 
			 
			 	    if Use[4] then
			  
			  
			     --- RLW[j][i]:update(mode);	
			  
				
				if  
				 ( RLW[j][i].DATA:size()-1)  < first[i]
				then				
				
				     	core.host:execute("drawLabel1", id, Size*5+(i)*Size*5,  core.CR_LEFT, Size*2+(j)*Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, Bold, No,  "*" );			  
						id = id+1;
                return;

                end	
				
				
				
				if   RLW[j][i].DATA[RLW[j][i].DATA:size()-1]> P1[i] 
				then
				rlw[j][i]= -1;
				elseif    RLW[j][i].DATA[RLW[j][i].DATA:size()-1]< P2[i] 
				then
				rlw[j][i]= 1;
				else
				rlw[j][i]= 0;
				end 

             end
			 --*********************************************************************
			 if (dmi[j][i]== nil and stochastic[j][i]== nil and stochastic_rsi[j][i]== nil and rlw[j][i]== nil)  then
			  Indication[j][i]= 0;
			  
			 else
			 
			 
			 
					 if (dmi[j][i]== 1   or dmi[j][i]== nil  )
					 and (stochastic[j][i]== 1   or stochastic[j][i]== nil  )
					 and (stochastic_rsi[j][i]~= -1   or stochastic_rsi[j][i]== nil  )
					 and (rlw[j][i]~= -1   or  rlw[j][i]== nil  )
					 then
					 
							 if dmi[j][i] == 1 or stochastic[j][i]== 1 then
							 Indication[j][i]= 1;
							 else
							  
							 
							 
							    if  stochastic_rsi[j][i] == rlw[j][i] then
							    Indication[j][i]= stochastic_rsi[j][i];
								 elseif  stochastic_rsi[j][i] == nil  then
							    Indication[j][i]= rlw[j][i];
								 elseif  rlw[j][i] == nil  then
							    Indication[j][i]= stochastic_rsi[j][i];
                                else
								 Indication[j][i]= 0;
							    end
							 end
							 
													 
					end

					
					 if  (dmi[j][i]== -1   or dmi[j][i]== nil  )
					  and (stochastic[j][i]== -1   or stochastic[j][i]== nil  )
					  and (stochastic_rsi[j][i]~= 1   or stochastic_rsi[j][i]== nil  )
					   and (rlw[j][i]~= 1   or  rlw[j][i]== nil  )
					  then
					       
						   
						    if dmi[j][i] == -1 or stochastic[j][i]== -1 then
							 Indication[j][i]= -1;
							 else
							  
							 
							 
							    if  stochastic_rsi[j][i] == rlw[j][i] then
							    Indication[j][i]= stochastic_rsi[j][i];
								 elseif  stochastic_rsi[j][i] == nil  then
							    Indication[j][i]= rlw[j][i];
								 elseif  rlw[j][i] == nil  then
							    Indication[j][i]= stochastic_rsi[j][i];
                                else
								 Indication[j][i]= 0;
							    end
							 end
						    
					 end
					 
					 
            end
						local Color =nil;			
						local Style = nil 
						
					 
						
                        font = Font;
						
               		   

						 if Indication[j][i] == 1 then
										
											
											Color = Up;
											
									 
										 font = Wingdings;
										 Style= "\225";
										 
											
										
						elseif Indication[j][i] == -1 then
											
											  Color = Down;	

                                        
										 font = Wingdings;
										 Style= "\226";
									 									  
											
												
						 else				
                                           					 
											 Color = No;
										 
										 font = Wingdings;
										 Style= "\167";
										 		
						 end 		
						 
						 
						 

						
						if Style ~= nil then
						core.host:execute("drawLabel1", id, Size*5+(i)*Size*5,  core.CR_LEFT, Size*2+(j)*Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, font, Color,  Style );			  
						id = id+1;
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

	
	local i,j;
    Id=0;
	
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
	          Id=Id+1;	 
		 
			  if cookie == (1000 + Id) then
			  loading[j][i] = true;
		      elseif  cookie == (2000 + Id) then
			  loading[j][i] = false;  
			  
			  end
		       
          end
	end    
	
	
	
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	
	
	  if not FLAG and cookie==1 then
  
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		  if Use[1] then
		   DMI[j][i]:update(core.UpdateLast);	
		  end
		  if Use[2] then
		  STOCHASTIC[j][i]:update(core.UpdateLast);	
		  end
		  if Use[3] then
		  STOCHASTIC_RSI[j][i]:update(core.UpdateLast);	
		  end
		  if Use[4] then
		   RLW[j][i]:update(core.UpdateLast);	
		  end
     end
   end 
  end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	
    else
	instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end

function getPointSize()
    SIZE = {};
   
    local count = 0;   
    local row, enum;   
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
      
        SIZE[count] = row.PointSize;      
      
        row = enum:next();
    end

end

