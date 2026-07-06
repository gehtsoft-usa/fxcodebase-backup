-- Id: 1837
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2330

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
    indicator:name("T3 RSI");
    indicator:description("T3 RSI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Parameters");
    indicator.parameters:addInteger("RSIFrame", "RSI Period", "No description", 8);
    indicator.parameters:addInteger("T3Frame", "T3 Period", " ", 8);
    indicator.parameters:addDouble("Curvature", " T3 Curvature", " ", 0.618);
	
	indicator.parameters:addGroup("RSI Style");
	indicator.parameters:addInteger("RSIwidth", "RSI Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("RSIstyle", "RSI Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("RSIstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("RSI_color", "Color of RSI", "Color of RSI", core.rgb(255, 0, 0));
	indicator.parameters:addGroup("T3 Style");
	indicator.parameters:addInteger("T3width", "T3 Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("T3style", "T3 Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("T3style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("T3_color", "Color of T3", "Color of T3", core.rgb(0, 255, 0));
	
	indicator.parameters:addGroup("Overbought/Oversold Level");
    indicator.parameters:addDouble("overbought", "Overbought Level", "", 45, 0, 100);
    indicator.parameters:addDouble("oversold", "Oversold Level", "", 55, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Style", "", core.LINE_SOLID);
	 indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(255, 255, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RSIFrame;
local T3Frame;
local Curvature;

local first;
local source = nil;

-- Streams block
local RSI = nil;
local RAW;
local T3 = nil;

local w1,w2,n,b2,b3,c1,c2,c3,c4;

        local e1=0;
		local e2=0;
		local e3=0;
		local e4=0;
		local e5=0;
		local e6=0;

function SET ()
 b2=Curvature*Curvature;
 b3=b2*Curvature;
 c1=-b3;
 c2=(3*(b2+b3));
 c3=-3*(2*b2+Curvature+b3);
 c4=(1+3*Curvature+b3+3*b2);
 n=T3Frame;

	if n<1 then 
	n=1;
	end
n = 1 + 0.5*(n-1);
w1 = 2 / (n + 1);
w2 = 1 - w1;

end

-- Routine
function Prepare(nameOnly)
    RSIFrame = instance.parameters.RSIFrame;
    T3Frame = instance.parameters.T3Frame;
    Curvature = instance.parameters.Curvature;
    source = instance.source;
   
	
	SET();

    local name = profile:id() .. "(" .. source:name() .. ", " .. RSIFrame .. ", " .. T3Frame .. ", " .. Curvature .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	RAW = core.indicators:create("RSI", source.close, T3Frame);
	first = RAW.DATA:first();
    RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSI_color, RAW.DATA:first());
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
	RSI:setWidth(instance.parameters.RSIwidth);
    RSI:setStyle(instance.parameters.RSIstyle);
	
	--RSI:addLevel(45);
    RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
   -- RSI:addLevel(55);
    RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    
	
    T3 = instance:addStream("T3", core.Line, name .. ".T3", "T3", instance.parameters.T3_color, RAW.DATA:first());
    T3:setPrecision(math.max(2, instance.source:getPrecision()));
	T3:setWidth(instance.parameters.T3width);
    T3:setStyle(instance.parameters.T3style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
   
	
    	RAW:update(mode);
		
		 if period < first or not source:hasData(period) then
		 return;
		 end
	 
	    if RAW.DATA:hasData(period) then
        RSI[period] = RAW.DATA[period];
		
		e1 = w1*RSI[period] + w2*e1;
		e2 = w1*e1 + w2*e2;
		e3 = w1*e2 + w2*e3;
		e4 = w1*e3 + w2*e4;
		e5 = w1*e4 + w2*e5;
		e6 = w1*e5 + w2*e6;

		T3[period]=c1*e6 + c2*e5 + c3*e4 + c4*e3;
		
       
		end
  
end

