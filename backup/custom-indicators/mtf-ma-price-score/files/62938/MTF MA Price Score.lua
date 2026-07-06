-- Id: 9180
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=37983

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
    indicator:name("MTF MA Price Score");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	
	Parameters (1 , "m1", true  ); 
	Parameters (2 , "m5" , true );
	Parameters (3 , "m15" , true );
    Parameters (4 , "m30", true  );
	Parameters (5 , "H1" , true );
	Parameters (6 , "H2", true  ); 
	Parameters (7 , "H3", true  );
	Parameters (8 , "H4", true  );
    Parameters (9 , "H8", true  );
	Parameters (10 , "D1", true  );
	Parameters (11 , "W1", true  ); 
	Parameters (12 , "M1", true  );
 
 
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("Size", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	indicator.parameters:addColor("Up", "Bull Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Bear Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	
end


function Parameters (id, frame , flag )

    indicator.parameters:addGroup(id..".  Time Frame");
    indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", flag);	    
	indicator.parameters:addString("TF" .. id, id.. ". Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);

  	
    indicator.parameters:addInteger("Period"..id, "Period", "", 10);
	
	indicator.parameters:addString("Method"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");

  
end

local On={};
local TF={};
local source; 
local day_offset, week_offset;
local host;
local first={};
local Up, Down, Neutral, Note;
local Shift;
 local font1;
 local font2;
local Show={};	
local Method={};
local SourceData={};
local loading={};
local Size;
local Test1={};
local Test2={};
local Label;
local Note={};
local id;
local Price={};
local  Period={};
 local Num;
local Indicator={};
local  Bull;
function Prepare(nameOnly)  

  	
    source = instance.source;		 
    host = core.host;
	day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Label=instance.parameters.Label;
    Shift=instance.parameters.Shift;
	 Size=instance.parameters.Size; 
	
   	local i;
	Num=0;
	
    for i= 1, 12, 1 do		 
	
	 On[i]= instance.parameters:getBoolean ("On"..i);	
     if On[i] then	 
	 Num=Num+1;
      TF[Num]= instance.parameters:getString ("TF"..i);
	  Period[Num]= instance.parameters:getInteger ("Period"..i);
	  Method[Num]= instance.parameters:getString ("Method"..i);
	  end
     
 
	end
      
   
	
    local name = "(" .. profile:id() .. ", "  .. instance.source:name().. ", "  .. source:barSize().. ")" ;
   instance:name(name);
    if   (nameOnly) then
        return;
    end

	for i= 1, Num, 1 do
	
	 Note[i]= "(" .. TF[i]..", " .. Period[i] ..", " .. Method[i]..")";
	 

   	 
	end

	
	

	

	  font1 = core.host:execute("createFont", "Arial", Size, true, false);
       font2 = core.host:execute("createFont", "Wingdings", Size, false, false);
	   
	 
	   
	 for i = 1, Num, 1 do	
	
	  
	    SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(),  math.min( Period[i]) , 200+i, 100+i);
		  loading[i] = true;   
    assert(core.indicators:findIndicator(Method[i]) ~= nil, Method[i] .. " indicator must be installed");
	    Indicator[i]= core.indicators:create(Method[i], SourceData[i].close, Period[i]);
	end
end


function Update(period)


    core.host:execute ("setStatus", "")
 
    if  period <  source:size() - 1 then	
       return;
	end
	
	local Flag = false;
	local i;
	
	for i = 1, Num , 1 do
		if loading[i] then
		Flag= true;
		end
		
	end
	
	if  Flag   then	
	core.host:execute ("setStatus", "Loading");
	return;	
	else
	core.host:execute ("setStatus", "Loaded");
	end
	
	
			
	   local i, color;
		id =0;
		
	
			                 id=id+1;
							
							   core.host:execute("drawLabel1", id, -7*Size, core.CR_RIGHT,Size*4+Shift , core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,source:name());
						 
		Bull =0;					 
		
		for i = 1 ,Num , 1  do		
			
		Calculation( i  );	
		
		
		 end 
		 
		 local Percentage;
		 local B, S;
		 
	 
		 B= Bull/ (Num/100);
         S= 100-B;
		 
							
							 
							 			    
												id=id+1;
												core.host:execute("drawLabel1", id, -1*7*Size, core.CR_RIGHT, Size*3+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, Up, string.format("%." .. 2 .. "f", B));												
												
												 
												id=id+1;
                                                core.host:execute("drawLabel1", id, -1*7*Size,core.CR_RIGHT, Size*5+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, Down,  string.format("%." .. 2 .. "f", S));												
												 
	  
end


function ReleaseInstance()
       core.host:execute("deleteFont", font1);
       core.host:execute("deleteFont", font2);
 end
   
function Calculation ( i)
		
		      Indicator[i]:update(core.UpdateLast );
			  
			  if Indicator[i].DATA:hasData( Indicator[i].DATA:size()-1) then
				 
				if SourceData[i].close[SourceData[i].close:size()-1] >  Indicator[i].DATA[Indicator[i].DATA:size()-1]  then
				Bull= Bull+1;
				end
			 end	
		 
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


  
     local i;
	 
	 for i = 1, Num, 1 do
	
	 
	 
		 if cookie == 100+i then
			loading[i] = true;
	 
		elseif cookie == 200+i then
			loading[i] = false;		
		end
	 end	
	 
	 
	 local Flag = false;
 
	
	for i = 1, Num , 1 do
		if loading[i] then
		Flag= true;
		end
		
	end
	
	if not Flag then
	instance:updateFrom(0);
	end
	
	
		
    return core.ASYNC_REDRAW;
end
