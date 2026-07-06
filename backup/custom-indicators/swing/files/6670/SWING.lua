-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2920

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("SWING");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 20);
    indicator.parameters:addColor("strong_color_up", "Color of Strong Swing", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("weak_color_up", "Color of  Weak Swing", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("strong_color_down", "Color of Strong Swing", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("weak_color_down", "Color of  Weak Swing", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;
local  ArrowSize;
local SWING;
local Up, Down;
local UpOne, DownOne;
local DownOld, UpOld;

-- Streams block
local StrongUp,WeakUp;
local StrongDown,WeakDown;
local strong_color_up, weak_color_up, strong_color_down,weak_color_down;
-- Routine
function Prepare(nameOnly)    
     ArrowSize=instance.parameters.ArrowSize;   
    source = instance.source;
    first = source:first();
	
	strong_color_up=instance.parameters.strong_color_up;
	weak_color_up=instance.parameters.weak_color_up;
	strong_color_down=instance.parameters.strong_color_down;
	weak_color_down=instance.parameters.weak_color_down;

    local name = profile:id() .. "(" .. source:name() ..  ")";
    instance:name(name);
	if nameOnly then
		return;
	end
   
    StrongUp= instance:createTextOutput ("Strong", "", "Wingdings",  ArrowSize, core.H_Center, core.V_Top, strong_color_up, first);
	WeakUp= instance:createTextOutput ("Weak", "", "Wingdings",  ArrowSize, core.H_Center, core.V_Top, weak_color_up, first);
	
	StrongDown= instance:createTextOutput ("", "", "Wingdings",  ArrowSize, core.H_Center, core.V_Bottom, strong_color_down, first);
	WeakDown= instance:createTextOutput ("", "", "Wingdings",  ArrowSize, core.H_Center, core.V_Bottom, weak_color_down, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function Update(period)


 
  if period == first then
  
  
		  if source.close[period] > source.open[period] then
		  SWING = "UP";	
		  UpOne=period;
		  Down=period;
		  else
		  SWING = "DOWN";	
		  DownOne=period;
		   Up=period;
		  end  
  end

    if period < first+3 or  not source:hasData(period) then
	return;
	end
	
	 period = period -1;
	
	    if source.close[period] >= source.open[period] and source.close[period-1] < source.open[period-1] then 
		SWING = "UP";		
		UpOne=period;
		Down=period-1;
			if DownOne~= nil then
			DownOld=DownOne-1;
			end
	    elseif source.close[period] <= source.open[period] and source.close[period-1] > source.open[period-1] then 
		SWING = "DOWN";		
		DownOne=period;		
		Up=period-1;
			if UpOne~= nil then
			UpOld=UpOne-1;
			end
		end
	
        if Down== nil or  Up == nil then
		return;
		end
		
		if DownOne== nil or  DownOne == nil then
		return;
		end
		
		
		if UpOld== nil or  DownOld == nil then
		return;
		end
	
		
		
			
		if SWING == "DOWN"then
				if 	 source.high[Up] - 	 source.low[UpOne-1] >   source.high[DownOld] - source.low[Down] then
				StrongUp:set(Up , source.high[Up], "\108");			
				else
				 WeakUp:set(Up , source.high[Up], "\108");	
				end
		elseif  SWING == "UP"   then	
		        if 	     source.high[DownOne-1] - source.low[Down] > source.high[Up] - source.low[UpOld]   then    
				StrongDown:set(Down, source.low[Down],"\108");
		        else
				WeakDown:set(Down, source.low[Down],"\108");		
				end
		end
	   
   
end

