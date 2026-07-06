-- Id: 8229

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27966

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("FX Multi-Meter");
    indicator:description("FX Multi-Meter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    Add(1, "m1");
	Add(2, "m5");
	Add(3, "m15");
	Add(4, "m30");
	Add(5, "H1");
	Add(6, "H4");
	Add(7, "D1");
	
	
	indicator.parameters:addGroup("Percent Range indicator");
	indicator.parameters:addInteger("RLWPeriod", "RLW Period", "RLW Period", 14);
	indicator.parameters:addGroup("MA Calculation");
	indicator.parameters:addString("MaMethod", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MaMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MaMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MaMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MaMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MaMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MaMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MaMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MaMethod", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("MaPeriod", "MA Period", "MA Period", 14);
	
	indicator.parameters:addGroup("SAR Calculation");
    indicator.parameters:addDouble("Step", "Step", "", 0.02, 0.001, 1);
    indicator.parameters:addDouble("Max", "Max", "", 0.2, 0.001, 10);
	
	
	indicator.parameters:addGroup("Cross Calculation");
	indicator.parameters:addString("Method1", "1. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("Period1", "Period", "1.Period", 3);
	
	indicator.parameters:addString("Method2", "2. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("Period2", "Period", "2..Period", 6);
	
	
	
	indicator.parameters:addGroup("MACD Calculation");
    indicator.parameters:addInteger("FastP", "Fast Ema Period", "Fast Ema Period", 12);
    indicator.parameters:addInteger("SlowP", "Slow Ema Period", "Slow Ema Period", 26);
    indicator.parameters:addInteger("SignalP", "Signal Sma Period", "Signal Sma Period", 9);
	
	indicator.parameters:addGroup("Stochastic Calculation");
	indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "MT");
	indicator.parameters:addStringAlternative("MVAT_K" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "WMA", "", "WMA");	
    
    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("MVAT_D" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "WMA", "", "WMA");	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addString("Mode", "Mode", "", "L");    
    indicator.parameters:addStringAlternative("Mode", "Live", "", "L");
    indicator.parameters:addStringAlternative("Mode", "End of Turn", "", "E");
	
	 
	 
	-- indicator.parameters:addBoolean("V", "Show Values", "", true);
   -- indicator.parameters:addBoolean("P", "Show Percentages", "", true);
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255,0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color", "", core.rgb(128,128, 128));
    indicator.parameters:addColor("NE", "Neutral color", "", core.rgb(0, 0, 0));		
    indicator.parameters:addColor("LABEL", "Label color", "", core.COLOR_LABEL);
     indicator.parameters:addInteger("Size", "Font Size", "", 10, 1, 20);
end

 
function Add(id, TF)


    indicator.parameters:addGroup(id .. ". Time Frame");
    indicator.parameters:addString("TF"..id, "Time frame", "", TF);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
end 
local Step, Max;
local Method2, Method1, Period1, Period2;
local Up, Down;
local FastP, SlowP, SignalP;
local K, SD, D, MVAT_K, MVAT_D; 
local offset,weekoffset;
local SourceData={};
local  TF={};
local host;
local first;
local source = nil;
local loading={};
--local p;
local Stochastic={};
local MA={};
local Mode;
local V,P,IN,NE,LABEL, Size;
local font1, font2;
local id=0;
local Last,last;
local FIRST;
local MaPeriod;
local MaMethod;
local Neutral;
local RLWPeriod;
local Temp={};
local Bar={};
local BarsAverage={};
local SpreadLast;
local BarPercent={};
local MACD,SAR, SHORT, LONG;
local MACDSignal;
local font3,font4;

function ReleaseInstance()
  core.host:execute("deleteFont", font1); 
  core.host:execute("deleteFont", font2);    
    core.host:execute("deleteFont", font3);   
	 core.host:execute("deleteFont", font4); 
	host:execute ("killTimer", 1) 
	 
	 
end


-- Routine
function Prepare(nameOnly)
    source = instance.source;
	 
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Step= instance.parameters.Step;
	Max= instance.parameters.Max;
    Method2= instance.parameters.Method2;
	Method1= instance.parameters.Method1;
	Period1= instance.parameters.Period1;
	Period2= instance.parameters.Perido2;
    FastP= instance.parameters.FastP;
	SlowP= instance.parameters.SlowP;
	SignalP= instance.parameters.SignalP;
    Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	RLWPeriod= instance.parameters.RLWPeriod;
    MaMethod= instance.parameters.MaMethod;
	MaPeriod= instance.parameters.MaPeriod;
    K= instance.parameters.K;
	SD= instance.parameters.SD;
	D= instance.parameters.D;
	MVAT_K= instance.parameters.MVAT_K;
	MVAT_D= instance.parameters.MVAT_D;
	Mode= instance.parameters.Mode;
	Neutral= instance.parameters.Neutral;
		
    Size= instance.parameters.Size;    
    IN= instance.parameters.NE;
    NE= instance.parameters.NE;
    LABEL= instance.parameters.LABEL
  
   
    first = source:first();
	
	host=core.host;
	
	font1 = core.host:execute("createFont", "Arial", Size, false, false);
	font2= core.host:execute("createFont", "Wingdings", Size, false, false);
	font3= core.host:execute("createFont", "Wingdings", Size*2, false, false);
	font4= core.host:execute("createFont", "Wingdings", Size*5, false, false);
	offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	

	
	Temp[1] = core.indicators:create("STOCHASTIC", source, K, SD, D, MVAT_K, MVAT_D);
    assert(core.indicators:findIndicator(MaMethod) ~= nil, MaMethod .. " indicator must be installed");
	Temp[2] = core.indicators:create(MaMethod, source.close, MaPeriod);
	Temp[3] = core.indicators:create("RLW", source , RLWPeriod);
	MACD = core.indicators:create("MACD", source.close , FastP, SlowP, SignalP);
	SAR = core.indicators:create("SAR", source  , Step, Max);
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	SHORT = core.indicators:create(Method1, source.close , Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	LONG = core.indicators:create(Method2, source.close , Period2);
	
	FIRST=math.max(Temp[1].DATA:first() , Temp[2].DATA:first());
	
	
	local i;
	for  i = 1, 7, 1 do
	TF[i]= instance.parameters:getString("TF" .. i);
	SourceData[i] = core.host:execute("getSyncHistory",source:instrument(), TF[i], source:isBid(), FIRST, 200+i, 100+i);
	Stochastic[i]=core.indicators:create("STOCHASTIC", SourceData[i], K, SD, D, MVAT_K, MVAT_D);
	MA[i]=core.indicators:create(MaMethod, SourceData[i].close,MaPeriod);
	
	loading[i]=true;
	end



   core.host:execute ("setTimer", 1,1);
end

function Coloring (value,min, max)

local color;
local mid =(min+max)/2;


if value <= mid then
color = core.rgb(255 * (value / mid), 255, 0) 
else 
color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
end


return  color;

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

   
    local Ask = core.host:findTable("offers"):find("Instrument", source:instrument()).Ask;
	local Bid = core.host:findTable("offers"):find("Instrument", source:instrument()).Bid;
    local Spread  = (Ask  - Bid)/source:pipSize();	
	 if Spread  ~= SpreadLast  then
	 SpreadLast=Spread;
	  DrawSpread(Spread);
	 end
	
	
	
  

    if period  < source:size()-1 
	or period < Temp[3].DATA:first() 
	or period < Temp[2].DATA:first() 
	or period < Temp[1].DATA:first() 
	or period < MACD.SIGNAL:first()
	or period < SHORT.DATA:first()
	or period < LONG.DATA:first()
	then
    return;	  
    end	

	local Flag = false;
	local i;
	--p={};
	
	
	for i= 1, 7, 1 do
	
	 Stochastic[i]:update(mode);
	 MA[i]:update(mode); 
	
		if loading[i] 
		then
		Flag=true;
		end
	end
	
	
	 Temp [1]:update(mode);
	 Temp [2]:update(mode);
     Temp [3]:update(mode);	
	 MACD:update(mode);
	 SHORT:update(mode);
	 LONG:update(mode);
	 SAR:update(mode);
	
	if Flag then	
	return;
	end
	 
	
	if source:serial(period) ~= Last
	or source.close[period] ~= last	
	then
	Last=source:serial(period);
	last = source.close[period];	 
	id=0;
	core.host:execute ("removeAll")
	end
	
	
	 DrawMACD(period ); 
	 DrawCross(period );
     DrawSAR(period ); 	 
	 DrawAlert(period ); 	 
	for i = 0, 11 , 1 do	
	Bar[i+1]=math.abs(source.close[period-i]-source.close[period-i-1])/source:pipSize();
	end
	
	for i = 0, 7 , 1 do
	BarsAverage[i+1] = (Bar[i+2] + Bar[i+3] + Bar[i+4] + Bar[i+5])/4;
	BarPercent [i+1]=100* Bar[i+1]/BarsAverage[i+1];
    end
	
	
	for i = 1, 7 , 1 do	
		
	DrawStochastic (i, period, 0, 100,  Stochastic[i].DATA[ Stochastic[i].DATA:size()-1] , Size*7, Size*3*i, Size*7);	
	   DrawMA (i  , period,   0,    0,  MA[i].DATA[ MA[i].DATA:size()-1] , Size, Size*3*i, Size*16);
	 
     
	DrawBars(i, period, 0, 0,  0 , Size, Size*3*i,Size*21)
	end
	
	DrawRLW(1, period, 0, -100,  Temp[3].DATA[ Temp[3].DATA:size()-1] , Size*5, Size*3, Size*25);	
	
	--DrawRLW (num, period, max, min, value , Height, X, Y, Z)
end

function DrawAlert(period ) 
    local X=Size*3*6.5;
	local Y=Size*24;
	
	local Signal = 0;
	
	
	--Signal Down  ------------------------ 
    if ( MACD.MACD[period]>MACD.SIGNAL[period] 
	and SHORT.DATA[period]> LONG.DATA[period] 
	and Temp[3].DATA[period]>-50 
	and Temp[3].DATA[period] > Temp[3].DATA[period-1]
	and Temp[1].K[period] >  Temp[1].K[period-1] 
	and source.close[period]>source.close[period-1])
	then

     Signal = 1;
     end 
    
    --Signal Up  ------------------------  
    if ( MACD.MACD[period]<MACD.SIGNAL[period] 
	and SHORT.DATA[period]< LONG.DATA[period] 
	and Temp[3].DATA[period]<-50 
	and Temp[3].DATA[period] < Temp[3].DATA[period-1]
	and Temp[1].K[period] <  Temp[1].K[period-1] 
	and source.close[period]< source.close[period-1])
	then
     
     Signal = -1;
    end    
 
	
	 if Signal == 1 then
	 
		
			 core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size*3 , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font4, Up,   "\217");
			 id = id +1;
			 
	 
	 elseif Signal == -1 then
	 
	
			  core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size*3 , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font4, Down,  "\218");
			  id = id +1; 
	 
      
	 else 
	 
	         core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size*3 , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font4, Neutral,  "\108");
			  id = id +1; 
	  
   
	end
	
	
    core.host:execute("drawLabel1", id, -X , core.CR_RIGHT, -Y+Size*2, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL, "Signal");
	       id = id +1; 		   
		   

end




function DrawSAR(period ) 
    local X=Size*3*5;
	local Y=Size*24;
	
	local Color;
 
	
	 if SAR.DN:hasData(period) then
	 
			 if  not SAR.DN:hasData(period-1)then
			 core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Up,   "\199");
			 id = id +1; 
			 else
			 core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Up,   "\217");
			 id = id +1;
			 end
	 
	 elseif SAR.UP:hasData(period) then
	 
	  if  not SAR.UP:hasData(period-1)  then
	  core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Down,  "\201");
	  id = id +1; 
	   else
	  core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Down,  "\218");
	  id = id +1; 
	 
      end 
   
	end
	
	core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y+Size, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  source:barSize());
	       id = id +1; 
    core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y+Size*2, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL, "PSAR");
	       id = id +1; 		   
		   

