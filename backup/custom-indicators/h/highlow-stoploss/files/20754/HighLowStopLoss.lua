-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9745
-- Id: 5294

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("HighLow StopLoss");
    indicator:description("Last HighLow StopLoss");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	    indicator.parameters:addGroup("Calculation");

	indicator.parameters:addString("SS", "Stop Source", "", "Bid");
    indicator.parameters:addStringAlternative("SS", "Bid", "", "Bid");
    indicator.parameters:addStringAlternative("SS", "Ask", "", "Ask");
	
	indicator.parameters:addString("LS", "Limit Source", "", "Bid");
    indicator.parameters:addStringAlternative("LS", "Bid", "", "Bid");
    indicator.parameters:addStringAlternative("LS", "Ask", "", "Ask");
	
	indicator.parameters:addString("HShift", "Last Period", "", "Last");
    indicator.parameters:addStringAlternative("HShift", "Last", "", "Last");
    indicator.parameters:addStringAlternative("HShift", "Previous", "", "Previous");	
   
   indicator.parameters:addDouble("VShift", "Vertical Shift (in Pips)", "", 10);  
   
   
    indicator.parameters:addGroup("Position sizing");
    indicator.parameters:addString("Type", "Balance/Equity", "", "Balance");
    indicator.parameters:addStringAlternative("Type", "Equity", "", "Equity");
    indicator.parameters:addStringAlternative("Type", "Balance", "", "Balance");
	
	  indicator.parameters:addDouble("Percentage", "Percentage", "", 1);     

    indicator.parameters:addGroup("Style");
	 indicator.parameters:addInteger("FontSize", "Font Size", "", 10);
    indicator.parameters:addColor("Stop", "Stop", "Stop", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
	 
	 indicator.parameters:addGroup("Positioning");
	indicator.parameters:addString("Positioning", "Positioning", "", "top-right");	
	indicator.parameters:addStringAlternative("Positioning", "top-left" , "", "top-left");
	indicator.parameters:addStringAlternative("Positioning", "bottom-left" , "", "bottom-left");
	indicator.parameters:addStringAlternative("Positioning", "top-right" , "", "top-right");
	indicator.parameters:addStringAlternative("Positioning", "bottom-right" , "", "bottom-right");
 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local bid, ask;
local SS, LS;
local first;
local source = nil;
local LD;
local SD;
local Type;
local HShift;
local VShift;
local Percentage;
local id;
local font;
local Label;
local FontSize;
local Pos;
local V, Balance, accounts;
local loading={};
local Size;
-- Routine
function Prepare(nameOnly)
    Pos = instance.parameters.Positioning;
    FontSize = instance.parameters.FontSize;
    Label = instance.parameters.Label;
    Percentage = instance.parameters.Percentage; 
    Type = instance.parameters.Type;

    VShift = instance.parameters.VShift;
	SS = instance.parameters.SS;
	LS = instance.parameters.LS;
    source = instance.source;
    first = source:first();
	
	VShift = VShift * source:pipSize()
		
	if  instance.parameters.HShift == "Last" then
	HShift =0;
	else
	HShift = 1;
	end

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
    if nameOnly then
    	return;
    end
	bid = core.host:execute("getBidPrice");
    ask = core.host:execute("getAskPrice");
	font = core.host:execute("createFont", "Ariel", FontSize, true, false);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period < source:size() -1
	--or loading[1]
	--or loading[2]
	then
	return;
	end
	
	
	V = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost; 
	accounts = core.host:findTable("accounts");
	
	if accounts== nil then
	return;
	end
	
	id=0;
	
    local enum = accounts:enumerator();
	local row = enum:next();
    if row ~= nil then
	
	if Type == "Balance" then
	Balance= row.Balance;
	else
	Balance= row.Equity;
	end
	
	if Balance==nil then
	return;
	end
					
	
	Size = (Balance / 100)*Percentage;
	
	DRAW( 1,   "Short");	
	DRAW(2,   "Long");
	

	 end
end

function DRAW(ID,   label)

 if ID== 1 then
    if SS == "Bid" then
	value1 =bid.low[NOW - HShift] -  VShift;
	else
	value1 = ask.low[NOW - HShift] -  VShift;
	end
	
	
	if SS == "Bid" then
	value2 = (Size / (((  bid.close[NOW] -value1)/ source:pipSize())* V ) );
	else
	value2 = (Size / (((   ask.close[NOW] -value1)/ source:pipSize())* V ) );
	end
	
	
 else
 
    if LS == "Bid" then
	value1=   bid.high[NOW -  HShift] +  VShift;
	else
	value1=   ask.high[NOW -  HShift] +  VShift ;
	end
	
	
	if LS == "Bid" then
	value2= (Size / ((( value1- bid.close[NOW])/source:pipSize()) * V) ) ;
	else
	value2= (Size / ((( value1 - ask.close[NOW])/source:pipSize()) * V) ) ;
	end
	
	--value
 end
  

 id = id +1;
 core.host:execute("drawLine", id , source:date(first), value1, source:date(NOW), value1, instance.parameters.Stop);
 id = id+1;
 core.host:execute("drawLabel", id,   source:date(NOW), value1,    string.format("%." .. source:getPrecision() .. "f", value1  ) );
 
 
 
   value2 = win32.formatNumber(value2, false, 2);  	
   Draw (ID, value2 , 25, FontSize*1.5, Pos);
   Draw (ID, label , 75, FontSize*1.5, Pos);

end


function Positioning (Poz)

    if Poz == "top-right" then
	return  core.CR_RIGHT,  core.CR_TOP, -1,1, core.H_Left, core.V_Bottom;
	
    elseif Poz == "top-left" then
	return core.CR_LEFT, core.CR_TOP, 1,1 , core.H_Right , core.V_Bottom;
	
    elseif Poz ==  "bottom-left" then
	return  core.CR_LEFT, core.CR_BOTTOM, 1,-1 ,core.H_Right, core.V_Bottom;
	
    elseif Poz == "bottom-right" then
	return    core.CR_RIGHT,  core.CR_BOTTOM , -1, -1 , core.H_Left , core.V_Bottom;
	
	elseif Poz ==  "center" then
	return  core.CR_CENTER, core.CR_CENTER, 1, 1, core.H_Left, core.V_Bottom;
	
	elseif Poz ==  "price"  then
	return  core.CR_CHART,  core.CR_CHART, 1, 1,core.H_Left, core.V_Bottom;
	
	else
	return -1;
	end
	                                      
	
  

end


function Draw (line, value , x, y, Pos)
 
    local  POZ={};
    POZ["X"] , POZ["Y"], POZ["x"] , POZ["y"], POZ["H"], POZ["V"] = Positioning (Pos );
	
	if POZ["X"] == -1 then
	
	id = id+1;
	core.host:execute("drawLabel1",id, -x, core.CR_RIGHT, y*line, core.CR_TOP, core.H_Left, core.V_Bottom,  font, Label,   "Incorrect positioning parameter"  );
	return;	
	end


	
    local X, Y;
	
    if Poz ==  "price" then
	X=source:date(x);
	Y=source.close[y];
	else
	X=POZ["x"] * x;
	Y=POZ["y"] * y *line;
    end
    id = id+1;
	core.host:execute("drawLabel1",id,  X, POZ["X"], Y, POZ["Y"], POZ["H"], POZ["V"],  font, Label,   value  );
	
end



function ReleaseInstance()
       core.host:execute("deleteFont", font);      

end
--[[

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Num=0;
local Id=0;
    for j = 1, 2, 1 do
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + Id ) then
			  loading[j]  = false;
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
           
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((2) - Num) .. " / " .. (2) );	 
	else
	core.host:execute ("setStatus", "Loaded");	            
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
	
	
end]]