-- Id: 12738
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61338

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
    indicator:name("Two Time Frame Stochastic with Direction");
    indicator:description("Two Time Frame Stochastic with Direction");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("TF", "Higher Time Frame", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	indicator.parameters:addGroup("First Stochastic");
	 indicator.parameters:addInteger("K1", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000);
    indicator.parameters:addInteger("SD1", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
    indicator.parameters:addInteger("D1", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K1", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K1", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K1", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K1", "MetaTrader", "The MetaTrader algorithm.", "MT");
	indicator.parameters:addStringAlternative("MVAT_K1" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_K1" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_K1" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_K1" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_K1" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_K1" , "WMA", "", "WMA");	
    
    indicator.parameters:addString("MVAT_D1", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D1", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D1", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("MVAT_D1" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_D1" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_D1" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_D1" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_D1" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_D1" , "WMA", "", "WMA");	
	
	
	indicator.parameters:addGroup("Second Stochastic");
	 indicator.parameters:addInteger("K2", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000);
    indicator.parameters:addInteger("SD2", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
    indicator.parameters:addInteger("D2", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K2", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K2", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K2", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K2", "MetaTrader", "The MetaTrader algorithm.", "MT");
	indicator.parameters:addStringAlternative("MVAT_K2" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_K2" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_K2" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_K2" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_K2" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_K2" , "WMA", "", "WMA");	
    
    indicator.parameters:addString("MVAT_D2", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D2", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D2", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("MVAT_D2" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_D2" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_D2" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_D2" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_D2" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_D2" , "WMA", "", "WMA");
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ChartTimeFrameStochastic_color_Up", "Color of Chart Time Frame Stochastic Up", "Color of Stochastic", core.rgb(0, 255, 0));
	indicator.parameters:addColor("ChartTimeFrameStochastic_color_Down", "Color of Chart Time Frame Stochastic Down", "Color of Stochastic", core.rgb(0, 150, 0));
	indicator.parameters:addColor("ChartTimeFrameStochastic_color_Neutral", "Color of Chart Time Frame Stochastic Neutral", "Color of Stochastic", core.rgb(0, 50, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("HigherTimeFrameStochastic_color_Up", "Color of Higher Time Frame Stochastic Up", "Color of Stochastic", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("HigherTimeFrameStochastic_color_Down", "Color of Higher Time Frame Stochastic Down", "Color of Stochastic", core.rgb(150, 0, 0));
	 indicator.parameters:addColor("HigherTimeFrameStochastic_color_Neutral", "Color of Higher Time Frame Stochastic Neutral", "Color of Stochastic", core.rgb(50, 0, 0));
	 indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","",80);
    indicator.parameters:addDouble("oversold","Oversold Level","",  20);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local loading, Source;
-- Streams block
local ChartTimeFrameStochastic, HigherTimeFrameStochastic;
local ChartTimeFrameStochasticOutput, HigherTimeFrameStochasticOutput;
local TF;
local dayoffset, weekoffset;

local k1;
local d1;
local sd1;
local averageTypeK1 = nil;
local averageTypeD1 = nil;


local k2;
local d2;
local sd2;
local averageTypeK2 = nil;
local averageTypeD2 = nil;
-- Routine


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	



function Prepare(nameOnly)
    source = instance.source;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	
	TF= instance.parameters.TF;
	
	k1 = instance.parameters.K1;
    d1 = instance.parameters.D1;
    sd1 = instance.parameters.SD1; 
    averageTypeK1 = instance.parameters.MVAT_K1;
    averageTypeD1 = instance.parameters.MVAT_D1;
    
	
	k2 = instance.parameters.K2;
    d2 = instance.parameters.D2;
    sd2 = instance.parameters.SD1; 
    averageTypeK2 = instance.parameters.MVAT_K2;
    averageTypeD2 = instance.parameters.MVAT_D2;
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	
     local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");

   
	
    Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	loading=true;
	
	
	 ChartTimeFrameStochastic = core.indicators:create("STOCHASTIC", source, K1, SD1, D1, averageTypeK1, averageTypeD1);	 
	 first =ChartTimeFrameStochastic.DATA:first();
	 HigherTimeFrameStochastic = core.indicators:create("STOCHASTIC", Source,  K2, SD2, D2, averageTypeK2, averageTypeD2);

 
        ChartTimeFrameStochasticOutput = instance:addStream("ChartTimeFrameStochastic", core.Line, name, "Chart Time Frame Stochastic", instance.parameters.ChartTimeFrameStochastic_color_Up, first);
    ChartTimeFrameStochasticOutput:setPrecision(math.max(2, instance.source:getPrecision()));
		ChartTimeFrameStochasticOutput:setWidth(instance.parameters.width1);
        ChartTimeFrameStochasticOutput:setStyle(instance.parameters.style1);
		
		ChartTimeFrameStochasticOutput:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
        ChartTimeFrameStochasticOutput:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		
		HigherTimeFrameStochasticOutput = instance:addStream("HigherTimeFrameStochastic", core.Line, name, "Higher Time Frame Stochastic", instance.parameters.HigherTimeFrameStochastic_color_Up, first);
    HigherTimeFrameStochasticOutput:setPrecision(math.max(2, instance.source:getPrecision()));
		HigherTimeFrameStochasticOutput:setWidth(instance.parameters.width2);
        HigherTimeFrameStochasticOutput:setStyle(instance.parameters.style2);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

     ChartTimeFrameStochastic:update(mode); 
     

    if period < first 
	or not source:hasData(period)	
	then
	return;
	end

		
		
        ChartTimeFrameStochasticOutput[period] = ChartTimeFrameStochastic.DATA[period];
		if  ChartTimeFrameStochastic.DATA[period] >  ChartTimeFrameStochastic.DATA[period-1] then
		ChartTimeFrameStochasticOutput:setColor(period,  instance.parameters.ChartTimeFrameStochastic_color_Up);
		elseif  ChartTimeFrameStochastic.DATA[period] <  ChartTimeFrameStochastic.DATA[period-1] then
		ChartTimeFrameStochasticOutput:setColor(period,  instance.parameters.ChartTimeFrameStochastic_color_Down);
		else
		ChartTimeFrameStochasticOutput:setColor(period,  instance.parameters.ChartTimeFrameStochastic_color_Neutral);
		end
   
   
     if loading then
	 return;
	 end
			
	HigherTimeFrameStochastic:update(mode); 	 		
	local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
        HigherTimeFrameStochasticOutput[period] = HigherTimeFrameStochastic.DATA[p]; 
		
		if  HigherTimeFrameStochastic.DATA[p] >  HigherTimeFrameStochastic.DATA[p-1] then
		HigherTimeFrameStochasticOutput:setColor(period,  instance.parameters.HigherTimeFrameStochastic_color_Up);
		elseif HigherTimeFrameStochastic.DATA[p] <  HigherTimeFrameStochastic.DATA[p-1] then
		HigherTimeFrameStochasticOutput:setColor(period,  instance.parameters.HigherTimeFrameStochastic_color_Down);
		else
		HigherTimeFrameStochasticOutput:setColor(period,  instance.parameters.HigherTimeFrameStochastic_color_Neutral);
		end
end

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end