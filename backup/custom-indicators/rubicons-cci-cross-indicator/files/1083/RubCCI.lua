-- Id: 349

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=613

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
 


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Rubicon CCI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
  
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CCI_N", "CCI parameter", "", 10);
    indicator.parameters:addInteger("EMA_N", "EMA parameter", "", 3);

	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("CCI_color", "Color of CCI", "Color of CCI", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("EMA_color", "Color of EMA", "Color of EMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("LBL_color", "Color of labels", "Color of labels", core.COLOR_LABEL);
    indicator.parameters:addColor("BG_color", "Color of background", "Color of backgroung", core.rgb(127, 127, 127));
    indicator.parameters:addInteger("BG_trans", "Background transparency", "Transparency of background", 90, 0, 100);
	
	indicator.parameters:addInteger("Size", "Font Size", "Font Size",10);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addInteger("OB", "OB Level", "OB Level",100);
	indicator.parameters:addInteger("OS", "OS Level", "OS Level",-100);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local CCI_N;
local EMA_N;

local source = nil;
local Size;
-- Streams block
local CCI = nil;
local EMA = nil;
local LBL1 = nil;
local LBL2 = nil;
--local L1 = nil;
--local L2 = nil;
--local L3 = nil;
--local L4 = nil;
local _CCI = nil;
local _EMA = nil;
local OB,OS;
-- Routine
function Prepare(nameOnly)
    CCI_N = instance.parameters.CCI_N;
    EMA_N = instance.parameters.EMA_N;
	Size= instance.parameters.Size;
	OB= instance.parameters.OB;
	OS= instance.parameters.OS;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. CCI_N .. ", " .. EMA_N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    L1 = instance:addInternalStream(0, 0);
    L2 = instance:addInternalStream(0, 0);
    instance:createChannelGroup("BG", "BG", L1, L2, instance.parameters.BG_color, 100 - instance.parameters.BG_trans);
 

    LBL1 = instance:createTextOutput ("L", "L", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.LBL_color, 0);
    LBL2 = instance:createTextOutput ("L", "L", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.LBL_color, 0);

    _CCI = core.indicators:create("CCI", source, CCI_N);
    _EMA = core.indicators:create("EMA", _CCI.DATA, EMA_N);
	
	
    CCI = instance:addStream("CCI", core.Line, name .. ".CCI", "CCI", instance.parameters.CCI_color, _CCI.DATA:first());   
	CCI:setWidth(instance.parameters.width1);
    CCI:setStyle(instance.parameters.style1);
	
    CCI:addLevel(0);
	CCI:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	CCI:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    EMA = instance:addStream("EMA", core.Line, name .. ".EMA", "EMA", instance.parameters.EMA_color, _EMA.DATA:first());
	EMA:setWidth(instance.parameters.width2);
    EMA:setStyle(instance.parameters.style2);
	
	CCI:setPrecision(math.max(2, instance.source:getPrecision()));		
	EMA:setPrecision(math.max(2, instance.source:getPrecision()));		
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    local i;
	
	
    _CCI:update(mode);
    _EMA:update(mode);	
	
	LBL1:setNoData(period );
	LBL2:setNoData(period );
	
    L1[period] = OB;
    L2[period] = OS;
   -- L3[period] = OB;
   -- L4[period] = OS;
    if period < _CCI.DATA:first() then
	return;
	end
	
	
        CCI[period] = _CCI.DATA[period];

    if period < _EMA.DATA:first() then
	return;
	end
	
        EMA[period] = _EMA.DATA[period];
	
  
    if period< _EMA.DATA:first() + 1 or period < _CCI.DATA:first() + 1 then
	return;
	end
	
        if core.crossesOver(_EMA.DATA, OS, period) then
            for i = period, period - 5, -1 do
                if core.crossesOver(_CCI.DATA, OS, i) then
                    LBL2:set(period, OS, "\225");
                    break;
                end
            end
        elseif core.crossesUnder(_EMA.DATA, OB, period) then
            for i = period, period - 5, -1 do
                if core.crossesUnder(_CCI.DATA, OB, i) then
                    LBL1:set(period, OB, "\226");
                    break;
                end
            end
        end
    
end

