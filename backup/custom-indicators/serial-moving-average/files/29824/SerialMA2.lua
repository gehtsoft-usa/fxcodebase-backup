-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15886
-- Id: 6337

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
    indicator:name("Serial MA indicator");
    indicator:description("Serial MA indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local SerialMA=nil;
local StartPoint;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    SerialMA = instance:addStream("SerialMA", core.Line, name .. ".SerialMA", "SerialMA", instance.parameters.clr, first);
    SerialMA:setWidth(instance.parameters.widthLinReg);
    SerialMA:setStyle(instance.parameters.styleLinReg);
    core.host:execute ("addCommand", 1, "Start point", "Start point");
    StartPoint=nil;
end

function Update(period, mode)
   local StartBar;
   if StartPoint==nil then
    StartBar=first;
   else 
    StartBar=core.findDate(source, StartPoint, false);
   end 
   
    if StartBar==-1 then
   StartBar=first;
   end
   
   
   if (period>StartBar) then
    SerialMA[period]=core.avg(source, core.range(StartBar, period));
   elseif period==StartBar then
    SerialMA[period]=source[period];
   elseif period>=first and period<StartBar then
    SerialMA[period]=nil; 
   end 
end

function AsyncOperationFinished(cookie, success, message)
 if cookie==1 then
  local t, c = core.parseCsv(message, ";");
  local PrevStartBar;
  if StartPoint==nil then
   PrevStartBar=first;
  else 
   PrevStartBar=core.findDate(source, StartPoint, false);
  end 
  StartPoint=t[1];
  local StartBar=core.findDate(source, StartPoint, false);
  instance:updateFrom(math.min(StartBar, PrevStartBar));
 end
end

