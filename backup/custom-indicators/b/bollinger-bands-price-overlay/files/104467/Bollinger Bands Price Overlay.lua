
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63078

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
    indicator:name("Bollinger Bands Price Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Price" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price" , "Weighted ", "", "weighted");		
	
	 indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000);
	 indicator.parameters:addDouble("Deviations", "Number of standard deviations", "", 2);

	 indicator.parameters:addBoolean("Show", "Show Bollinger Bands", "", false);
	
	indicator.parameters:addGroup("Overlay Style");
	indicator.parameters:addColor("Up", "Color of Up Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Color of Down in Up Trend", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("Down", "Color of Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownUp", "Color of Up in Down Trend", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("NeutralUp", "Color of Neutral Trend Up", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("NeutralDown", "Color of Neutral Trend Down", "", core.rgb(100, 100, 100));
	
	indicator.parameters:addGroup("Line Style");
	indicator.parameters:addColor("TC", "Color of Top Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("BC", "Color of Bottom Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, NeutralUp, NeutralDown,DownUp, UpDown;
local first;
local source = nil;

local Price;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local TC,BC;

local BB, Deviations, Period;

local Show, TL,BL;


function Prepare(nameOnly)

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
	
	TC= instance.parameters.TC;
	BC= instance.parameters.BC;
	
	UpDown = instance.parameters.UpDown;
    DownUp= instance.parameters.DownUp;
	
    NeutralDown= instance.parameters.NeutralDown;
	NeutralUp= instance.parameters.NeutralUp;
   
    Deviations = instance.parameters.Deviations;
	Price = instance.parameters.Price;
	Period= instance.parameters.Period;
 
	 Show= instance.parameters.Show;

	source = instance.source;
	
	 

   local Label1, Label2,Lebel3;
    
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()..", ".. Period..", ".. Deviations
	..  ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	BB=core.indicators:create("BB",  source[Price], Period, Deviations);
	first= BB.DATA:first();
   
    if Show then
	TL = instance:addStream("TL", core.Line, name, "", TC, first);
    BL = instance:addStream("BL", core.Line, name, "", BC, first);		
	TL:setWidth(instance.parameters.width);
    TL:setStyle(instance.parameters.style);
	BL:setWidth(instance.parameters.width);
    BL:setStyle(instance.parameters.style);
	else
	TL = instance:addInternalStream(first, 0);
	BL = instance:addInternalStream(first, 0);
	end
     	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	  BB:update(mode);
			if period < first then
			open:setColor(period, NeutralUp);	
			return;
			end
	 
		
		 TL[period]=BB.TL[period];
		 BL[period]=BB.BL[period];
		
		if source.close[period]> BB.TL[period]    then	
			if source.close[period]> source.open[period] then		
			open:setColor(period,  Up);
			else
			open:setColor(period,  UpDown);
			end
        elseif source.close[period]< BB.BL[period] then
			if source.close[period]< source.open[period] then
			open:setColor(period,  Down);
			else
			open:setColor(period,  DownUp);
			end
		else
			if source.close[period]> source.open[period] then
			open:setColor(period, NeutralUp);	
			else		
			open:setColor(period, NeutralDown);	
			end
		end
		
		
				

		
 end


