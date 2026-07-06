-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=25131
-- Id: 7787

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

-- Indicator profile initialization routine
-- If the current bars of AC and AO are green, it shows that the zone is green.
-- If the current bars of �� and �� red, it shows that the zone is red.
-- If the bars of AC and AO are differently directed then the bar is colored grey (grey zone).
function Init()
    indicator:name("MA Sequence");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector"); 
	indicator.parameters:addBoolean("Use1" , "Use 1. Filter"  , "", true); 
	indicator.parameters:addBoolean("Use2" , "Use 2. Filter"  , "", true); 
	indicator.parameters:addBoolean("Use3" , "Use 3. Filter"  , "", true); 
	
	
    Add(1, "EMA", 10);
	Add(2,"EMA", 20);
	Add(3,"EMA", 50);
	Add(4,"EMA", 200);
	
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(255, 128, 0));

	
end

function Add(id, M, P)

    indicator.parameters:addGroup(id.. ". MA Calculation"); 
	
    indicator.parameters:addInteger("Period"..id , "Period", "", P);
	
	indicator.parameters:addString("Method"..id, "MA Method", "Method" , M);
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");

end



-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Up, Down, No;
local Period={};
local Method={};
local Use={};
local first;
local source = nil;

-- Streams block
local Top = nil;
local Bottom = nil;

local indicator={};

-- Routine
function Prepare(nameOnly)
 
    source = instance.source;
   Up=instance.parameters.Up;
   Down=instance.parameters.Down;
   No=instance.parameters.No;
   
    local name = profile:id() .. "," .. source:name() ;
	
	Use[3]=instance.parameters.Use3;
	Use[2]=instance.parameters.Use2;
	Use[1]=instance.parameters.Use1;
   
   local i;
   
    for i= 1, 4, 1 do
        Method[i]=instance.parameters:getString("Method" .. i);
        Period[i]=instance.parameters:getInteger("Period" .. i);
        if not nameOnly then
    assert(core.indicators:findIndicator(Method[i]) ~= nil, Method[i] .. " indicator must be installed");
            indicator[i] = core.indicators:create(Method[i], source, Period[i]);
        end
      
        name= name.. "(" .. i.. ". MA - " .. Method[i] .. "," .. Period[i] ..")" ;
    end

    instance:name(name);
    if nameOnly then
        return;
    end
   
   first = math.max(  indicator[1].DATA:first(), indicator[2].DATA:first(), indicator[3].DATA:first(),indicator[4].DATA:first()  );	
  
   Top = instance:addStream("Top", core.Line, name, "", No, first); 
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
   Bottom= instance:addStream("Bottom", core.Line, name, "", No, first); 
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
   instance:createChannelGroup ("ZONE", "ZONE", Top, Bottom,  No, 100)
	
	 if onlyName then
        return ;
    end
	
end

-- Indicator calculation routine
function Update(period, mode)

   Top[period]=1;
   Bottom[period]=0;



    indicator[1]:update(mode);
    indicator[2]:update(mode);
	indicator[3]:update(mode);
    indicator[4]:update(mode);
    
	Top:setColor(period, No);
 
	if period < first  or not source:hasData(period) then	
    return;
    end 

			
      
				if ( indicator[1].DATA[period]	> indicator[2].DATA[period]	 or not  Use[1]	)
				and ( indicator[2].DATA[period]	> indicator[3].DATA[period]	 or not  Use[2]	)
				and ( indicator[3].DATA[period]	> indicator[4].DATA[period]	 or not  Use[3] )
				and ( Use[1] or Use[2] or Use[3]  )
				then 	
				Top:setColor(period, Up);
				elseif ( indicator[1].DATA[period]	< indicator[2].DATA[period]  or not  Use[1]	)
				and ( indicator[2].DATA[period]	< indicator[3].DATA[period]	  or not  Use[2] )	
				and ( indicator[3].DATA[period]	< indicator[4].DATA[period]  or not  Use[3]	)
                and ( Use[1] or Use[2] or Use[3])				
				then
				Top:setColor(period, Down);	
				else
				Top:setColor(period, No);
				end
		
				  
end

