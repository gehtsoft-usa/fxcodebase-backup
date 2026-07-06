-- Id: 12674
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function Init()
    indicator:name("Multiple Moving Average Cross");
    indicator:description("Multiple Moving Average Cross");
    indicator:requiredSource(core.Bar);
	indicator:type(core.Indicator);   	
    local i;	 
	
	 			
			local LENGHT={12,36,36, 36}
			local B={16,128,255, 128}
			
			local R=0;
			local G=255;
			local Step=0; 
			
			indicator.parameters:addBoolean("SIGNAL", "Show Signals", "", true);
			
			indicator.parameters:addGroup("AO Filter");	
			indicator.parameters:addBoolean("TestAO", "Use AOFilter", "", true);
			
			indicator.parameters:addInteger("FM", "AO Fast Moving Average", "", 12, 2, 2000);
            indicator.parameters:addInteger("SM", "AO Slow Moving Average", "", 36, 2, 2000);
			
			indicator.parameters:addGroup("Stochastic Filter");	
			indicator.parameters:addBoolean("TestStochastic", "Use Stochastic Filter", "", true);
			
			indicator.parameters:addInteger("Shift", "Stochastic Shift", "", 5, 0, 1000);
			
		
		indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000);
		indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
		indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

		indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
		indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA");
		indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA");
		indicator.parameters:addStringAlternative("MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "FS");
 
		
		indicator.parameters:addString("MVAT_D" , "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
		indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA");
		indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA");
	 
		
			
			
						
			for i =1 , 4 , 1 do 
			indicator.parameters:addGroup("MA ".. i);
			indicator.parameters:addBoolean("Flag"..i, "Show "..i..". Line ", "", true);
			indicator.parameters:addInteger("F"..i, "Period", "", LENGHT[i]);
			indicator.parameters:addString("M"..i , "Method for avegage", "", "MVA");
            indicator.parameters:addStringAlternative("M"..i , "MVA", "", "MVA");
            indicator.parameters:addStringAlternative("M"..i, "EMA", "", "EMA");
            indicator.parameters:addStringAlternative("M"..i , "LWMA", "", "LWMA");
			
			if i == 1 then
			indicator.parameters:addInteger("IN"..i , "Data Source", "", 4);
			else
			indicator.parameters:addInteger("IN"..i , "Data Source", "", i);
			end
            indicator.parameters:addIntegerAlternative("IN"..i , "Open", "", 1);
            indicator.parameters:addIntegerAlternative("IN"..i, "Low", "", 2);
            indicator.parameters:addIntegerAlternative("IN"..i , "Close", "", 3);
			indicator.parameters:addIntegerAlternative("IN"..i , "High", "", 4);
			indicator.parameters:addIntegerAlternative("IN"..i, "Median", "", 5);
            indicator.parameters:addIntegerAlternative("IN"..i , "Typical", "", 6);
			indicator.parameters:addIntegerAlternative("IN"..i , "Weighted ", "", 7);
			
			
			R=R+Step;
			G= G-Step;
				
			Step= 255/4;
			
			indicator.parameters:addColor("S"..i.."_color", "Color of " .. i .. " MVA", "", core.rgb( R ,G, B[i]));
			end
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local F={};
local Color={};
local Flag={};
local M={};
local IN={};
local U=nil;
local D=nil;
local Signal;
local MAX=0;
local AO=nil;
local Slow=nil;
local Fast=nil;
local TestAO=nil;
local Shift;
local ONEUP=false;
local TWOUP=false;
local THREEUP=false;
local ONEDOWN=false;
local TWODOWN=false;
local THREEDOWN=false;

local first={};
local source = nil;

-- Streams block
local S = {};
local Row = {};
local TestStochastic;

local K, SD, D, MVAT_D, MVAT_K;
local StochasticUP, StochasticDOWN;
-- Routine
function Prepare()

    source = instance.source;
    Shift=instance.parameters.Shift;
	Signal=instance.parameters.SIGNAL;	
	TestAO=instance.parameters.TestAO;
	Fast=instance.parameters.FM;	
	Slow=instance.parameters.SM;	
    TestStochastic=instance.parameters.TestStochastic; 
    K=instance.parameters.K
	SD=instance.parameters.SD
	D=instance.parameters.D
	MVAT_D=instance.parameters.MVAT_D
	MVAT_K=instance.parameters.MVAT_K	
	local i;

		
    StochasticUP=0;
	StochasticDOWN=0;
	
    for i = 1, 4, 1 do
  	F[i]= instance.parameters:getInteger("F" .. i);
	Color[i]= instance.parameters:getColor("S".. i.."_color");
	Flag[i]= instance.parameters:getBoolean("Flag".. i);
	M[i]= instance.parameters:getString("M".. i);
	IN[i]= instance.parameters:getInteger("IN".. i);	
	
	end	
	
	AO=core.indicators:create("AO",  source, Fast, Slow);
	Stochastic=core.indicators:create("STOCHASTIC",  source, K, SD, D, MVAT_K, MVAT_D);
	
	for i = 1, 4, 1 do
		if IN[i]== 1 then
    assert(core.indicators:findIndicator(M[i]) ~= nil, M[i] .. " indicator must be installed");
		Row[i]=core.indicators:create(M[i],  source.open, F[i]);
		
		elseif  IN[i]== 2 then
		Row[i]=core.indicators:create(M[i],  source.low, F[i]);
		 
		elseif  IN[i]== 3 then
		Row[i]=core.indicators:create(M[i],  source.close, F[i]);
		 
		elseif  IN[i]== 4 then
		Row[i]=core.indicators:create(M[i],  source.high, F[i]);
		 
		elseif  IN[i]== 5 then
		Row[i]=core.indicators:create(M[i],  source.median, F[i]);
		 
		elseif  IN[i]== 6 then
		Row[i]=core.indicators:create(M[i],  source.typical, F[i]);
		 
		elseif  IN[i]== 7 then
		Row[i]=core.indicators:create(M[i],  source.weighted, F[i]);
		end
				
		 first[i] =  Row[i].DATA:first();		
	end
	
	

    local name = profile:id() .. "(" .. source:name() ..  ")";
    instance:name(name);
	
	for i = 1 , 4 , 1 do
		if Flag[i] then		
		S[i] = instance:addStream("S".. i , core.Line, name .. ".S"..i, F[i]..", ".. M[i], Color[i],first[i]);
		else
		S[i]  = instance:addInternalStream(0, 0);
		end		
		
	end    
	
	    if Signal then
				
				U = instance:createTextOutput ("U", "Up", "Wingdings", 20, core.H_Center, core.V_Bottom, core.rgb( 0, 255, 0), math.max(first[1],first[2], first[3],first[4]));
				D = instance:createTextOutput ("D", "Down", "Wingdings", 20, core.H_Center, core.V_Top, core.rgb( 255,0,0), math.max(first[1],first[2], first[3],first[4]));
		
				 	
		end
	
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   	AO:update(mode);
	Stochastic:update(mode);

    if period <AO.DATA:first()
	or period < Stochastic.D:first() +1 
	then
	return;
	end
	
	
	
	if core.crossesOver (Stochastic.K, Stochastic.D, period) then
	StochasticUP=period;
	elseif core.crossesUnder (Stochastic.K, Stochastic.D, period) then
	StochasticDOWN=period;
	end
	
	
	local i,j,k;
	
	                  
					
					
	
	
			for i = 1 , 4 do 	
				  if Flag[i] then
						if period >= first[i]  then 
						Row[i]:update(mode);
						S[i][period] = Row[i].DATA[period];								
						end
						
				  end

				 
				  
			end
			
			
		if period <   math.max(first[1],first[2], first[3],first[4]) then
		return;
		end
		 
						if Signal then	
						
							              	 
									 for i= 1 ,3 ,1 do  
									           k=0;
											   for j= i+1 ,4 ,1 do											   
																  
														k=k+1;

														if k== 7 then
														break;
														end
															if  core.crossesOver( S[i], S[j], period) then		
															
															if i== 1 and j== 2  then
															ONEUP=true;
															ONEDOWN=false;
															end
															if i== 1 and j== 3  then
															TWOUP=true;
															TWODOWN=false;
															end
															if i== 1  and j== 4 then
															THREEUP=true;
															THREEDOWN=false;
															end
															
															end
															
															if  core.crossesUnder( S[i], S[j], period) then	
                                                            if i== 1  and j== 2 then
															ONEUP=false;
															ONEDOWN=true;
															end
															if i== 1 and j== 3  then
															TWOUP=false;
															TWODOWN=true;
															end
															if i== 1 and j== 4  then
															THREEUP=false;
															THREEDOWN=true;
															end															
															
															end
												end      
												
												
										
									 end		
                             
							      
											if ( AO.DATA[period-1] < AO.DATA[period] or not TestAO)
											and   (  (period-Shift ) <= StochasticUP   or not TestStochastic)
											and ONEUP and  TWOUP 
											then
											U:set(period, source.low[period], "\225"); 
											TWOUP=false;
											elseif(AO.DATA[period-1] > AO.DATA[period]  or not TestAO)
											and  (  (period-Shift ) <= StochasticDOWN  or not TestStochastic)
											and THREEDOWN  and  TWODOWN 
											then
											D:set(period, source.high[period], "\226"); 
											TWODOWN=false;
											end							
								
                                     						
											
							   
						end				
			
			 
			
    
end