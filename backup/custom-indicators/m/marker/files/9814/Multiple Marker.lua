-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3963
-- Id: 7978

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Multiple Marker");
    indicator:description("Markers the x bars back");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	Add (1, 0);
	Add (2, 0);
	Add (3, 0);
	Add (4, 0);
	Add (5, 0);
	
    AddStyle(1)
	AddStyle(2)
	AddStyle(3)
	AddStyle(4)
	AddStyle(5)

end

function AddStyle(id)

    indicator.parameters:addGroup(id.. ". Marker Style");
	
	
	
	indicator.parameters:addString("LabelText"..id, "Label Text", "The label text.", tostring(id));
	indicator.parameters:addColor("LabelColor"..id, "Label Color", "The text color.", core.rgb(128, 128, 128));
	indicator.parameters:addString("LabelFontFamily"..id, "Label Font", "The label font.", "Verdana");
	indicator.parameters:addStringAlternative("LabelFontFamily"..id, "Verdana", "", "Verdana");
	indicator.parameters:addStringAlternative("LabelFontFamily"..id, "Arial", "", "Arial");
	indicator.parameters:addStringAlternative("LabelFontFamily"..id, "Tahoma", "", "Tahoma");
	indicator.parameters:addStringAlternative("LabelFontFamily"..id, "Times New Roman", "", "Times New Roman");
	indicator.parameters:addInteger("LabelFontSize"..id, "Label Font Size", "The font size of the label.", 10, 5, 72);

end

function Add(id, Period)
  
	indicator.parameters:addGroup( id  .. ". Market");
	indicator.parameters:addInteger("LookBack".. id, "LookBack Period", "", Period);
	indicator.parameters:addString("Mode".. id, "Market Type", "", "Trailing");
    indicator.parameters:addStringAlternative("Mode".. id, "Trailing", "", "Trailing");
	indicator.parameters:addStringAlternative("Mode".. id, "Locked", "", "Locked");
	
	indicator.parameters:addString("Type".. id, "Market Type", "", "Candle");
    indicator.parameters:addStringAlternative("Type".. id, "Candle", "", "Candle");
	indicator.parameters:addStringAlternative("Type".. id, "Marker", "", "Marker");
	indicator.parameters:addStringAlternative("Type".. id, "Label", "", "Label");

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Color={};
local Width={};
local LookBack={};
local Type={};
local first;
local source = nil;
-- Streams block
local open={};
local close={};
local high={};
local low={};
local MARKER={}; 
local Mode={};
local LAST={};
local FIRST={};

local LabelText={};
local LabelColor={};
local LabelFontFamily={};
local LabelFontSize={};


local Count=5;

-- Routine
function Prepare(nameOnly)


    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() ;


    local i;
	for i= 1, Count, 1 do
	Mode[i]=  instance.parameters:getString("Mode" .. i);
	Type[i]=  instance.parameters:getString("Type" .. i);
    Color[i]=  instance.parameters:getInteger("LabelColor" .. i);
	Width[i]=  instance.parameters:getInteger("LabelFontSize" .. i);
    LookBack[i]=  instance.parameters:getInteger("LookBack" .. i)  	
	
	 LabelText[i] =  instance.parameters:getString("LabelText" .. i);
    LabelColor[i] =  instance.parameters:getInteger("LabelColor" .. i);
    LabelFontFamily[i] =  instance.parameters:getString("LabelFontFamily" .. i);
    LabelFontSize[i] =  instance.parameters:getInteger("LabelFontSize" .. i);
	
	name = name.. ", ".. i .. ". ".. LookBack[i]
	
	end 
	--id
      
	
	name = name  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
	    for i = 1, Count , 1 do
	
			if Type[i]  == "Candle" then
				open[i] = instance:addStream("open"..i, core.Line, name, "open", core.rgb(0, 0, 0), first)
				high[i] = instance:addStream("high"..i, core.Line, name, "high", core.rgb(0, 0, 0), first)
				low[i] = instance:addStream("low"..i, core.Line, name, "low", core.rgb(0, 0, 0), first)
				close[i] = instance:addStream("close"..i, core.Line, name, "close", core.rgb(0, 0, 0), first)
				instance:createCandleGroup("MARKER".. i , "", open[i], high[i], low[i], close[i]);
			elseif Type[i] == "Marker" then
				MARKER[i] = instance:createTextOutput ("MARKER"..i, "MARKER" ..i, "Wingdings", Width[i], core.H_Center, core.V_Bottom,  Color[i], 0);
			else
				MARKER[i] = instance:createTextOutput ("MARKER"..i, "MARKER"..i, LabelFontFamily[i], LabelFontSize[i], core.H_Center, core.V_Bottom, LabelColor[i], 0);
			end
		 
		FIRST[i]= true
		LAST[i]=nil;	
		 end
    end
	
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < source:size()-1 then 
	return;
	end	
	
	
	
	local i;
	for i = 1, Count, 1 do
	Calculate(i, period);
	end

	
