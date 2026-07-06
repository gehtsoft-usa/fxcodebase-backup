-- Id: 14624

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62495

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
    indicator:name("ZerolLagRSI");
    indicator:description("ZerolLagRSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("smoothing1", "1. Smoothing","", 15);  
	indicator.parameters:addInteger("smoothing2", "2. Smoothing","", 7);  
	
	indicator.parameters:addDouble("Factor1", "1. Factor","", 0.05);
	indicator.parameters:addInteger("RSI_period1", "1. RSI Period","", 8);	
	
	indicator.parameters:addDouble("Factor2", "2. Factor","", 0.1);
	indicator.parameters:addInteger("RSI_period2", "2. RSI Period","", 21);
	
	indicator.parameters:addDouble("Factor3", "3. Factor","", 0.16);
	indicator.parameters:addInteger("RSI_period3", "3. RSI Period","", 34);
	
	indicator.parameters:addDouble("Factor4", "4. Factor","", 0.26);
	indicator.parameters:addInteger("RSI_period4", "4. RSI Period","", 55);
	
	indicator.parameters:addDouble("Factor5", "5. Factor","", 0.43);
  	indicator.parameters:addInteger("RSI_period5", "5. RSI Period","", 89);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ZerolLagRSI_color", "Color of ZerolLagRSI", "Color of ZerolLagRSI", core.rgb(0, 0, 255));
	
	indicator.parameters:addColor("UpUp", "Up in Up Trend", "Up in Up Trend", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down in Up Trend", "Down in Up Trend", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Up in Up Trend", "Up in Up Trend", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend", "Down in Down Trend", core.rgb(200, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local smoothing1, smoothing2;
-- Streams block
local ZerolLagRSI = nil;
local Factor1, Factor2, Factor3,Factor4,Factor5;
local RSI_period1, RSI_period2, RSI_period3, RSI_period4, RSI_period5;
local Factor1, Factor2, Factor3, Factor4, Factor5;
local FastTrend,SlowTrend;
local RSI={};
local smoothConst1, smoothConst2;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	
	smoothing1=instance.parameters.smoothing1;
	smoothing2=instance.parameters.smoothing2;
	
	RSI_period1=instance.parameters.RSI_period1;
	RSI_period2=instance.parameters.RSI_period2;
	RSI_period3=instance.parameters.RSI_period3;
	RSI_period4=instance.parameters.RSI_period4;
	RSI_period5=instance.parameters.RSI_period5;
	
	Factor1=instance.parameters.Factor1;
	Factor2=instance.parameters.Factor2;
	Factor3=instance.parameters.Factor3;
	Factor4=instance.parameters.Factor4;
	Factor5=instance.parameters.Factor5;
	
	smoothConst1=(smoothing1-1.0)/smoothing1;
    smoothConst2=(smoothing2-1.0)/smoothing2;
	
    

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	RSI[1] = core.indicators:create("RSI", source, RSI_period1);
	RSI[2] = core.indicators:create("RSI", source, RSI_period2);
	RSI[3] = core.indicators:create("RSI", source, RSI_period3);
	RSI[4] = core.indicators:create("RSI", source, RSI_period4);
	RSI[5] = core.indicators:create("RSI", source, RSI_period5);
	
	FastTrend= instance:addInternalStream(0, 0);
	SlowTrend= instance:addInternalStream(0, 0);
	
    first = math.max( RSI[1].DATA:first(),  RSI[2].DATA:first(), RSI[3].DATA:first(), RSI[4].DATA:first(), RSI[5].DATA:first());

     
        ZerolLagRSI = instance:addStream("ZerolLagRSI", core.Bar, name, "ZerolLagRSI", instance.parameters.ZerolLagRSI_color, first);
        ZerolLagRSI:setPrecision(math.max(2, source:getPrecision())); 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    ZerolLagRSI:setColor(period, instance.parameters.ZerolLagRSI_color);
		
	RSI[1]:update(mode);
    RSI[2]:update(mode);
	RSI[3]:update(mode);
	RSI[4]:update(mode);
	RSI[5]:update(mode);
	
	if period < first or not  source:hasData(period) then
	return;
	end
	
	  local Osc1 = Factor1 * RSI[1].DATA[period];
      local Osc2 = Factor2 * RSI[2].DATA[period];
      local Osc3 = Factor2 * RSI[3].DATA[period];
      local Osc4 = Factor4 * RSI[4].DATA[period];
      local Osc5 = Factor5 * RSI[5].DATA[period];
      
      FastTrend[period] = Osc1 + Osc2 + Osc3 + Osc4 + Osc5;
      SlowTrend[period] = FastTrend[period]/ smoothing1 + SlowTrend[period-1] * smoothConst1;
      
      ZerolLagRSI[period]=(FastTrend[period]-SlowTrend[period])/smoothing2+ZerolLagRSI[period-1]*smoothConst2;
	   
		
	local diff=ZerolLagRSI[period]-ZerolLagRSI[period-1];
	
	if ZerolLagRSI[period] > 0 then
	    if diff > 0 then
		ZerolLagRSI:setColor(period, instance.parameters.UpUp);
		else
		ZerolLagRSI:setColor(period, instance.parameters.UpDown);
		end
	else	
	    if diff > 0 then
		ZerolLagRSI:setColor(period, instance.parameters.DownUp);
		else
		ZerolLagRSI:setColor(period, instance.parameters.DownDown);
		end 
	end
     
end

