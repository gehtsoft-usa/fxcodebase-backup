-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=61802

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
    indicator:name("Volume Divergence Markers");
    indicator:description("Volume Divergence Markers");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Volume", "Continuous Volume", "Continuous Volume", 2);
    indicator.parameters:addInteger("Price", "Continuous Price", "Continuous Price", 2);
    indicator.parameters:addBoolean("Live", "Live", "Live", false);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color of Label", "Color of Label", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "Font Size",15);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Volume;
local Price;
local Live;

local first;
local source = nil;
local Size, font;
local color;

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end
	   
 

-- Routine
function Prepare(nameOnly)
    Volume = instance.parameters.Volume;
    Price = instance.parameters.Price;
    Live = instance.parameters.Live;
	Size= instance.parameters.Size;
	color= instance.parameters.color;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Volume) .. ", " .. tostring(Price) .. ", " .. tostring(Live) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

     font  = core.host:execute("createFont", "Wingdings", Size, false, false);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period < first or not  source:hasData(period) then
	return;
	end
	
	if not Live and period == source:size()-1 then 
	return;
	end
	
	  local dir= CalculatePrice (period )
	
	  if  dir == nil then
	  core.host:execute ("removeLabel", source:serial(period));
	  return;
	  end
	  
	  
	    if   CalculateVolume (period,dir) then
		    
           core.host:execute("drawLabel1", source:serial(period), source:date(period),core.CR_CHART, source.close[period] , core.CR_CHART, core.H_Center, core.V_Center,   font , color, "\108"); 
		else
            core.host:execute ("removeLabel", source:serial(period));		
		end
end

function  CalculatePrice(X )

    local up=0;
	local down=0;
	
    for period= X, X-Price+1, -1 do
		 if math.abs(source.open[period]-source.close[period])>math.abs(source.open[period-1]-source.close[period-1]) then
		 up=up+1;
		 end
	end
 
    for period= X, X-Price+1, -1 do
		if math.abs(source.open[period]-source.close[period])< math.abs(source.open[period-1]-source.close[period-1]) then
		down=down+1;
		end
	end
 
   
   if(Price==up) then
      return true;
   elseif(Price==down) then
       return false;
    else
       return nil;	
   end	  
end
  
  

function  CalculateVolume(X,dir)
   
   local counter=0;

   if(dir==true) then
         for period= X, X-Volume+1, -1 do
		     if source.volume[period]<  source.volume[period-1] then
			 counter= counter+1; 
			 end
		end
   elseif(dir==false) then
        for period= X, X-Volume+1, -1 do    
		     if source.volume[period]>  source.volume[period-1] then
			 counter= counter+1;  
			 end 
		end
    end
   if(counter==Volume) then
      return true;
   else
      return false;
   end
 
end

