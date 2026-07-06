
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1855

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
    indicator:name("DSS Overlay");
    indicator:description("DSS Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Stochastic Period", "Stochastic Period", 13);
    indicator.parameters:addInteger("EMAFrame", "Smooth Period", "Smooth Period", 8);
	indicator.parameters:addInteger("SignalFrame", "Signal Period", "Signal Period", 8);
	
	indicator.parameters:addString("Method", "Overlay Method", "Method" , "Slope");
    indicator.parameters:addStringAlternative("Method", "Slope", "Slope" , "Slope");
    indicator.parameters:addStringAlternative("Method", "DSS/SIGNAL", "DSS/SIGNAL" , "DSS/SIGNAL");
    indicator.parameters:addStringAlternative("Method", "DSS/CENTRAL", "DSS/CENTRAL" , "DSS/CENTRAL");
	
	indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Stochastic Up", "Color of Stochastic", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Stochastic Down", "Color of Stochastic", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color of Stochastic Neutral", "Color of Stochastic", core.rgb(128, 128, 128));
	 

	 
	indicator.parameters:addColor("OBColor", "Overbought Zone Color","", core.rgb(0, 200, 0));
	indicator.parameters:addColor("OSColor", "Oversold Zone Color","", core.rgb(200, 0, 0));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local EMAFrame;
local SignalFrame;

local first;
local source = nil;

-- Streams block
local DSS= nil;
local EMA = nil;
local Show;
local HIGH=nil;
local LOW=nil;

local DELTA=nil;
local MIT=nil;
local SmoothCoefficient=nil;

local Buffer=nil;
local Signal=nil;
local OUT=nil;
local transparency; 
local OBColor, OSColor;
local Up, Down,Neutral;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local OB, OS;
local Method;
-- Routine
function Prepare(nameOnly) 
    Frame = instance.parameters.Frame;
    EMAFrame = instance.parameters.EMAFrame;
	SignalFrame = instance.parameters.SignalFrame;
	Show = instance.parameters.Show; 
	OBColor = instance.parameters.OBColor;
	OSColor = instance.parameters.OSColor;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
	OS= instance.parameters.oversold;
	OB= instance.parameters.overbought;
	Method= instance.parameters.Method;

    source = instance.source;
    first = source:first()+Frame;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ", " .. EMAFrame ..", ".. SignalFrame.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Buffer=instance:addInternalStream(0, 0);
	OUT=instance:addInternalStream(0, 0);
	
	
    DSS =instance:addInternalStream(0, 0);

	
	EMA = core.indicators:create("EMA", OUT, SignalFrame);
	
    Signal =instance:addInternalStream(0, 0);
	
	SmoothCoefficient= 2.0 / (1.0 + EMAFrame); 
	
	 open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
    if period < first or not source:hasData(period) then
	open:setColor(period, Neutral);	
	return;
	end 
	
	
			HIGH = mathex.max(source.high, period-Frame+1, period);
			LOW = mathex.min(source.low, period-Frame+1, period);
			DELTA = source.close[period] - LOW;
			MIT = DELTA/(HIGH - LOW)*100.0;
			Buffer[period] = SmoothCoefficient * (MIT - Buffer[period-1]) + Buffer[period-1];
			
			if period < 2*Frame  then
			return;
			end
			
					LOW, HIGH = mathex.minmax(Buffer , period-Frame-1, period);
					DELTA= Buffer[period] -LOW; 
					MIT = DELTA/(HIGH - LOW)*100.0;
					OUT[period] = SmoothCoefficient * (MIT - OUT[period-1]) + OUT[period-1];
					
					if period < 3*Frame + EMAFrame then
					return;
					end
					
					
					DSS[period]=OUT[period];
					 
					
							 	
							EMA:update(mode);
							
							if period < EMA.DATA:first() then
							return;
							end
							
							Signal[period] = EMA.DATA[period];
							 
		 
    if Method== "Slope" then
		if DSS[period]> DSS[period-1] then
		open:setColor(period,Up);	 
		elseif DSS[period]< DSS[period-1] then	
		open:setColor(period,Down);	 
		else
		open:setColor(period,Neutral);	  
		end
		
		if DSS[period]> OB then
		open:setColor(period,OBColor);	
		elseif DSS[period]< OS then
		open:setColor(period,OSColor);	
		end
	elseif Method== "DSS/SIGNAL" then
		if DSS[period]> Signal[period] then
		open:setColor(period,Up);	 
		elseif DSS[period]< Signal[period] then	
		open:setColor(period,Down);	 
		else
		open:setColor(period,Neutral);	  
		end
		
		if DSS[period]> OB then
		open:setColor(period,OBColor);	
		elseif DSS[period]< OS then
		open:setColor(period,OSColor);	
		end
	elseif Method== "DSS/CENTRAL" then
		if DSS[period]> 50 then
		open:setColor(period,Up);	 
		elseif DSS[period]< 50 then	
		open:setColor(period,Down);	 
		else
		open:setColor(period,Neutral);	  
		end
		
		if DSS[period]> OB then
		open:setColor(period,OBColor);	
		elseif DSS[period]< OS then
		open:setColor(period,OSColor);	
		end	
	end
	
end

 