-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34020

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
    indicator:name("Up/Down Percentage Trading System");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Buy", "Buy", "Buy", 1);
    indicator.parameters:addDouble("Sell", "Sell", "Sell", 1);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Long", "Open Long Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Short", "Open Short Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Buy;
local Sell;
local Long;
local Short;

local first;
local source = nil;
 local font;
local h_ep, l_ep;
local position;
local sellstop, buystop;
local Size;
-- Routine
function Prepare(nameOnly)
    Buy = instance.parameters.Buy;
    Sell = instance.parameters.Sell;
	Size = instance.parameters.Size;
   
    source = instance.source;
    first = source:first();

	
	Long=1+(Buy/100);
	Short=1-(Sell/100);
	


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Buy) .. ", " .. tostring(Sell) .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	
	 position = instance:addInternalStream(0, 0);
		
	 font = core.host:execute("createFont", "Wingdings", Size, false, false);


  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

  if period< first  then
  return;
  end
  
  
  core.host:execute ("removeLabel", source:serial(period));
  
  
		 if period == first then  
				position[period]=0;
				h_ep=source.high[period];
				l_ep=source.low[period];				
				sellstop=h_ep*Short;
				buystop=l_ep*Long;
			
				
		else
		position[period]=position[period-1];
					if position[period-1] >= 0 then  
							if source.close[period-1] > h_ep then h_ep=source.close[period-1]; end
							sellstop=h_ep*Short;

									if source.close[period] <= sellstop then  
									position[period]=-1;
									l_ep=source.close[period];
									end;
							
					end 
					if position[period-1]<=0 then  
							if source.close[period-1] < l_ep then l_ep=source.close[period-1]; end
							buystop=l_ep*Long;
							
							if source.close[period] >=buystop then  
							position[period]=1;
							h_ep=source.close[period];
					         end 
		end 
end

    if position[period] == 1 
	and  position[period-1] ~=1 
	then
   
       
   core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom,  font, instance.parameters.Long, "\225");
	 
    elseif position[period] == -1 
	and  position[period-1] ~= -1 	 
     then	
	 
	  
     core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,  font, instance.parameters.Short, "\226");
    end
	
	
	
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
   
   end

