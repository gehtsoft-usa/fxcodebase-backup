-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32319

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
    indicator:name("Multi Time Frame, Multi Currency Pair, RSI List");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m5", true  );
	Parameters (2 , "m15", false   );
	Parameters (3 , "m30", false  );
	Parameters (4 , "H1", false    );
    Parameters (5 , "H8", false  );
	Parameters (6 , "D1", false   );
	Parameters (7 , "W1", false  );
	Parameters (8 , "M1", false    );
	
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
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	

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
	
   indicator.parameters:addInteger("N"..id, "Period", "", 14);
   
   
   	indicator.parameters:addString("Live"..id , "Live / End of Turn", "", "Live");	
	indicator.parameters:addStringAlternative("Live"..id , "Live", "", "Live");
    indicator.parameters:addStringAlternative("Live"..id , "End of Turn", "", "End of Turn");
   
   indicator.parameters:addGroup(id ..". Time Frame Modified Expansion");
   indicator.parameters:addDouble("OB"..id, "Custom OB Level", "", 60);
   indicator.parameters:addDouble("OS"..id, "Custom OS Level", "", 40);
   
   
  
    indicator.parameters:addString("Mode"..id, "Mode", "", "Value OB/OS");
    indicator.parameters:addStringAlternative("Mode"..id, "Value OB/OS", "", "Value OB/OS");
	 indicator.parameters:addStringAlternative("Mode"..id, "Value Custom OB/OS", "", "Value Custom OB/OS");
    indicator.parameters:addStringAlternative("Mode"..id, "Arrows OB/OS", "", "Arrows OB/OS");
	indicator.parameters:addStringAlternative("Mode"..id, "Arrows Custom OB/OS ", "", "Arrows Custom OB/OS");
	
 
end

local loading={};
local SourceData={};
local Indicator={};
local Pair;
local Font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first;
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
local Mode={};
local Trend={};
local OB={};
local OS={};
local Live={};
function ReleaseInstance()
       core.host:execute("deleteFont", Font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
 end  

function Prepare(nameOnly)  
    Type=instance.parameters.Type;   
	
	Shift=instance.parameters.Shift; 
	Level=instance.parameters.Level;
	 
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
	
		if   (nameOnly) then
        return;
    end
	
	instance:name(name);
	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;
	
	
	 
	 Pair, Count = getInstrumentList();
	 getPointSize();    

	Num=0;
	
	
	
	for i = 1 , 8 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	   
	   OB[Num]=  instance.parameters:getDouble ("OB"..i);
	   OS[Num]=  instance.parameters:getDouble ("OS"..i);
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   Live[Num]=  instance.parameters:getString ("Live"..i);
	   Price[Num]=  instance.parameters:getString ("Price"..i);
       N[Num]=  instance.parameters:getInteger ("N"..i);
	   Mode[Num]=  instance.parameters:getString ("Mode"..i); 
	  end
	end	 
   	
	Font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	 
		
	
	for j = 1, Count, 1 do
	
	
	         Trend[j] = {};
	         SourceData[j] = {};
			 Indicator[j] = {};	
             loading[j] = {};	
	   
	   
		 for i = 1, Num, 1 do	
		 
		      Test = core.indicators:create("RSI", source.close ,N[i]);   
	          first= Test.DATA:first() ;
		 
		 					--  (1000 + j*10+i)
							
		       if 	 Mode[i] ~= "Arrows OB/OS"  and   Mode[i] ~= "Value OB/OS"  then	
                SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), first  , 2000 + j*10+i , 1000 + j*10+i);			   
               else			   
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), first +200 , 2000 + j*10+i , 1000 + j*10+i);
			   end
			   loading[j][i] = true;  
			  
			   Indicator[j][i] = core.indicators:create("RSI", SourceData[j][i][Price[Num]],N[i]);

             			  
			  
		end
	end
    
	
	
	 core.host:execute("setTimer", 1, 5);
	 
end




function Update(period, mode)




 if period < source:size()-1 then
 return
 end
 
	local i,j,k;
	local id =1;
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
 

core.host:execute ("setStatus", "")
  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, 200+(i-1)*100 ,  core.CR_LEFT, 40  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, 100 ,  core.CR_LEFT, 60+(j-1)*15+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do

				
				Indicator[j][i]:update(core.UpdateLast);
				
				
				if  Indicator[j][i].DATA:hasData(Indicator[j][i].DATA:size()-1) and Indicator[j][i].DATA:hasData(Indicator[j][i].DATA:size()-2) then					
                       
						local Color =nil;			
						local Style = nil 
						
						
						 
						Style = string.format("%." .. 5 .. "f", Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1]	);
						
                        font = Font;
						
               		   

						 if Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1] >  Indicator[j][i].DATA[Indicator[j][i].DATA:size()-2] then
										
											
									
											
										if Mode[i]	~= "Value OB/OS" and Mode[i]	~= "Value Custom OB/OS" then
										 font = Wingdings;
										 Style= "\225";
										end
											
										
						elseif Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1] <  Indicator[j][i].DATA[Indicator[j][i].DATA:size()-2] then
											
								
                                        if Mode[i]	~= "Value OB/OS" and Mode[i]	~= "Value Custom OB/OS" then
										 font = Wingdings;
										 Style= "\226";
										end											  
											
												
						 else				
                                          
											 
										if Mode[i]	~= "Value OB/OS" and Mode[i]	~= "Value Custom OB/OS" then
										 font = Wingdings;
										 Style= "\167";
										end			
						 end 		
						 
						 
						 if  Mode[i] == "Arrows OB/OS"  or   Mode[i] == "Value OB/OS"  then
								 if Live[i]== "Live" then
									 if Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1] > 70 then
									 Color = Up;
									 elseif Indicator[j][i].DATA[Indicator[j][i].DATA:size()-1]  < 30 then
									  Color = Down;	
									 else
									  Color = No;	
									 end  
								else
								       if Indicator[j][i].DATA[Indicator[j][i].DATA:size()-2] > 70 then
									 Color = Up;
									 elseif Indicator[j][i].DATA[Indicator[j][i].DATA:size()-2]  < 30 then
									  Color = Down;	
									 else
									  Color = No;	
									 end  
								end						
						 else	 
						  for k =  SourceData[j][i]:size()-1-200, SourceData[j][i]:size()-1, 1 do 
						  Coloring(j, i, k)	
						  end
                          Color =	Trend[j][i];					  
						 end


						
						
						if  Color  ~= nil then
						core.host:execute("drawLabel1", id, 200+(i-1)*100,  core.CR_LEFT, 60+(j-1)*15 +Shift , core.CR_TOP, core.H_Left, core.V_Center, font, Color,  Style );			  
						id = id+1;
						end

				end
				
				end
        end
    
end

function Coloring(j, i, period)


 



if Live[i]== "Live" then
 


                             if Indicator[j][i].DATA[period] > OB[i] then
							 Trend[j][i] = Up;
							 end
							 
							 if Indicator[j][i].DATA[period]  < OS[i] then
							  Trend[j][i] = Down;	
							 end

 

else
  


                             if Indicator[j][i].DATA[period-1] > OB[i] then
							 Trend[j][i] = Up;
							 end
							 
							 if Indicator[j][i].DATA[period-1]  < OS[i] then
							  Trend[j][i] = Down;	
							 end
 
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

    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
			  if cookie == (1000 + j*10+i) then
			  loading[j][i] = true;
		      elseif  cookie == (2000 + j*10+i) then
			  loading[j][i] = false;            
			  instance:updateFrom(0);
			  
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
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
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

