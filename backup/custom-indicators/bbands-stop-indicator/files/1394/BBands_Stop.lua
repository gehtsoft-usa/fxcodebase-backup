-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=757
-- Id: 856

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("BBands_Stop Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Length", "Bollinger Bands Period", 20);
    indicator.parameters:addDouble("Deviation", "Deviation", "Deviation", 2);
    indicator.parameters:addDouble("MoneyRisk", "MoneyRisk", "Offset Factor", 1);
    indicator.parameters:addInteger("Signal", "Signal", "Display signals mode: 1-Signals & Stops; 0-only Stops; 2-only Signals;", 1);
    indicator.parameters:addInteger("Line", "Line", "Display line mode: 0-no,1-yes", 1);

	  indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
	   indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Wine Style", "", core.LINE_SOLID);
	 indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	

end

local first;
local source = nil;
local Signal;
local Line;

local Bands=nil;

local UpTrendBuffer=0;
local DownTrendBuffer=0;
local UpTrendSignal=0;
local DownTrendSignal=0;
local UpTrendLine=nil;
local DownTrendLine=nil;
local smin=0;
local smax=0;
local bsmin=0;
local bsmax=0;

function Prepare(nameOnly)
    source = instance.source;
    MoneyRisk=instance.parameters.MoneyRisk;
    Signal=instance.parameters.Signal;
    Line=instance.parameters.Line;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Length .. ", " .. instance.parameters.Deviation .. ", " .. instance.parameters.MoneyRisk .. ", " .. instance.parameters.Signal .. ", " .. instance.parameters.Line .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Bands = core.indicators:create("BB", source.close, instance.parameters.Length,instance.parameters.Deviation);
    first = Bands.DATA:first()+1;
    UpTrendBuffer = instance:addStream("UP_B", core.Dot, name .. ".UP_B", "UP_B", instance.parameters.UP_color, first);	
	UpTrendBuffer:setWidth(instance.parameters.width);
    DownTrendBuffer = instance:addStream("DN_B", core.Dot, name .. ".DN_B", "DN_B", instance.parameters.DN_color, first);
	DownTrendBuffer:setWidth(instance.parameters.width);
    UpTrendSignal = instance:addStream("UP_S", core.Dot, name .. ".UP_S", "UP_S", instance.parameters.UP_color, first);
	UpTrendSignal:setWidth(instance.parameters.width);
    DownTrendSignal = instance:addStream("DN_S", core.Dot, name .. ".DN_S", "DN_S", instance.parameters.DN_color, first);
	DownTrendSignal:setWidth(instance.parameters.width);
    UpTrendLine = instance:addStream("UP_L", core.Line, name .. ".UP_L", "UP_L", instance.parameters.UP_color, first);
	UpTrendLine:setWidth(instance.parameters.width);
    UpTrendLine:setStyle(instance.parameters.style);
    DownTrendLine = instance:addStream("DN_L", core.Line, name .. ".DN_L", "DN_L", instance.parameters.DN_color, first);
	DownTrendLine:setWidth(instance.parameters.width);
    DownTrendLine:setStyle(instance.parameters.style);
    smax=instance:addInternalStream(0, 0);
    smin=instance:addInternalStream(0, 0);
    bsmax=instance:addInternalStream(0, 0);
    bsmin=instance:addInternalStream(0, 0);
end

function Update(period, mode)
    Bands:update(mode);
    if (period>first) then
     smax[period]=Bands.TL[period];
     smin[period]=Bands.BL[period];
     
     if source.close[period]>smax[period-1] then
      trend=1;
     end
     if source.close[period]<smin[period-1] then
      trend=-1;
     end
     
     if trend>0 and smin[period]<smin[period-1] then
      smin[period]=smin[period-1];
     end
     if trend<0 and smax[period]>smax[period-1] then
      smax[period]=smax[period-1];
     end
     
     bsmax[period]=smax[period]+0.5*(MoneyRisk-1)*(smax[period]-smin[period]);
     bsmin[period]=smin[period]-0.5*(MoneyRisk-1)*(smax[period]-smin[period]);
     
     if trend>0 and bsmin[period]<bsmin[period-1] then
      bsmin[period]=bsmin[period-1];
     end
     if trend<0 and bsmax[period]>bsmax[period-1] then
      bsmax[period]=bsmax[period-1];
     end
     
     if trend>0 then
      if Signal>0 and UpTrendBuffer[period-1]==-1. then
       UpTrendSignal[period]=bsmin[period];
       UpTrendBuffer[period]=bsmin[period];
       if Line>0 then
        UpTrendLine[period]=bsmin[period];
       end
      else
       UpTrendBuffer[period]=bsmin[period];
       if Line>0 then
        UpTrendLine[period]=bsmin[period];
       end
       UpTrendSignal[period]=-1;
      end
      if Signal==2 then
       UpTrendBuffer[period]=0;
      end
      DownTrendSignal[period]=-1;
      DownTrendBuffer[period]=-1;
      DownTrendLine[period]=nil;
     end
     
     if trend<0 then
      if Signal>0 and DownTrendBuffer[period-1]==-1. then
       DownTrendSignal[period]=bsmax[period];
       DownTrendBuffer[period]=bsmax[period];
       if Line>0 then
        DownTrendLine[period]=bsmax[period];
       end
      else
       DownTrendBuffer[period]=bsmax[period]; 
       if Line>0 then
        DownTrendLine[period]=bsmax[period];
       end
       DownTrendSignal[period]=-1;
      end
      UpTrendSignal[period]=-1;
      UpTrendBuffer[period]=-1;
      UpTrendLine[period]=nil;
     end
     
    elseif first==period then
     UpTrendSignal[period]=0;
     UpTrendBuffer[period]=0;
     UpTrendLine[period]=nil;
     DownTrendSignal[period]=0;
     DownTrendBuffer[period]=0;
     DownTrendLine[period]=nil;
 end    
end

