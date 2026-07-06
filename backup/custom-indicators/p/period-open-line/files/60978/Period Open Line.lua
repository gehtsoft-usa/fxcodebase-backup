-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36333


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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Period Open Line");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addString("TF", "Time Frame", "", "W1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	indicator.parameters:addInteger("Shift", "Shift", "", 0, 0, 1000);
 
	
	indicator.parameters:addGroup("Style"); 	
	indicator.parameters:addBoolean("Open" , "Show Open Line" , "", true);
    indicator.parameters:addColor("color1", "Open Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addBoolean("High" , "Show High Line" , "", true);
	indicator.parameters:addColor("color2", "High Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addBoolean("Low" , "Show Low Line" , "", true);
	indicator.parameters:addColor("color3", "Low Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Shift;
	local first;
	local source = nil;	 
	local host;
	local offset;
	local weekoffset;
	local SourceData;
	local loading = false;   
    local Line = nil;
	local TF;	
    local p;
    local High,Low,Open;
	local high, low, open;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
    first = source:first();
	TF= instance.parameters.TF;
	Shift= instance.parameters.Shift;
	
	High= instance.parameters.High;
	Low= instance.parameters.Low;
	Open= instance.parameters.Open;
		
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(TF)  .. ", " .. tostring(Shift).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");
    
	SourceData=core.host:execute("getSyncHistory",source:instrument(), TF, source:isBid(), 0, 100, 101);
    loading=true;
	
    

   
	   
        if Open  then
        open = instance:addStream("OPEN", core.Line, name, "OPEN", instance.parameters.color1, first);
		open:setWidth(instance.parameters.width1);
        open:setStyle(instance.parameters.style1);
		else
		open= instance:addInternalStream(0, 0);
		end
		
		if High  then
		high = instance:addStream("HIGH", core.Line, name, "HIGH", instance.parameters.color2, first);
		high:setWidth(instance.parameters.width2);
        high:setStyle(instance.parameters.style2);
		else
		high= instance:addInternalStream(0, 0);
		end
		
		if Low then
		low = instance:addStream("LOW", core.Line, name, "LOW", instance.parameters.color3, first);
		low:setWidth(instance.parameters.width3);
        low:setStyle(instance.parameters.style3);
		else
		low= instance:addInternalStream(0, 0);
		end
   
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), offset, weekoffset);

  
    if loading or SourceData:size() == 0  then
        return false;
    end

    
	
    if period < source:first() then
        return false;
    end

    local r = core.findDate(SourceData, Candle, false);
	

    -- candle is not found
    if r < 0 then
        return false;
	else return r;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

        local r;
		r=  Initialization(period) 
     
	    if not r
		or r < Shift 
		then
		return;
		end		
	  
	    
       open[period]= SourceData.open[r-Shift];
	   high[period]= SourceData.high[r-Shift];
	   low[period]= SourceData.low[r-Shift];
	  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


