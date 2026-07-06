-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71144

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Custom Pattern 2");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addInteger("Size", "Font Size","", 15);
    indicator.parameters:addColor("clrUP", "Top Color","", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Bottom Color","", core.COLOR_DOWNCANDLE);
	
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 
local first;
local source = nil;
 
local Label_Top, Label_Bottom; 
local Size; 
local HL, OC, Body,Close, Top,Bottom; 
-- Routine
 function Prepare(nameOnly)   
  
	Size= instance.parameters.Size;
 

	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    HL= instance:addInternalStream(0, 0);
    OC= instance:addInternalStream(0, 0);
	Body= instance:addInternalStream(0, 0);
	Close= instance:addInternalStream(0, 0);
	Top= instance:addInternalStream(0, 0);
	Bottom= instance:addInternalStream(0, 0);
			
    source = instance.source; 
    first=source:first()+2 ;
	
 
	Label_Top = instance:createTextOutput ("Top", "Top", "Wingdings", Size, core.H_Right, core.V_Top, instance.parameters.clrUP, 0);
	Label_Bottom = instance:createTextOutput ("Bottom", "Bottom", "Wingdings", Size, core.H_Right, core.V_Bottom, instance.parameters.clrDN, 0);

end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	
	local Candle1=period-3;
	local Candle2=period-2;
	local Candle3=period-1;
	local Candle4=period;
	
    local C1=0;
	local C2=0;
	local C3=0;
	local C4=0;
	
	HL[period]=source.high[period]-source.low[period];
	OC[period]=source.close[period]-source.open[period];
	Body[period]= math.abs(OC[period]) /(HL[period]/100);
	Close[period]= (source.close[period]-source.low[period]) /(HL[period]/100);
	--Top[period]= (source.high[period]-math.max(source.open[period],source.close[period])) /(HL[period]/100);
	--Bottom[period]= (math.min(source.open[period],source.close[period])-source.low[period]) /(HL[period]/100);
	
	if OC[Candle1]>0
	and Body[Candle1]> 50
	and Close[Candle1]> 66
	then
	C1=1;
	end
	
	if OC[Candle1]<0
	and Body[Candle1]> 50
	and Close[Candle1]<33
	then
	C1=-1;
	end
	
	if OC[Candle2]>0
	and source.low[Candle2]> source.low[Candle1]
	and source.close [Candle2] > source.low[Candle1]
	and source.close [Candle2] < source.high[Candle1]
	then
	C2=1;
	end
	
	if OC[Candle2]<0
	and source.high[Candle2]< source.high[Candle1]
	and source.close [Candle2] > source.low[Candle1]
	and source.close [Candle2] < source.high[Candle1]
	then
	C2=-1;
	end
	
	
	
	if  source.high[Candle3 ] > source.high[Candle2 ]
	and source.high[Candle3 ] > source.high[Candle1] 
	and source.open[Candle3 ] >source.low[Candle2]   
	and source.close[Candle3 ] > source.low[Candle2]   
	and source.high[Candle3 ] > source.low[Candle2]   
	then
	C3=1;
	end
	
	
	if  source.low[Candle3 ] < source.low[Candle2 ]
	and source.low[Candle3 ] < source.low[Candle1 ] 
	and source.open[Candle3 ] < source.high[Candle2]   
	and source.close[Candle3 ] < source.high[Candle2]   
	and source.high[Candle3 ] < source.high[Candle2] 
	then
	C3=-1;
	end
	
	
		
	if  source.low[Candle4 ] < source.low[Candle2 ] 
	then
	C4=1;
	end
	
	if   source.high[Candle4 ] > source.high[Candle2 ] 
	then
	C4=-1;
	end
	
	
	
	if C1==1 and C2==1 and C3==1 and C4==1 then
	--if C1==1 and C2==1 and C3==1  then
	Label_Top:set(period , source.high[period ], "\217");  
	end
	
	if C1==-1 and C2==-1 and C3==-1 and C4==-1 then
	--if C1==-1 and C2==-1 and C3==-1  then
    Label_Bottom:set(period , source.low[period ], "\218"); 
	end
	
 
 
				  
end
 
