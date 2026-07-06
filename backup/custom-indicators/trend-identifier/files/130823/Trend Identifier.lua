-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69334

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
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

function Init()
    indicator:name("Trend Identifier");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addBoolean("ItIsOscillator", "Oscillator", "", false);
   
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(128, 128, 128));
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period ; 
local first;
local source = nil;
local Top, Bottom;
local Oscillator;  
local ItIsOscillator;
local Trend;
-- Routine
 function Prepare(nameOnly)   
 
 
    ItIsOscillator= instance.parameters.ItIsOscillator;
   
	
	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+6 ;
	
	Top= instance:addInternalStream(0, 0);
    Bottom= instance:addInternalStream(0, 0);
	Trend= instance:addInternalStream(0, 0);
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.Up, first, Period2); 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first() +6
	then
	return;
	end
	
	Top[period-2]=0;
	Bottom[period-2]=0;
 
        local curr;
		curr= source.high[period - 2];
		
		
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period]) 
		then
        Top[period-2]=1;    
        end
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period])
		then
        Bottom[period-2]=-1;  
        end
	 local Up=0;
	 local Count=0;
	 local Data={}
	 local First;
	 for i= period-2, first,-1 do
		 if Top[i]==1 then
		 Count=Count+1;
		 Data[Count]=i;
		 end
		 if Count == 2 then 
		 break;
		 end
     end
	 
	 if Data[1]== nil or Data[2] == nil  then
	 return;
	 end
	 
	 if source.high[Data[1]] > source.high[Data[2]] then
	 Up=1;
	 elseif source.high[Data[1]] < source.high[Data[2]] then
	 Up=-1;
	 end
	 
	 First=Data[1];

     Count=0; 
     Data={};
	 local Down=0;
	 
	 for i= period-2, first,-1 do
	     if Bottom[i]==-1 then
		 Count=Count+1;
		 Data[Count]=i;
		 end
		 if Count == 2 then 
		 break;
		 end
     end 
	 
	 
	 if Data[1]== nil or Data[2] == nil  then
	 return;
	 end
	 
	 Second=Data[1];
	 
	 if source.low[Data[1]] > source.low[Data[2]] then
	 Down=1;
	 elseif source.low[Data[1]] < source.low[Data[2]] then
	 Down=-1;
	 end
	 
	    if Up==1 and Down==1 then  
		 Trend[period]=1;		 
		 elseif Up==-1 and Down==-1 then  
		  Trend[period]=-1;
		 elseif Up ~=Down then
		 Trend[period]= 0;
		 else
		 Trend[period]=Trend[period];
		 end
	 
	 if ItIsOscillator then
		 
		 
		     
		    Oscillator[period]= (source.close[period]-Second)/((First-Second)/100); 
		 
	 else
	 
			 if Trend[period]== 1 then 
			 Oscillator[period]=1;
			 elseif Trend[period]==-1 then
             Oscillator[period]=-1; 
			 elseif Trend[period]== 0 then	
			 Oscillator[period]=0;
			 else
			 Oscillator[period]=Oscillator[period-1];
			 end
	 end
	 
	 
	 if Trend[period]== 1	then 
	 Oscillator:setColor(period, instance.parameters.Up);
	 elseif Trend[period]== -1	 then
	 Oscillator:setColor(period, instance.parameters.Down);
	 else
	 Oscillator:setColor(period, instance.parameters.Neutral);
	 end
				  
end

 