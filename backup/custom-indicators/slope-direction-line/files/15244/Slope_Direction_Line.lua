-- Id: 4665

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=949

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
function Init()
    indicator:name("Slope direction line");
    indicator:description("Slope direction line");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("Period", "Period", "Period", 80);
    indicator.parameters:addString("Method", "Method", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "", "TMA");

    indicator.parameters:addColor("clrUp", "Color of Slope Direction Line (UP)", "Color of Slope Direction Line (Up)", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDn", "Color of Slope Direction Line (Dn)", "Color of Slope Direction Line (Dn)", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local MA;
local MA2;
local Period;
local Method;
local vect;
local MA_A;
local trend;
local SDL;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    vect = instance:addInternalStream(0, 0);
    trend = instance:addInternalStream(0, 0);
    SDL = instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA = core.indicators:create(Method, source, Period);
    MA2 = core.indicators:create(Method, source, math.floor(Period/2));	
	first1 = math.max(MA.DATA:first(),MA2.DATA:first() );
	
    MA_A = core.indicators:create(Method, vect, math.floor(math.sqrt(Period)));
    first2=MA_A.DATA:first();
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Method .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    UpTrend = instance:addStream("UpTrend", core.Line, name .. ".UpTrend", "UpTrend", instance.parameters.clrUp, first2);
    DnTrend = instance:addStream("DnTrend", core.Line, name .. ".DnTrend", "DnTrend", instance.parameters.clrDn, first2);
    UpTrend:setWidth(instance.parameters.widthLinReg);
    UpTrend:setStyle(instance.parameters.styleLinReg);
    DnTrend:setWidth(instance.parameters.widthLinReg);
    DnTrend:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
    MA:update(mode);
    MA2:update(mode);
	
	 if period < first1 then
	return;
	end
    
    vect[period]=2.*MA2.DATA[period]-MA.DATA[period];
    MA_A:update(mode);
	
	if period < first2 then
	return;
	end
	
    SDL[period]=MA_A.DATA[period];
    
     trend[period]=trend[period-1];
     if SDL[period]>SDL[period-1] then
      trend[period]=1;
     end
     if SDL[period]<SDL[period-1] then
      trend[period]=-1;
     end
     if trend[period]>0 then
      UpTrend[period]=SDL[period];
      if trend[period-1]<0 then
       UpTrend[period-1]=SDL[period-1];
      end
      DnTrend[period]=nil;
     end
     if trend[period]<0 then
      DnTrend[period]=SDL[period];
      if trend[period-1]>0 then
       DnTrend[period-1]=SDL[period-1];
      end
      UpTrend[period]=nil;
     end
    
    
end

