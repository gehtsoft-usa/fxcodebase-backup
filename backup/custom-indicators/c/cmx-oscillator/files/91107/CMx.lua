-- Id: 10511
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59971


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
    indicator:name("CMx oscillator");
    indicator:description("CMx oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 12);
    indicator.parameters:addDouble("K", "K", "", 1.682);
    indicator.parameters:addDouble("L", "L", "", 18);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Levels color", "Levels color", core.rgb(128, 128, 128));
    
	
	for i= 1, 8, 1 do
	Add(i);
	end
end

function Add (i)

    local Level={61.8,61.8,161.8,-161.8,261.8,-261.8,423.8,-423.8 };
    indicator.parameters:addGroup(i..". Level");	
    indicator.parameters:addDouble("Level"..i, "Level","", Level[i]);
 
	indicator.parameters:addColor("level_overboughtsold_color"..i, "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width"..i,"Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style"..i, "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style"..i, core.FLAG_LEVEL_STYLE);




end

local first;
local source = nil;
local Period;
local K_Period;
local K;
local L;
local MA, MA_K;
local ADX;
local Diff;
local D;
local CMx=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    K=instance.parameters.K;
    L=instance.parameters.L;
    K_Period=math.floor(Period*K+0.5);
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.K .. ", " .. instance.parameters.L .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
    Diff = instance:addInternalStream(0, 0);
    D = instance:addInternalStream(0, 0);
    MA = core.indicators:create("EMA", source.close, Period);
    MA_K = core.indicators:create("EMA", source.close, K_Period);
    ADX = core.indicators:create("ADX", source, Period);
	
	first = ADX.DATA:first();
    
    CMx = instance:addStream("CMx", core.Line, name .. ".CMx", "CMx", instance.parameters.clr, first+K_Period);
    CMx:setWidth(instance.parameters.widthLinReg);
    CMx:setStyle(instance.parameters.styleLinReg);
	 
	for i= 1, 8, 1 do
	CMx:addLevel(instance.parameters:getDouble("Level" .. i), instance.parameters:getInteger("level_overboughtsold_style" .. i), instance.parameters:getInteger("level_overboughtsold_width" .. i), instance.parameters:getColor("level_overboughtsold_color" .. i));
	end
	
    CMx:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
  
    MA:update(mode);
    MA_K:update(mode);
    ADX:update(mode);
	 if period<first then
	 return;
	 end
	
    Diff[period]=MA.DATA[period]-MA_K.DATA[period];
	
	 if period<first+K_Period then
	 return;
	 end
    local mean=mathex.avg(Diff, period-K_Period+1, period);
    local meandev=mathex.meandev(Diff, period-K_Period+1, period);
    local CCI=(Diff[period]-mean)/(meandev*0.015);
    CMx[period]=CCI*ADX.DATA[period]/(L*K);
 
end

