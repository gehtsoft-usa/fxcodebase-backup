-- Id: 9159

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=37544

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
    indicator:name("MTF MCP Price MA Difference");
    indicator:description("MTF MCP Price MA Difference");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m1" , "MVA" , false);
	Parameters (2 , "m15", "MVA"  , false  );
	Parameters (3 , "m30", "MVA" , false  );
	Parameters (4 , "H1" , "MVA" , true   );
	Parameters (5 , "H2", "MVA" , false   );
	Parameters (6 , "H3" , "MVA" , false  );
	Parameters (7 , "H4", "MVA" , false   );
	Parameters (8 , "H8", "MVA" , true  );
	Parameters (9 , "D1" , "MVA" , true   );
	Parameters (10 , "W1", "MVA"  , true  );	
	Parameters (11 , "M1", "MVA" , true   );
	
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addString("Pip", "Value/Pip", "", "Value");
    indicator.parameters:addStringAlternative("Pip", "Value", "", "Value");
    indicator.parameters:addStringAlternative("Pip", "Pips", "", "Pip");
end


function Parameters (id , FRAME, Method , TimeFrameFlag)
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", TimeFrameFlag);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	
	indicator.parameters:addString("Method"..id, "MA Method", "Method" , Method);
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addInteger("Period"..id, "Period", "Period" , 50);
	
    
	indicator.parameters:addString("Type"..id, "Indicaton Type", "", "Numeric");
    indicator.parameters:addStringAlternative("Type"..id, "Numeric", "", "Numeric");
    indicator.parameters:addStringAlternative("Type"..id, "Trend", "", "Trend");
	
	 
	
end

local Pip;
local Period={};
local loading={};
local SourceData={};
local Indicator={};
local Pair;
local font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first={};
local Test={};
local Count;
local Up, Down, No, LabelColor;
local N={};
local Shift;
local On={};
local Num; 
local SC={}; 
local Method={};
local Type={};
 local PipSize ;
 
function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		 
		 core.host:execute ("killTimer", 1);
		 
 end  

function Prepare(nameOnly)    
    
	Shift=instance.parameters.Shift; 
    source = instance.source;
	Pip=instance.parameters.Pip;
	 
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
	
 
	 
	 Pair, Count,PipSize = getInstrumentList();
	  

	Num=0;
	
	for i = 1 , 11 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	   Method[Num]=  instance.parameters:getString ("Method"..i);
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	   Type[Num]=  instance.parameters:getString ("Type"..i);
	   Period[Num]=  instance.parameters:getInteger ("Period"..i);
	    
	 
		--**********************************************************************************	 
    assert(core.indicators:findIndicator(Method[Num]) ~= nil, Method[Num] .. " indicator must be installed");
			   Test[Num] =  core.indicators:create(Method[Num], source.close, Period[Num]);  
	           first[Num]= Test[Num]:getStream(0):first() ;					 
	  
         
	
	  end
	end	
	

	
		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	 
	
	
	local ID=0;	
	
	for j = 1, Count, 1 do
	
	         SourceData[j] = {};
			 
             loading[j] = {};				
			 Indicator[j] = {};
			 
			
	   
	   
		 for i = 1, Num, 1 do	
		 
		      ID=ID+1;
		 					  
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(300,first[i]) , 2000 + ID , 1000 + ID);
			   loading[j][i] = true;  
			  
			   
			  --**********************************************************************************
			   Indicator[j][i] = core.indicators:create(Method[Num], SourceData[j][i].close, Period[Num]);  
			 

             			  
			  
		end
	end
    
	
	
	 core.host:execute ("setTimer", 1, 1);
	 
end


 

function Update(period, mode)




 if period < source:size()-1 then
 return
 end
 
   
 
  
    local FLAG=false;
	
	local i,j;
	local id =1;
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
	return;
	else
	 core.host:execute ("setStatus", "" );
	end
	
  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, Size*5+(i)*Size*5 ,  core.CR_LEFT, Size  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, Size*5 ,  core.CR_LEFT, Size+(j)*Size+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do
--close
				
			--	Indicator[j][i]:update(core.UpdateLast);
				
				
				if  Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size()-1) and Indicator[j][i]:getStream(0):hasData(Indicator[j][i]:getStream(0):size()-2)  then					
                local Current= (SourceData[j][i].close[SourceData[j][i].close:size()-1]- Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-1] );
				local Previous= (   SourceData[j][i].close[SourceData[j][i].close:size()-2] - Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(0):size()-2]);
				
						local Color =nil;			
						local Style = nil 
						local Font=nil;
						
						Style =Current;			

					
						 
						if Current >  0 then							  			
						   Style= "\225";
						elseif Current <  0 then 
						   Style= "\226";
						else   						 
						    Style= "\158";
						end   
						
						if Current >  Previous then
						 Color = Up;
						 elseif Current <  Previous then
						  Color = Down;
						 else
						    Color = No;
						end
						
                        if Type[i]~= "Trend" then
						Font= font;	
						
						        if Pip == "Pip" then
								Current= Current/ PipSize[j];								
								Style= string.format("%." .. 2 .. "f", Current); 
								else
								Style= string.format("%." .. 5 .. "f", Current);   
								end
								
						
					
						
								
						
						
						else
						Font= Wingdings;						
                        end						
						
						
						if Style ~= nil then
						core.host:execute("drawLabel1", id, Size*5+(i)*Size*5,  core.CR_LEFT, Size+(j)*Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, Font, Color,   Style );			  
						id = id+1;
						end

				end
				
				end
        end
    
end




function getInstrumentList()
    local list={};
	local SIZE={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
		SIZE[count] = row.PointSize;  
        row = enum:next();
    end

    return list, count, SIZE;
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

    local ID=0;
	
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		      ID=ID+1;
			  if cookie == (1000 + ID) then
			  loading[j][i] = true;
		      elseif  cookie == (2000 + ID) then
			  loading[j][i] = false;    
			  
			  end
		       
          end
	end    
	
	local FLAG=false;
	
	 for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		 if  loading[j][i] then
		  FLAG=true;
		 end
		 
	end
    end

	
	if not FLAG and cookie== 1 then
	
			 for j = 1, Count, 1 do				
			 for i = 1, Num, 1  do
		 
						
						Indicator[j][i]:update(core.UpdateLast);
						
			end
			end
	end
	
	if not FLAG then	
	 instance:updateFrom(0);	
	end
	
   
        
    return 0;
end