end



function DrawCross(period ) 
    local X=Size*3*4;
	local Y=Size*24
	
	local Color;
 
	
	
	
	 if SHORT.DATA[period]> LONG.DATA[period] then
	 
			 if  SHORT.DATA[period-1]<LONG.DATA[period-1] then
			 core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Up,   "\199");
			 id = id +1; 
			 else
			 core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Up,   "\217");
			 id = id +1;
			 end
	 
	 elseif SHORT.DATA[period]< LONG.DATA[period] then
	 
	  if  SHORT.DATA[period-1]>LONG.DATA[period-1]  then
	  core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Down,  "\201");
	  id = id +1; 
	   else
	  core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Down,  "\218");
	  id = id +1; 
	 
      end 
   
	end
	
	core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y+Size, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  source:barSize());
	       id = id +1; 
    core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y+Size*2, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL, "Cross");
	       id = id +1; 		   
		   

end



function DrawMACD(period ) 
    local X=Size*3*3;
	local Y=Size*24
	
	local Color;
	 if MACD.MACD[period]> 0 then
	 Color=Up;
	 else
	 Color=Down;
	 end
	
	
	
	 if MACD.MACD[period]>MACD.SIGNAL[period] then
	 
			 if  MACD.MACD[period-1]<MACD.SIGNAL[period-1] then
			 core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Color,   "\199");
			 id = id +1; 
			 else
			 core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Color,   "\217");
			 id = id +1;
			 end
	 
	 elseif MACD.MACD[period]<MACD.SIGNAL[period] then
	 
	  if  MACD.MACD[period-1]>MACD.SIGNAL[period-1]  then
	  core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size,  core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Color,  "\201");
	  id = id +1; 
	   else
	  core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y-Size , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font3, Color,  "\218");
	  id = id +1; 
	 
      end 
   
	end
	
	core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y+Size, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  source:barSize());
	       id = id +1; 
    core.host:execute("drawLabel1", id, -X - 2, core.CR_RIGHT, -Y+Size*2, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL, "MACD");
	       id = id +1; 		   
		   

