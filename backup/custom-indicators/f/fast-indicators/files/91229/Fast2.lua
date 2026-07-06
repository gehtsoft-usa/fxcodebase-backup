-- Id: 10584

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60020

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Fast2 oscillator");
    indicator:description("Fast2 oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period 1", "", 3);
    indicator.parameters:addInteger("Period2", "Period 2", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Hclr", "Histogram color", "Histogram color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("MA1clr", "MA1 color", "MA1 color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("MA1width", "MA1 width", "MA1 width", 1, 1, 5);
    indicator.parameters:addInteger("MA1style", "MA1 style", "MA1 style", core.LINE_SOLID);
    indicator.parameters:setFlag("MA1style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("MA2clr", "MA2 color", "MA2 color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("MA2width", "MA2 width", "MA2 width", 1, 1, 5);
    indicator.parameters:addInteger("MA2style", "MA2 style", "MA2 style", core.LINE_SOLID);
    indicator.parameters:setFlag("MA2style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "", 10);
end

local first;
local source = nil;
local Period1;
local Period2;
local MA1, MA2;
local Histogram=nil;
local MA1_Buff=nil;
local MA2_Buff=nil;
local UP=nil;
local DN=nil;
local Sqrt2, Sqrt3;
local pipSize;

function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1;
    Period2=instance.parameters.Period2;
     
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Period2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Hclr, source:first() + 2);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
	  
	MA1 = core.indicators:create("LWMA", Histogram, Period1);
    MA2 = core.indicators:create("LWMA", Histogram, Period2);
	
	first = math.max(MA1.DATA:first() ,MA2.DATA:first())+2;
	
	
  
   
	
    MA1_Buff = instance:addStream("MA1", core.Line, name .. ".MA1", "MA1", instance.parameters.MA1clr, first);
    MA1_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    MA1_Buff:setWidth(instance.parameters.MA1width);
    MA1_Buff:setStyle(instance.parameters.MA1style);
    MA2_Buff = instance:addStream("MA2", core.Line, name .. ".MA2", "MA2", instance.parameters.MA2clr, first);
    MA2_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    MA2_Buff:setWidth(instance.parameters.MA2width);
    MA2_Buff:setStyle(instance.parameters.MA2style);
    Sqrt2=math.sqrt(2);
    Sqrt3=math.sqrt(3);
    pipSize=source:pipSize();
    UP = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.UPclr, 0);
    DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.DNclr, 0);
end

function Update(period, mode)
     if period < source:first() + 2 then
	 return;
	 end
	 
    Histogram[period]=(source.close[period]-source.open[period]+(source.close[period-1]-source.open[period-1])/Sqrt2+(source.close[period-2]-source.open[period-2])/Sqrt3)/pipSize;
    MA1:update(mode);
    MA2:update(mode);
	
	 if period<first then
	 return;
	 end
	
    MA1_Buff[period]=MA1.DATA[period];
    MA2_Buff[period]=MA2.DATA[period];
	
    if MA1.DATA[period-2]>MA2.DATA[period-2] and MA1.DATA[period-1]<MA2.DATA[period-1] and MA1.DATA[period]<MA2.DATA[period] and MA1.DATA[period-2]>0 and MA2.DATA[period-2]>0 and Histogram[period-1]<=0 and Histogram[period]<0 then
     DN:set(period, Histogram[period], "\238");
    else
     DN:setNoData(period);
    end
    if MA1.DATA[period-2]<MA2.DATA[period-2] and MA1.DATA[period-1]>MA2.DATA[period-1] and MA1.DATA[period]>MA2.DATA[period] and MA1.DATA[period-2]<0 and MA2.DATA[period-2]<0 and Histogram[period-1]>=0 and Histogram[period]>0 then
     UP:set(period, Histogram[period], "\236");
    else
     UP:setNoData(period);
    end
   
   
end

