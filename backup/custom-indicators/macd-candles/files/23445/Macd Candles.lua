-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=11695
-- Id: 5554

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Macd Candles");
    indicator:description("Macd Candles");
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


	indicator.parameters:addGroup("Chart Time Frame"); 
	 indicator.parameters:addInteger("ShortPeriod", "Short Periods", "", 12);
	indicator.parameters:addInteger("LongPeriod", "Long Periods", "", 26);
    indicator.parameters:addInteger("SignalPeriod", "Signal Periods", "", 9);
	
	
	Parameters (1 , "m1" );
	Parameters (2 , "m5" );
	Parameters (3 , "m15" );
    Parameters (4 , "m30" );
	Parameters (5 , "H1" );
	Parameters (6 , "H2" );
	Parameters (7 , "H3" );
	Parameters (8 , "H4" );
    Parameters (9 , "H6" );
	Parameters (10 , "H8" );
	Parameters (11 , "D1" );
	Parameters (12 , "W1" );
	Parameters (13 , "M1" );
 
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "Font Size", "", 20);
	indicator.parameters:addInteger("Position", "Vertical Position", "", 0, 0 , 500);
	 

	indicator.parameters:addColor("UpUp", "Up Positiv  Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down Pozitiv Color", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Up Negativ  Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownDown", "Down Negativ Color", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Signal", "Signal  Arrow Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addGroup("Selection");	
	indicator.parameters:addBoolean("Overlay", "Show Overlay", "", true);
	indicator.parameters:addBoolean("SIGNAL", "Show Signal", "", true);
	
end


function Parameters (id , FRAME )
    indicator.parameters:addGroup(id ..". MACD Calculation");
    indicator.parameters:addInteger("ShortPeriod"..id, "Short Periods", "", 12);
	indicator.parameters:addInteger("LongPeriod"..id, "Long Periods", "", 26);
    indicator.parameters:addInteger("SignalPeriod"..id, "Signal Periods", "", 9);
	
    indicator.parameters:addString("B"..id, "MACD Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
end

local Label;
local UpUp, UpDown, Neutral , DownUp, DownDown;

local  ArrowSize;
local source;
local MACD={};
local day_offset, week_offset;

local host;
local Overlay;
local first;
local Signal;
local PriceType;
local font1, font2,font3;

local Price;
local Position;

local up, down;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local DefMACD;
local SIGNAL;
local Source={};
local loading={};
local Number=13;

function ReleaseInstance()
       core.host:execute("deleteFont", font1);
       core.host:execute("deleteFont", font2);
	  
end

function Prepare(nameOnly)   
	Signal=instance.parameters.Signal;
	Overlay=instance.parameters.Overlay;
	SIGNAL=instance.parameters.SIGNAL;
	Neutral=instance.parameters.Neutral;
    Label=instance.parameters.Label;
	UpUp=instance.parameters.UpUp;
    UpDown=instance.parameters.UpDown;
	DownUp=instance.parameters.DownUp;
    DownDown=instance.parameters.DownDown;
	
    Position=instance.parameters.Position;     	
    ArrowSize=instance.parameters.ArrowSize;   
	PriceType=instance.parameters.PriceType;
    local name =  profile:id() .. ","  .. instance.source:name() ;
	instance:name(name);
	if nameOnly then
		return;
	end
    source = instance.source;
	
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");   
	
	
	if (instance.parameters:getInteger ("LongPeriod")<= instance.parameters:getInteger ("ShortPeriod")) then
       error("The short EMA period must be smaller than long EMA period");
    end

	
	for i= 1, 13, 1 do
	
		if (instance.parameters:getInteger ("LongPeriod"..i)<= instance.parameters:getInteger ("ShortPeriod"..i)) then
		   error("The short EMA period must be smaller than long EMA period");
		end
	
   	end
	
	for i= 1, 13, 1 do
	
	  Source[i] = core.host:execute("getSyncHistory",source:instrument(), instance.parameters:getString ("B"..i), source:isBid(), math.min(300,  instance.parameters:getInteger ("LongPeriod"..i)), 200+i, 100+i);
	  MACD[i] = core.indicators:create("MACD", Source[i][PriceType], instance.parameters:getInteger ("ShortPeriod"..i) , instance.parameters:getInteger ("LongPeriod"..i), instance.parameters:getInteger ("SignalPeriod"..i));
	  loading[i]=true;
	end
	
	
	   font1 = core.host:execute("createFont", "Ariel", ArrowSize/2, true, false);
       font2 = core.host:execute("createFont", "Wingdings", ArrowSize/2, false, false);
	
	   
	     i = "Chart";
	   DefMACD = core.indicators:create("MACD", source[PriceType], instance.parameters.ShortPeriod , instance.parameters.LongPeriod, instance.parameters.SignalPeriod);
	   
	   
	   
	   
      first= DefMACD.SIGNAL:first();	   

	   open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", ArrowSize, core.H_Center, core.V_Top, Signal, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", ArrowSize, core.H_Center, core.V_Bottom, Signal, 0);
	 
end 
 
function Update(period, mode)

	
	DefMACD:update(mode);
	
	
		 
						if Overlay  then
						    
						                        if DefMACD.MACD[period] > DefMACD.MACD[period-1] 
											   and DefMACD.MACD[period]  > 0 
											   then
																
                                                        MACD_Color = UpUp; 
												elseif DefMACD.MACD[period] < DefMACD.MACD[period-1] 
											   and DefMACD.MACD[period]  > 0 
											   then				
														MACD_Color =UpDown;  						
												elseif DefMACD.MACD[period] > DefMACD.MACD[period-1] 
											   and DefMACD.MACD[period]  < 0 
											   then
																
                                                        MACD_Color = DownUp; 
												elseif DefMACD.MACD[period] < DefMACD.MACD[period-1] 
											   and DefMACD.MACD[period]  < 0 
											   then				
														MACD_Color =DownDown;  		
												  
												else
													
													    MACD_Color = Neutral;                                                									
												
												end 		
												
							if SIGNAL and DefMACD.SIGNAL:hasData(period-1) and  DefMACD.MACD:hasData(period-1) then					
								if core.crossesOver (DefMACD.MACD, DefMACD.SIGNAL, period) then
								  up:set(period, source.high[period], "\217");
                                else
								  up:setNoData (period);
                                end
								
						         if core.crossesUnder (DefMACD.MACD, DefMACD.SIGNAL, period) then
								  down:set(period, source.low[period], "\218");
                                else
								 down:setNoData (period);
                                end
						    end
						
							high[period]= source.high[period];
							low[period]= source.low[period];		   
							close[period] = source.close[period];
							open[period]  = source.open[period];	
							open:setColor(period, MACD_Color);
						
						end
						
						
	
	if   period < source:size() - 1 then	
	return;
	end
	
local Flag=false;

   for i= 1, Number, 1 do

		if loading[i]  then		
	    Flag=true;
		end
	end
		
	
	if Flag then
	return;
	end	
	
	
	
	local MACD_Color=Neutral;
	local SIGNAL_Color=nil;
	
			for i = 1, 13, 1  do
		  
						MACD[i]:update(mode);
						
					if  MACD[i].SIGNAL:hasData(MACD[i].SIGNAL:size()-1)  and  MACD[i].SIGNAL[MACD[i].SIGNAL:size()-2]  then	

					
					                   	       if MACD[i].MACD[MACD[i].MACD:size()-1] > MACD[i].MACD[MACD[i].MACD:size()-2] 
											   and MACD[i].MACD[MACD[i].MACD:size()-1]  > 0 
											   then
																
                                                        MACD_Color = UpUp; 
												elseif MACD[i].MACD[MACD[i].MACD:size()-1] < MACD[i].MACD[MACD[i].MACD:size()-2] 
											   and MACD[i].MACD[MACD[i].MACD:size()-1]  > 0 
											   then				
														MACD_Color =UpDown;  						
												elseif MACD[i].MACD[MACD[i].MACD:size()-1] > MACD[i].MACD[MACD[i].MACD:size()-2] 
											   and MACD[i].MACD[MACD[i].MACD:size()-1]  < 0 
											   then
																
                                                        MACD_Color = DownUp; 
												elseif MACD[i].MACD[MACD[i].MACD:size()-1] < MACD[i].MACD[MACD[i].MACD:size()-2] 
											   and MACD[i].MACD[MACD[i].MACD:size()-1]  < 0 
											   then				
														MACD_Color =DownDown;  						
												
												  
												else
													
													    MACD_Color = Neutral;                                                									
												
												end 		
					
						
                      

                     							 
							      core.host:execute("drawLabel1", i, -i*50, core.CR_RIGHT,Position+25, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, MACD_Color, instance.parameters:getString ("B"..i));
							 
						   
												
											
																	 
			end 
	 
	    end
	 
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false; 	 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 
   end
   
   
		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		instance:updateFrom(0);	
		end
			  
	    
   
        
		return core.ASYNC_REDRAW ;
end
 