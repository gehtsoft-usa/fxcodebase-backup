-- Id: 8219
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27932

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Zero Lag Stochastic");
    indicator:description("Zero Lag Stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
	
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("smoothing", "Smoothing", "Smoothing", 15);
    Add (1, 18,  3, 3)
	Add (2, 21,  5, 3)
	Add (3, 34,  8, 3)
	Add (4, 55, 13, 3)
	Add (5, 89, 21, 3)
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("K_color", "Color of K", "Color of K", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("D_color", "Color of D", "Color of D", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

function Add(id, k, sd, d)

    local Weight={0.05,0.10,0.16 ,0.26,0.43};
	 
	indicator.parameters:addGroup(id ..". Stochastic Calculation");		
    indicator.parameters:addInteger("K"..id, "Number of periods for %K", "The number of periods for %K.", k, 2, 1000);
    indicator.parameters:addInteger("SD"..id, "%D slowing periods", "The number of periods for slow %D.", sd, 2, 1000);
    indicator.parameters:addInteger("D"..id, "Number of periods for %D", "The number of periods for %D.", d, 2, 1000);

    indicator.parameters:addString("MVAT_K"..id, "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "MetaTrader", "The MetaTrader algorithm.", "FS");
 
    
    indicator.parameters:addString("MVAT_D"..id, "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D"..id, "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D"..id, "EMA", "EMA", "EMA");
 
	
	indicator.parameters:addDouble("Weight"..id, "Weight", "Weight", Weight[id]);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local P1;
local smoothConst,smoothing;
local first;
local source = nil;

-- Streams block
local K = nil;
local D = nil;
local k={};
local d={};
local sd={};
local DType={};
local KType={};
local Indicator={};
local Weight={};
-- Routine
function Prepare(nameOnly)
  
    source = instance.source;
    first = source:first();
	smoothing= instance.parameters.smoothing;
	smoothConst = (smoothing - 1.0) / smoothing;
	
	local i;
	local name = profile:id() .. "(" .. source:name() ;
	for i = 1, 5 , 1 do
        k[i] = instance.parameters:getInteger("K" .. i);
        d[i]  = instance.parameters:getInteger("D" .. i);
        sd[i] =  instance.parameters:getInteger("SD" .. i);
        DType[i] =instance.parameters:getString("MVAT_K" .. i);
        KType[i] = instance.parameters:getString("MVAT_D" .. i);
        Weight[i] = instance.parameters:getDouble("Weight" .. i)
        name= name .. " ("..   k[i].. " ,"..   sd[i] .. " ,"..   d[i].. " ,"..   KType[i].. " ,"..   DType[i] .. " ,"..   Weight[i] .. ")"
        
        if not nameOnly then
            Indicator[i] = core.indicators:create("STOCHASTIC", source,k[i],   sd[i],  d[i] );
            first =  math.max(first, Indicator[i].DATA:first());
        end
	end
	
	name=name..")";
	
    instance:name(name);

    if (not (nameOnly)) then
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.K_color, first);
    K:setPrecision(math.max(2, instance.source:getPrecision()));
		K:setWidth(instance.parameters.width1);
        K:setStyle(instance.parameters.style1);
		
		K:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		K:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
	
        D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.D_color, first);
    D:setPrecision(math.max(2, instance.source:getPrecision()));
		D:setWidth(instance.parameters.width2);
        D:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    local i;
	
	for i = 1, 5, 1 do
	Indicator[i]:update(mode);
	end

    if period < first  then
	return;
	end
	
	local  Stoch1 = Weight[1] * Indicator[1].DATA[period];
    local  Stoch2 = Weight[2] * Indicator[2].DATA[period];
    local  Stoch3 = Weight[3] * Indicator[3].DATA[period];
    local  Stoch4 = Weight[4] * Indicator[4].DATA[period];
    local  Stoch5 = Weight[5] * Indicator[5].DATA[period];
	
	
	
        K[period] =  Stoch1 + Stoch2 + Stoch3 + Stoch4 + Stoch5;
        D[period] = K[period] / smoothing + D[period- 1] * smoothConst;
    
end

