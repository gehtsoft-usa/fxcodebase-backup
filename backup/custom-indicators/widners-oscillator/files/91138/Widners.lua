-- Id: 10528

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=59984

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
    indicator:name("Widners oscillator");
    indicator:description("Widners oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Sclr", "Support color", "Support color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Swidth", "Support line width", "Support line width", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Support line style", "Support line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Rclr", "Resistance color", "Resistance color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Rwidth", "Resistance line width", "Resistance line width", 1, 1, 5);
    indicator.parameters:addInteger("Rstyle", "Resistance line style", "Resistance line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Rstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local P;
local H, L;
local Support=nil;
local Resistance=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    P=math.floor((Period-1)/2);
    first = source:first()+2;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	H = instance:addInternalStream(first, 0);
    L = instance:addInternalStream(first, 0);
	
	
    Support = instance:addStream("Support", core.Line, name .. ".Support", "Support", instance.parameters.Sclr, first);
    Support:setPrecision(math.max(2, instance.source:getPrecision()));
    Support:setWidth(instance.parameters.Swidth);
    Support:setStyle(instance.parameters.Sstyle);
    Resistance = instance:addStream("Resistance", core.Line, name .. ".Resistance", "Resistance", instance.parameters.Rclr, first);
    Resistance:setPrecision(math.max(2, instance.source:getPrecision()));
    Resistance:setWidth(instance.parameters.Rwidth);
    Resistance:setStyle(instance.parameters.Rstyle);
end

function FindLastValues(St, index)
 local v1, v2, v3, v4, v5, v6 = 0, 0, 0, 0, 0, 0;
 local i=index;
 while i>first and v6==0 do
  if St[i]~=v1 then
   v6=v5;
   v5=v4;
   v4=v3;
   v3=v2;
   v2=v1;
   v1=St[i];
  end
  i=i-1;
 end
 return v1, v2, v3, v4, v5, v6;
end

function Update(period, mode)
   if period>first+Period then
    if source.low[period-P]==mathex.min(source.low, period-Period+1, period) then
     L[period]=source.low[period-P];
    else
     L[period]=L[period-1];
    end
    if source.high[period-P]==mathex.max(source.high, period-Period+1, period) then
     H[period]=source.high[period-P];
    else
     H[period]=H[period-1];
    end
    local C=source.close[period];
    local rs1, rs2, rs3, rs4, rs5, rs6 = FindLastValues(L, period);
    Support[period]=100*(1-(math.floor(rs1/C)+math.floor(rs2/C)+math.floor(rs3/C)+math.floor(rs4/C)+math.floor(rs5/C)+math.floor(rs6/C))/6);
    if Support[period]==0 then
     Support[period]=Support[period]+1;
    elseif Support[period]==100 then
     Support[period]=Support[period]-1;
    end
    
    rs1, rs2, rs3, rs4, rs5, rs6 = FindLastValues(H, period);
    Resistance[period]=100*(1-(math.floor(rs1/C)+math.floor(rs2/C)+math.floor(rs3/C)+math.floor(rs4/C)+math.floor(rs5/C)+math.floor(rs6/C))/6);
    if Resistance[period]==0 then
     Resistance[period]=Resistance[period]+1;
    elseif Resistance[period]==100 then
     Resistance[period]=Resistance[period]-1;
    end
    
   end 
end

