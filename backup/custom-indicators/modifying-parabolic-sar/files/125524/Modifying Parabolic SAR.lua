
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68291

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Modifying Parabolic SAR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("xo_inc", "xo_inc", "", 3.25);
    indicator.parameters:addDouble("AF_start", "AF_start", "", 0.06);
	indicator.parameters:addDouble("AF_inc", "AF_inc", "", 0.04);
	indicator.parameters:addDouble("AF_max", "AF_max", "", 1.0);
	
	
	
	
 
	 

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUp", "Up Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrDown", "Down Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first;
local source = nil;
local Position;

-- Streams block
local SAR = nil;

local xo_inc, AF_start, AF_inc,AF_max;

local Xhi, Xlo;

 local AF;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first(); 	
	
	xo_inc=instance.parameters.xo_inc*source:pipSize();
	AF_start=instance.parameters.AF_start ; 
	AF_inc=instance.parameters.AF_inc ; 
	AF_max=instance.parameters.AF_max ; 

    local name = profile:id() .. "(" .. source:name() .. "," .. xo_inc .. "," .. AF_start.. "," .. AF_inc.. "," .. AF_max.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
 
    Xhi	 = instance:addInternalStream(0, 0);
	Xlo = instance:addInternalStream(0, 0);
 
	
	Position= instance:addInternalStream(0, 0);
	
    --Signal = instance:addInternalStream(0, 0);
	
	AF = instance:addInternalStream(0, 0);
 
	
	SAR = instance:addStream("UP", core.Dot, name .. ".Up", "UP", instance.parameters.clrUp, first);
    SAR:setWidth(instance.parameters.width);
  
end

-- Indicator calculation routine
function Update(period)



 Position [period]=Position [period-1];
 Xhi[period]=Xhi [period-1];
 Xlo[period]=Xlo[period-1];
 AF[period]=AF[period-1];

 if period == source:first() then
 Position [period] = 1;
 AF[period]=AF_start;
 Xhi[period]= source.high[period];  
 Xlo[period]= source.low[period];  
 SAR[period]=source.close[period];

 
 else  
	 if source.high[period] > Xhi[period] then Xhi[period] = source.high[period]; end
	 if source.low[period] < Xlo[period] then Xlo[period] = source.low[period];  end
	  
	 
	  if Position[period] == 1 then    
		 if source.low[period] <= (SAR[period-1]-xo_inc) then
		 Position[period] = -1;  
		 end	 
	 else 
		 if source.high[period] >= (SAR[period-1]+xo_inc)  then
		 Position[period] = 1;  
		 end 
	 end
 
 end
 
 
 
 
 


 local thi,tlo;
 
  if Position[period] == 1 then
	 if Position[period-1] ~= 1  then     
		 SAR[period] = Xlo[period];    
		 AF[period] = AF_start; 
		 Xlo[period] = source.low[period];
		 Xhi[period] = source.high[period]; 
	  
	 else 
		 SAR[period] = SAR[period-1]+AF[period]*( Xhi[period]-SAR[period-1]); 
		 if Xhi[period] > Xhi[period-1] and AF[period] < AF_max then  AF[period] = AF[period-1]+AF_inc;  end
		 if AF[period] > AF_max then  AF[period]=AF_max;   end
	 end
	 
	 tlo=source.low[period]; 
	 if source.low[period-1] < source.low[period] then  tlo=source.low[period-1]; end
	 if tlo < SAR[period-1] then  tlo=SAR[period-1]; end 
	 if SAR[period] > tlo then  SAR[period]=tlo; end
 
 
 else
 
	 if Position[period-1] ~=-1 then 
	  
	 SAR[period] = Xhi[period]; 
	 AF[period] = AF_start;   
	 Xlo[period] =source.low[period];   
	 Xhi[period] = source.high[period];   
	 
	 else 
	 
	 SAR[period] = SAR[period-1]+AF[period]*(Xlo[period]-SAR[period-1]); 
	 if Xlo[period] < Xlo[period-1] and AF[period] < AF_max then  AF[period] = AF[period-1]+AF_inc; end     
	 if AF[period] > AF_max then AF[period]=AF_max;  end
	 end  
     thi= source.high[period];   
	 if source.high[period-1] < source.high[period] then thi=source.high[period-1];  end
	 if thi > SAR[period-1] then thi=SAR[period-1]; end  
	 if SAR[period] < thi then SAR[period]=thi;  end  
 end
 
 
 
         if Position[period]==1 then
            SAR:setColor(period, instance.parameters.clrDown);
         else 
             SAR:setColor(period, instance.parameters.clrUp);
         end
    
end


