-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4089

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


function Init()
    indicator:name("Multi Time Frame MACD");
    indicator:description("Multi Time Frame MACD");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

    indicator.parameters:addGroup("Price Type");       
   	indicator.parameters:addString("PriceType", "Price", "", "close");
	indicator.parameters:addStringAlternative("PriceType","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("PriceType", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("PriceType", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("PriceType", "LOW", "", "low");
    indicator.parameters:addStringAlternative("PriceType", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("PriceType", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("PriceType", "WEIGHTED", "", "weighted");	
	
	Parameters (1 , "H1" );
	Parameters (2 , "H4" );
	Parameters (3 , "H8" );
    Parameters (4 , "D1" );
	Parameters (5 , "W1" );
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Position", "Vertical Position", "", 0, 0 , 500);
	 
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
	indicator.parameters:addColor("Up", "Up Arrow Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Arrow Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Arrow Color", "", core.rgb(128, 128, 128));
	
	
end


function Parameters (id , FRAME )
    indicator.parameters:addGroup(id ..". Time Frame");
	
	indicator.parameters:addString("TF"..id, "MACD Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);

    indicator.parameters:addInteger("ShortPeriod"..id, "Short Periods", "", 12);
	indicator.parameters:addInteger("LongPeriod"..id, "Long Periods", "", 26);
    indicator.parameters:addInteger("SignalPeriod"..id, "Signal Periods", "", 9);
	
end

local Label;
local Up, Down, Neutral;
local loading={};
local  ArrowSize;
local source;
local MACD={};
local day_offset, week_offset; 
local SourceData={};
local host; 
local first;

local PriceType;
local font1, font2,font3;

local Price; 
local Position;


function ReleaseInstance()
       core.host:execute("deleteFont", font1);
       core.host:execute("deleteFont", font2);
	  core.host:execute ("killTimer", 1);
   end

function Prepare(nameOnly) 
   
	Neutral=instance.parameters.Neutral;
    Label=instance.parameters.Label;
	Up=instance.parameters.Up;
    Down=instance.parameters.Down;
    Position=instance.parameters.Position;     
    ArrowSize=instance.parameters.ArrowSize;   
	PriceType=instance.parameters.PriceType;
    local name =  profile:id() .. ","  .. instance.source:name() ;
	instance:name(name);
	if   (nameOnly) then
        return;
    end
	
    source = instance.source;
	first= source:first();
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");   
	
	
   local i;
	first=source:first();
	local Test={};
	for i= 1, 5, 1 do	
	if (instance.parameters:getInteger ("LongPeriod"..i)<= instance.parameters:getInteger ("TF"..i)) then
       error("The short EMA period must be smaller than long EMA period");	   
	   
	Test[i]  = core.indicators:create("MACD", source.close, instance.parameters:getInteger ("ShortPeriod"..i) , instance.parameters:getInteger ("LongPeriod"..i), instance.parameters:getInteger ("SignalPeriod"..i)); 
     first= math.max(first, Test[i].HISTOGRAM:first() )*2  ;	
	end
	
	 
    for i= 1, 5, 1 do	
	  SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), instance.parameters:getString ("TF"..i), source:isBid(),  math.min(first,300)  , 200+i, 100+i);	 
	  MACD[i] = core.indicators:create("MACD", SourceData[i][PriceType], instance.parameters:getInteger ("ShortPeriod"..i) , instance.parameters:getInteger ("LongPeriod"..i), instance.parameters:getInteger ("SignalPeriod"..i));
	 loading[i] = true;     
    end
	
	 
	end
	 
	
	   font1 = core.host:execute("createFont", "Arial", ArrowSize, true, false);
       font2 = core.host:execute("createFont", "Wingdings", ArrowSize, false, false);
	      core.host:execute ("setTimer", 1, 1);
end


function Update(period, mode)

    if  period <  source:size() - 1 then	
       return;
	end	
	
	if loading[1] or loading[2] or loading[3] or loading[4] or loading[5] then		
	return;	
	end
	
	
	local MACD_Color=nil;
	local SIGNAL_Color=nil;
	
			for i = 1, 5, 1  do
		  
					--MACD[i]:update(mode);
						
						
						if  MACD[i].SIGNAL:hasData(MACD[i].SIGNAL:size()-1)  and  MACD[i].SIGNAL:hasData(MACD[i].SIGNAL:size()-2)  then	
                      

                     							 
							      core.host:execute("drawLabel1", i, -i*50, core.CR_RIGHT,Position+25, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label, instance.parameters:getString ("TF"..i));
							 
						
											   if MACD[i].MACD[MACD[i].MACD:size()-1] > MACD[i].MACD[MACD[i].MACD:size()-2] then
																
                                                        MACD_Color = Up; 
																
																					
												
												elseif MACD[i].MACD[MACD[i].MACD:size()-1] < MACD[i].MACD[MACD[i].MACD:size()-2] then
												
																									 
												        MACD_Color = Down;    
												else
													
													    MACD_Color = Neutral;                                                									
												
												end 		
												
												
												if MACD[i].SIGNAL[MACD[i].SIGNAL:size()-1] > MACD[i].SIGNAL[MACD[i].SIGNAL:size()-2] then
																
                                                        SIGNAL_Color = Up; 
																
																					
												
												elseif MACD[i].SIGNAL[MACD[i].SIGNAL:size()-1] < MACD[i].SIGNAL[MACD[i].SIGNAL:size()-2] then
												
																									 
												        SIGNAL_Color = Down;    
												else
													
													    SIGNAL_Color = Neutral;                                                									
												
												end 		
												
												
									      
												
												 local Macd_Level ;
												 local Signal_Level; 
												 local Zero_Level; 
												local MZ, SZ, MS; 
												local min,max;
												
												local macd = MACD[i].MACD[MACD[i].MACD:size()-1];
												local signal = MACD[i].SIGNAL[MACD[i].SIGNAL:size()-1];

                                                min = math.max (signal, macd , 0);												
												max = math.min (signal, macd , 0);	 
												
												
												
												if  macd== min    then                                             
												Macd_Level = 3;
												elseif  macd == max then
												Macd_Level = 1;
												else
												Macd_Level = 2;
												end
												
												if  signal == min    then                                             
												Signal_Level = 3;
												elseif  signal == max then
												Signal_Level = 1;
												else
												Signal_Level = 2;
												end
												
												if  0 == min    then                                             
												Zero_Level = 3;
												elseif  0 == max then
												Zero_Level = 1;
												else
												Zero_Level = 2;
												end
												
												
												
															
													core.host:execute("drawLabel1", 15+i, -i*50,core.CR_RIGHT, 100+Position-Macd_Level*20, core.CR_TOP, core.H_Right, core.V_Bottom,
																	font2, MACD_Color, "\108"  );	
															
                                                    core.host:execute("drawLabel1", 30+i, -i*50,core.CR_RIGHT, 100+Position-Signal_Level*20, core.CR_TOP, core.H_Right, core.V_Bottom,
																	font2, SIGNAL_Color, "\110"  );	
														
											
										            core.host:execute("drawLabel1", 45+i, -i*50,core.CR_RIGHT, 100+Position-Zero_Level*20, core.CR_TOP, core.H_Right, core.V_Bottom,
						                                            font2, Neutral, "\117"  );																	
																	
							                          core.host:execute("drawLabel1", 51, -3*50,core.CR_RIGHT, 100+Position, core.CR_TOP, core.H_Right, core.V_Bottom,																
                                                                     font2, Neutral, "\108"  );			
					
				                                     core.host:execute("drawLabel1", 52, -2*50,core.CR_RIGHT, 100+Position, core.CR_TOP, core.H_Right, core.V_Bottom,																
                                                                     font2, Neutral, "\110"  );
													 core.host:execute("drawLabel1", 53, -1*50,core.CR_RIGHT, 100+Position, core.CR_TOP, core.H_Right, core.V_Bottom,																
                                                                     font2, Neutral, "\117"  );	

 													core.host:execute("drawLabel1", 54, -4*50,core.CR_RIGHT, 100+Position , core.CR_TOP, core.H_Right, core.V_Bottom,																
                                                                     font1, Down, "Red"  );
													 core.host:execute("drawLabel1", 55, -5*50,core.CR_RIGHT, 100+Position , core.CR_TOP, core.H_Right, core.V_Bottom,																
                                                                     font1, Up, "Green"  );	



													core.host:execute("drawLabel1", 61, -3*50,core.CR_RIGHT, 100+Position+20, core.CR_TOP, core.H_Right, core.V_Bottom,																
                                                                     font1, Neutral, "MACD"  );			
					
				                                     core.host:execute("drawLabel1", 62, -2*50,core.CR_RIGHT, 100+Position+20, core.CR_TOP, core.H_Right, core.V_Bottom,																
                                                                     font1, Neutral, "Signal"  );
													 core.host:execute("drawLabel1", 63, -1*50,core.CR_RIGHT, 100+Position+20, core.CR_TOP, core.H_Right, core.V_Bottom,																
                                                                     font1, Neutral, "Zero"  );	
                                                    
													core.host:execute("drawLabel1", 64, -4*50,core.CR_RIGHT, 100+Position+20, core.CR_TOP, core.H_Right, core.V_Bottom,																
                                                                     font1, Neutral, "Fall"  );
													 core.host:execute("drawLabel1", 65, -5*50,core.CR_RIGHT, 100+Position+20, core.CR_TOP, core.H_Right, core.V_Bottom,																
                                                                     font1, Neutral, "Growth"  );	
																	 
			end 
	 
	    end
	 
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     if cookie == 101 then
        loading[1] = true;
    elseif cookie == 102 then
        loading[2] = true;
    elseif cookie == 103 then
        loading[3] = true;
    elseif cookie == 104 then
        loading[4] = true;
    elseif cookie == 105 then
        loading[5] = true;
    elseif cookie == 201 then
        loading[1] = false;
  
    elseif cookie == 202 then
        loading[2] = false;
       
    elseif cookie == 203 then
        loading[3] = false;
 
    elseif cookie == 204 then
        loading[4] = false;
 
    elseif cookie == 205 then
        loading[5] = false;
  
    end
	
	if loading[1] or loading[2] or loading[3] or loading[4] or loading[5] then		
	return;	
	end
	
	   if   cookie== 1 then
		for i= 1, 5 , 1 do
			  MACD[i]:update(core.UpdateLast );
		end
	  end	
	
    return core.ASYNC_REDRAW;
end


