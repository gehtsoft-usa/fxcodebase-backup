-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3612

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("RSI on chart indicator");
    indicator:description("RSI on chart indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI_Period", "RSI_Period", "", 14);
    indicator.parameters:addString("RSI_Price", "RSI_Price", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price", "close", "", "close");
    indicator.parameters:addStringAlternative("RSI_Price", "open", "", "open");
    indicator.parameters:addStringAlternative("RSI_Price", "high", "", "high");
    indicator.parameters:addStringAlternative("RSI_Price", "low", "", "low");
    indicator.parameters:addStringAlternative("RSI_Price", "median", "", "median");
    indicator.parameters:addStringAlternative("RSI_Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("RSI_Price", "weighted", "", "weighted");
    indicator.parameters:addInteger("MA_Period", "MA_Period", "", 20);
    indicator.parameters:addString("MA_Method", "MA_Method", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addString("MA_Price", "MA_Price", "", "close");
    indicator.parameters:addStringAlternative("MA_Price", "close", "", "close");
    indicator.parameters:addStringAlternative("MA_Price", "open", "", "open");
    indicator.parameters:addStringAlternative("MA_Price", "high", "", "high");
    indicator.parameters:addStringAlternative("MA_Price", "low", "", "low");
    indicator.parameters:addStringAlternative("MA_Price", "median", "", "median");
    indicator.parameters:addStringAlternative("MA_Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("MA_Price", "weighted", "", "weighted");
    indicator.parameters:addInteger("OverBought", "OverBought", "", 70);
    indicator.parameters:addInteger("OverSold", "OverSold", "", 30);
    indicator.parameters:addDouble("ATR_Coeff", "ATR_Coeff", "", 5);
    indicator.parameters:addBoolean("EnableHorizontalLines", "Enable horizontal lines", "", true);
    
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrBand", "Color band", "Color band", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrRSI", "Color RSI", "Color RSI", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "width", "width", 1, 1, 5);
    indicator.parameters:addInteger("style", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("clrLines", "Color Lines", "Color Lines", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLines", "width lines", "width lines", 1, 1, 5);
    indicator.parameters:addInteger("styleLines", "style lines", "style lines", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLines", core.FLAG_LEVEL_STYLE);
end

local first;
local source = nil;
local RSI_Period;
local RSI_Price;
local MA_Period;
local MA_Method;
local MA_Price;
local OverBought;
local OverSold;
local ATR_Coeff;
local BuffTop=nil;
local BuffMiddle=nil;
local BuffBottom=nil;
local BuffTopLine=nil;
local BuffBottomLine=nil;
local BuffRSI=nil;
local ATR;
local MA;
local RSI;


 function Prepare(nameOnly)  
 
 
    source = instance.source;
    RSI_Period=instance.parameters.RSI_Period;
    RSI_Price=instance.parameters.RSI_Price;
    MA_Period=instance.parameters.MA_Period;
    MA_Method=instance.parameters.MA_Method;
    MA_Price=instance.parameters.MA_Price;
    OverBought=instance.parameters.OverBought;
    OverSold=instance.parameters.OverSold;
    ATR_Coeff=instance.parameters.ATR_Coeff;
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSI_Period .. ", " .. instance.parameters.RSI_Price .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.MA_Method .. ", " .. instance.parameters.MA_Price .. ", " .. instance.parameters.OverBought .. ", " .. instance.parameters.OverSold .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
	
    ATR = core.indicators:create("ATR", source, MA_Period);
    if MA_Price=="close" then
     MA = core.indicators:create("AVERAGES", source.close, MA_Method, MA_Period, false);
    elseif MA_Price=="open" then
     MA = core.indicators:create("AVERAGES", source.open, MA_Method, MA_Period, false);
    elseif MA_Price=="high" then
     MA = core.indicators:create("AVERAGES", source.high, MA_Method, MA_Period, false);
    elseif MA_Price=="low" then
     MA = core.indicators:create("AVERAGES", source.low, MA_Method, MA_Period, false);
    elseif MA_Price=="median" then
     MA = core.indicators:create("AVERAGES", source.median, MA_Method, MA_Period, false);
    elseif MA_Price=="typical" then
     MA = core.indicators:create("AVERAGES", source.typical, MA_Method, MA_Period, false);
    else
     MA = core.indicators:create("AVERAGES", source.weighted, MA_Method, MA_Period, false);
    end 
    if RSI_Price=="close" then
     RSI = core.indicators:create("RSI", source.close, RSI_Period);
    elseif RSI_Price=="open" then
     RSI = core.indicators:create("RSI", source.open, RSI_Period);
    elseif RSI_Price=="high" then
     RSI = core.indicators:create("RSI", source.high, RSI_Period);
    elseif RSI_Price=="low" then
     RSI = core.indicators:create("RSI", source.low, RSI_Period);
    elseif RSI_Price=="median" then
     RSI = core.indicators:create("RSI", source.median, RSI_Period);
    elseif RSI_Price=="typical" then
     RSI = core.indicators:create("RSI", source.typical, RSI_Period);
    else
     RSI = core.indicators:create("RSI", source.weighted, RSI_Period);
    end 
    
    first = math.max(ATR.DATA:first(),MA.DATA:first(),RSI.DATA:first())+2;
  
    BuffTop = instance:addStream("BuffTop", core.Line, name .. ".Top", "Top", instance.parameters.clrBand, first);
    BuffMiddle = instance:addStream("BuffMiddle", core.Line, name .. ".Middle", "Middle", instance.parameters.clrBand, first);
    BuffBottom = instance:addStream("BuffBottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.clrBand, first);
    BuffRSI = instance:addStream("BuffRSI", core.Line, name .. ".RSI", "RSI", instance.parameters.clrRSI, first);
    BuffTop:setWidth(instance.parameters.width);
    BuffTop:setStyle(instance.parameters.style);
    BuffMiddle:setWidth(instance.parameters.width);
    BuffMiddle:setStyle(instance.parameters.style);
    BuffBottom:setWidth(instance.parameters.width);
    BuffBottom:setStyle(instance.parameters.style);
    BuffRSI:setWidth(instance.parameters.width);
    BuffRSI:setStyle(instance.parameters.style);
    if instance.parameters.EnableHorizontalLines then
     BuffTopLine = instance:addStream("BuffTopLine", core.Line, name .. ".TopLine", "TopLine", instance.parameters.clrLines, first,10);
     BuffBottomLine = instance:addStream("BuffBottomLine", core.Line, name .. ".BottomLine", "BottomLine", instance.parameters.clrLines, first,10);
     BuffTopLine:setWidth(instance.parameters.widthLines);
     BuffTopLine:setStyle(instance.parameters.styleLines);
     BuffBottomLine:setWidth(instance.parameters.widthLines);
     BuffBottomLine:setStyle(instance.parameters.styleLines);
    end
end

function Update(period, mode)
   if (period>first) then
    ATR:update(mode);
    MA:update(mode);
    RSI:update(mode);
    BuffMiddle[period]=MA.DATA[period];
    BuffTop[period]=MA.DATA[period]+(ATR.DATA[period]*ATR_Coeff*(OverBought-50)/100);
    BuffBottom[period]=MA.DATA[period]-(ATR.DATA[period]*ATR_Coeff*(50-OverSold)/100);
    BuffRSI[period]=MA.DATA[period]+ATR.DATA[period]*ATR_Coeff*(RSI.DATA[period]-50)/100;
    if (period==source:size()-1 and instance.parameters.EnableHorizontalLines) then
     core.drawLine(BuffTopLine,core.range(first,period+10),BuffTop[period],first,BuffTop[period],period+10);
     core.drawLine(BuffBottomLine,core.range(first,period+10),BuffBottom[period],first,BuffBottom[period],period+10);
    end
   end 
end

