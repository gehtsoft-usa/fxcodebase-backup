-- Id: 19811
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59573

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
    indicator:name("WeisWave oscillator");
    indicator:description("WeisWave oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("trendDetectionLength", "Trend Detection Length", "", 2);
    indicator.parameters:addBoolean("Absolute", "Absolute", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("Divisor Calculation");
	indicator.parameters:addInteger("Divisor", "Divisor", "", 1);
	indicator.parameters:addIntegerAlternative("Divisor", "1", "", 1);
    indicator.parameters:addIntegerAlternative("Divisor", "100", "", 100);
    indicator.parameters:addIntegerAlternative("Divisor", "1000", "", 1000);
    indicator.parameters:addIntegerAlternative("Divisor","10000", "", 10000)
	indicator.parameters:addIntegerAlternative("Divisor","100000", "", 100000)
	indicator.parameters:addIntegerAlternative("Divisor","1000000", "", 1000000)
end

local first;
local source = nil;
local trendDetectionLength;
local Absolute;
local difPip;
local mov, trend, wave, vol;
local Volume;
local Divisor;
function Prepare(nameOnly)
    source = instance.source;
    trendDetectionLength=instance.parameters.trendDetectionLength;
	Divisor=instance.parameters.Divisor;
    Absolute=instance.parameters.Absolute;
    first = source:first()+2;    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.trendDetectionLength .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    mov = instance:addInternalStream(first, 0);
    trend = instance:addInternalStream(first, 0);
    wave = instance:addInternalStream(first, 0);

    Volume = instance:addStream("Volume", core.Bar, name .. ".Volume", "Volume", instance.parameters.UPclr, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
 
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    if source.close[period]>source.close[period-1] then
     mov[period]=1;
    elseif source.close[period]<source.close[period-1] then
     mov[period]=-1;
    else
     mov[period]=0;
    end
	
	
	--[[
	if mov <>0 and mov <> mov[1] then
	 trend=mov
	else
	 trend=trend[0]
	endif
	]]
	
    if mov[period]~=0 and mov[period]~=mov[period-1] then
     trend[period]=mov[period];
    else
     trend[period]=trend[period-1];
    end
	
	
 
	if math.abs(source.close[period]-source.close[period-1])> math.abs(source.close[period]-source.close[period-trendDetectionLength]) then
	rising=true;
	else
	rising=false;
	end
	
    if  math.abs(source.close[period]-source.close[period-1])< math.abs(source.close[period]-source.close[period-trendDetectionLength]) then
     falling=true;
	 else
	 falling=false;
     end 
  
    local isTrending=false;
	
    if rising or falling then
	 isTrending= true
	 else
	 
	end
	
	--[[
	if trend <> wave[1] and isTrending then
	 wave=trend
	else
	 wave=wave[0]
	endif

	]]
		
    if trend[period]~=wave[period-1] and isTrending then
     wave[period]=trend[period];
    else
     wave[period]=wave[period-1];
    end
	

	
    if wave[period]==wave[period-1] then
     Volume[period]=Volume[period-1]+source.volume[period]/Divisor;
    else
     Volume[period]=source.volume[period]/Divisor;
    end
	
	
    if wave[period]==1 then
     Volume:setColor(period, instance.parameters.UPclr);
    elseif wave[period]==-1 then
    Volume:setColor(period, instance.parameters.DNclr);
     end 
     
   
end