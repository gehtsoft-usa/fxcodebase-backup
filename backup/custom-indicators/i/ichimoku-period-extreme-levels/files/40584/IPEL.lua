-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23584
-- Id: 7442

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Ichimoku Period Extreme Levels");
    indicator:description("Ichimoku Period Extreme Levels");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Tenkan", "Tenkan", "Tenkan", 9);
    indicator.parameters:addInteger("Kijun", "Kijun", "Kijun", 26);
    indicator.parameters:addInteger("Senkou", "Senkou", "Senkou", 52);
	
	 indicator.parameters:addInteger("SP", "SL Period", "SL Period", 9);
    indicator.parameters:addInteger("TP", "TL Period", "TL Period", 9);
    indicator.parameters:addInteger("CP", "CS Period", "CS Period ", 9);
	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("CC", "CL Line Color", " ", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("CW", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("CS", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("CS", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("TC", "TL Line Color", " ", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("TW", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("TS", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("TS", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("SC", "SL Line Color", " ", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("SW", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("SS", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SS", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Label", "Label Color", " ", core.rgb(0, 0, 0));
	 indicator.parameters:addInteger("ArrowSize", "Font Size", "", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Tenkan,Kijun,Senkou;
local SP,SP,CP;
local first;
local source = nil;
local CC, CS,TC, TS, SC, SS;
local SW,TW, CW;
-- Streams block
local ICH = nil;
local ArrowSize;
local font,Label;
local Size;
-- Routine
function Prepare(nameOnly)

    source = instance.source;
    first = source:first();
	
    Tenkan = instance.parameters.Tenkan;
	Kijun = instance.parameters.Kijun;
	Senkou = instance.parameters.Senkou;
	
	SP = instance.parameters.SP;
	TP = instance.parameters.TP;
	CP = instance.parameters.CP;
	
	CC = instance.parameters.CC;
	CS = instance.parameters.CS;
	TC = instance.parameters.TC;
	TS = instance.parameters.TS;
	SC = instance.parameters.SC;
	SS = instance.parameters.SS;
	SW = instance.parameters.SW;
	TW = instance.parameters.TW;
	CW = instance.parameters.CW;
	Label= instance.parameters.Label;
	
	ArrowSize = instance.parameters.ArrowSize;
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Tenkan).. ", " .. tostring(Kijun).. ", " .. tostring(Senkou) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		font = core.host:execute("createFont", "Arial", ArrowSize, true, false);
			
		local s,e;
		 s, e = core.getcandle(source:barSize(), core.now(), 0, 0);	
		 
		 Size= e-s;
			
		ICH= core.indicators:create("ICH",source, Tenkan,Kijun,Senkou);	
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	--SL, TL, CS;
	
    ICH:update(mode);

    local ID=1;	
	
	local min, max;
	
	if ICH.SL:first()<  ICH.SL:size()-1 - SP then
	min, max= mathex.minmax (ICH.SL, ICH.SL:size()-1 - SP, ICH.SL:size()-1);
	
	core.host:execute("drawLine", ID, source:date(ICH.SL:size()-1 - SP), max, source:date(source:size()-1), max, SC, SS, SW);
	ID=ID+1;
													
    core.host:execute("drawLine", ID, source:date(ICH.SL:size()-1 - SP), min, source:date(source:size()-1), min, SC, SS, SW);
	ID=ID+1;
	
	core.host:execute("drawLabel1", ID, source:date(source:size()-1)+Size, core.CR_CHART, max, core.CR_CHART, core.H_Right, core.V_Top, font, Label,  string.format("%." .. 5 .. "f",  max ));		
    ID=ID+1;	
    core.host:execute("drawLabel1", ID, source:date(source:size()-1)+Size, core.CR_CHART, min, core.CR_CHART, core.H_Right, core.V_Top, font, Label,  string.format("%." .. 5 .. "f",  min ));		
    ID=ID+1;
	end
	
	if ICH.TL:first()<  ICH.TL:size()-1 - TP then
	min, max= mathex.minmax (ICH.TL, ICH.TL:size()-1 - TP, ICH.TL:size()-1);
	core.host:execute("drawLine", ID, source:date(ICH.TL:size()-1 - TP), max, source:date(source:size()-1), max, TC, TS, TW);
	ID=ID+1;
    core.host:execute("drawLine", ID, source:date(ICH.TL:size()-1 - TP), min, source:date(source:size()-1), min, TC, TS, TW);
	ID=ID+1;
	
	core.host:execute("drawLabel1", ID, source:date(source:size()-1)+Size, core.CR_CHART, max, core.CR_CHART, core.H_Right, core.V_Top, font, Label,  string.format("%." .. 5 .. "f",  max ));		
    ID=ID+1;	
    core.host:execute("drawLabel1", ID, source:date(source:size()-1)+Size, core.CR_CHART, min, core.CR_CHART, core.H_Right, core.V_Top, font, Label,  string.format("%." .. 5 .. "f",  min ));		
    ID=ID+1;
	end
	
	if ICH.CS:first()<  ICH.CS:size()-1 - CP then
    min, max= mathex.minmax (ICH.CS, ICH.CS:size()-1 - CP, ICH.CS:size()-1);	
	core.host:execute("drawLine", ID, source:date(ICH.CS:size()-1 - CP), max, source:date(source:size()-1), max, CC, CS, CW);
	ID=ID+1;
    core.host:execute("drawLine", ID, source:date(ICH.CS:size()-1 - CP), min, source:date(source:size()-1), min, CC, CS, CW);
	ID=ID+1;
	
	core.host:execute("drawLabel1", ID, source:date(source:size()-1)+Size, core.CR_CHART, max, core.CR_CHART, core.H_Right, core.V_Top, font, Label,  string.format("%." .. 5 .. "f",  max ));		
    ID=ID+1;	
    core.host:execute("drawLabel1", ID, source:date(source:size()-1)+Size, core.CR_CHART, min, core.CR_CHART, core.H_Right, core.V_Top, font, Label,  string.format("%." .. 5 .. "f",  min ));		
    ID=ID+1;
	end
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);      
end


