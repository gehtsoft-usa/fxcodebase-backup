-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3763

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
    indicator:name("Color candle");
    indicator:description("Color candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrBeginUp", "Begin Up Color", "Begin Up Color", core.rgb(0, 100, 0));
    indicator.parameters:addColor("clrEndUp", "End Up Color", "End Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrBeginDn", "Begin Dn Color", "Begin Dn Color", core.rgb(100, 0, 0));
    indicator.parameters:addColor("clrEndDn", "End Dn Color", "End Dn Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local clrBeginUp;
local clrEndUp;
local clrBeginDn;
local clrEndDn;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local PriceSize;

function Prepare(nameOnly)
    source = instance.source;
    clrBeginUp=instance.parameters.clrBeginUp;
    clrEndUp=instance.parameters.clrEndUp;
    clrBeginDn=instance.parameters.clrBeginDn;
    clrEndDn=instance.parameters.clrEndDn;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    PriceSize = instance:addInternalStream(0, 0);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ColorCandle", "", open, high, low, close);
end

function Update(period, mode)

   if (period<first) then
   return;
   end
   
    PriceSize[period]=math.abs(source.close[period]-source.open[period]);
    open[period]=source.open[period];
    close[period]=source.close[period];
    high[period]=source.high[period];
    low[period]=source.low[period];
	
	
    if period<source:size()-1 then
	return;
	end
	
		 local MaxSize=mathex.max(PriceSize,first,period);
		 
		 
		 local i;
		 for i=first,period,1 do
		--  local CurSize=math.abs(source.close[i]-source.open[i]); -> PriceSize[period]
		  local CurColor;
		  if source.close[i]>source.open[i] then
		   CurColor=GetColor(clrBeginUp,clrEndUp,PriceSize[i],MaxSize);
		   open:setColor(i, CurColor);
		  else
		   CurColor=GetColor(clrBeginDn,clrEndDn,PriceSize[i],MaxSize);
		   open:setColor(i, CurColor);
		  end
     end
 
  
end

function GetColor(BeginColor,EndColor,Value,MaxValue)
 local R_B;
 local G_B;
 local B_B;
 local R_E;
 local G_E;
 local B_E;
 local R;
 local G;
 local B;
 local Temp;
 Temp,R_B=math.modf(BeginColor/256);
 R_B=R_B*256;
 B_B,G_B=math.modf(Temp/256);
 G_B=G_B*256;
 Temp,R_E=math.modf(EndColor/256);
 R_E=R_E*256;
 B_E,G_E=math.modf(Temp/256);
 G_E=G_E*256;
 R=(Value/MaxValue)*(R_E-R_B)+R_B;
 G=(Value/MaxValue)*(G_E-G_B)+G_B;
 B=(Value/MaxValue)*(B_E-B_B)+B_B;
 return core.rgb(R,G,B);
end