end


function DrawBars (num, period, max, min, value , Height, X, Y, Z)
    
	local i, j;
	
	if num == 1 then
    core.host:execute("drawLabel1", id, -X , core.CR_RIGHT, -Y+Size*3, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  "Bar % Meter ");
	id = id+1;
										
	end
 

	if period == source:size()-1 
	and  Mode == "E"
    then	
	period= period-1;
    elseif  Mode == "E" then
    return;        
	end
				

	
	if period ~= source:size()-1  
	and Mode == "L"
	then		
	return;	
	end
	
	
			
	core.host:execute("drawLabel1", id, -X - 2*num, core.CR_RIGHT, -Y+Size, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  string.format("%." .. 2 .. "f", BarPercent[num] ));
	     id = id +1; 
 

local Color= IN;

                     
	

					 
							  Color= NE; 
							  
							 
							    if BarsAverage[num] > BarsAverage[num+1] then
							     Color =  Up;
								 elseif BarsAverage[num] <  BarsAverage[num+1] then
                                 Color = Down;	
								 else
								  Color =Neutral;
                                end								 
							 	      
						   
					
								  for j  = 1, 25 , 5 do		               
								   
								core.host:execute("drawLabel1", id, -X - j, core.CR_RIGHT, -Y+Size*2, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font2, Color,  "\108");
								id = id +1; 
								
						   		

							 
						end

   
