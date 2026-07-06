-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66209

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
    indicator:name("SveVolatilityBand Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
 
	
	indicator.parameters:addInteger("MiddleLineLwma", "MiddleLineLwma", "", 20);
	indicator.parameters:addInteger("BandsPeriod", "BandsPeriod", "", 20);
    indicator.parameters:addDouble("BandsDeviation", "Deviation", "", 2.4);
     indicator.parameters:addDouble("LowbandAdjust", "LowbandAdjust", "", 0.9);
 
	
    indicator.parameters:addGroup("Style");

    indicator.parameters:addInteger("Top_S", "Top Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Top_S", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("Top_W", "Top Line Width", "", 1, 1, 5);
    indicator.parameters:addColor("Top_C", "Top Line Color", "", core.rgb(127, 0, 0));

    indicator.parameters:addInteger("Bottom_S", "Bottom Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Bottom_S", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("Bottom_W", "Bottom Line Width", "", 1, 1, 5);
    indicator.parameters:addColor("Bottom_C", "Bottom Line  Color", "", core.rgb(255, 128, 64));
	
	
	indicator.parameters:addInteger("Central_S", "Central Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Central_S", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("Central_W", "Central Line Width", "", 1, 1, 5);
    indicator.parameters:addColor("Central_C", "Central Line  Color", "", core.rgb(0, 0, 255))
 
end

local BandsDeviation,BandsPeriod,LowbandAdjust,MiddleLineLwma;
local first;
local source; 
local LWMA,TYPICAL;
local AtrBuf;
local TempBuf;
function Prepare(onlyName)
    local name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
    source = instance.source;
    BandsDeviation = instance.parameters.BandsDeviation;
	BandsPeriod= instance.parameters.BandsPeriod;
	LowbandAdjust= instance.parameters.LowbandAdjust;
	MiddleLineLwma= instance.parameters.MiddleLineLwma;
    first = source:first() ;
	
	
	LWMA = core.indicators:create("LWMA", source.close, BandsPeriod);
	TYPICAL= core.indicators:create("LWMA", source.typical, MiddleLineLwma);
	
	TempBuf = instance:addInternalStream(0, 0);
	AtrBuf = instance:addInternalStream(0, 0);

    Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_C,LWMA.DATA:first() );
    Top:setStyle(instance.parameters.Top_S);
    Top:setWidth(instance.parameters.Top_W);
    Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_C,  LWMA.DATA:first() );
    Bottom:setStyle(instance.parameters.Bottom_S);
    Bottom:setWidth(instance.parameters.Bottom_W);
 
    Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.Central_C,  TYPICAL.DATA:first() );
    Central:setStyle(instance.parameters.Central_S);
    Central:setWidth(instance.parameters.Central_W);
	
  end

  

function Update(period, mode)
  --Use a price range
  if period == source:first() then  
  TempBuf[period]=source.high[period]-source.low[period];
  else
  TempBuf[period]=math.max(source.high[period],source.close[period-1])-math.min(source.low[period],source.close[period-1]);
  end
  
   --calculate price deviation
   
   if period < first +BandsPeriod*2 then
   return;
   end
   
   AtrBuf[period]=mathex.avg(TempBuf, period -BandsPeriod*2+1,period) *BandsDeviation;
   
    -- Create upper, lower channel and middle line
   LWMA:update(mode);
   TYPICAL:update(mode);
   
    if period >= LWMA.DATA:first() then
    Top[period]=   LWMA.DATA[period] +  (LWMA.DATA[period]*AtrBuf[period]/source.close[period]);
    Bottom[period]=LWMA.DATA[period] -  (LWMA.DATA[period]*AtrBuf[period]* LowbandAdjust/source.close[period]);
	end
	if period >= TYPICAL.DATA:first() then
    Central[period]=TYPICAL.DATA[period];
    end
end




