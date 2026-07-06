-- Id: 13786
-- More information about this indicator can be found at:
-- http://www.fxcodebase.com/code/viewtopic.php?f=17&t=61997

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
    indicator:name("UNIVERSAL OSCILLATOR");
    indicator:description("UNIVERSAL OSCILLATOR");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("BandEdge", "BandEdge", "BandEdge", 20, 2, 100);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UNIVERSALOSCILLATOR_color", "Color of UNIVERSALOSCILLATOR", "Color of UNIVERSALOSCILLATOR", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local BandEdge;

local first;
local source = nil;

-- Streams block
local UNIVERSALOSCILLATOR = nil;
local WhiteNoise;
local pi, r2,a1,b1,c1,c2,c2;
local Input;
local Filt;
local Peak;
-- Routine
function Prepare(nameOnly)
    BandEdge = instance.parameters.BandEdge;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(BandEdge) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    first = source:first()+2;
	-- SuperSmoother filter 
    -- note: in AFL angles are in radians 
	pi = math.pi; 
	r2 = math.sqrt( 2 ); 
	a1 = math.exp( - r2 * pi / BandEdge ); 
	b1 = 2 * a1 * math.cos( r2 * pi / BandEdge ); 
	c2 = b1; 
	c3 = - a1 * a1; 
	c1 = 1 - c2 - c3; 
	WhiteNoise = instance:addInternalStream(0, 0);
    Input = instance:addInternalStream(0, 0);
	Filt = instance:addInternalStream(0, 0);
	Peak = instance:addInternalStream(0, 0);


    
        UNIVERSALOSCILLATOR = instance:addStream("UNIVERSALOSCILLATOR", core.Line, name, "UNIVERSALOSCILLATOR", instance.parameters.UNIVERSALOSCILLATOR_color, first+1+2);
    UNIVERSALOSCILLATOR:setPrecision(math.max(2, instance.source:getPrecision()));
		UNIVERSALOSCILLATOR:setWidth(instance.parameters.width);
        UNIVERSALOSCILLATOR:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

   
    if period < first or not  source:hasData(period) then
	return;
	end
	
	 WhiteNoise[period] = ( source.close[period] - source.close[period-2] ) / 2;  
	 
	 
    Input[period]= ( WhiteNoise[period] + WhiteNoise[period-1] ) / 2; 	
		
	Filt[period]= c1 * Input[period] + c2*Filt[period-1] +c3*Filt[period-2]; 
	
 
	Peak[period] = 0.991*Peak[period-1]
	
	if math.abs(Filt[period]) > Peak[period] then
        Peak[period] = math.abs(Filt[period]);
    end
  
	if Peak[period]~= 0 then
    UNIVERSALOSCILLATOR[period] = Filt[ period ] / Peak[period];
	end
    
end

