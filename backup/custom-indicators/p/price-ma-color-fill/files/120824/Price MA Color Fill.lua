-- Id: 22192
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66607
 

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Price MA Color Fill");
    indicator:description("Price MA Color Fill");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Type", "Overlay Style", "", "PN");
    indicator.parameters:addStringAlternative("Type", "Pozitiv/Negativ", "", "PN");
    indicator.parameters:addStringAlternative("Type", "Slope", "", "S");
	indicator.parameters:addStringAlternative("Type", "Simple Fill", "", "F");
	
	
	
	indicator.parameters:addGroup("Price Calculation");
	
	
 
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	indicator.parameters:addStringAlternative("Price", "HIGH-LOW", "", "HIGH_LOW");	
	
	indicator.parameters:addGroup("1. MA Calculation");
	
	
	indicator.parameters:addBoolean("Show1", "Show 1. MA ", "", true);
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("Period1", "MA Period", "", 50);

	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("2. MA Calculation");
	
	
	indicator.parameters:addBoolean("Show2", "Show 2. MA ", "", true);
	indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("Period2", "MA Period", "", 200);

	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	
	indicator.parameters:addGroup("1. Fill Style");
	
    
    indicator.parameters:addColor("up1", "Pozitiv  Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("down1", "Negativ Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("neutral1", "Neutral Color", "", core.rgb(128, 128, 128))
    indicator.parameters:addInteger("transp1", "Transparency, %", "Transparency, %", 80, 0, 100);
 
	
	indicator.parameters:addGroup("2. Fill Style");
	
    
    indicator.parameters:addColor("up2", "Pozitiv  Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("down2", "Negativ Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("neutral2", "Neutral Color", "", core.rgb(128, 128, 128))
    indicator.parameters:addInteger("transp2", "Transparency, %", "Transparency, %", 80, 0, 100);
	
	

	
 
end

local Price;
local first = 0;
local source = nil;
local Type;
local MA1,Price1;
local MA2,Price2;
local Show1, Show2;

-- initializes the instance of the indicator
function Prepare(nameOnly)
    source = instance.source;   
    first =source:first();
    Type=instance.parameters.Type;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	 
   Show1=instance.parameters.Show1;
   Show2=instance.parameters.Show2;
   Price=instance.parameters.Price;
   
   
   if Show1 then
    assert(core.indicators:findIndicator(instance.parameters.Method1) ~= nil, instance.parameters.Method1 .. " indicator must be installed");
   ma1 = core.indicators:create(instance.parameters.Method1, source[instance.parameters.Price1], instance.parameters.Period1);
   
   
     MA1 = instance:addStream("MA1", core.Line, "MA1", "MA1", core.rgb(0, 0, 0),  ma1.DATA:first()) 
    MA1:setStyle(core.LINE_NONE);

    Price1 = instance:addStream("Price1", core.Line, "Price1", "Price1", core.rgb(0, 0, 0),   ma1.DATA:first()) 
    Price1:setStyle(core.LINE_NONE);
	
    instance:createChannelGroup("Fill1", "1. Fill", MA1, Price1, instance.parameters.up1, 100 - instance.parameters.transp1, true);
	
	
   end
   
   if Show2 then
    assert(core.indicators:findIndicator(instance.parameters.Method2) ~= nil, instance.parameters.Method2 .. " indicator must be installed");
   ma2 = core.indicators:create(instance.parameters.Method2, source[instance.parameters.Price2], instance.parameters.Period2);
   
   
      MA2 = instance:addStream("MA2", core.Line, "MA2", "MA2", core.rgb(0, 0, 0),  ma2.DATA:first()) 
    MA2:setStyle(core.LINE_NONE);

    Price2 = instance:addStream("Price2", core.Line, "Price2", "Price2", core.rgb(0, 0, 0),  ma2.DATA:first()) 
    Price2:setStyle(core.LINE_NONE);
	
    instance:createChannelGroup("Fill2", "2. Fill", MA2, Price2, instance.parameters.up1, 100 - instance.parameters.transp2, true);
	
	
   end
   
  
	
   
 
   
end

-- calculate the value
function Update(period)

    if period < first  then
    return;
	end
	
 
  if Show1 then
  ma1:update(mode);
  end
  
  if Show2 then
  ma2:update(mode);
  end
  
    if Price~= "HIGH_LOW" then
    Price1[period] = source.close[period];
    Price2[period] = source.close[period];
	else
	 if source.close[period]> ma1.DATA[period] then
	 Price1[period] = source.high[period];
	 else
	  Price1[period] = source.low[period];
	 end
     
	 if source.close[period]> ma2.DATA[period] then
	 Price2[period] = source.high[period];
	 else
	  Price2[period] = source.low[period];
	 end
	
	end
	
	
  if Show1 and period >=  ma1.DATA:first() then
  
  
  
   
         
          MA1[period] = ma1.DATA[period];
          
         
		  
		  
		if Type == "PN" then		 
				
				if MA1[period] < Price1[period]  then
				MA1:setColor(period, instance.parameters.up1);
				elseif MA1[period] > Price1[period]  then
				MA1:setColor(period, instance.parameters.down1);
				else
				MA1:setColor(period, instance.parameters.neutral);
				end
        elseif  Type == "S" then
		       
			    if MA1[period] > MA1[period-1] then
				MA1:setColor(period, instance.parameters.up1);
				elseif MA1[period] < MA1[period-1] then
				MA1:setColor(period, instance.parameters.down1);
				else
				MA1:setColor(period, instance.parameters.neutral1);
				end
		       
        end		

		
	 end
	 
	 
	 
	 if Show2 and period >=  ma2.DATA:first() then
  
  
  
   
         
          MA2[period] = ma2.DATA[period]; 
		  
		  
		if Type == "PN" then		 
				
				if MA2[period] < Price2[period] then
				MA2:setColor(period, instance.parameters.up2);
				elseif MA2[period] > Price2[period] then
				MA2:setColor(period, instance.parameters.down2);
				else
				MA2:setColor(period, instance.parameters.neutral2);
				end
        elseif  Type == "S" then
		       
			    if MA2[period] > MA2[period-1] then
				MA2:setColor(period, instance.parameters.up2);
				elseif MA2[period] < MA2[period-1] then
				MA2:setColor(period, instance.parameters.down2);
				else
				MA2:setColor(period, instance.parameters.neutral2);
				end
		       
        end		

		
	 end

	 
end

