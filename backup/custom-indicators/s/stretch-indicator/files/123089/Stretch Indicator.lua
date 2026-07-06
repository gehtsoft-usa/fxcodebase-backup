-- Id: 23507
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67220

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Stretch Indicator");
    indicator:description("EMA Template");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("Period", "MA Period", "MA Period", 10);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period;
	local first;
	local source = nil;
 
 
	local Indicator;
-- Streams block
    local Stretch = nil;

-- Routine

function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	Data = instance:addInternalStream(0, 0);
	
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();	
	 
     

     
	    Indicator = core.indicators:create("MVA", Data, Period);

        Stretch = instance:addStream("Stretch", core.Line, name, "Stretch", instance.parameters.color, source:first());
    Stretch:setPrecision(math.max(2, instance.source:getPrecision()));
		Stretch:setWidth(instance.parameters.width);
        Stretch:setStyle(instance.parameters.style);
   
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)



        if period < source:first()  then
		return;
		end
		
        Data[period]=math.max(math.abs(source.open[period]- source.high[period]), math.abs(source.open[period]- source.low[period])  );
	
	   
		
		if period < source:first() +Period then
		return;
		end
		
		
		Indicator:update(mode); 	
		 
    
	    if Indicator.DATA:hasData(period) then
        Stretch[period] =Indicator.DATA[period];
		end
  
end
 


