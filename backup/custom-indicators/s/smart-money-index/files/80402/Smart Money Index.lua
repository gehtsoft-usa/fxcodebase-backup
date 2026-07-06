-- Id: 9532
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=52933

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
    indicator:name("Smart Money Index ");
    indicator:description("Smart Money Index ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   indicator.parameters:addGroup("Calculation"); 
   indicator.parameters:addInteger("open", "Open Hour", "", 3, 0, 23);
   indicator.parameters:addInteger("Length", "Length of Session", "", 8);
   indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SMI_color", "Color of SMI", "Color of SMI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;

-- Streams block
local SMI = nil; 
local open, Length;



-- Routine
 function Prepare(nameOnly)  

    open = instance.parameters.open;
	Length = instance.parameters.Length;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(open).. ", " .. tostring(Length) .. ")";
    instance:name(name);
	
	
    if   (nameOnly) then
        return;
    end
	

	 assert(source:barSize()== "H1", "Time Frame must be Set to H1.");
	
   
        SMI = instance:addStream("SMI", core.Line, name, "SMI", instance.parameters.SMI_color, first);
    SMI:setPrecision(math.max(2, instance.source:getPrecision()));
		SMI:setWidth(instance.parameters.width);
        SMI:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
		
			
		 local date = source:date(period);       -- bar date;
		local sfrom, sto;
		 
		local t;
		t = math.floor(date * 86400 + 0.5);     -- date/time in seconds
		
		t = t - open * 3600;
		t = math.floor(t / 86400 + 0.5) * 86400;	 
		t = t + open * 3600;

		sfrom = t;                          -- begin of the session
		sto = sfrom +Length * 3600;   -- end of the session

		sfrom = sfrom / 86400;
		sto = sto / 86400;		
		
		local X1= core.findDate (source, sfrom, false);
		local X2= core.findDate (source, sto, false);
		
		if period == X1 or period == X2 then
        SMI[period] = SMI[period-1] - (source.close[X1]-source.open[X1]) +(source.close[X2]-source.open[X2]) ;
		else
		SMI[period] = SMI[period-1];
		end
   
end

