-- Id: 11034
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60261

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("MA Cross Zones");
    indicator:description("MA Cross Zones");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	
	      indicator.parameters:addGroup("1. MA Calculation");
  	        indicator.parameters:addInteger("Period1", "Period", "", 14); 
			
			indicator.parameters:addString("Method1", "Method", "", "MVA");
			indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
			indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
			indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
			indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
			indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
			indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
			indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
			indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
			indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
			indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
			indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
			indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
			indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
			indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
			indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
			indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
			indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
			indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
			indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
			indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
			
			
			 indicator.parameters:addGroup("2. MA Calculation");
  	        indicator.parameters:addInteger("Period2", "Period", "", 34);  
			
			indicator.parameters:addString("Method2", "Method", "", "MVA");
			indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
			indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
			indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
			indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
			indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
			indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
			indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
			indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
			indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
			indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
			indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
			indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
			indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
			indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
			indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
			indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
			indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
			indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
			indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
			indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
			
	 indicator.parameters:addGroup("MA Style");
	 indicator.parameters:addBoolean("Show", "Show MA`s", "", false);
	 indicator.parameters:addBoolean("Background", "Show Background", "", true);
	   indicator.parameters:addColor("First", "First MA Line Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Second", "First MA Line Color", "", core.rgb(255, 0, 0));
	 
	 
	 indicator.parameters:addGroup("Background Style");
     indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);	 	 
    indicator.parameters:addColor("up_color", "Up Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("dn_color", "Down Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("no_color", "Down Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Background;
local first;
local source = nil;

-- Streams block
local Transparency = nil;
local Indicator1,Indicator2;
local Period1, Period1;
local Period2, Period2;
local Method1Method1;
local Method2Method2;
local First, Second; 
local up_color,dn_color,no_color;
local Show; 
local init;
local  firstBar, lastBar;
-- Routine
function Prepare(nameOnly)
    no_color = instance.parameters.no_color;
	up_color = instance.parameters.up_color;
	dn_color  = instance.parameters.dn_color;
	Show  = instance.parameters.Show;
    Period1 = instance.parameters.Period1;	 
	Period2 = instance.parameters.Period2;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Background = instance.parameters.Background;
	Transparency= 100 -instance.parameters.Transparency;
	init = false;
    
    source = instance.source; 
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
	
    local name = profile:id() .. "(" .. source:name()  ..", ".. Method1 ..", "..  Period1..", ".. Method2 ..", "..  Period2  ..")";
	instance:name(name);
	if nameOnly then
		return;
	end
    Indicator1 = core.indicators:create("AVERAGES", source, Method1 ,  Period1, false);
	Indicator2 = core.indicators:create("AVERAGES", source, Method2 ,  Period2, false);
    first=math.max(Indicator1.DATA:first(), Indicator2.DATA:first())
	
 
	 min=instance:addInternalStream(0, 0);
	 max=instance:addInternalStream(0, 0);    
	if   Background then
	instance:createChannelGroup("Group","Group" , min, max, up_color, Transparency);
	end
	
	if Show then
	First = instance:addStream("First", core.Line, name .. "First MA", "", instance.parameters.First, first);
    Second = instance:addStream("Second", core.Line, name .. "Second MA", "",instance.parameters.Second, first); 
	else
	First =   instance:addInternalStream(0, 0);
    Second=   instance:addInternalStream(0, 0);
	end
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   Indicator1:update(mode);
   Indicator2:update(mode);
  
    if period < first  or not source:hasData(period)  then
	min:setColor(period,up_color);
	return;
	end		

	
	First[period]= Indicator1.DATA[period];
	Second[period]= Indicator2.DATA[period];
	
	if  First[period] > Second[period]  then	
	min:setColor(period,up_color);
	elseif  First[period] < Second[period]  then	
	min:setColor(period,dn_color);
    else
	min:setColor(period,no_color);
	end
	
	if period == source:size()-1 then
	
	local Min,Max= mathex.minmax(source,first, source:size()-1);
	Max= Max*2;
	
	local i;
		for i= first, period, 1 do
		min[i]= Min;
		max[i]= Max;
		end
	end
end

