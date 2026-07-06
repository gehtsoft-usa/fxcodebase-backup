-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41294

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MTF SSL with NRTR indicator");
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
	
	 
	 indicator.parameters:addInteger("Period".. id, "Period", "", 13);
    indicator.parameters:addString("Method".. id, "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method".. id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method".. id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method".. id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method".. id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method".. id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method".. id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method".. id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method".. id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method".. id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method".. id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method".. id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method".. id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method".. id, "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method".. id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method".. id, "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method".. id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method".. id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method".. id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method".. id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method".. id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method".. id, "JSmooth", "", "JSmooth");
    indicator.parameters:addBoolean("NRTR".. id, "Enable NRTR", "", true);
	
  
end

local Method={};
local Period={};
local NRTR={};
 
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
local Label;
local Note={};
local id;
local Indicator={};

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
	 Method[i]= instance.parameters:getString ("Method"..i);
	 Period[i]= instance.parameters:getInteger  ("Period"..i);
	 NRTR[i]= instance.parameters:getBoolean ("NRTR"..i);
	 
	end
      
   assert(core.indicators:findIndicator("SSL_WITH_NRTR") ~= nil, "Please, download and install SSL_WITH_NRTL.LUA indicator");
   assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
	
    local name = "(" .. profile:id() .. ", "  .. instance.source:name().. ", "  .. source:barSize().. ")" ;


	for i= 1, 5, 1 do
	
	 Note[i]= "(" .. TF[i].. ", " .. Period[i]..", " ..Method[i]..")";
	name = name.. ", " .. Note[i] ..  ")";   

   	Test1[i] = core.indicators:create("SSL_WITH_NRTR", source ,Period[i],Method[i],NRTR[i]);   

	first[i] =Test1[i].DATA:first();
	end

	instance:name(name);
    if (nameOnly) then
        return;
    end

	  font1 = core.host:execute("createFont", "Arial", Size, true, false);
       font2 = core.host:execute("createFont", "Wingdings", Size, false, false);
	   
	 
	   
	 for i = 1, 5, 1 do	
	
	  
	    SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(),  first[i] , 200+i, 100+i);
		  loading[i] = true;   
	   		 
		Indicator[i] = core.indicators:create("SSL_WITH_NRTR", SourceData[i] , Period[i],Method[i],NRTR[i]);
		
	end
end


function Update(period)


    core.host:execute ("setStatus", "")
 
    if  period <  source:size() - 1 then	
       return;
	end
	
	
	if loading[1] or loading[2] or loading[3] or loading[4] or loading[5] then	
	core.host:execute ("setStatus", "Loading")
	return;	
	end
	
	
			
	   local i, color;
		id =0;
		
		local date = source:date(period);
		
		                 
		
			                 id=id+1;
							
							   core.host:execute("drawLabel1", id, -70, core.CR_RIGHT,75+Shift- Size*2, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,source:name());
						 
							 
		
		for i = 1 ,5 , 1  do			
			
		Calculation( i );	
		
		
		 end 
	  
end


function ReleaseInstance()
       core.host:execute("deleteFont", font1);
       core.host:execute("deleteFont", font2);
 end
   
function Calculation ( i)
		
		
				
						Indicator[i]:update(core.UpdateLast);
						
				
                     							
							
						
							  id=id+1;
							
							   core.host:execute("drawLabel1", id, -i*70, core.CR_RIGHT,75+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label,TF[i]);
							 
							 
							
							 
						
											   if Indicator[i].UP:hasData(Indicator[i].UP:size()-1) then
												id=id+1;
												core.host:execute("drawLabel1", id, -i*70, core.CR_RIGHT, 100+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Up, "\225");												
												
												elseif Indicator[i].DN:hasData(Indicator[i].DN:size()-1)  then
												id=id+1;
                                                core.host:execute("drawLabel1", id, -i*70,core.CR_RIGHT, 100+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Down, "\226");												
												
												else
												id=id+1;	
                                                core.host:execute("drawLabel1", id, -i*70 ,core.CR_RIGHT, 100+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Neutral, "\223");	
																						
												
												end 		
												
												
											 
					
				
   
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     if cookie == 101 then
        loading[1] = true;
    elseif cookie == 102 then
        loading[2] = true;
    elseif cookie == 103 then
        loading[3] = true;
    elseif cookie == 104 then
        loading[4] = true;
    elseif cookie == 105 then
        loading[5] = true;
    elseif cookie == 201 then
        loading[1] = false;
        instance:updateFrom(0);
    elseif cookie == 202 then
        loading[2] = false;
        instance:updateFrom(0);
    elseif cookie == 203 then
        loading[3] = false;
        instance:updateFrom(0);
    elseif cookie == 204 then
        loading[4] = false;
        instance:updateFrom(0);
    elseif cookie == 205 then
        loading[5] = false;
        instance:updateFrom(0);
    else
        return 0;
    end
    return core.ASYNC_REDRAW;
end
