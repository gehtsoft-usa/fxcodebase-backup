-- Id: 5029
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8169

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
    indicator:name("Stochastic RSI MT2");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods for RSI", "", 8, 1, 200);
    indicator.parameters:addInteger("K", "%K Stochastic Periods", "", 8, 1, 200);
	indicator.parameters:addInteger("D", "%K Slowing Periods", "", 8, 1, 200);
    --indicator.parameters:addInteger("KS", "%K Slowing Periods", "", 5, 1, 200);
	indicator.parameters:addGroup("Style");
    
    indicator.parameters:addColor("K_color", "Color of K", "Color of K", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("widthK", "K Line width", "K Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleK", "K Line style", "K Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleK", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("D_color", "Color of D", "Color of D", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("widthD", "D Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleD", "D Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleD", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 1);
	indicator.parameters:addDouble("central","Central Level","", 0);
    indicator.parameters:addDouble("oversold","Oversold Level","", -1);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("OB_style", "OB Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("OB_style", core.FLAG_LEVEL_STYLE);
	indicator.parameters:addInteger("OS_style", "OS Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("OS_style", core.FLAG_LEVEL_STYLE);
	indicator.parameters:addInteger("Central_style", "Central Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("Central_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine

-- Parameters block
local N;
local K;
local D;

local first;
local firstMVA;
local source = nil;

-- Streams block
local SK = nil;
local SD = nil;
local RSI = nil;
local MVA;
local Buffer;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    K = instance.parameters.K;
   -- KS = instance.parameters.KS;
    D = instance.parameters.D;
    source = instance.source;
  
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. K  ..", " .. D .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    RSI = core.indicators:create("RSI", source, N);
	 first  = RSI.DATA:first()+K; 
	 
    Buffer = instance:addInternalStream(0, 0);
	
	MVA = core.indicators:create("LWMA", Buffer, D);
	firstMVA  = MVA.DATA:first();
    SK = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.K_color, firstMVA); 
    SK:setPrecision(math.max(2, instance.source:getPrecision()));
    SK:addLevel(instance.parameters.oversold, instance.parameters.OS_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	SK:addLevel(instance.parameters.overbought, instance.parameters.OB_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	SK:addLevel(instance.parameters.central, instance.parameters.Central_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	
	SK:setWidth(instance.parameters.widthK);
    SK:setStyle(instance.parameters.styleK);
    
    
    SD = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.D_color, firstMVA);
    SD:setPrecision(math.max(2, instance.source:getPrecision()));
	SD:setWidth(instance.parameters.widthD);
    SD:setStyle(instance.parameters.styleD);
end

function Update(period, mode)


    if period <  first then
	return;
	end
	
	    RSI:update(mode);
	
        local min, max;
        local range;
         min, max =  mathex.minmax (RSI.DATA, period-K +1 , period)
     		
			
		local  Value1 = (RSI.DATA[period] - min);
        local  Value2 =  (max - min)
      
	    if Value2 ~= 0 then
        Buffer[period] = Value1 / Value2;
		else
		Buffer[period]=0;
		end		
		
	if period <  firstMVA then
	return;
	end	
		
		 MVA:update(mode);
       
        SK[period] = 2 * (MVA.DATA[period] -0.5);
   
        SD[period] = SK[period-1];
 
end

