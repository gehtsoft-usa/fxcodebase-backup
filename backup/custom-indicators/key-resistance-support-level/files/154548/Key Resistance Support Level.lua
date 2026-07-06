-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74652

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+


function Init()
    indicator:name("Key Resistance Support Level");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Selector");	
    indicator.parameters:addBoolean("Confirmation", "Confirmation", "", true);   
    indicator.parameters:addBoolean("Zone", "Zone", "", true);  	
 
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("NumberOf", "Number of fractals)", "Number of fractals", 2, 1,99);
    indicator.parameters:addInteger("ConfirmationPeriod", "Confirmation Period", "Confirmation", 8, 1,99);
    indicator.parameters:addDouble("ZoneWidth", "Zone Width (in Pips)", "Zone Width", 10, 0,20000);	
    
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
end

local source;
local up, down;
local NumberOf,ConfirmationPeriod,Confirmation, Zone, ZoneWidth;
local Size;
local first;

function Prepare()
   
	
    Size = instance.parameters.Size;
	NumberOf = instance.parameters.NumberOf;
	ConfirmationPeriod = instance.parameters.ConfirmationPeriod;
    Confirmation= instance.parameters.Confirmation;
	Zone= instance.parameters.Zone;
	ZoneWidth= instance.parameters.ZoneWidth;
	
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
 
    source = instance.source;
	first=source:first()+NumberOf*2+ConfirmationPeriod;
  
  local name = profile:id() .. " ( " .. NumberOf  .. " )";
    instance:name(name);
end

function Update(period, mode)
 
 
	period = period-math.max(NumberOf,ConfirmationPeriod);
 
 
    
    if (period <= first) then
	return;
	end
	
	 down:setNoData(period);
	 up:setNoData(period);
	

	    local test=true;
 
	
		
		
         for i= 1, NumberOf, 1 do
		
		     if  source.high[period] < source.high[period+i] or  source.high[period] < source.high[period-i] then
			 test=false;
			 end
			
		 end
 
 
        if Confirmation then
			 for i= 1, ConfirmationPeriod, 1 do
			
				 if  source.high[period] < source.high[period+i]   then
				 test=false;
				 end
				
			 end
		end 
		
		
		if Zone then 
		
				 for i= 1, ConfirmationPeriod, 1 do
			
				 if  source.high[period] - ZoneWidth*source:pipSize() < source.high[period+i]   
				 then
				 test=false;
				 end
				
			 end	
		
		end
		
		 
		 
		 if test then
		   up:set(period, source.high[period], "\226");
		 end

        test=true; 
		
        for i= 1, NumberOf, 1 do
		
		     if  source.low[period] > source.low[period+i] or source.low[period] > source.low[period-i] then
			 test=false;
			 end
			
		 end	
        if Confirmation	 then	 
			for i= 1, ConfirmationPeriod, 1 do
			
				 if  source.low[period] > source.low[period+i]   then
				 test=false;
				 end
				
			 end	
         end 	

		if Zone then 
		
			for i= 1, ConfirmationPeriod, 1 do
			
				 if  source.low[period] + ZoneWidth*source:pipSize() > source.low[period+i]   then
				 test=false;
				 end
				
			 end		
		
		end		 
	   
	      if test then
	      down:set(period, source.low[period], "\225");
		  end
        
 
end
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+