end

function Calculate (id, period)

if Mode[id] == "Trailing" then
			
						if source:serial(source:size()-1) ~= LAST[id]  and period == source:size()-1 then
						  
						  
						  
						   if LookBack[id] ~= 0  and LookBack[id]+1 < period  then
						   
						   
						      LAST[id]  = source:serial(source:size()-1);
							  
							    if Type[id]  == "Candle" then
							   		high[id][period-LookBack[id]]= source.high[period-LookBack[id]];
									low[id][period-LookBack[id]]= source.low[period-LookBack[id]];
									close[id][period-LookBack[id]] = source.close[period-LookBack[id]];
									open[id][period-LookBack[id]]  = source.open[period-LookBack[id]];
									open[id]:setColor(period-LookBack[id], Color[id]);
									
									
									if open[id][period-LookBack[id]-1] <  close[id][period-LookBack[id]-1] then
									open[id]:setColor(period-LookBack[id]-1,  core.COLOR_UPCANDLE );
									else
									open[id]:setColor(period-LookBack[id]-1,  core.COLOR_DOWNCANDLE);
									end
									

								elseif Type[id] == "Marker" then
									MARKER[id]:set(period-LookBack[id], source.low[period-LookBack[id]] , "\108");				
									MARKER[id]:setNoData (period-LookBack[id]-1);
								else
									MARKER[id]:set(period-LookBack[id], source.low[period-LookBack[id]] , LabelText[id]);
									MARKER[id]:setNoData (period-LookBack[id]-1);
								end

							end
						  
						  
						end  
			
				 else
					
					
					 if  FIRST[id] and  period == source:size()-1 then	
					     FIRST[id] = false;
						  
							if LookBack[id] ~= 0  and LookBack[id]+1 < period  then	

                                if Type  == "Candle" then
							   		high[id][period-LookBack[id]]= source.high[period-LookBack[id]];
									low[id][period-LookBack[id]]= source.low[period-LookBack[id]];
									close[id][period-LookBack[id]] = source.close[period-LookBack[id]];
									open[id][period-LookBack[id]]  = source.open[period-LookBack[id]];
									open[id]:setColor(period-LookBack[id], Color[id]);
									
									
									if open[id][period-LookBack[id]-1] <  close[id][period-LookBack[id]-1] then
									open[id]:setColor(period-LookBack[id]-1,  core.COLOR_UPCANDLE );
									else
									open[id]:setColor(period-LookBack[id]-1, core.COLOR_DOWNCANDLE );
									end 							

								 elseif Type[id] == "Marker" then
									MARKER[id]:set(period-LookBack[id], source.low[period-LookBack[id]] , "\108");				
									MARKER[id]:setNoData (period-LookBack[id]-1);
								else
									MARKER[id]:set(period-LookBack[id], source.low[period-LookBack[id]] , LabelText[id]);
									MARKER[id]:setNoData (period-LookBack[id]-1);
								end

							end
						  
						  
					end	  
				 

				 end
				 
				 

end




