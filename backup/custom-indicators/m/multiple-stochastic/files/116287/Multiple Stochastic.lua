-- Id: 19863

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65415

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Generic Tick Based Stochastic");
    indicator:description("Generic Tick Based Stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector");
   indicator.parameters:addBoolean("Show_K", "Show K Line", "", true);	 
   indicator.parameters:addBoolean("Show_D", "Show D Line", "", false);	
   
   Add(1, 5,3,3);
   Add(2, 12,3,3);
   Add(3, 25,3,3);
   Add(4, 50,3,3);
   Add(5, 100,3,3);

   
   AddStyle(1,  core.rgb(0, 255, 0),  core.rgb(255, 0, 0));
   AddStyle(2,  core.rgb(0, 255, 0),  core.rgb(255, 0, 0));
   AddStyle(3,  core.rgb(0, 255, 0),  core.rgb(255, 0, 0));
   AddStyle(4,  core.rgb(0, 255, 0),  core.rgb(255, 0, 0));
   AddStyle(5,  core.rgb(0, 255, 0),  core.rgb(255, 0, 0));  
	
end

function AddStyle(id, Color1,Color2)

    indicator.parameters:addGroup(id .. ". Line Style");
    indicator.parameters:addColor("color1"..id, "%K line color", "The color of the %K line.", Color1);
    indicator.parameters:addColor("color2"..id, "%D line color", "The color of the %D line.", Color2);
	
	indicator.parameters:addInteger("width"..id, "Line width", "", id, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);
	
end	
	

function Add(id,K,SD,D, MVAT_K, MVAT_D)

    indicator.parameters:addGroup(id .. ". Line");

    indicator.parameters:addInteger("K"..id, "Stochastic Period", "Stochastic Period", K, 2,  100000);
    indicator.parameters:addInteger("SD"..id, "Smoothing period for %K", "Smoothing period for %K", SD, 1, 100000);
    indicator.parameters:addInteger("D"..id, "Smoothing period for %D", "Smoothing period for %D", D, 2, 100000);

    indicator.parameters:addString("MVAT_K"..id, "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "MetaTrader", "The MetaTrader algorithm.", "MT");
    
    indicator.parameters:addString("MVAT_D"..id, "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D"..id, "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D"..id, "EMA", "EMA", "EMA");
	
end

local Flag;
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local K={};
local D={};

local Show_K, Show_D;

local source = nil; 
-- Streams block
local Stochastic = {};
 
function Prepare(nameOnly) 
 
    source = instance.source;
	
	Show_K=instance.parameters.Show_K;
	Show_D=instance.parameters.Show_D;
	 
    Flag=true;
	
    local name = profile:id() .. "(" .. source:name().. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
   for i= 1, 5, 1 do
        Stochastic[i] = core.indicators:create("STOCHASTIC", source, instance.parameters:getInteger("K" .. i), instance.parameters:getInteger("SD" .. i) , instance.parameters:getInteger("D" .. i), instance.parameters:getString("MVAT_K" .. i), instance.parameters:getString("MVAT_D" .. i));
        
		if Show_K then
		K[i] = instance:addStream("K"..i, core.Line, name .. ".K", i ..". K", instance.parameters:getColor("color1" .. i), Stochastic[i].K:first());      
    K[i]:setPrecision(math.max(2, instance.source:getPrecision()));
        K[i]:setWidth(instance.parameters:getInteger("width" .. i));
        K[i]:setStyle(instance.parameters:getInteger("style" .. i));
		else
		K[i]= instance:addInternalStream(Stochastic[i].K:first(), 0);
		end
		
		if Show_D then
	    D[i]= instance:addStream("D"..i, core.Line , name .. ".D", i.. ". D", instance.parameters:getColor("color2" .. i), Stochastic[i].D:first());
    D[i]:setPrecision(math.max(2, instance.source:getPrecision()));
        D[i]:setWidth(instance.parameters:getInteger("width" .. i));
        D[i]:setStyle(instance.parameters:getInteger("style" .. i));
		else
		D[i]= instance:addInternalStream(Stochastic[i].D:first(), 0);
		end
    
	 if Flag then
	 Flag=false;
	 D[i]:addLevel(20);
     D[i]:addLevel(80);
	 end
	
    end

end

-- Indicator calculation routine
function Update(period, mode)
 
 
     for i= 1, 5, 1 do
	 Stochastic[i]:update(mode);
		 if Stochastic[i].K:hasData(period) then
		 K[i][period]=Stochastic[i].K[period];
		 end
		 if Stochastic[i].D:hasData(period) then
		 D[i][period]=Stochastic[i].D[period];
		 end	 
		 end
	 
end

