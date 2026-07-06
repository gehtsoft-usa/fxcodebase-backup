-- Id: 21008
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=658

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
    indicator:name("Moving Average Envelope (New Version)");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods for Moving Average", "", 14);
    indicator.parameters:addString("MET", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MET", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MET", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MET", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MET", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MET", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MET", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MET", "Wilders*", "", "WMA");

    indicator.parameters:addDouble("B", "Band Width", "", 25);
    indicator.parameters:addString("BWU", "Band Width Units", "", "%%");
    indicator.parameters:addStringAlternative("BWU", "In 1/100 of percent", "", "%%");
    indicator.parameters:addStringAlternative("BWU", "In pips", "", "pip(s)");
    indicator.parameters:addInteger("Period", "Periods for Switch", "", 3);
    
    indicator.parameters:addGroup("Shift");
    indicator.parameters:addString("Method", "Method", "Method" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Value", "Value" , "Value");
	indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addInteger("SX", "Shift in periods", "Postive is future, negative is past", 0);
    indicator.parameters:addDouble("SY", "Shift in points", "", 0);


    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("SM", "Show MA line", "", true);
    indicator.parameters:addColor("MVA_color", "Color of MA line", "", core.rgb(0, 0, 255)); 
    indicator.parameters:addColor("Up", "Color of Up Band", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Down Band", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local B;
local BWU;
local MET;
local SM;

local first;
local first2 = 0;
local source = nil;
local IND;
local Period;

-- Streams block
local MVA = nil;
local UB = nil;
local LB = nil;

-- Shift params
local SX, SY;
local ShiftMethod;
local Up, Down,Neutral;

-- output candles
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local color=nil;


-- Routine
 function Prepare(nameOnly) 
    N = instance.parameters.N;
    B = instance.parameters.B;
    BWU = instance.parameters.BWU;
    MET = instance.parameters.MET;
    SM = instance.parameters.SM;
    source = instance.source;
    assert(core.indicators:findIndicator(MET) ~= nil, MET .. " indicator must be installed");
    IND = core.indicators:create(MET, source, N);
    ShiftMethod=instance.parameters.Method;
    SX = instance.parameters.SX;

    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	Period=instance.parameters.Period;

    first = IND.DATA:first();    
    first2 = first + SX;
    if first2 < 0 then
        first2 = 0;
    end


    local name = profile:id() .. "(" .. source:name() .. "," .. MET .. "(" .. N .. ")," .. B .. BWU .. ", " .. instance.parameters.SX .. " bars," .. instance.parameters.SY .. " points)";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    if BWU == "%%" then
        BWU = 1;
    else
        BWU = 2;
        B = B * source:pipSize();
    end

    if SM then
        MVA = instance:addStream("MVA", core.Line, name .. ".MVA", "MVA", instance.parameters.MVA_color, first2, SX);
    end
    
	if Method=="Pips" then
        SY = instance.parameters.SY * source:pipSize();
    else 
        SY = instance.parameters.SY;
	end

    UB = instance:addStream("UB", core.Line, name .. ".UB", "UB", instance.parameters.Up, first2, SX);
    LB = instance:addStream("LB", core.Line, name .. ".LB", "LB", instance.parameters.Down, first2, SX);   
    
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);

	color = instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];


    local p1 = period + SX;
    if p1 >= 0 and period >= first then   
        IND:update(mode);

        local d = IND.DATA[period];
        local s;

        if BWU == 1 then
            s = d * B / 10000;
        else
            s = B;
        end

        if SM then
            if ShiftMethod~="Percentage" then
                MVA[p1] = d + SY;
            else
                MVA[p1] = d + (d/100)*SY;
            end
        end
                    
        if ShiftMethod~="Percentage" then
            UB[p1] = (d + s)+ SY;
            LB[p1] = (d - s)+ SY;
        else
            UB[p1] = (d + s) + ((d + s)/100)*SY;
            LB[p1] = (d - s) + ((d - s)/100)*SY;
        end
        
        if period >= first + SX - Period then
            Check(period);
            if color[period] == 1 then 
                open:setColor(period, Up);
            elseif color[period] == -1  then
                open:setColor(period, Down);	
            else 
                open:setColor(period, Neutral);				 
            end
        else
            open:setColor(period, Neutral);		
        end
    else
        open:setColor(period, Neutral);			
    end
end

function Check(period)
    local i;
	local T=1;
	local D=1;
	local N=1;

	for i= period, period-Period+1, -1 do
	     
	    if (UB:size() < i or LB:size() < i) then 
	        return 
	    end   
	   
	        
	    if source.close[i]< UB[i] then
		T=0;
		end
		
		if source.close[i]> LB[i] then
		D=0;
		end
		
		if source.close[i]<  LB[i] or  source.close[i]> UB[i] then
		N=0;
		end
	
	    if T== 0 and D== 0 and N== 0 then
		return;
		end
	
	end
	
    
    if T== 1 then 
        color[period]= 1;
	elseif D== 1 then 
        color[period]=-1;
	elseif N== 1 then 
        color[period] =0; 
     end

end
