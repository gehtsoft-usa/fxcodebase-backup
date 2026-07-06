-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62211

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
 
function Init()
    indicator:name("Two Indicator Generic Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	

    indicator.parameters:addGroup("1. Indicator Selection");	
	indicator.parameters:addString("INDICATOR1", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR1",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number1", "Data Stream Number", "", 1, 1 , 100);
	
    indicator.parameters:addGroup("2. Indicator Selection");	
	indicator.parameters:addString("INDICATOR2", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR2",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number2", "Data Stream Number", "", 1, 1 , 100);
		

 

    indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("Up", "Up  Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128)); 
 
 
   
   
end 

 
local Number1;
local INDICATOR1;
local Number2;
local INDICATOR2;

local FIRST=1;
local source;

local Indicator1= nil;
local Count1; 
local INDEX1;

local Indicator2= nil;
local Count2; 
local INDEX2;

local Up,Down,Neutral;
local first; 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;


function Prepare(nameOnly)
 
    source = instance.source;	
	 

    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name );
	if nameOnly then
		return;
	end
	
	 
	 
    INDICATOR1=instance.parameters.INDICATOR1;    
   	Number1=instance.parameters.Number1;
	Number1=Number1-1;
	
	
	INDICATOR2=instance.parameters.INDICATOR2;    
   	Number2=instance.parameters.Number2;
	Number2=Number2-1;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	 
			 
 
	
		local iprofile1 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR1"));
		local iparams1 = instance.parameters:getCustomParameters("INDICATOR1");
		
		local iprofile2 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR2"));
		local iparams2 = instance.parameters:getCustomParameters("INDICATOR2");
		

		if  iprofile1:requiredSource() == core.Tick then			
			Indicator1 = iprofile1:createInstance( source.close, iparams1);
		else
			Indicator1 = iprofile1:createInstance(source, iparams1);
		end
		
		
		if  iprofile2:requiredSource() == core.Tick then			
			Indicator2 = iprofile2:createInstance( source.close, iparams2);
		else
			Indicator2 = iprofile2:createInstance(source, iparams2);
		end
	
	 Count1= Indicator1:getStreamCount ();
	 Count2= Indicator2:getStreamCount ();
	 
	 if Number1 >= Count1 then
	 Number1 = Count1;
	  assert( false, "Incorrect index of stream. The indicator has only ".. Count1  .. " stream(s).");
	 end	 
	 
	 
	  if Number2 >= Count2 then
	 Number2 = Count2;
	  assert( false, "Incorrect index of stream. The indicator has only ".. Count2  .. " stream(s).");
	 end	 
	 
	 
	INDEX1=  Indicator1:getStream (Number1);	
	INDEX2=  Indicator2:getStream (Number2);			

 
    FIRST=math.max(INDEX1:first(),INDEX2:first() );

 	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), FIRST);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), FIRST);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), FIRST);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), FIRST);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end



function Update(period, mode)

    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	if period < FIRST then
	open:setColor(period,  Neutral);
	return;
	end
	

   Indicator1:update(mode);
   Indicator2:update(mode);	
	          
				
										
												 
														if INDEX1[period]>  INDEX2[period] then
														open:setColor(period,  Up);
														elseif  INDEX1[period]<  INDEX2[period] then
														open:setColor(period,  Down);
														else
														open:setColor(period,  Neutral);
														end
										 
									         	     			
				
	
end
 
