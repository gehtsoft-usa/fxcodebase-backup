-- Id: 1456
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2020&p=4124#p4124

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
			indicator.parameters:addBoolean("TEST", "Test AO", "", true);
			indicator.parameters:addInteger("FM", "AO Fast Moving Average", "", 12, 2, 10000);
            indicator.parameters:addInteger("SM", "AO Slow Moving Average", "", 36, 2, 10000);
			
						
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
local TEST=nil;

local ONEUP=false;
local TWOUP=false;
local THREEUP=false;
local ONEDOWN=false;
local TWODOWN=false;
local THREEDOWN=false;

local first;
local source = nil;

-- Streams block
local S = {};
local Row = {};


-- Routine
function Prepare(nameOnly)

    source = instance.source;
    first = source:first();
	Signal=instance.parameters.SIGNAL;	
	TEST=instance.parameters.TEST;
	Fast=instance.parameters.FM;	
	Slow=instance.parameters.SM;	
     
    local name = profile:id() .. "(" .. source:name() ..  ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	local i;
	assert(core.indicators:findIndicator("AO") ~= nil, "Please, download and install AO.LUA indicator");
		
    
    for i = 1, 4, 1 do
  	F[i]= instance.parameters:getInteger("F" .. i);
	Color[i]= instance.parameters:getColor("S".. i.."_color");
	Flag[i]= instance.parameters:getBoolean("Flag".. i);
	M[i]= instance.parameters:getString("M".. i);
	IN[i]= instance.parameters:getInteger("IN".. i);	
	
	end	
	
	AO=core.indicators:create("AO",  source, Fast, Slow );
	
	
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
	end

	
	for i = 1 , 4 , 1 do
		if Flag[i] then		
		S[i] = instance:addStream("S".. i , core.Line, name .. ".S"..i, F[i]..", ".. M[i], Color[i], F[i]+1);
		else
		S[i]  = instance:addInternalStream(F[i]+1, 0);
		end		
		
	end    
	
	    if Signal then
				
				U = instance:createTextOutput ("U", "Up", "Wingdings", 20, core.H_Center, core.V_Bottom, core.rgb( 0, 255, 0), first);
				D = instance:createTextOutput ("D", "Down", "Wingdings", 20, core.H_Center, core.V_Top, core.rgb( 255,0,0), first);
		
				 	
		end
	
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if period >=  math.max(Fast,Slow, F[1], F[2], F[3], F[4])  and source:hasData(period) then
	
	local i,j,k;
	
	                  
						AO:update(mode);
					
	
	
			for i = 1 , 4 do 	
				  if Flag[i] then
						if period >= first+F[i]  then 
						Row[i]:update(mode);
						S[i][period] = Row[i].DATA[period];								
						end
						
				  end

				 if F[i] > MAX then
					MAX=F[i];
				end 
				  
			end
			
			
			
			if period >  MAX + 1 then
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
                             
							if TEST then 
											if AO.DATA[period-1] < AO.DATA[period] and ONEUP and  TWOUP then
											U:set(period, source.low[period], "\225"); 
											TWOUP=false;
											elseif AO.DATA[period-1] > AO.DATA[period] and THREEDOWN  and  TWODOWN then
											D:set(period, source.high[period], "\226"); 
											TWODOWN=false;
											end							
									else	
							               if  ONEUP and  TWOUP then
											U:set(period, source.low[period], "\225"); 
											TWOUP=false;
											elseif THREEDOWN  and  TWODOWN then
											TWODOWN=false;
											D:set(period, source.high[period], "\226"); 
											end			
                            end 							
											
							   
						end				
			
			end
			
    end
end