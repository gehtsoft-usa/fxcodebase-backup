-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=2067

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Repulse indicator");
    indicator:description("Repulse indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RepulsePeriod1", "RepulsePeriod1", "", 1);
    indicator.parameters:addInteger("RepulsePeriod2", "RepulsePeriod2", "", 5);
    indicator.parameters:addInteger("RepulsePeriod3", "RepulsePeriod3", "", 15);

    indicator.parameters:addGroup("First Line Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));	
	indicator.parameters:addInteger("first_width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("first_style", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("first_style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Second Line Style");
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("second_width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("second_style", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("second_style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Third Line Style");
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("third_width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("third_style", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("third_style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 0);
	indicator.parameters:addDouble("Level2", "2. Level","", 0);
	indicator.parameters:addDouble("Level3", "3. Level","", 0); 
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);	
	
end

local first;
local source = nil;
local RepulsePeriod1;
local RepulsePeriod2;
local RepulsePeriod3;
local PosBuffer1;
local NegBuffer1;
local PosBuffer2;
local NegBuffer2;
local PosBuffer3;
local NegBuffer3;
local MAPos1;
local MANeg1;
local MAPos2;
local MANeg2;
local MAPos3;
local MANeg3;
local F1, F2, F2;
function Prepare(nameOnly)
    source = instance.source;
    RepulsePeriod1=instance.parameters.RepulsePeriod1;
    RepulsePeriod2=instance.parameters.RepulsePeriod2;
    RepulsePeriod3=instance.parameters.RepulsePeriod3;
    first = source:first()+2;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RepulsePeriod1 .. ", " .. instance.parameters.RepulsePeriod2 .. ", " .. instance.parameters.RepulsePeriod3 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    PosBuffer1 = instance:addInternalStream(first+RepulsePeriod1, 0);
    NegBuffer1 = instance:addInternalStream(first+RepulsePeriod1, 0);
    PosBuffer2 = instance:addInternalStream(first+RepulsePeriod2, 0);
    NegBuffer2 = instance:addInternalStream(first+RepulsePeriod2, 0);
    PosBuffer3 = instance:addInternalStream(first+RepulsePeriod3, 0);
    NegBuffer3 = instance:addInternalStream(first+RepulsePeriod3, 0);
    MAPos1 = core.indicators:create("EMA", PosBuffer1, RepulsePeriod1*5);
    MANeg1 = core.indicators:create("EMA", NegBuffer1, RepulsePeriod1*5);
	F1=math.max(MAPos1.DATA:first(),MANeg1.DATA:first());
	
    MAPos2 = core.indicators:create("EMA", PosBuffer2, RepulsePeriod2*5);
    MANeg2 = core.indicators:create("EMA", NegBuffer2, RepulsePeriod2*5);
	F2=math.max(MAPos2.DATA:first(),MANeg2.DATA:first());
	
    MAPos3 = core.indicators:create("EMA", PosBuffer3, RepulsePeriod3*5);
    MANeg3 = core.indicators:create("EMA", NegBuffer3, RepulsePeriod3*5);
	F3=math.max(MAPos3.DATA:first(),MANeg3.DATA:first());
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".Buff1", "Buff1", instance.parameters.clr1, F1);
	Buff1:setWidth(instance.parameters.first_width);
    Buff1:setStyle(instance.parameters.first_style);
	Buff1:setPrecision (2);
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".Buff2", "Buff2", instance.parameters.clr2, F2);
    Buff2:setWidth(instance.parameters.second_width);
    Buff2:setStyle(instance.parameters.second_style);
	Buff2:setPrecision (2);
    Buff3 = instance:addStream("Buff3", core.Line, name .. ".Buff3", "Buff3", instance.parameters.clr3, F3);
	Buff3:setWidth(instance.parameters.third_width);
    Buff3:setStyle(instance.parameters.third_style);
	Buff3:setPrecision (2);

	Buff1:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Buff1:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Buff1:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);		
end

function Update(period, mode)
   if (period>first+RepulsePeriod1) then
    local MinPrice1=core.min(source.low,core.rangeTo(period,RepulsePeriod1));
    local MaxPrice1=core.max(source.high,core.rangeTo(period,RepulsePeriod1));
    PosBuffer1[period]=(3.*source.close[period]-2.*MinPrice1-source.open[period])/source.close[period]*100.;
    NegBuffer1[period]=(source.open[period]+2.*MaxPrice1-3.*source.close[period])/source.close[period]*100.;
   end 
   MAPos1:update(mode);
   MANeg1:update(mode);
   
   if period > F1 then
   Buff1[period]=MAPos1.DATA[period]-MANeg1.DATA[period];
   end
   
   if (period>first+RepulsePeriod2) then 
    local MinPrice2=core.min(source.low,core.rangeTo(period,RepulsePeriod2));
    local MaxPrice2=core.max(source.high,core.rangeTo(period,RepulsePeriod2));
    PosBuffer2[period]=(3.*source.close[period]-2.*MinPrice2-source.open[period-RepulsePeriod2])/source.close[period]*100.;
    NegBuffer2[period]=(source.open[period-RepulsePeriod2]+2.*MaxPrice2-3.*source.close[period])/source.close[period]*100.;
   end 
   MAPos2:update(mode);
   MANeg2:update(mode);
   
   if period > F2 then
   Buff2[period]=MAPos2.DATA[period]-MANeg2.DATA[period];
   end
   
   if (period>first+RepulsePeriod3) then    
    local MinPrice3=core.min(source.low,core.rangeTo(period,RepulsePeriod3));
    local MaxPrice3=core.max(source.high,core.rangeTo(period,RepulsePeriod3));
    PosBuffer3[period]=(3.*source.close[period]-2.*MinPrice3-source.open[period-RepulsePeriod3])/source.close[period]*100.;
    NegBuffer3[period]=(source.open[period-RepulsePeriod3]+2.*MaxPrice3-3.*source.close[period])/source.close[period]*100.;
   end 
   MAPos3:update(mode);
   MANeg3:update(mode);
   
   if period > F3 then
   Buff3[period]=MAPos3.DATA[period]-MANeg3.DATA[period];
   end  
end

