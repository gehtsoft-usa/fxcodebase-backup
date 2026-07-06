-- Id: 1747
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2255

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
    indicator:name("Wide/Narrow Spread");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
    indicator.parameters:addGroup("Parameters");
	indicator.parameters:addInteger("WSBL", "Wide/Narrow Spread Bar Period", "", 4, 0, 1000);
	
	indicator.parameters:addGroup("Show Patern");
	indicator.parameters:addBoolean("On1", "Show Wide Spread Bar", "", true);
	indicator.parameters:addBoolean("On2", "Show Narrow Spread Bar", "", true);

   
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("FontSize", "Font Size", "", 12, 4, 20);
    indicator.parameters:addColor("WColor", "Color for pattern labels", "", core.rgb(0,255,0));
	indicator.parameters:addColor("NColor", "Color for pattern labels", "", core.rgb(255,0,0));
end

local source;


local WSBL;
local ON={};
local Raw;
local Wide,Narrow;
local first;


function Prepare(nameOnly)

    source = instance.source; 
	WSBL  = instance.parameters.WSBL;
		
	first=source:first()+WSBL;
	
  
	
	ON[1]  = instance.parameters.On1;
	ON[2]  = instance.parameters.On2;
      
	
    local name;
    name = profile:id();
	instance:name(name);
	if nameOnly then
		return;
	end
	
	 Raw = instance:addInternalStream(0, 0);

   if ON[1] then 
   Wide = instance:createTextOutput("W", "W", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.WColor, 0);
   end
   if ON[2] then 
   Narrow = instance:createTextOutput("N", "N", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.NColor, 0);
   end 
end


function Update(period)
  
	
    if period >= first then
	Raw[period] = source.high[period] - source.low[period];		
	
		
			if period >  WSBL then		
			   
						 
				if ON[1] then  
						 if core.max(Raw, core.range(period-WSBL,period )) == Raw[period] then
						 Wide:set(period, source.high[period],  "\108","Wide");
						 else
						 Wide:setNoData (period);
						 end
				end		 
				if ON[2] then  		 
						 if core.min(Raw, core.range(period-WSBL,period )) == Raw[period] then
						 Narrow:set(period, source.high[period],  "\108","Narrow");
						 else 
						 Narrow:setNoData (period);
						 end
				 end
			end 
			
    end
  
end