end	

 
function DrawSpread(Spread) 
    local X=Size*3*2;
	local Y=Size*24;
	
	core.host:execute("drawLabel1", 10001, -X - 2, core.CR_RIGHT, -Y+Size*1, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL, "Pips");	       
    core.host:execute("drawLabel1", 10002, -X - 2, core.CR_RIGHT, -Y+Size*2, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL, "Spread");	
	core.host:execute("drawLabel1", 10003, -X - 2, core.CR_RIGHT, -Y-Size, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  string.format("%." .. 2 .. "f", Spread ));
	        
	

end




function DrawRLW (num, period, max, min, value , Height, X, Y, Z)
    
	local i, j;
	
	if num == 1 then
    core.host:execute("drawLabel1", id, -X , core.CR_RIGHT, -Y+Size*3, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  "RWL % ");
	id = id+1;
										
	end
	
	
	core.host:execute("drawLabel1", id, -X - 2*num, core.CR_RIGHT, -Y+Size*2, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  source:barSize());
	       id = id +1; 
		
	core.host:execute("drawLabel1", id, -X - 2*num, core.CR_RIGHT, -Y+Size, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  string.format("%." .. 2 .. "f", value ));
	       id = id +1; 

	if period == source:size()-1 
	and  Mode == "E"
    then	
	period= period-1;
    elseif  Mode == "E" then
    return;        
	end
				

	
	if period ~= source:size()-1  
	and Mode == "L"
	then		
	return;	
	end

