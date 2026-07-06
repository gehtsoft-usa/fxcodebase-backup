-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61209


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
    indicator:name("Price Momentum Oscillator");
    indicator:description("Price Momentum Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("one", "Short Period", "Period", 20);
	indicator.parameters:addInteger("two", "Long Period", "Period", 35);
	indicator.parameters:addInteger("Period", "Signal Period", "Period", 10);
	
	indicator.parameters:addBoolean("SH", "Show Horizontal Line", "", true);
	indicator.parameters:addBoolean("SV", "Show Vertical Line", "", true);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of PMO Up", "Color of PMO", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of PMO Down", "Color of PMO", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local one, two;

local first;
local source = nil;
local RawOne,RawTwo;
-- Streams block
local PMO = nil;
local SmoothingMultiplierOne,SmoothingMultiplierTwo;
local CustomSmoothingFunctionOne;
local CustomSmoothingFunctionTwo;
local Signal;
local EMA;
local Period;
local SH,SV;
-- Routine
function Prepare(nameOnly)
    one = instance.parameters.one;
	two = instance.parameters.two;
	Period= instance.parameters.Period;
	SH= instance.parameters.SH;
	SV= instance.parameters.SV;
    source = instance.source;
    first = source:first();
	
	RawOne = instance:addInternalStream(0, 0);
	RawTwo = instance:addInternalStream(0, 0);
	CustomSmoothingFunctionOne= instance:addInternalStream(0, 0);
    CustomSmoothingFunctionTwo= instance:addInternalStream(0, 0);
	
	SmoothingMultiplierOne = (2 / one);
	SmoothingMultiplierTwo = (2 / two);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(one) .. ", " .. tostring(two) .. ", " .. tostring(Period).. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
        PMO = instance:addInternalStream(0, 0);	 
		EMA = core.indicators:create("EMA", PMO, Period);		
		Signal = instance:addInternalStream(0, 0);		
		instance:ownerDrawn(true);

	 
    
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2  then
	return;
	end
	
        if not init then
            context:createPen (1	, context:convertPenStyle (instance.parameters.style), instance.parameters.width,  instance.parameters.Up_color);
			context:createPen (2    , context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Down_color);
            init = true;
        end

		
		for period= math.max(context:firstBar () ,EMA.DATA:first()), math.min(context:lastBar (), source:size()-1), 1 do
			if PMO[period]> Signal[period] 
			and PMO[period-1]<= Signal[period-1]
			then
			if SV then
			x, x1, x2 = context:positionOfBar (period);
			context:drawLine (1, x, context:top (), x, context:bottom ());
			end
			
			if SH then
			x, x1, x2 = context:positionOfBar (period);
			visible, y = context:pointOfPrice (source[period] );
			context:drawLine (1, x, y, context:right (), y);
			end
			
			elseif PMO[period]< Signal[period]
			and PMO[period-1]>= Signal[period-1]
			then
			if SV then
			x, x1, x2 = context:positionOfBar (period);			
			context:drawLine (2, x, context:top (), x, context:bottom ());
			end
			
			if SH then
			x, x1, x2 = context:positionOfBar (period);
			visible, y = context:pointOfPrice (source[period] );
			context:drawLine (2, x, y, context:right (), y);
			end
			end

       end		
end		

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   if period < first or not source:hasData(period) then
	return;
	end  
	 
   RawOne[period] =(( (source[period]/source[period-1]) * 100)-100)  ;
   
   Two(RawOne,period)
   
   RawTwo[period]= 10*CustomSmoothingFunctionTwo[period];
	
    One(RawTwo,period);
	
        PMO[period] = CustomSmoothingFunctionOne[period];
		
		EMA:update(mode);
		if period < EMA.DATA:first() then
		return;
		end
		
		Signal[period]= EMA.DATA[period];
		
		
		
    
end

function One ( Close, period)

CustomSmoothingFunctionOne[period] = (Close[period] - CustomSmoothingFunctionOne[period-1]) * SmoothingMultiplierOne +  CustomSmoothingFunctionOne[period-1];
end

function Two(Close, period)
CustomSmoothingFunctionTwo[period] = (Close[period] - CustomSmoothingFunctionTwo[period-1]) * SmoothingMultiplierTwo +  CustomSmoothingFunctionTwo[period-1];
end
 