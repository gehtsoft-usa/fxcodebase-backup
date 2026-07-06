
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12428

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



-- Indicator profile initialization routine
 
function Init()
    indicator:name("ICH CLOUD BAR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Zone Trade");
    indicator.parameters:addGroup("ICH Calculation");
    indicator.parameters:addInteger("X", "Tenkan-sen period", "", 9, 1, 10000);
    indicator.parameters:addInteger("Y", "Kijun-sen period", "", 26, 1, 10000);
    indicator.parameters:addInteger("Z", "Kijun-sen period", "", 52, 1, 10000);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Up Cloud in Up Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDn", "Down Cloud in Up Trend", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DnUp", "Up Cloud in Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DnDn", "Down Cloud in Down Trend", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("NoUp", "Up Cloud in No Trend", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("NoDn", "Down Cloud in No Trend", "", core.rgb(200, 100, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Indicator;


local first;
local source = nil;


local open=nil;
local close=nil;
local high=nil;
local low=nil;

local Parameters={};
local Short={};

-- Routine
function Prepare(nameOnly) 

    Parameters["X"]=  instance.parameters.X;
	Parameters["Y"]=  instance.parameters.Y;
	Parameters["Z"]=  instance.parameters.Z;
	
	
    source = instance.source;
 

    local name = profile:id() .. "(" .. source:name() .. ", " .. Parameters["X"] ..", " .. Parameters["Y"] ..", " .. Parameters["Z"].. ")";
    instance:name(name);
   
   if   (nameOnly) then
        return;
    end
	
	Indicator = core.indicators:create("ICH", source,  Parameters["X"],  Parameters["Y"],  Parameters["Z"]);
	Short["A"] = Indicator:getStream(3);
	Short["B"] = Indicator:getStream(4);
   
      first = Short["B"]:first();
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)
     
	if period < first  or not source:hasData(period) then
	open:setColor(period, core.rgb(128, 128, 128));	
    return;
    end 
 
    Indicator:update(mode);
   
	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];
	
	
	if source.close[period] >   math.max(Short["A"][period] , math.max(Short["B"][period] ))then
	
	    if Short["A"][period] > Short["B"][period] then
	    open:setColor(period, instance.parameters.UpUp);	
		else
		open:setColor(period, instance.parameters.UpDn);
		end
		
	elseif source.close[period] <   math.min(Short["A"][period] , math.max(Short["B"][period] ))then
	
	     if Short["A"][period] > Short["B"][period] then
	    open:setColor(period, instance.parameters.DnUp);	
		else
		open:setColor(period, instance.parameters.DnDn);
		end
	else
	    if Short["A"][period] > Short["B"][period] then
	    open:setColor(period, instance.parameters.NoUp);	
		else
		open:setColor(period, instance.parameters.NoDn);
		end
	end
	
				   
   
    
				  
    end

