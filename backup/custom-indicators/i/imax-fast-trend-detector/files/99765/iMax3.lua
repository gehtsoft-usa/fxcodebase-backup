-- Id: 13974
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62103

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("iMAX3");
    indicator:description("iMAX3");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addDouble("Ph1stepHPmodes", "Ph1stepHPmodes", "", 0);	  
	indicator.parameters:addBoolean("hpMode", "hpMode", "", true);	 
	indicator.parameters:addBoolean("hpxMode", "hpxMode", "", true);
    indicator.parameters:addBoolean("iMAXmode", "iMAXmode", "", true);	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("hpx0_color", "Color of hpx0", "Color of hpx0", core.rgb(0, 255, 0));
	indicator.parameters:addColor("hpx1_color", "Color of hpx1", "Color of hpx1", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("hp0_color", "Color of hp0", "Color of hp0", core.rgb(255, 128, 0));
	indicator.parameters:addColor("hp1_color", "Color of hp1", "Color of hp1", core.rgb(255, 128, 192));
	
	indicator.parameters:addColor("iMAX0_color", "Color of iMAX0", "Color of iMAX0", core.rgb(128,128,128));
	indicator.parameters:addColor("iMAX1_color", "Color of iMAX1", "Color of iMAX1", core.rgb(0, 0, 255));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local hpMode = nil;
local hpxMode=nil;
local Ph1stepHPmodes;
local Ph1step; 
local hp0, hp1;
local iMAX0, iMAX1;
local hpx0, hpx1;
local iMAXPhases, iMAXmode;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+3;
	Ph1stepHPmodes = instance.parameters.Ph1stepHPmodes;
	hpxMode = instance.parameters.hpxMode;
	hpMode = instance.parameters.hpMode; 
	iMAXPhases = instance.parameters.iMAXPhases;
	iMAXmode = instance.parameters.iMAXmode;
	
	local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	        if(hpxMode) then 		     
			hpx0  = instance:addStream("hpx0", core.Line, name, "hpx0", instance.parameters.hpx0_color, first);
    hpx0:setPrecision(math.max(2, instance.source:getPrecision()));
	        hpx1  = instance:addStream("hpx1", core.Line, name, "hpx1", instance.parameters.hpx1_color, first);
    hpx1:setPrecision(math.max(2, instance.source:getPrecision()));
		    else
			hpx0 = instance:addInternalStream(0, 0);
	        hpx1 = instance:addInternalStream(0, 0);
			end
    
     
     
      if(hpMode) then
       hp0   = instance:addStream("hp", core.Line, name, "hp0", instance.parameters.hp0_color, first);
    hp0:setPrecision(math.max(2, instance.source:getPrecision()));
	   hp1  = instance:addStream("hp1", core.Line, name, "hp1", instance.parameters.hp1_color, first);
    hp1:setPrecision(math.max(2, instance.source:getPrecision()));
      else 
	   hp0 = instance:addInternalStream(0, 0);
	   hp1 = instance:addInternalStream(0, 0);
	  end
	  
    

  
    if iMAXmode  then
     
     iMAX0  = instance:addStream("iMAX0", core.Line, name, "iMAX0", instance.parameters.iMAX0_color, first);
    iMAX0:setPrecision(math.max(2, instance.source:getPrecision()));
	 iMAX1   = instance:addStream("iMAX1", core.Line, name, "iMAX1", instance.parameters.iMAX1_color, first);
    iMAX1:setPrecision(math.max(2, instance.source:getPrecision()));
     
     else
     iMAX0 = instance:addInternalStream(0, 0);
	 iMAX1 = instance:addInternalStream(0, 0);
     end
	
 
		 
		  if(Ph1stepHPmodes==0.0) then 
				  if source:barSize() == "m1" then
				  Ph1step=0.0001;
				   elseif source:barSize() =="m5" then
				   Ph1step = 0.00015;
				   elseif source:barSize() =="m15" then
				   Ph1step = 0.0003;
				   elseif source:barSize() =="m30" then
				   Ph1step = 0.0005;
				   elseif source:barSize() =="H1" then
				   Ph1step = 0.00075;				
				   elseif source:barSize() =="H4" then
				   Ph1step = 0.0015;
				   elseif source:barSize() == "D1" then
				   Ph1step = 0.003;
				   elseif source:barSize() =="W1" then
				   Ph1step = 0.005;
				   elseif source:barSize() == "M1" then
				   Ph1step = 0.01;
				   else
				   Ph1step =Ph1stepHPmodes;
				   end
			 
		  else
			 Ph1step=Ph1stepHPmodes; 
		  end	
     
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	      
		-- HPX
		
         hpx1[period]=(0.13785 *(2 *source.median[period] -source.median[period-1]))
                 + (0.0007  * (2 * source.median[period-1] - source.median[period-2]))
                 + (0.13785 * (2 * source.median[period-2] - source.median[period-3]))
                 + (1.2103  * hpx0[period- 1] - 0.4867 * hpx0[period - 2]);
         if(source.close[period]>hpx1[period]) then
            hpx0[period]=hpx1[period]+Ph1step; 
		 end
         if(source.close[period]<hpx1[period]) then
           hpx0[period]=hpx1[period]-Ph1step;
		  end 
     
	 
	    -- IMAX
	 
         iMAX0[period]=(0.13785 *(2 *source.median[period] -source.median[period-1]))
                  + (0.0007  * (2 * source.median[period-1] - source.median[period-2] ))
                  + (0.13785 * (2 * source.median[period-2] -source.median[period-3] ))
                  + (1.2103  * iMAX0[period- 1] - 0.4867 * iMAX0[period - 2]);
         xhp0=iMAX0[period];
         iMAX1[period]=iMAX0[period-1];
      

         --XHP
         local  xhp1;
         if(source.close[period]>iMAX0[period]) then
            xhp1=iMAX0[period]+Ph1step; 
		 end  
         if(source.close[period]<iMAX0[period]) then
            xhp1=iMAX0[period]-Ph1step; 
		  end 
         hp0[period]=xhp1;
		 hp1[period]=xhp0;
       
    
end

