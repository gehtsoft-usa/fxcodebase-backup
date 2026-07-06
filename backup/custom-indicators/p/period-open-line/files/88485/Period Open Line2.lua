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
    indicator.parameters:addStringAlternative("TF", "m1", "", "m1");
    indicator.parameters:addStringAlternative("TF", "m5", "", "m5");
    indicator.parameters:addStringAlternative("TF", "m15", "", "m15");
    indicator.parameters:addStringAlternative("TF", "m30", "", "m30");
    indicator.parameters:addStringAlternative("TF", "H1", "", "H1");
    indicator.parameters:addStringAlternative("TF", "H2", "", "H2");
    indicator.parameters:addStringAlternative("TF", "H3", "", "H3");
    indicator.parameters:addStringAlternative("TF", "H4", "", "H4");
    indicator.parameters:addStringAlternative("TF", "H6", "", "H6");
    indicator.parameters:addStringAlternative("TF", "H8", "", "H8");
    indicator.parameters:addStringAlternative("TF", "D1", "", "D1");
    indicator.parameters:addStringAlternative("TF", "W1", "", "W1");
    indicator.parameters:addStringAlternative("TF", "M1", "", "M1");
    indicator.parameters:addStringAlternative("TF", "Y1", "", "Y1");
	indicator.parameters:addInteger("Shift", "Shift", "", 0, 0, 1000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	
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
    local IsAnnual;
    local Shift;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
    first = source:first();
	TF= instance.parameters.TF;
	Shift= instance.parameters.Shift;
	if TF=="Y1" then
	 IsAnnual=true;
	else
	 IsAnnual=false;
	end
		
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(TF).. ", " .. tostring(Shift) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	
	local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");
    
    if not(IsAnnual) then
     SourceData=core.host:execute("getSyncHistory",source:instrument(), TF, source:isBid(), 0, 100, 101);
    else
     SourceData=core.host:execute("getSyncHistory",source:instrument(), "M1", source:isBid(), 0, 100, 101);
    end 

	
    
	   

        Line = instance:addStream("OPEN", core.Line, name, "OPEN", instance.parameters.color, first);
		Line:setWidth(instance.parameters.width);
        Line:setStyle(instance.parameters.style);
    
end


function   Initialization(period)

    local Candle;
    if IsAnnual then
     local t = core.dateToTable(source:date(period));
     t.month=1;
     t.day=1;
     t.hour=0;
     t.min=0;
     t.sec=0;
     Candle = core.getcandle(TF, core.tableToDate(t), offset, weekoffset);
    else
     Candle = core.getcandle(TF, source:date(period), offset, weekoffset);
    end 

  
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
		or r <  Shift
		then
		return;
		end		
		
		
	  
	    
       Line[period]= SourceData.open[r-Shift];
	  
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


