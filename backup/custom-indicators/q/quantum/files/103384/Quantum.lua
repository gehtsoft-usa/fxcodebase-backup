-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62888

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

function Init()
    indicator:name("Quantum");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Period", "Period", "Period", 300);
	 indicator.parameters:addBoolean("ReversalOnly", "Trend reversal only", "", true);	
	 indicator.parameters:addBoolean("SignalMode", "SignalMode", "", false);	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0)); 
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
end

local source;
local up, down; 
local Size; 
local Period;
local first;
local Period;
local ReversalOnly;
local Confirmation;
local SignalMode,Signal;
function Prepare(nameOnly)  
    source = instance.source;
	
	
	 local name = profile:id() ;
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    Size = instance.parameters.Size;
	Period = instance.parameters.Period; 
	SignalMode= instance.parameters.SignalMode;
	
	if SignalMode then
	Signal= instance:addStream("Signal", core.Bar, name .. ".Signal", "MA", instance.parameters.UP, 0);
	else
	Signal= instance:addInternalStream(0, 0);
	end
	
	Confirmation = instance:addInternalStream(0, 0);
	
	ReversalOnly = instance.parameters.ReversalOnly;
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	first=source:first()+Period; 
	 
 
end

function Update(period)


       up:setNoData (period);
	   down:setNoData (period);
       Signal[period]=0;
       
       if period < first  then
	   return;
	   end
	  
	   local min,max=mathex.minmax(source,period-Period+1, period);
	  
	   
	   if source.high[period]== max then
        
             Confirmation[period]=1;
			 
			 if  ((ReversalOnly and  Confirmation[period-1]~=1) or not ReversalOnly) then
			 if not SignalMode then
			 down:set(period, source.low[period], "\225");
			 end
			 Signal[period]= 1;
			 end 
        
        elseif  source.low[period]== min   then
             if  ((ReversalOnly and  Confirmation[period-1]~=-1) or not ReversalOnly) then
			 if not SignalMode then
			 up:set(period , source.high[period], "\226");
			 end
			 Signal[period]= -1;
			 end
			 Confirmation[period]=-1;
       else
	        Confirmation[period]=Confirmation[period-1];
       end
	   
		    
	      
	 
end
