-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71125

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Turning Points");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "M1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	indicator.parameters:addDouble("Level1", "1. Level", "", 0.25);
	indicator.parameters:addDouble("Level2", "2. Level", "", 0.50); 
    
	
	indicator.parameters:addGroup("BB Style");  
    indicator.parameters:addColor("TopClr", "Bands Line Color", "Line color", core.rgb(219, 64, 0));
    indicator.parameters:addInteger("BandsWidth", "Bands Line Width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("BandsStyle", "Bands Line Style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("BandsStyle", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("BottomClr", "Bottom Line Color", "Line color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("AverageWidth", "Average Line Width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("AverageStyle", "Average Line Style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("AverageStyle", core.FLAG_LINE_STYLE);
 
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 
local first;
local source = nil;
local BB_Top_Mid, BB_Bottom_Mid;
local BB_Top,  BB_Bottom;
local Source,  loading;
local dayoffset, weekoffset,TF;
local Level1, Level2;

-- Routine
 function Prepare(nameOnly)   
 
  

	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	Level1=instance.parameters.Level1;
	Level2=instance.parameters.Level2;

    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	first =source:first();
 
	
	BB_Top = instance:addStream("BB_Top", core.Line, name .. ".Top", "Top", instance.parameters.TopClr, first);   
    BB_Top_Mid = instance:addStream("BB_Top_Mid", core.Line, name .. ".Top_Mid", "Top_Mid", instance.parameters.TopClr, first);
	
	BB_Bottom = instance:addStream("BB_Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.BottomClr, first);
    BB_Bottom_Mid = instance:addStream("BB_Bottom_Mid", core.Line, name .. ".Bottom_Mid", "Bottom_Mid", instance.parameters.BottomClr, first);
	
	
    BB_Top:setWidth(instance.parameters.BandsWidth);
    BB_Top:setStyle(instance.parameters.BandsStyle);
    BB_Bottom:setWidth(instance.parameters.BandsWidth);
    BB_Bottom:setStyle(instance.parameters.BandsStyle);
	
	BB_Top_Mid:setWidth(instance.parameters.BandsWidth);
    BB_Top_Mid:setStyle(instance.parameters.BandsStyle);
    BB_Bottom_Mid:setWidth(instance.parameters.BandsWidth);
    BB_Bottom_Mid:setStyle(instance.parameters.BandsStyle);
	
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.min(300,first), 100, 101);
	loading=true;
 
end

-- Indicator calculation routine
function Update(period, mode)

  
	if period < first
	then
	return;
	end
	
	
    local p =  Initialization(period) 
     
	if not p then
	return;
	end
	
	p=p-1;
		
	if p < 1 then	
	return;
	end
		
	local A = Source.high[p];
	local B = Source.low[p];
	local C =  Source.high[p]- Source.low[p];
	local D = Level1 *C;
	local E = Level2 *C;


	
 
	BB_Top[period]=A+D;
	BB_Top_Mid[period]=A+E;
    BB_Bottom[period]=B-D;
    BB_Bottom_Mid[period]=B-E;
 
				  
end


 

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
 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

