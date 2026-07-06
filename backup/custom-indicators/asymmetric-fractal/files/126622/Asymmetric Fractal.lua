-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68523

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


function Init()
    indicator:name("Advanced fractal");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Right", "Number of fractals  (Right) ", "Number of fractals", 2, 0,99);
	indicator.parameters:addInteger("Left", "Number of fractals  (Left) ", "Number of fractals", 2, 0,99);
    
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
end

local source;
local up, down;
local Left, Right;
local Size;
local first;

function Prepare()
   
	
    Size = instance.parameters.Size;
	
	Left = instance.parameters.Left;
	Right = instance.parameters.Right;
	
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
 
    source = instance.source;
	first=source:first()+Left+Right;
  
  local name = profile:id() .. " ( " .. Left.. " , ".. Right  .. " )";
    instance:name(name);
end

function Update(period, mode)
 
 
	period = period-Right;
 
 
    
    if (period < first) then
	return;
	end
	
	 down:setNoData(period);
	 up:setNoData(period);
	

	    local test1=true;
        local test2=true;    
	
		
		
         for i= 1, Left, 1 do
		
		     if  source.high[period] < source.high[period-i] then
			 test1=false;
			 end
			
		 end	
		 
		 for i= 1, Right, 1 do
		
		     if  source.high[period] < source.high[period+i]  then
			 test1=false;
			 end
			
		 end
		 
		 if test1 and test2 and  ( source.high[period] ~=  source.high[period-1]) then
		   up:set(period, source.high[period], "\226");
		 end

        test1=true; 
		test2=true; 
		
		
        for i= 1, Left, 1 do
		
		     if source.low[period] > source.low[period-i] then
			 test1=false;
			 end
			
		 end	
		 
		 
		  for i= 1, Right, 1 do
		
		     if  source.low[period] > source.low[period+i]  then
			 test2=false;
			 end
			
		 end
	   
	      if test1 and test2  and  ( source.low[period] ~=  source.low[period-1]) then
	      down:set(period, source.low[period], "\225");
		  end
        
 
end
