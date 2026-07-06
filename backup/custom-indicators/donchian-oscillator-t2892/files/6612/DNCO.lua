-- Id: 2577
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2892

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Donchian Oscillator");
    indicator:description("Donchian Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("SF", "Slow Period", "", 20);
    indicator.parameters:addInteger("FF", "Fast Period", "", 10);
	indicator.parameters:addBoolean("USE", "Use Average", "", true);
	indicator.parameters:addInteger("AF", "Average Period", "", 10);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("High_color", "Color of High", "Color of High", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Low_color", "Color of Low", "Color of Low", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Sum_color", "Color of Sum", "Color of Sum", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SF;
local FF;
local USE;
local AF;

local first;
local source = nil;

local HH, HL,LH, LL;

-- Streams block
local High = nil;
local Low = nil;
local Top, Bottom;
local MAT, MAB;
local SUM;

-- Routine
 function Prepare(nameOnly) 
 
    AF = instance.parameters.AF;
    SF = instance.parameters.SF;
    FF = instance.parameters.FF;
    USE = instance.parameters.USE;
	source = instance.source;
	first = math.max(FF,SF);
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. SF .. ", " .. FF .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	if USE then
	Top = instance:addInternalStream (first, 0);
	Bottom = instance:addInternalStream (first, 0);
	 
	MAT= core.indicators:create("MVA", Top, AF);
	MAB= core.indicators:create("MVA", Bottom, AF); 
	first = MAT.DATA:first();
	end
	

    High = instance:addStream("High", core.Line, name .. ".High", "High", instance.parameters.High_color, first);
	High:setWidth(instance.parameters.width1);
    High:setStyle(instance.parameters.style1);
	
	SUM= instance:addStream("Sum", core.Line, name .. ".Sum", "Sum", instance.parameters.Sum_color, first);	
	SUM:setWidth(instance.parameters.width3);
    SUM:setStyle(instance.parameters.style3);
	
    Low = instance:addStream("Low", core.Line, name .. ".Low", "Low", instance.parameters.Low_color, first);
	Low:setWidth(instance.parameters.width2);
    Low:setStyle(instance.parameters.style2);
	
	High:setPrecision(math.max(2, instance.source:getPrecision()));
	Low:setPrecision(math.max(2, instance.source:getPrecision()));
	SUM:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < FF or not source:hasData(period) or period < SF then
	return;
	end
	
	    HL, HH= mathex.minmax(source , period -SF+1, period  );
		LL, LH =  mathex.minmax(source , period -FF+1, period  );
	
	if USE then	
	
	  Top[period] = LH-HH;
      Bottom[period] = LL-HL;
	  
	   MAT:update(mode); 
	   MAB:update(mode); 
	   
 
	   
	   High[period]= MAT.DATA[period];
	   Low[period] =  MAB.DATA[period];
	  
	  
	else

     	
	High[period] = LH-HH;
    Low[period] = LL-HL;    

    
	end
	
	
	SUM[period]=  High[period] + Low[period] ;
	
	
	
   	
      
end

