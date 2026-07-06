-- Id: 13362
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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=61668


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("WaveTrend");
    indicator:description("WaveTrend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("n1", "Channel Length", "Channel Length", 10);
    indicator.parameters:addInteger("n2", "Average Length", "Average Length", 21);
	indicator.parameters:addInteger("n3", "Signal Length", "Signal Length", 4);
	
	indicator.parameters:addGroup("Over Bought/Over Sold");	
    indicator.parameters:addInteger("obLevel1", "Over Bought Level 1", "Over Bought Level 1", 50);   
    indicator.parameters:addInteger("osLevel1", "Over Sold Level 1", "Over Sold Level 1", -60);
	
	indicator.parameters:addColor("level_overboughtsold_color1", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width1","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addInteger("obLevel2", "Over Bought Level 2", "Over Bought Level 2", 53);
    indicator.parameters:addInteger("osLevel2", "Over Sold Level 2", "Over Sold Level 2", -53);
	indicator.parameters:addColor("level_overboughtsold_color2", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width2","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("wt1_color", "Color of wt1", "Color of wt1", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("wt2_color", "Color of wt2", "Color of wt2", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("wt3_color", "Color of wt3", "Color of wt3", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local n1;
local n2;
local n3;
local obLevel1;
local obLevel2;
local osLevel1;
local osLevel2;

local first;
local source = nil;

-- Streams block
local wt1 = nil;
local wt2 = nil;
local wt3 = nil;
local EMA1,EMA2,EMA3;
local Raw1,Raw2;
local SMA;
-- Routine
function Prepare(nameOnly)
    n1 = instance.parameters.n1;
    n2 = instance.parameters.n2;
	n3 = instance.parameters.n3;
    obLevel1 = instance.parameters.obLevel1;
    obLevel2 = instance.parameters.obLevel2;
    osLevel1 = instance.parameters.osLevel1;
    osLevel2 = instance.parameters.osLevel2;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(n1) .. ", " .. tostring(n2) .. ", " .. tostring(obLevel1) .. ", " .. tostring(obLevel2) .. ", " .. tostring(osLevel1) .. ", " .. tostring(osLevel2) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	EMA1 = core.indicators:create("EMA", source.typical, n1);
    first = EMA1.DATA:first();
	Raw1= instance:addInternalStream(0, 0);
	EMA2 = core.indicators:create("EMA", Raw1, n1);
	Raw2= instance:addInternalStream(0, 0);
    EMA3 = core.indicators:create("EMA", Raw2, n2);
  
   
	
	

   
        wt1 = instance:addStream("wt1", core.Line, name .. ".wt1", "wt1", instance.parameters.wt1_color, EMA3.DATA:first());
		wt1:addLevel(osLevel1, instance.parameters.level_overboughtsold_style1, instance.parameters.level_overboughtsold_width1, instance.parameters.level_overboughtsold_color1);
		wt1:addLevel(obLevel1, instance.parameters.level_overboughtsold_style1, instance.parameters.level_overboughtsold_width1, instance.parameters.level_overboughtsold_color1);
		wt1:setWidth(instance.parameters.width1);
        wt1:setStyle(instance.parameters.style1);			
		wt1:addLevel(osLevel2, instance.parameters.level_overboughtsold_style2, instance.parameters.level_overboughtsold_width2, instance.parameters.level_overboughtsold_color2);
		wt1:addLevel(obLevel2, instance.parameters.level_overboughtsold_style2, instance.parameters.level_overboughtsold_width2, instance.parameters.level_overboughtsold_color2);   
		
		SMA = core.indicators:create("MVA", wt1, n3);
		
        wt2 = instance:addStream("wt2", core.Line, name .. ".wt2", "wt2", instance.parameters.wt2_color, SMA.DATA:first());
		wt2:setWidth(instance.parameters.width2);
        wt2:setStyle(instance.parameters.style2);
        wt3 = instance:addStream("wt3", core.Bar, name .. ".wt3", "wt3", instance.parameters.wt3_color, SMA.DATA:first());
		
		
		wt1:setPrecision(math.max(2, instance.source:getPrecision()));
		wt2:setPrecision(math.max(2, instance.source:getPrecision()));
		wt3:setPrecision(math.max(2, instance.source:getPrecision()));
		
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    EMA1:update(mode);
	
    if period < first 
	or not source:hasData(period) then
	return;
	end
	
	Raw1[period]= math.abs(source.typical[period]-EMA1.DATA[period]);
	
	EMA2:update(mode);
	 
	if period < EMA2.DATA:first() then
	return;
	end 
	
	Raw2[period]= (source.typical[period]-EMA1.DATA[period])/(0.015*EMA2.DATA[period]);
	
	
	EMA3:update(mode);
	if period < EMA3.DATA:first() then
	return;
	end 
	
        wt1[period] = EMA3.DATA[period];
		
    SMA:update(mode);
	if period < SMA.DATA:first() then
	return;
	end 	
		
        wt2[period] = SMA.DATA[period];
        wt3[period] =  wt1[period]- wt2[period];
    
end
