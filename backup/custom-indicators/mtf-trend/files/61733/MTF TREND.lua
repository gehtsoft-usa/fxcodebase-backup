-- Id: 9142

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36938

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
    indicator:name("MTF TREND");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	
	Parameters (1 , "H1"  ); 
	Parameters (2 , "H4"  );
	Parameters (3 , "H8"  );
    Parameters (4 , "D1"  );
	Parameters (5 , "W1"  );
	
	
 
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("Size", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "No Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	
end


function Parameters (id, frame , Def )

    indicator.parameters:addGroup(id..".  Time Frame"); 
	indicator.parameters:addString("TF" .. id, id.. ". Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	 
	indicator.parameters:addString("Price".. id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price".. id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price".. id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price".. id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price".. id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price".. id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price".. id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price".. id, "WEIGHTED", "", "weighted");	

  	
    indicator.parameters:addInteger("ShortPeriod"..id, "Short Period", "", 50);
	indicator.parameters:addString("Method1".. id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1".. id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1".. id, "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method1".. id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1".. id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1".. id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1".. id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1".. id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1".. id, "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("LongPeriod"..id, "Long Period", "", 200);
	indicator.parameters:addString("Method2".. id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2".. id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2".. id, "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method2".. id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2".. id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2".. id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2".. id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2".. id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2".. id, "WMA", "WMA" , "WMA");
	
  
end

local Method1={};
local Method2={};
 
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
 
local SourceData={};
local loading={};
local Size;
local Test1={};
local Test2={};
local Label;
local Note={};
local id;
 local Price={};
    	local Short={};
		local Long={};
        local ShortPeriod={};
        local LongPeriod={};
 
	

	

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
	
    for i= 1, 5, 1 do		 
	 	 
     TF[i]= instance.parameters:getString ("TF"..i);	 
	 Method1[i]= instance.parameters:getString ("Method1"..i);
	  Method2[i]= instance.parameters:getString  ("Method2"..i);
	  ShortPeriod[i]= instance.parameters:getInteger ("ShortPeriod"..i);
	 LongPeriod[i]= instance.parameters:getInteger ("LongPeriod"..i);
	 Price[i]= instance.parameters:getString ("Price"..i);
	end
      
   
	
    local name = "(" .. profile:id() .. ", "  .. instance.source:name().. ", "  .. source:barSize().. ")" ;
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	

	for i= 1, 5, 1 do
	
	 Note[i]= "(" .. TF[i]..", " ..ShortPeriod[i]..", " .. LongPeriod[i]..")";
	 

    assert(core.indicators:findIndicator(Method1[i]) ~= nil, Method1[i] .. " indicator must be installed");
   	Test1[i] = core.indicators:create(Method1[i], source[Price[i]] ,ShortPeriod[i]);   
    assert(core.indicators:findIndicator(Method2[i]) ~= nil, Method2[i] .. " indicator must be installed");
	Test2[i] = core.indicators:create(Method2[i], source[Price[i]] ,LongPeriod[i]);
	first[i] = math.max(Test1[i].DATA:first(), Test2[i].DATA:first());
	end

	
	

	

	  font1 = core.host:execute("createFont", "Arial", Size, true, false);
       font2 = core.host:execute("createFont", "Wingdings", Size, false, false);
	   
	 
	   
	 for i = 1, 5, 1 do	
	
	  
	    SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), math.min(300,  first[i]) , 200+i, 100+i);
		  loading[i] = true;   
	   
	  
		 
		 
		Short[i] = core.indicators:create(Method1[i], SourceData[i][Price[i]] ,ShortPeriod[i]);   		
		Long[i] = core.indicators:create(Method2[i], SourceData[i][Price[i]] ,LongPeriod[i]);
	end
	
	     core.host:execute ("setTimer", 1, 1);
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
core.host:execute("deleteFont", font1);
core.host:execute("deleteFont", font2);
end 

function Update(period)


   
	  
end

 
function Calculation ( i)
		
		
				
					
				
                     							
							if not Short[i].DATA:hasData(Short[i].DATA:size()-1)
							or not Long[i].DATA:hasData(Long[i].DATA:size()-1) 
							then
							return;
							end
						
							  id=id+1;
							
							   core.host:execute("drawLabel1", id,-Size*2 -i*Size*4, core.CR_RIGHT,Size+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,TF[i]);
							 
							 
							
							 
						
											   if Short[i].DATA[Short[i].DATA:size()-1]   >  Long[i].DATA[Long[i].DATA:size()-2] then
												id=id+1;
												core.host:execute("drawLabel1", id,-Size*2  -i*Size*4, core.CR_RIGHT, Size*2+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Up, "\225");												
												
												elseif Short[i].DATA[Short[i].DATA:size()-1]   <  Long[i].DATA[Long[i].DATA:size()-2]  then
												id=id+1;
                                                core.host:execute("drawLabel1", id,-Size*2  -i*Size*4,core.CR_RIGHT, Size*2+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Down, "\226");												
												
												else
												id=id+1;	
                                                core.host:execute("drawLabel1", id,-Size*2  -i*Size*4 ,core.CR_RIGHT, Size*2+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Neutral, "\223");	
																						
												
												end 		
												
												
											 
					
				
   
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

    local Flag= false;
	
     if cookie == 101 then
        loading[1] = true;
		Flag=true;
    elseif cookie == 102 then
        loading[2] = true;
		Flag=true;
    elseif cookie == 103 then
        loading[3] = true;
		Flag=true;
    elseif cookie == 104 then
        loading[4] = true;
		Flag=true;
    elseif cookie == 105 then
	    Flag=true;
        loading[5] = true;
    elseif cookie == 201 then
        loading[1] = false;
    elseif cookie == 202 then
        loading[2] = false;
    elseif cookie == 203 then
        loading[3] = false;
    elseif cookie == 204 then
        loading[4] = false;
    elseif cookie == 205 then
        loading[5] = false;
    
    end
	
	
	
	
	
	
	if cookie == 1 and not Flag then
	                    for i = 1 ,5 , 1  do	 
		                Short[i]:update(core.UpdateLast);
						Long[i]:update(core.UpdateLast);
						end
						
						
						 core.host:execute ("setStatus", "")
 
 
	
			
					   
						id =0;
						 
						
										 
						
											 id=id+1;
											
											   core.host:execute("drawLabel1", id, -Size*4, core.CR_RIGHT,Size+Shift , core.CR_TOP, core.H_Right, core.V_Bottom,
											 font1, Label,source:name());
										 
											 
						
						for i = 1 ,5 , 1  do			
							
						Calculation( i );	
						
						
						 end 
						
	end
	
	
	if  not Flag
	then
        instance:updateFrom(0);
	end
	
    return core.ASYNC_REDRAW;
end
