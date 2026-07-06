-- Id: 5668

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9634

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
    indicator:name("3 MA_Price Bar with SuperTrend confirmation");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Three MA Calculation");
    indicator.parameters:addInteger("P1", "1. Period", "1. Period", 34);
    indicator.parameters:addInteger("P2", "2. Period", "2. Period", 68);
    indicator.parameters:addInteger("P3", "3. Period", "3. Period", 102);
	indicator.parameters:addString("Price", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addGroup("Super Trend Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "No description", 10);
    indicator.parameters:addDouble("M", "Multiplier", "No description", 1.5);
	
	indicator.parameters:addString("Type", "Smoothing type", "", "EMA");
    indicator.parameters:addStringAlternative("Type", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("Type", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("Type" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("Type" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("Type" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("Type" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("Type" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("Type" , "WMA", "", "WMA");	
				
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Dn", "Color for Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Color for No Trend", "", core.rgb(255, 255, 0));
	 indicator.parameters:addInteger("Size", "Arrow Size", "", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local P1;
local P2;
local P3;
local Type;

local Size;

local first;
local source = nil;
local N;
local M;

-- Streams block
local Indicator={};
local Out = nil;
local Price;

local up, down;
-- Routine
function Prepare(nameOnly)
    Price= instance.parameters.Price;
    P1 = instance.parameters.P1;
    P2 = instance.parameters.P2;
    P3 = instance.parameters.P3;
	N = instance.parameters.N;
    M = instance.parameters.M;
	Type = instance.parameters.Type;
    source = instance.source;
    Size = instance.parameters.Size;
	


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type) .. ", " .. tostring(P1) .. ", " .. tostring(P2) .. ", " .. tostring(P3).. ", " .. tostring(N) .. ", " .. tostring(M) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("SUPERTREND") ~= nil, "Please, download and install SUPERTREND.LUA indicator");
	
    assert(core.indicators:findIndicator(Type) ~= nil, Type .. " indicator must be installed");
	 Indicator[1] = core.indicators:create(Type, source[Price], P1);
	 Indicator[2] = core.indicators:create(Type, source[Price], P2);
	 Indicator[3] = core.indicators:create(Type, source[Price], P3);
	 Indicator[4] = core.indicators:create("SUPERTREND", source, N, M, core.rgb(0, 255, 0), core.rgb(255, 0, 0));
	 
	 first = math.max(Indicator[1].DATA:first(),Indicator[2].DATA:first(),Indicator[3].DATA:first(), Indicator[4].DATA:first());

     
        Out = instance:addStream("Out", core.Bar, name, "Out", instance.parameters.Up, first);
	    Out:addLevel(0);
		Out:setPrecision(math.max(2, source:getPrecision()));
    
	
	up = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Dn, 0);
     down = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
	
	core.host:execute ("attachTextToChart", "Up");
	core.host:execute ("attachTextToChart", "Dn");
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < period or  not source:hasData(period) then
	return;
	end
	
	 Indicator[1]:update(mode);
	 Indicator[2]:update(mode);
	 Indicator[3]:update(mode);
	  Indicator[4]:update(mode);
	 
	  Out[period] = 1;
	 
	 if   source.close[period] > Indicator[1].DATA[period] 
	 and Indicator[1].DATA[period] > Indicator[2].DATA[period]
	 and  Indicator[2].DATA[period] > Indicator[3].DATA[period]
	 and  Indicator[4].DATA:colorI(period) ==  core.rgb(0, 255, 0) 
	 then
	  Out:setColor(period, instance.parameters.Up);  
	  if Out:colorI(period-1)~=  instance.parameters.Up then
	  down:set(period, source.low[period], "\225");
	  end
	  up:setNoData (period);

	  elseif   source.close[period] < Indicator[1].DATA[period]
	 and Indicator[1].DATA[period] < Indicator[2].DATA[period]
	 and  Indicator[2].DATA[period] < Indicator[3].DATA[period] 
	  and  Indicator[4].DATA:colorI(period) ==  core.rgb(255, 0, 0) 
	 then
	  Out:setColor(period, instance.parameters.Dn); 
	    if Out:colorI(period-1)~=  instance.parameters.Dn then
	    up:set(period, source.high[period], "\226");
		end
		 down:setNoData (period);
	 else
	 
	  Out:setColor(period, instance.parameters.No);  
	   up:setNoData (period);
	  down:setNoData (period);
	 end
	
       
    
end

