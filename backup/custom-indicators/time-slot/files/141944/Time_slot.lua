-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71179

--+------------------------------------------------------------------------+
--|                                    Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                 http://fxcodebase.com  |
--+------------------------------------------------------------------------+
--|                                      Support our efforts by donating   | 
--|                                         Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------+
--|                                           Developed by : Mario Jemic   |                    
--|                                               mario.jemic@gmail.com    |
--|                                https://AppliedMachineLearning.systems  |
--|                                     Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------+

--+------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |  
--|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
--|Binance MEMO (BEP2 only)   : 107152697                                  |   
--|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |  
--+------------------------------------------------------------------------+

function Init()
    indicator:name("Time slot");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("StartTime", "Start Time for Trading", "", 0);
    indicator.parameters:addInteger("StopTime", "Stop Time for Trading", "", 24);

    indicator.parameters:addColor("bg_color", "Backgound color", "", core.colors().Red);
    indicator.parameters:addInteger("transparency", "Transparency", "", 50, 0, 100);
end


local StartTime,StopTime;
local source, OpenTime, CloseTime;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
	
	StartTime=instance.parameters.StartTime;
	StopTime=instance.parameters.StopTime;
   
    instance:ownerDrawn(true);
end

function Update(period, mode)
end

local init = false;
local PEN = 1;
local BRUSH = 2;
local transparency;
function Draw(stage, context)
    if stage ~= 0 then
        return;
    end
    if not init then
        context:createPen(PEN, context.SOLID, 1, instance.parameters.bg_color);
        context:createSolidBrush(BRUSH, instance.parameters.bg_color);
        transparency = context:convertTransparency(instance.parameters.transparency);
        init = true;
    end
   local Date= source:date(source:size()-1);
   local DayStart = math.floor(Date);
 
      local StartDate=DayStart+StartTime*(1/24);
	  local StopDate=DayStart+StopTime*(1/24);
        x, x1, x = context:positionOfDate (StartDate);
		x, x, x2 = context:positionOfDate (StopDate);
		
		context:drawRectangle(PEN, BRUSH, x1, context:top(), x2, context:bottom(), transparency);
        core.host:trace("1");
 
end