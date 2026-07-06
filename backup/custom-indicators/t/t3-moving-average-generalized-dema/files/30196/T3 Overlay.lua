-- Id: 6365
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1302

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
    indicator:name("T3 Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Price" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price" , "Weighted ", "", "weighted");		

	indicator.parameters:addDouble("VF", "Volume Factor", "Volume Factor", 0.7, 0, 1);
    indicator.parameters:addInteger("F", "Period", "Period",20,2,2000);
	
	indicator.parameters:addString("Method" , "Method for avegage", "", "T3");
   indicator.parameters:addStringAlternative("Method" , "T3", "", "T3");
   indicator.parameters:addStringAlternative("Method", "GD", "", "GD");


	
	indicator.parameters:addString("Type" , "Overlay Type", "", "Slope");
    indicator.parameters:addStringAlternative("Type" , "Slope", "", "Slope");
    indicator.parameters:addStringAlternative("Type", "Cross", "", "Cross");


	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local Price;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local MA;
local Method;
local Period;
function Prepare(nameOnly)
    Type = instance.parameters.Type;
	Price = instance.parameters.Price;
	F= instance.parameters.F;
	VF= instance.parameters.VF;	
	Method= instance.parameters.Method;
	source = instance.source;	
	
	assert(core.indicators:findIndicator("T3") ~= nil, "Please, download and install T3.LUA indicator");
	assert(core.indicators:findIndicator("GD") ~= nil, "Please, download and install GD.LUA indicator");
	
    local name = profile:id() .. "(" .. source:name() ..", ".. VF ..", ".. F..", ".. Type..", ".. Method .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA=core.indicators:create(Method,  source[Price], VF ,  F);
	     
	
	
	first= MA.DATA:first();

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
			if period < first then
			open:setColor(period, instance.parameters.No);	
			return;
			end
	


		 MA:update(mode);
			 
		 
	if Type == "Slope" then
	
		if MA.DATA[period]> MA.DATA[period-1] then		
		open:setColor(period, instance.parameters.Up);
        elseif  MA.DATA[period]< MA.DATA[period-1]  then
		open:setColor(period, instance.parameters.Dn);
		else
		open:setColor(period, instance.parameters.No);			
		end
		
	elseif Type == "Cross" then

          if  source[Price][period] > MA.DATA[period] then		
		open:setColor(period, instance.parameters.Up);
        elseif source[Price][period] < MA.DATA[period]  then
		open:setColor(period, instance.parameters.Dn);
		else
		open:setColor(period, instance.parameters.No);			
		end	
		
	end	
				

		
 end


