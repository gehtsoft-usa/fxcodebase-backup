-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=32688


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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Volume Adjusted Moving Average Bollinger Band");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Price", "CLOSE", "", "close");
	indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
	
    indicator.parameters:addInteger("N", "Number of Periods", "", 20, 1, 10000);
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "", 2.0, 0.0001, 1000.0); 
	
    indicator.parameters:addGroup("Band Style");
    indicator.parameters:addColor("clrBBP", "Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthBBB", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBBB", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBB", core.FLAG_LEVEL_STYLE);
	
    indicator.parameters:addGroup("Average line");
    indicator.parameters:addBoolean("HideAve", "Hide average line", "", false);
    indicator.parameters:addColor("clrBBA", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthBBA", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBBA", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBA", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local D;

local first;
local source = nil;

local Price;

-- Streams block
local TL = nil;
local BL = nil;
local AL = nil;
local PriceTimesVolume;
-- Routine
function Prepare(nameOnly) 
	Price = instance.parameters.Price;
    N = instance.parameters.N;
    D = instance.parameters.Dev;
    source = instance.source;	
		
	first =source:first(period)+N ;


    local name = profile:id() .. "(" .. source:name() .. ", " .. Price .. ", " .. N .. ", " .. D .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
		 assert(source:supportsVolume(), "The source must have volume");
	
	PriceTimesVolume = instance:addInternalStream(0,0);
	
	
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrBBP, first)
    TL:setWidth(instance.parameters.widthBBB);
    TL:setStyle(instance.parameters.styleBBB);
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.clrBBP, first)
    BL:setWidth(instance.parameters.widthBBB);
    BL:setStyle(instance.parameters.styleBBB);
    if not instance.parameters.HideAve then
        AL = instance:addStream("AL", core.Line, name .. ".AL", "AL", instance.parameters.clrBBA, first);
        AL:setWidth(instance.parameters.widthBBA);
        AL:setStyle(instance.parameters.styleBBA);
	else	
	    AL = instance:addInternalStream(0,0);
    end
end

-- Indicator calculation routine
function Update(period, mode)

	
   PriceTimesVolume[period]=source[Price][period] *source.volume[period];
   
    if period < first then
	return;
	end
   
	  AL[period] =  mathex.sum(PriceTimesVolume,period-N+1,period)/mathex.sum(source.volume, period-N+1, period );	
	         
     local dAmount=0;
     local i;
     for i=0,N,1 do
      dAmount=dAmount+math.pow((source[Price][period-i]- AL[period]),2);
     end
       
	   
	  local d =math.sqrt(dAmount/N);
        local Dd = D * d;
        TL[period] = AL[period] + Dd;
        BL[period] =AL[period] - Dd;
		
end





