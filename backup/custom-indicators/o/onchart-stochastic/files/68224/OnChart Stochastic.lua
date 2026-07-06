-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41814
-- Id: 9420

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

-- The indicator corresponds to the Stochastic indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 135-137)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("OnChart Stochastic");
    indicator:description("Shows the location of the current close relative to the high/low range over a set number of periods.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "", 3, 2, 1000);

    indicator.parameters:addString("averageTypeK", "The type of smoothing algorithm for %K", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeK","MVA", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeK", "EMA", "", "EMA");
     

    indicator.parameters:addString("averageTypeD","The type of smoothing algorithm for %D", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeD", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("averageTypeD", "EMA", "", "EMA");
	
	
	 indicator.parameters:addInteger("AP", "ATR Period", "", 14);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFirst", "K Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthFirst","K Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleFirst", "K Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFirst", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSecond", "D Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSecond", "D Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSecond", "D Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSecond", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 80, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 20, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width","OverboughtSold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "OverboughtSold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "OverboughtSold Line Color", "", core.FLAG_LEVEL_STYLE);
	
	
	 
end

 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
--////////
local AP;
local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;

local source = nil;
local obl, osl;
  
 
local Indicator;
-- Streams block
local K = nil;
local D = nil;
local ATR;
local OB, OS;
local MA;
local Central;
-- Routine
function Prepare(nameOnly)
    OB=instance.parameters.overbought;
	OS=instance.parameters.oversold;
	
	averageTypeK=instance.parameters.averageTypeK;
    averageTypeD=instance.parameters.averageTypeD;
	
    assert(instance.parameters.oversold < instance.parameters.overbought, "OverSold is bigger then OverBought");
    AP=instance.parameters.AP;
    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD .. ", " ..  AP .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	Indicator = core.indicators:create("STOCHASTIC", source, k , d , sd , averageTypeK, averageTypeD);
    ATR = core.indicators:create("ATR", source, AP);
    MA = core.indicators:create( averageTypeK, source.close, AP);
   
    K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst,  math.max(Indicator.K:first(), ATR.DATA:first()) ); 
    K:setWidth(instance.parameters.widthFirst);
    K:setStyle(instance.parameters.styleFirst);
    K:setPrecision(2);

  
    D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrSecond, math.max(Indicator.D:first(), ATR.DATA:first()) );
    D:setWidth(instance.parameters.widthSecond);
    D:setStyle(instance.parameters.styleSecond);
    D:setPrecision(2); 
	
	
	
	osl = instance:addStream("OS", core.Line, name .. ".OS", "OS", instance.parameters.level_overboughtsold_color, math.max(Indicator.D:first(), ATR.DATA:first()) );
    osl:setWidth(instance.parameters.level_overboughtsold_width);
    osl:setStyle(instance.parameters.level_overboughtsold_style);
    osl:setPrecision(2);

    obl = instance:addStream("OB", core.Line, name .. ".OB", "OB", instance.parameters.level_overboughtsold_color, math.max(Indicator.D:first(), ATR.DATA:first()) );
    obl:setWidth(instance.parameters.level_overboughtsold_width);
    obl:setStyle(instance.parameters.level_overboughtsold_style);
    obl:setPrecision(2);
	
	Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.level_overboughtsold_color, math.max(Indicator.D:first(), ATR.DATA:first()) );
    Central:setWidth(instance.parameters.level_overboughtsold_width);
    Central:setStyle(instance.parameters.level_overboughtsold_style);
    Central:setPrecision(2);
	 
end

 
 

-- Indicator calculation routine
function Update(period, mode) 

	Indicator:update(mode);
	ATR:update(mode);
	MA:update(mode);

  if period <  math.max(Indicator.D:first(), ATR.DATA:first()) then
  return;
  end
 
     
      Central[period]=MA.DATA[period];
      obl[period]=MA.DATA[period]+(ATR.DATA[period]*(OB-50)/100);
      osl[period]=MA.DATA[period]-(ATR.DATA[period]*(50-  OS)/100);
      K[period]=MA.DATA[period]+(Indicator.K[period] -50)/100*ATR.DATA[period];
      D[period]=MA.DATA[period]+(Indicator.D[period]-50)/100*ATR.DATA[period]; 
 
end
