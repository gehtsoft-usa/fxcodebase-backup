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
    indicator:name("Zig Zag Based Trend Identifier ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("P2", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("P3", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
	
	

   
 
	
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
local ItIsOscillator;
local Trend;

local ZigZag;
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
	ZigZag= core.indicators:create("ZIGZAG", source, instance.parameters.P1, instance.parameters.P2,instance.parameters.P3);
	
	first=ZigZag.DATA:first() ;
	
	Top= instance:addInternalStream(0, 0);
    Bottom= instance:addInternalStream(0, 0);
	Trend= instance:addInternalStream(0, 0);
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.Up, first, Period2); 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end
local FirstLoad=true;
local SecondLoad=true;
local Last;
-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:size()-1  
	then
	return;
	end
	
	
	if Last~=source:serial(period) then
	Last=source:serial(period);	
	
	ZigZag:update(core.UpdateAll);
	end
	
	local FirstPeriod, SecondPeriod;
	
	if FirstLoad then
	FirstLoad=false;
	
	
			for i= first, source:size()-1, 1 do
			
			     Top[i]=0;
				Bottom[i]=0;
			 
				  FirstPeriod, SecondPeriod= FindLast(i)
					
					
					if FirstPeriod~= 0 then
					Top[FirstPeriod]=1;  
					IsIt(i,1)
					end
					
					if SecondPeriod~=0 then
					Bottom[SecondPeriod]=-1;  
					IsIt(i,2)
					end
					
					
					
			end
	
	else
	
	
	
		Top[period]=0;
		Bottom[period]=0;
	 
		    FirstPeriod, SecondPeriod= FindLast(period)
			
			
			if FirstPeriod~= 0 then
			Top[FirstPeriod]=1;  
			IsIt(period,1)
			end
			
			if SecondPeriod~=0 then
			Bottom[SecondPeriod]=-1; 
			IsIt(period,2)
			end
		
    end    
	
	
				
	 
	 
				  
end


function IsIt(period, Flag)

                
                 local Up=0;
				 local Count=0;
				 local Data={}
				 local First;
				 for i= period, first,-1 do
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
				 
				 for i= period, first,-1 do
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
				 
				
				 
						 if Trend[period]== 1 then 
						 Oscillator[period]=1;
						 elseif Trend[period]==-1 then
						 Oscillator[period]=-1; 
						 elseif Trend[period]== 0 then	
						 Oscillator[period]=0;
						 else
						 Oscillator[period]=Oscillator[period-1];
						 end
				
				 
				 if Trend[period]== 1	then 
				 Oscillator:setColor(period, instance.parameters.Up);
				 elseif Trend[period]== -1	 then
				 Oscillator:setColor(period, instance.parameters.Down);
				 else
				 Oscillator:setColor(period, instance.parameters.Neutral);
				 end

end

function FindLast(period)

		local X1,X2=0,0;

		for i = period, first, -1 do 
		
		    if ZigZag.DATA:hasData(i) then

					if X1== 0 
					and source.high[i]== ZigZag.DATA[i]
					then
					X1=i;
					end
					
					if X2== 0 
					and source.low[i]== ZigZag.DATA[i]
					then
					X2=i;
					end

            end			
			
			if X1~=0 and X2~=0 then
			break;
			end

		end


   return X1, X2;

end

 