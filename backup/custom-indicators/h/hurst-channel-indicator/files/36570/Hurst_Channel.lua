-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20881
-- Id: 6982

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Hurst Channel indicator");
    indicator:description("Hurst Channel indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Price1", "Price 1", "", "close");
    indicator.parameters:addStringAlternative("Price1", "close", "", "close");
    indicator.parameters:addStringAlternative("Price1", "open", "", "open");
    indicator.parameters:addStringAlternative("Price1", "high", "", "high");
    indicator.parameters:addStringAlternative("Price1", "low", "", "low");
    indicator.parameters:addStringAlternative("Price1", "median", "", "median");
    indicator.parameters:addStringAlternative("Price1", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "weighted", "", "weighted");
    indicator.parameters:addInteger("Period1", "Period 1", "", 10);
    indicator.parameters:addDouble("ChanWid1", "Multiplier for ATR", "", 1);
    
    indicator.parameters:addString("Price2", "Price 2", "", "close");
    indicator.parameters:addStringAlternative("Price2", "close", "", "close");
    indicator.parameters:addStringAlternative("Price2", "open", "", "open");
    indicator.parameters:addStringAlternative("Price2", "high", "", "high");
    indicator.parameters:addStringAlternative("Price2", "low", "", "low");
    indicator.parameters:addStringAlternative("Price2", "median", "", "median");
    indicator.parameters:addStringAlternative("Price2", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "weighted", "", "weighted");
    indicator.parameters:addInteger("Period2", "Period 2", "", 60);
    indicator.parameters:addDouble("ChanWid2", "Multiplier for ATR2", "", 3);

    indicator.parameters:addString("CompMode", "Compute mode for extension", "", "CMA shortening");
    indicator.parameters:addStringAlternative("CompMode", "CMA shortening", "", "CMA shortening");
    indicator.parameters:addStringAlternative("CompMode", "2nd degree polynomial", "", "2nd degree polynomial");

    indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("Show1", "Show Mid Line", "", false);
    indicator.parameters:addColor("UpperClr1", "Upper Color 1", "Upper Color 1", core.rgb(0, 255, 0));
	indicator.parameters:addColor("MidClr1", "Mid Color 1", "Mid Color 1", core.rgb(0, 0, 255));
    indicator.parameters:addColor("LowerClr1", "Lower Color 1", "Lower Color 1", core.rgb(255, 0, 0));
	  indicator.parameters:addInteger("width1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "Line style", core.LINE_SOLID);
	
	indicator.parameters:addBoolean("Show2", "Show Mid Line", "", false);
    indicator.parameters:addColor("UpperClr2", "Upper Color 2", "Upper Color 2", core.rgb(128, 255, 0));
	indicator.parameters:addColor("MidClr2", "Mid Color 2", "Mid Color 2", core.rgb(0, 0, 255));
    indicator.parameters:addColor("LowerClr2", "Lower Color 2", "Lower Color 2", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("width2", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end
local Show2,Show1;
local first;
local source = nil;
local Price1;
local Period1;
local Price2;
local Period2;
local ChanWid1;
local ChanWid2;
local CompMode;
local MA1;
local ATR1;
local MA2;
local ATR2;
local Upper1=nil;
local Lower1=nil;
local Upper2=nil;
local Lower2=nil;
local SetBack1;
local SetBack2;
local PriceStream1;
local PriceStream2;
local Ave1;
local Ave2;
local Mid1,Mid2;
function Prepare(nameOnly)
    Show2=instance.parameters.Show2;
	Show1=instance.parameters.Show1;
    source = instance.source;
    Price1=instance.parameters.Price1;
    Period1=instance.parameters.Period1;
    Price2=instance.parameters.Price2;
    Period2=instance.parameters.Period2;
    ChanWid1=instance.parameters.ChanWid1;
    ChanWid2=instance.parameters.ChanWid2;
    CompMode=instance.parameters.CompMode;
   
    if Price1=="close" then
     PriceStream1=source.close;
    elseif Price1=="open" then
     PriceStream1=source.open;
    elseif Price1=="high" then
     PriceStream1=source.high;
    elseif Price1=="low" then
     PriceStream1=source.low;
    elseif Price1=="median" then
     PriceStream1=source.median;
    elseif Price1=="typical" then
     PriceStream1=source.typical;
    else
     PriceStream1=source.weighted;
    end 
    if Price2=="close" then
     PriceStream2=source.close;
    elseif Price2=="open" then
     PriceStream2=source.open;
    elseif Price2=="high" then
     PriceStream2=source.high;
    elseif Price2=="low" then
     PriceStream2=source.low;
    elseif Price2=="median" then
     PriceStream2=source.median;
    elseif Price2=="typical" then
     PriceStream2=source.typical;
    else
     PriceStream2=source.weighted;
    end 
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Price1 .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.ChanWid1 .. ", " .. instance.parameters.Price2 .. ", " .. instance.parameters.Period2 .. ", " .. instance.parameters.ChanWid2 .. ", " .. instance.parameters.CompMode .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	first = source:first();
    MA1 = core.indicators:create("MVA", PriceStream1, Period1);
    ATR1 = core.indicators:create("ATR", source, Period1);
    Ave1 = instance:addInternalStream(0, 0);
    MA2 = core.indicators:create("MVA", PriceStream2, Period2);
    ATR2 = core.indicators:create("ATR", source, Period2);
    Ave2 = instance:addInternalStream(0, 0);

    Upper1 = instance:addStream("Upper1", core.Line, name .. ".Upper1", "Upper1", instance.parameters.UpperClr1, first+Period1);
	if Show1 then
	Mid1 = instance:addStream("Mid1", core.Line, name .. ".Mid1", "Mid1", instance.parameters.MidClr1, first+Period1);
	else
	Mid1 = instance:addInternalStream(0, 0);
	end
    Lower1 = instance:addStream("Lower1", core.Line, name .. ".Lower1", "Lower1", instance.parameters.LowerClr1, first+Period1);
    Upper2 = instance:addStream("Upper2", core.Line, name .. ".Upper2", "Upper2", instance.parameters.UpperClr2, first+Period1);
	if Show2 then
	Mid2 = instance:addStream("Mid2", core.Line, name .. ".Mid2", "Mid2", instance.parameters.MidClr2, first+Period2);
	else
	Mid2 = instance:addInternalStream(0, 0);
	end
    Lower2 = instance:addStream("Lower2", core.Line, name .. ".Lower2", "Lower2", instance.parameters.LowerClr2, first+Period2);
    Upper1:setWidth(instance.parameters.width1);
    Upper1:setStyle(instance.parameters.style1);
    Upper2:setWidth(instance.parameters.width2);
    Upper2:setStyle(instance.parameters.style2);
    Lower1:setWidth(instance.parameters.width1);
    Lower1:setStyle(instance.parameters.style1);
    Lower2:setWidth(instance.parameters.width2);
    Lower2:setStyle(instance.parameters.style2);
    SetBack1=math.floor((Period1-1)/2)+1;
    SetBack2=math.floor((Period2-1)/2)+1;
end

function Update(period, mode)
   if period>first+Period1 then
    ATR1:update(mode);
    MA1:update(mode);
    if period<source:size()-1 then
     Ave1[period]=MA1.DATA[period];
     Upper1[period]=Ave1[period]+ChanWid1*ATR1.DATA[period];
     Lower1[period]=Ave1[period]-ChanWid1*ATR1.DATA[period];
	 Mid1[period]=(Upper1[period]- Lower1[period])/2 + Lower1[period];
    else
     local Value5=(MA1.DATA[period]-MA1.DATA[period-SetBack1])/SetBack1;
     local Value1;
     local Value3;
     local Value4;
     local Value2;
     for Value1=SetBack1-1,0,-1 do
      Value3=0;
      Value4=Value1*2;
      for Value2=0,Value4,1 do
       Value3=Value3+PriceStream1[period-Value2];
      end
     Ave1[period]=Value3/(Value4+1);
     if CompMode=="2nd degree polynomial" then
      Ave1[period-Value1]=Ave1[period-Value1]/3+(Ave1[period-Value1-1]+Value5*(SetBack1-Value1))*2/3;
     end
     Upper1[period-Value1]=Ave1[period-Value1]+ChanWid1*ATR1.DATA[period-Value1];	 
     Lower1[period-Value1]=Ave1[period-Value1]-ChanWid1*ATR1.DATA[period-Value1];
	 Mid1[period-Value1]=(Upper1[period-Value1]- Lower1[period-Value1])/2 + Lower1[period-Value1];
     end
    end 
   end 

   
   
   
   if period>first+Period2 then
    ATR2:update(mode);
    MA2:update(mode);
    if period<source:size()-1 then
     Ave2[period]=MA2.DATA[period];
     Upper2[period]=Ave2[period]+ChanWid2*ATR2.DATA[period];
     Lower2[period]=Ave2[period]-ChanWid2*ATR2.DATA[period];
	 Mid2[period]=(Upper2[period]- Lower2[period])/2 + Lower2[period];
    else
     local Value5=(MA2.DATA[period]-MA2.DATA[period-SetBack2])/SetBack2;
     local Value1;
     local Value3;
     local Value4;
     local Value2;
     for Value1=SetBack2-1,0,-1 do
      Value3=0;
      Value4=Value1*2;
      for Value2=0,Value4,1 do
       Value3=Value3+PriceStream2[period-Value2];
      end
     Ave2[period]=Value3/(Value4+1);
     if CompMode=="2nd degree polynomial" then
      Ave2[period-Value1]=Ave2[period-Value1]/3+(Ave2[period-Value1-1]+Value5*(SetBack1-Value1))*2/3;
     end
     Upper2[period-Value1]=Ave2[period-Value1]+ChanWid2*ATR2.DATA[period-Value1];
     Lower2[period-Value1]=Ave2[period-Value1]-ChanWid2*ATR2.DATA[period-Value1];
	  Mid2[period-Value1]=(Upper2[period-Value1]- Lower2[period-Value1])/2 + Lower2[period-Value1];
     end
    end 
   end 
end

