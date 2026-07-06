-- Id: 16021

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63464

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
    indicator:name("Double OBOS indicator with CCI Filter");
    indicator:description("Double OBOS indicator with CCI Filter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    local colour = core.colors();
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("UpDown", "Show Up/Down", "", false);
	indicator.parameters:addBoolean("Show1", "Show 1. Indicator", "", true); 
	indicator.parameters:addBoolean("Show2", "Show 2. Indicator", "", true);
	

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD1", "1. Period", "", 9);
	indicator.parameters:addInteger("PERIOD2", "2. Period", "", 18);
	indicator.parameters:addInteger("Lookback", "Lookback Period", "", 4); 
	indicator.parameters:addInteger("TradeLength", "Trade length (in minutes)", "", 60);
    indicator.parameters:addInteger("OB_level", "OB level", "", 100);
    indicator.parameters:addInteger("OS_level", "OS level", "", -100);
	
	
	indicator.parameters:addGroup("CCI Filter Calculation");
	indicator.parameters:addBoolean("UseFilter", "Use CCI Filter", "", true);
	indicator.parameters:addInteger("CCIPeriod", "CCI Period", "", 14);
	indicator.parameters:addInteger("CCILookback", "Lookback Period", "", 14);
	
	indicator.parameters:addDouble("BuyLevel", "Buy Level ", "", 0);
	indicator.parameters:addDouble("SellLevel", "Sell Level", "", 0);
	

	
	indicator.parameters:addGroup("Style");
	
	indicator.parameters:addColor("ProfitColor", "Profit Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("LossColor", "Loss Color", "", core.rgb(255, 0, 0));
	
	 indicator.parameters:addInteger("widthProfit", "Profit Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleProfit", "Profit Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleProfit", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("UP_color1", "1. Indicator Color of UP", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color1", "1. Indicator Color of DOWN", "", core.rgb(0, 155, 0));
	
	indicator.parameters:addColor("UP_color2", "2. Indicator Color of UP", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("DN_color2", "2. Indicator Color of DOWN", "", core.rgb(0, 0, 155));
	
    indicator.parameters:addColor("OBOS_color_1", "1. Indicator Color of Overbought/Oversold", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("OBOS_color_2", "2. Indicator Color of Overbought/Oversold", "", core.rgb(128, 0, 255));
    indicator.parameters:addColor("ZL_color", "Zero line color", "", colour.Yellow);
    indicator.parameters:addColor("OB_color", "OB line color", "", colour.Magenta);
    indicator.parameters:addColor("OS_color", "OS line color", "", colour.Magenta);
    indicator.parameters:addColor("MID_color_1", "Mid line color", "", colour.Yellow);
	indicator.parameters:addColor("MID_color_2", "Mid line color", "", colour.Yellow);
	
	indicator.parameters:addColor("Background","Background Color","", core.COLOR_BACKGROUND  ); 
	indicator.parameters:addColor("Shade_color", "Indicator shading color", "", colour.Gray);

	
    indicator.parameters:addInteger("widthLinReg", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, " Signal Type A");	
	Parameters (2, " Signal Type B");	
 
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 
local Lookback;
local Number = 2;
local Up={};
local Down={};
local Label={};
local ON={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST=true;
local OnlyOnce;
local U={};
local D={};
local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local font;
local ShowAlert;
local Shift=0; 
local Trade;
local Length;
local TradeLength;
local UseFilter, CCIPeriod, CCILookback, BuyLevel, SellLevel, CCI;
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local first;
local source = nil;

local PERIOD1;
local open1,low1, high1, close1;
local MA1={};
local BUFFER1={};
local UP1, DOWN1;

local PERIOD2;
local open2,low2, high2, close2;
local MA2={};
local BUFFER2={};
local UP2, DOWN2;
local Show1,Show2;
local mid2, mid1;
local Signal1,Signal2;
local Trend1,Trend2;
local min, max;


-- Routine
function Prepare(nameOnly) 
    UseFilter= instance.parameters.UseFilter;
	CCIPeriod= instance.parameters.CCIPeriod;
	CCILookback= instance.parameters.CCILookback;
	BuyLevel= instance.parameters.BuyLevel;
	SellLevel= instance.parameters.SellLevel;
    Length = instance.parameters.Length;
    OnlyOnceFlag=true;
	FIRST=true;
	Lookback = instance.parameters.Lookback;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;

	
	 source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end	
	
		Size=instance.parameters.Size;
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
  
	Show1= instance.parameters.Show1;
    Show2= instance.parameters.Show2;
	
	UpDown= instance.parameters.UpDown;
   
	
	s1, e1 = core.getcandle("m1", 0, 0, 0);
	TradeLength= (e1-s1) * instance.parameters.TradeLength;
	
	 s2, e2 = core.getcandle(source:barSize(), 0, 0, 0);
	
	TradeLength= TradeLength / (e2-s2);
	
	TradeLength= round(TradeLength, 0);
	
 
    PERIOD1 = instance.parameters.PERIOD1;
	PERIOD2 = instance.parameters.PERIOD2;

   
	

          BUFFER1[1]= instance:addInternalStream(0, 0);	
		  BUFFER1[2]= instance:addInternalStream(0, 0);	
          BUFFER1[3]= instance:addInternalStream(0, 0);		 
          BUFFER1[4]= instance:addInternalStream(0, 0);			   
		  BUFFER1[5]= instance:addInternalStream(0, 0);				
		  BUFFER1[6]= instance:addInternalStream(0, 0);		

         Signal1= instance:addInternalStream(0, 0);		
		 Signal2= instance:addInternalStream(0, 0);		

         Trend1= instance:addInternalStream(0, 0);		
		 Trend2= instance:addInternalStream(0, 0);

         Trade= instance:addInternalStream(0, 0);	 		 
		  
		  UP1= instance:addInternalStream(0, 0);
		  DOWN1= instance:addInternalStream(0, 0);		  
		  
		  if UseFilter then
		  CCI= core.indicators:create("CCI", source,  CCIPeriod);
		  end
		  
	      MA1[1] = core.indicators:create("EMA", BUFFER1[1],  PERIOD1);
	      MA1[2] = core.indicators:create("EMA", BUFFER1[5],  PERIOD1);
		  MA1[3] = core.indicators:create("EMA",  BUFFER1[6],  PERIOD1);
		  MA1[4] = core.indicators:create("EMA", UP1,  PERIOD1);
		  local first1 = MA1[4].DATA:first();
		  
		  
		  
		  BUFFER2[1]= instance:addInternalStream(0, 0);	
		  BUFFER2[2]= instance:addInternalStream(0, 0);	
          BUFFER2[3]= instance:addInternalStream(0, 0);		 
          BUFFER2[4]= instance:addInternalStream(0, 0);			   
		  BUFFER2[5]= instance:addInternalStream(0, 0);				
		  BUFFER2[6]= instance:addInternalStream(0, 0);		 
		  
		  UP2= instance:addInternalStream(0, 0);
		  DOWN2= instance:addInternalStream(0, 0);		  
		  
	      MA2[1] = core.indicators:create("EMA", BUFFER2[1],  PERIOD2);
	      MA2[2] = core.indicators:create("EMA", BUFFER2[5],  PERIOD2);
		  MA2[3] = core.indicators:create("EMA",  BUFFER2[6],  PERIOD2);
		  MA2[4] = core.indicators:create("EMA", UP2,  PERIOD2);
		  local first2 = MA2[4].DATA:first();

   
	
			if Show1 then
			open1=instance:addStream("open1", core.Line, name, "1. open", core.rgb(128, 128, 128), first1);
			high1=instance:addStream("high1", core.Line, name, "1. high", core.rgb(128, 128, 128), first1);
			low1=instance:addStream("low1", core.Line, name, "1. low", core.rgb(128, 128, 128), first1);
			close1=instance:addStream("close1", core.Line, name, "1. close", core.rgb(128, 128, 128), first1);
			instance:createCandleGroup("OBOS1", "", open1, high1, low1, close1);
			mid1=instance:addStream("MID1", core.Line, name.."1. MID", "1. MID", instance.parameters.MID_color_1, first1);
			mid1:addLevel(instance.parameters.OB_level, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.OB_color);
			mid1:addLevel(instance.parameters.OS_level, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.OS_color);
			mid1:addLevel(0, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.ZL_color);
			else
			open1= instance:addInternalStream(0, 0);	
			high1= instance:addInternalStream(0, 0);	
			low1= instance:addInternalStream(0, 0);	
			close1= instance:addInternalStream(0, 0);	
			mid1= instance:addInternalStream(0, 0);	
			end
		
			if Show2 then
			open2=instance:addStream("open2", core.Line, name, "2. open", core.rgb(128, 128, 128), first2);
			high2=instance:addStream("high2", core.Line, name, "2. high", core.rgb(128, 128, 128), first2);
			low2=instance:addStream("low2", core.Line, name, "2. low", core.rgb(128, 128, 128), first2);
			close2=instance:addStream("close2", core.Line, name, "2. close", core.rgb(128, 128, 128), first2);
			instance:createCandleGroup("OBOS2", "", open2, high2, low2, close2);
			mid2=instance:addStream("MID2", core.Line, name.."2. MID", "2. MID", instance.parameters.MID_color_2, first2);
			mid2:addLevel(instance.parameters.OB_level, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.OB_color);
			mid2:addLevel(instance.parameters.OS_level, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.OS_color);
			mid2:addLevel(0, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.ZL_color);
			else
			open2= instance:addInternalStream(0, 0);	
			high2= instance:addInternalStream(0, 0);	
			low2= instance:addInternalStream(0, 0);	
			close2= instance:addInternalStream(0, 0);	
			mid2= instance:addInternalStream(0, 0);	
			end
	 
	 
	 open1:setPrecision(math.max(2, instance.source:getPrecision()));
	 high1:setPrecision(math.max(2, instance.source:getPrecision()));
	 low1:setPrecision(math.max(2, instance.source:getPrecision()));
	 close1:setPrecision(math.max(2, instance.source:getPrecision()));
	 mid1:setPrecision(math.max(2, instance.source:getPrecision()));
       
     open2:setPrecision(math.max(2, instance.source:getPrecision()));
	 high2:setPrecision(math.max(2, instance.source:getPrecision()));
	 low2:setPrecision(math.max(2, instance.source:getPrecision()));
	 close2:setPrecision(math.max(2, instance.source:getPrecision()));
	 mid2:setPrecision(math.max(2, instance.source:getPrecision()));
 
	
	instance:ownerDrawn(true);
	Initialization ();
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function  Initialization ()
    
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	 end
	 
	 
	 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  Up[i]=instance.parameters:getString("Up" .. i);
	  Down[i]=instance.parameters:getString("Down" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Up[i]=nil;
	  Down[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	


local init = false;
 
function Draw(stage, context)
       
	   
        if not init then
           context:createPen (1, context:convertPenStyle (instance.parameters.styleLinReg), context:pointsToPixels (instance.parameters.widthLinReg), instance.parameters.ZL_color);
		   context:createPen (2, context:convertPenStyle (instance.parameters.styleLinReg), context:pointsToPixels (instance.parameters.widthLinReg), instance.parameters.OB_color);
		   context:createPen (3, context:convertPenStyle (instance.parameters.styleLinReg), context:pointsToPixels (instance.parameters.widthLinReg), instance.parameters.OS_color);
		   context:createSolidBrush (4, instance.parameters.Shade_color);
	       context:createSolidBrush (5, instance.parameters.Shade_color);
		   
		   context:createPen (6, context.SOLID, 1, instance.parameters.Shade_color)
	       context:createPen (7, context.SOLID, 1, instance.parameters.Shade_color)
		   
           context:createSolidBrush (8, instance.parameters.Shade_color);
	       context:createSolidBrush (9, instance.parameters.Shade_color);
		   
		   context:createPen (10, context.SOLID, 1, instance.parameters.Shade_color)
	       context:createPen (11, context.SOLID, 1, instance.parameters.Shade_color)
		   
		   context:createPen (12, context:convertPenStyle (instance.parameters.styleProfit), context:pointsToPixels (instance.parameters.widthProfit), instance.parameters.ProfitColor);
		   context:createPen (13, context:convertPenStyle (instance.parameters.styleProfit), context:pointsToPixels (instance.parameters.widthProfit), instance.parameters.LossColor);
	  
            init = true;
        end 
		
		
	  
	  local First= math.max(source:first(), context:firstBar() );
	  local Last= math.min(source:size()-1, context:lastBar() );
	  
	  
	  if stage ~= 2 then
	  return;
	  end
	  
	  visible, y1 = context:pointOfPrice (0);
	  visible, y2 = context:pointOfPrice (instance.parameters.OB_level);
	  visible, y3 = context:pointOfPrice (instance.parameters.OS_level);
	  context:drawLine (1, context:left (), y1, context:right (), y1);
	  context:drawLine (2, context:left (), y2, context:right (), y2);
	  context:drawLine (3, context:left (), y3, context:right (), y3);
			  
			  for period= First, Last, 1 do  
						if period+TradeLength > source:size()-1 then
					EndPeriod= source:size()-1;
					else
					EndPeriod= period+TradeLength;
					end
					
					x, x1, x2 = context:positionOfBar (EndPeriod);
					
					if Trade[period]==1 then
						if source.close[period]< source.close[EndPeriod] then
						context:drawLine (12, x, context:top (), x, context:bottom ()); 
						else
						context:drawLine (13, x, context:top (), x, context:bottom ()); 
						end			
					elseif Trade[period]==-1 then
						if source.close[period]> source.close[EndPeriod] then
						context:drawLine (12, x, context:top (), x, context:bottom ()); 
						else
						context:drawLine (13, x, context:top (), x, context:bottom ()); 
						end  
					end
					
				end	
	 
	  
	   if stage ~= 0 then
	   return;
	   end
	   
	  
	 
	  
	  local  Color1=nil;
      local  Color2=nil;
	  
		for period= First, Last, 1 do  

        Color1=nil;
        Color2=nil;
		
				
					if Show1 then
									if mid1[period] >= instance.parameters.OB_level then 
									Color1=4  
									Pen1=6; 
									elseif mid1[period] <= instance.parameters.OS_level then        
									Color1= 5 
									Pen1=7;		 			
									end 
								
						end
			
						if Show2 then
							if mid2[period] >= instance.parameters.OB_level then    
							Color2=8;
							Pen2=10; 
							elseif mid2[period] <= instance.parameters.OS_level then
							Color2=9;
							Pen2=11;	 
							end	
						 
						
							
				
						end
			
			x, x1, x2 = context:positionOfBar (period);
			
			if Color1~= nil   then
			context:drawRectangle (Pen1, Color1, x1, context:top (), x2, context:bottom (), 0);
			end
			if Color2~= nil  then
			context:drawRectangle (Pen2, Color2, x1, context:top (), x2, context:bottom (), 0);
			end
			 
			
			
		end
		
	
	
	 
end		

 
function Calculate1 (period,mode)

 
   Trend1[period]=Trend1[period-1];
   

   BUFFER1[1][period]=(source.high[period]+source.low[period]+source.close[period]*2)/4;
	
  	
	MA1[1]:update(mode);	
	BUFFER1[3][period]= MA1[1].DATA[period];
	
	if  period <  source:first() + PERIOD1  then
	return;
	end
	
	BUFFER1[4][period] = mathex.stdev (BUFFER1[1], period - PERIOD1, period);
	
		
	BUFFER1[5][period] =  (BUFFER1[1][period]  - BUFFER1[3][period]) *100  / BUFFER1[4][period];

	MA1[2]:update(mode);
	BUFFER1[6][period]= MA1[2].DATA[period] ;

	MA1[3]:update(mode);
	UP1[period]=MA1[3].DATA[period];

	MA1[4]:update(mode);
	DOWN1[period] =MA1[4].DATA[period];

	open1[period] = DOWN1[period];
	close1[period] = UP1[period];
	high1[period] = math.max(open1[period], close1[period]);
    low1[period] = math.min(open1[period], close1[period]);
		
	mid1[period] = (high1[period] + low1[period])/2;
    
	Signal1[period]=0;
  
	                            if low1[period-1] < low1[period] and high1[period]< high1[period-1] then
									open1:setColor(period, instance.parameters.OBOS_color_1);
									
									 
									Signal1[period]=1;
									 
									
								else
								
								        if UP1[period] > DOWN1[period] then 										
										Trend1[period]=1;
										else
										Trend1[period]=-1;
										end
								 
									if UpDown then	
										if UP1[period] > DOWN1[period] then 
										open1:setColor(period, instance.parameters.UP_color1);
										Trend1[period]=1;
										else
										open1:setColor(period, instance.parameters.DN_color1);
										Trend1[period]=-1;
										end
									 
									end
							
	                            end
end

function Calculate2 (period,mode)

   Trend2[period]=Trend2[period-1];
   
   BUFFER2[1][period]=(source.high[period]+source.low[period]+source.close[period]*2)/4;
	
  	
	MA2[1]:update(mode);	
	BUFFER2[3][period]= MA2[1].DATA[period];
	
	if  period <  source:first() + PERIOD2  then
	return;
	end
	
	BUFFER2[4][period] = mathex.stdev (BUFFER2[1], period - PERIOD2, period);
	
		
	BUFFER2[5][period] =  (BUFFER2[1][period]  - BUFFER2[3][period]) *100  / BUFFER2[4][period];

	MA2[2]:update(mode);
	BUFFER2[6][period]= MA2[2].DATA[period] ;

	MA2[3]:update(mode);
	UP2[period]=MA2[3].DATA[period];

	MA2[4]:update(mode);
	DOWN2[period] =MA2[4].DATA[period];

	open2[period] = DOWN2[period];
	close2[period] = UP2[period];
	high2[period] = math.max(open2[period], close2[period]);
    low2[period] = math.min(open2[period], close2[period]);
	

	mid2[period] = (high2[period] + low2[period])/2;
	
	Signal2[period]=0;
	
	
	                        if low2[period-1] < low2[period] and high2[period]< high2[period-1] then
								open2:setColor(period, instance.parameters.OBOS_color_2);
								
								     
									Signal2[period]=1;
								 
									
							else
							     if UP2[period] > DOWN2[period] then 										
										Trend2[period]=1;
								else
										Trend2[period]=-1;
								end
										
										
								if UpDown  then
									if UP2[period] > DOWN2[period] then 
									open2:setColor(period, instance.parameters.UP_color2);
									else
									open2:setColor(period, instance.parameters.DN_color2);
									end
								 
									
								end
								
	 end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < source:first() or not source:hasData(period) then
        return;		
    end  
	
	open2:setColor(period, instance.parameters.Background);
	open1:setColor(period, instance.parameters.Background);
	
	Calculate1(period, mode);
	Calculate2(period, mode);
	
	if  mid2[period] >= instance.parameters.OB_level
	or mid2[period] <= instance.parameters.OS_level  
	or mid1[period] >= instance.parameters.OB_level
	or mid1[period] <= instance.parameters.OS_level  
	then
	
	    if not UpDown then
			 if Signal2[period] == 0 then							 
			 open2:setColor(period, instance.parameters.Shade_color);
			 end
			 
			 if Signal1[period] == 0 then	
			 open1:setColor(period, instance.parameters.Shade_color);
			 end
		end	
 
	end
	
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	
	core.host:execute ("removeLabel", source:serial(period)); 
    
	min= nil ;
	
	 if UseFilter then
	 CCI:update(mode); 
		 if period < CCI.DATA:first()+CCILookback then
		 return;
		 end
	 min, max =	 mathex.minmax(CCI.DATA,period-CCILookback+1, period );
     end
	 
    Activate (1, period);
	Activate (2, period);
end



function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Activate (id, period)

  
	  if id == 1  and ON[id]  then
	  
	       
			if  Signal1[period]== 1 and Signal2[period]==1  
			and (Signal1[period-1]~= 1 and Signal2[period-1]~=1	)
			and Trend1[period]==-1 
			and (not UseFilter  or  min < BuyLevel )
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, low1[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");
             Trade[period]=1;
 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Open Long ", period);
							  SendAlert(" Open Long ");  
							        
									Pop(Label[id], " Open Long " );  	
								    
								 
							  end
			elseif   Signal1[period]== 1 and Signal2[period]==1
            and (Signal1[period-1]~= 1 and Signal2[period-1]~=1	)	
            and Trend1[period]==1		
            and (not UseFilter  or  max > SellLevel )			
            then			
			Trade[period]=-1;
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, high1[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Open Short ", period);	
								 
									Pop(Label[id], " Open Short " );  	
								    SendAlert(" Open Short ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	  if id == 2  and ON[id]  then
	  
	       
			if   mid1[period]> mid1[period-1]
			and mid1[period-1]<= mid1[period-2]
			and Signal2[period]==1 
			and ItIs(period)
			and (not UseFilter  or  min < BuyLevel )
			then
			Trade[period]=1;           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, low1[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Open Long ", period);
							  SendAlert(" Open Long ");  
							        
									Pop(Label[id], " Open Long " );  	
								    
								 
							  end
			elseif  mid1[period] < mid1[period-1]
			and mid1[period-1] >= mid1[period-2]
			and Signal2[period]==1 
			and ItIs(period)
			and (not UseFilter  or  max > SellLevel )
            then			
			Trade[period]=-1;
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, high1[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Open Short ", period);	
								 
									Pop(Label[id], " Open Short " );  	
								    SendAlert(" Open Short ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end

function ItIs(Start) 

local Flag=true;

	for period =Start-1, Start-Lookback, -1 do
		if Signal1[period] == 1 then
		Flag=false;
		break;
		end
	end
 
return Flag;

end


function AsyncOperationFinished (cookie, success, message)
end


function Pop(label , note)
  
   if not Show then
   return;
   end
   
   core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );
 
end


function SendAlert(message)
    if not ShowAlert then
        return;
    end
 
    terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  if OnlyOnce and OnlyOnceFlag== false then
 return;
 end
 
  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

 if OnlyOnce and OnlyOnceFlag== false then
 return;
 end

 
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 


