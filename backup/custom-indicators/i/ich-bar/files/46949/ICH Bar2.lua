-- Id: 7969
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
    indicator:name("ICH Bar");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("TenkanSenPeriod", "Tenkan-sen period", "Tenkan-sen period", 9, 1, 1000);
    indicator.parameters:addInteger("KijunSenPeriod", "Kijun-sen period", "Kijun-sen period", 26, 1, 1000);
    indicator.parameters:addInteger("SenkouSpanPeriod", "Senkou Span B period", "Senkou Span B period", 52, 1, 1000);

	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("Up", "Color for Up Trend", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Up2", "Color for Up Trend 2", "", core.rgb(128, 255, 255));
	 indicator.parameters:addColor("Up3", "Color for Up Trend 3", "", core.rgb(128, 128, 255));
    indicator.parameters:addColor("Dn", "Color for Down Trend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Dn2", "Color for Down Trend 2", "", core.rgb(255, 128, 0));
    indicator.parameters:addColor("Dn3", "Color for Down Trend 3", "", core.rgb(128, 0, 128));
	 indicator.parameters:addColor("No", "Color for No Trend", "", core.rgb(255, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local Short={};

-- Streams block
local Indicator;
local Out = nil;
local Zero;
-- Routine
function Prepare(nameOnly)

	Type = instance.parameters.Type;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ")";
	 name = name .. ", " ..  instance.parameters.TenkanSenPeriod .. ", " .. instance.parameters.KijunSenPeriod .. ", " .. instance.parameters.SenkouSpanPeriod ;    
    instance:name(name);
	
	 Indicator = core.indicators:create("ICH", source,  instance.parameters.TenkanSenPeriod , instance.parameters.KijunSenPeriod , instance.parameters.SenkouSpanPeriod);

	Short["SL"] = Indicator:getStream(0);
	Short["TL"] = Indicator:getStream(1);
	Short["CS"] = Indicator:getStream(2);
	Short["A"] = Indicator:getStream(3);
	Short["B"] = Indicator:getStream(4);
	
	first= math.max(Short["A"]:first(), Short["B"]:first(), Short["SL"]:first(), Short["TL"]:first(),  Short["CS"]:first()) ;
	
	 

    if (not (nameOnly)) then
        Out = instance:addStream("Out", core.Bar, name, "Out", instance.parameters.Up, first);
		Zero = instance:addStream("Zero", core.Line, name, "Zero", instance.parameters.Up, first); 
    	Out:setPrecision(math.max(2, instance.source:getPrecision()));
	    Zero:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < period or  not source:hasData(period) then
	return;
	end
	Zero[period]=0;
	
	 Indicator:update(mode);
	 local CS_Size = Short["CS"]:size()-1;
	
	 
	  Out[period] = 1;
	 
	 if period<=CS_Size and Short["CS"][period]>Short["B"][period-instance.parameters.KijunSenPeriod]+Short["SL"][period] and Short["B"][period-instance.parameters.KijunSenPeriod]+Short["SL"][period]>Short["TL"][period] and Short["TL"][period]>Short["B"][period] then
	  Out:setColor(period, instance.parameters.Up2);  
	 elseif period<=CS_Size and Short["CS"][period]<Short["B"][period-instance.parameters.KijunSenPeriod]+Short["SL"][period] and Short["B"][period-instance.parameters.KijunSenPeriod]+Short["SL"][period]<Short["TL"][period] and Short["TL"][period]<Short["B"][period] then
	  Out:setColor(period, instance.parameters.Dn2);   
	 elseif source.close[period]>Short["SL"][period] and Short["SL"][period]>Short["TL"][period] and Short["TL"][period]>Short["B"][period] then
	  Out:setColor(period, instance.parameters.Up3);   
	 elseif source.close[period]<Short["SL"][period] and Short["SL"][period]<Short["TL"][period] and Short["TL"][period]<Short["B"][period] then
	  Out:setColor(period, instance.parameters.Dn3);   
	 elseif Short["SL"][period] > Short["TL"][period] 
	 and  Short["TL"][period] > Short["B"][period] 
	 then
	  Out:setColor(period, instance.parameters.Up);  
	 elseif Short["SL"][period] < Short["TL"][period] 
	 and  Short["TL"][period] < Short["B"][period] 
	 then
	  Out:setColor(period, instance.parameters.Dn);  
	 else
	  Out:setColor(period, instance.parameters.No);  
	 end
	
       
    
end