local Range = max-min;
local Percentage=  Range / 100;  
local Value = (value -min ) /  Percentage;   
local Index =  100/Height ;
local Color= IN;

                     
	

						for i =  1, Height , 10 do
							  Color= NE; 
							  
							  if Index *i <=  Value then
							  Color =  Coloring (i,   1, Height);		      
							  end		      
						   
					
								  for j  = 1, 25 , 5 do		               
								   
								core.host:execute("drawLabel1", id, -X - j, core.CR_RIGHT, -Y-i, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font2, Color,  "\108");
								id = id +1; 
								
						   		

							  end		
						end

   
end	


function DrawMA (num, period, max, min, value , Height, X, Y, Z)
    
	local i, j;
	
	if num == 1 then
    core.host:execute("drawLabel1", id, -X , core.CR_RIGHT, -Y+Size, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  "Moving Average Trend ");
	id = id+1;
										
	end
	


	if period == source:size()-1 
	and  Mode == "E"
    then	
	period= period-1;
    elseif  Mode == "E" then
    return;        
	end
				

	
	if period ~= source:size()-1  
	and Mode == "L"
	then		
	return;	
	end

local Range = max-min;
local Percentage=  Range / 100;  
local Value = (value -min ) /  Percentage;   
 
local Color= IN;

                     
	

						for i =  1, Height , Size do
							  Color= NE; 
							  
							 
							    if MA[num].DATA[ MA[num].DATA:size()-1] >  MA[num].DATA[ MA[num].DATA:size()-2] then
							     Color =  Up;
								 elseif MA[num].DATA[ MA[num].DATA:size()-1] <  MA[num].DATA[ MA[num].DATA:size()-2] then
                                 Color = Down;	
								 else
								  Color =Neutral;
                                end								 
							 	      
						   
					
								  for j  = 1, 25 , 5 do		               
								   
								core.host:execute("drawLabel1", id, -X - j, core.CR_RIGHT, -Y-i, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font2, Color,  "\108");
								id = id +1; 
								
						   		

							  end		
						end

   
end	


function DrawStochastic (num, period, max, min, value , Height, X, Y, Z)
    
	local i, j;
	
	if num == 1 then
    core.host:execute("drawLabel1", id, -X , core.CR_RIGHT, -Y+Size*3, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  "Stochastic Oscillator ");
	id = id+1;
										
	end
	
	
	core.host:execute("drawLabel1", id, -X - 2*num, core.CR_RIGHT, -Y+Size*2, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  TF[num]);
	       id = id +1; 
		


	if period == source:size()-1 
	and  Mode == "E"
    then	
	period= period-1;
    elseif  Mode == "E" then
    return;        
	end
				

	
	if period ~= source:size()-1  
	and Mode == "L"
	then		
	return;	
	end
	
		core.host:execute("drawLabel1", id, -X - 2*num, core.CR_RIGHT, -Y+Size, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  string.format("%." .. 2 .. "f", value ));
	       id = id +1; 

local Range = max-min;
local Percentage=  Range / 100;  
local Value = (value -min ) /  Percentage;   
local Index =  100/Height ;
local Color= IN;

                     
	

						for i =  1, Height , Size do
							  Color= NE; 
							  
							  if Index *i <=  Value then
							  Color =  Coloring (i,   1, Height);		      
							  end		      
						   
					
								  for j  = 1, 25 , 5 do		               
								   
								core.host:execute("drawLabel1", id, -X - j, core.CR_RIGHT, -Y-i, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font2, Color,  "\108");
								id = id +1; 
								
						   		

							  end		
						end

   
end	


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j ;
	
    for j = 1, 7, 1 do
		
			  if cookie == (100 +j) then
			  loading[j] = true;
			  core.host:execute ("setStatus", "Loading")
		      elseif  cookie == (200+j) then
			  core.host:execute ("setStatus", "")
			  loading[j] = false; 
              end
	end    
   
   if loading[1]or loading[2]or loading[3] or loading[4] or loading[5] or loading[6] or loading[7] then
   return;
   end
   
               
			 
    if cookie~= 1 then
	return;
	end
	
    local Ask = core.host:findTable("offers"):find("Instrument", source:instrument()).Ask;
	local Bid = core.host:findTable("offers"):find("Instrument", source:instrument()).Bid;
    local Spread  = (Ask  - Bid)/source:pipSize();	
	 DrawSpread(Spread);
		 
	  instance:updateFrom(0);	
	
   
        
		return core.ASYNC_REDRAW ;
end





function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end
