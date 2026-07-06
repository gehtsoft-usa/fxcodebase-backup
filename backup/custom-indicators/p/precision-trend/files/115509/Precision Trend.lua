-- Id: 19308


-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65185

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
function Init()
    indicator:name("Precision Trend");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
 

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("avgPeriod", "Average period", "", 30);
    indicator.parameters:addDouble("sensitivity", "Sensitivity", "", 3);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
   local sensitivity;
   local avgPeriod;
 
local first;
local source = nil;
  
-- Streams block
local OUT = nil;
 local Work={};
 
local range = 1;
local trend = 2;
local avg   = 3;
local avgd  = 4;
local avgu  = 5;
local minc  = 6;
local maxc  = 7;
 
 
local MA;
-- Routine
function Prepare(nameOnly)
    sensitivity = instance.parameters.sensitivity;
    avgPeriod = instance.parameters.avgPeriod;
    source = instance.source;
   
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. sensitivity .. ", " .. avgPeriod .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
	
	 for i= 1, 7, 1 do
	 Work[i]= instance:addInternalStream(first, 0);
	 end
	 
	MA= core.indicators:create("MVA", Work[range], avgPeriod);
   
    OUT = instance:addStream("OUT", core.Bar, name .. ".Super Trend", "Super Trend", instance.parameters.UP_color, first);    
    OUT:addLevel(0);
	OUT:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
 
    OUT[period] = 1;
	
    if period <first then
	return;
	end
	
	 PrecisionTrend(period, mode);
    
   	if Work[trend][period] == 1 then
	OUT:setColor(period, instance.parameters.UP_color); 
	elseif Work[trend][period] == -1 then
	OUT:setColor(period, instance.parameters.DN_color); 	
	end
	
end

function PrecisionTrend (period,mode)

Work[range][period]=  source.high[period]-source.low[period];

MA:update(mode);
if period< MA.DATA:first() then
return;
end


Work[avg][period]=  MA.DATA[period]*sensitivity;

if  period == MA.DATA:first() then


Work[trend][period]= 0;
Work[avgd][period]=   source.close[period]-Work[avg][period] ;
Work[avgu][period]=   source.close[period]+Work[avg][period];
Work[minc][period]=   source.close[period];
Work[maxc][period]=   source.close[period];

else 

Work[trend][period]= Work[trend][period-1];
Work[avgd][period]=  Work[avgd][period-1];
Work[avgu][period]=  Work[avgu][period-1];
Work[minc][period]=  Work[minc][period-1];
Work[maxc][period]=  Work[maxc][period-1];
end

local switch=Work[trend][period-1];

if switch== 0 then

if source.close[period]> Work[avgu][period-1] then

                        Work[minc][period]  = source.close[period];
                        Work[avgd][period] =  source.close[period]-Work[avg][period];
                        Work[trend][period] =  1;

elseif source.close[period]< Work[avgd][period-1] then
                        Work[maxc][period]  = source.close[period];
                        Work[avgd][period] =  source.close[period]+Work[avg][period];
                        Work[trend][period] =  -1;
end


elseif switch== 1 then
                       
                       Work[avgd][period]= Work[minc][period-1]-Work[avg][period]
					   if source.close[period]> Work[minc][period-1] then  Work[minc][period] =source.close[period]  end

					    if  source.close[period]< Work[avgd][period-1] then
						 Work[maxc][period]=source.close[period];
						 Work[avgu][period]=source.close[period]+Work[avg][period]
						 Work[trend][period]=-1;
						end 
elseif switch== -1 then                  
			  
					  Work[avgu][period]=Work[maxc][period-1]+Work[avg][period];
					  if source.close[period]< Work[maxc][period-1] then  Work[maxc][period] =source.close[period]  end

					    if  source.close[period]> Work[avgu][period-1] then
						Work[minc][period]=source.close[period];
						 Work[avgu][period]=source.close[period]-Work[avg][period]
						 Work[trend][period]=1;
						end 
end


end

