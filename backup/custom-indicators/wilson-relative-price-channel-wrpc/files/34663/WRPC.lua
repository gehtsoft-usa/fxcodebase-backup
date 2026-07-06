-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=19607
-- Id: 6686

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("WILSON RELATIVE PRICE CHANNEL");
    indicator:description("WILSON RELATIVE PRICE CHANNEL");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("CP", "Channel Periods", "Channel Periods", 34, 1, 2000);
    indicator.parameters:addInteger("SP", "Smoothing Period", "Smoothing Period", 14, 1, 2000);
    indicator.parameters:addDouble("OB", "Over Bought", "Over Bought", 70);
    indicator.parameters:addDouble("OS", "Over Sold", "Over Sold", 30);
    indicator.parameters:addDouble("UNZ", "Upper Neutral Zone", "Upper Neutral Zone", 55);
    indicator.parameters:addInteger("LNZ", "Lower Neutral Zone", "Lower Neutral Zone", 45);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("OverBought_color", "Color of OverBought", "Color of OverBought", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("OverSold_color", "Color of OverSold", "Color of OverSold", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CP;
local SP;
local OB;
local OS;
local UNZ;
local LNZ;
local Transparency;
local first;
local source = nil;

-- Streams block
local OverBought = nil;
local OverSold = nil;
local NeutralUp = nil;
local NeutralDown = nil;
local RSI, OBS, OSS;
local ROB, ROS;
local ROBUNZ, ROSLNZ; 
local UNZS,LNZS;
-- Routine
function Prepare(nameOnly)
    Transparency = instance.parameters.Transparency;
    CP = instance.parameters.CP;
    SP = instance.parameters.SP;
    OB = instance.parameters.OB;
    OS = instance.parameters.OS;
    UNZ = instance.parameters.UNZ;
    LNZ = instance.parameters.LNZ;
    source = instance.source;
	
	Transparency= 100-Transparency;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CP) .. ", " .. tostring(SP) .. ", " .. tostring(OB) .. ", " .. tostring(OS) .. ", " .. tostring(UNZ) .. ", " .. tostring(LNZ) .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	ROB=instance:addInternalStream(0, 0);
	ROS=instance:addInternalStream(0, 0);
	ROBUNZ =instance:addInternalStream(0, 0);
	ROSLNZ=instance:addInternalStream(0, 0);
	
	RSI = core.indicators:create( "RSI", source, CP);
	OBS = core.indicators:create( "EMA", ROB, SP);
	OSS = core.indicators:create( "EMA", ROS, SP);
	UNZS= core.indicators:create( "EMA", ROBUNZ, SP);
	LNZS= core.indicators:create( "EMA", ROSLNZ, SP);
	
	
	 first = UNZS.DATA:first();

    if (not (nameOnly)) then
        OverBought = instance:addStream("OverBought", core.Line, name .. ".OverBought", "OverBought", instance.parameters.OverBought_color, first);
        OverSold = instance:addStream("OverSold", core.Line, name .. ".OverSold", "OverSold", instance.parameters.OverSold_color, first);
        NeutralUp = instance:addStream("NeutralUp", core.Line, name .. ".NeutralUp", "NeutralUp", instance.parameters.OverBought_color, first);
        NeutralDown = instance:addStream("NeutralDown", core.Line, name .. ".NeutralDown", "NeutralDown", instance.parameters.OverSold_color, first);
		
		instance:createChannelGroup("Up","Up" , OverBought, NeutralUp, instance.parameters.OverBought_color, Transparency);
	   instance:createChannelGroup("Down","Down" , OverSold, NeutralDown, instance.parameters.OverSold_color, Transparency);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period <  first or not  source:hasData(period) then
	return;
	end
	
	 RSI:update(mode);
	 
	 ROB[period]= RSI.DATA[period] - OB;
	 ROS[period]= RSI.DATA[period] - OS;
	 ROBUNZ[period]= RSI.DATA[period] - UNZ;
	 ROSLNZ[period]= RSI.DATA[period] - LNZ;
	 
	 OBS:update(mode);
	 OSS:update(mode);
	 UNZS:update(mode);
	 LNZS:update(mode);

        OverBought[period] = source[period] - (source[period] * (OBS.DATA[period] /100) );
        OverSold[period] = source[period] - (source[period] * (OSS.DATA[period] /100) );
        NeutralUp[period] = source[period] - (source[period] * (UNZS.DATA[period] /100) );
        NeutralDown[period] = source[period] - (source[period] * (LNZS.DATA[period] /100) );
    
end

