-- Id: 14018
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62128

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
    indicator:name("Rahul Mohinder Oscillator histogram");
    indicator:description("Rahul Mohinder Oscillator histogram");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	  indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Period1", "1. EMA Period", "Period", 30);
	 indicator.parameters:addInteger("Period2", "2. EMA Period", "Period", 30);
	 indicator.parameters:addInteger("Period3", "3. EMA Period", "Period", 81);
	 
	indicator.parameters:addInteger("Period4", "Signal Line Period", "Period", 30); 
	indicator.parameters:addGroup("Style"); 
	
	indicator.parameters:addString("Method", "Line Method", "Method" , "Bar");
    indicator.parameters:addStringAlternative("Method", "Bar", "Bar" , "Bar");
    indicator.parameters:addStringAlternative("Method", "Line", "Line" , "Line");
	
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128,128));
	indicator.parameters:addBoolean("Show", "Show Background", "", false);
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Arrow", "Color of Arrow", "Color of Arrow", core.rgb(0, 0, 255));
	indicator.parameters:addDouble("transparency", "Transparency", "Transparency", 70);
	

	
	indicator.parameters:addColor("Signal Color", "Color of Signal", "Color of Signal", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("width2", "Signal Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Period4;
-- Streams block
local RMO = nil;
local MA={};
local SwingTrd={};
local EMA={};
local Period={};
local Up, Down,Neutral;
local Background;
local transparency;
local up, down;
local Arrow;
local Method;
local signal,Signal;
local Show;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Show=instance.parameters.Show;
    first = source:first();
	Down=instance.parameters.Down;
	Up=instance.parameters.Up;
	Neutral=instance.parameters.Neutral;
	Method=instance.parameters.Method;
	Period4=instance.parameters.Period4;
	
	Period[1]=instance.parameters.Period1;
	Period[2]=instance.parameters.Period2;
	Period[3]=instance.parameters.Period3;
	
	Arrow=instance.parameters.Arrow;

    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	MA[1]= instance:addInternalStream(source:first()+2, 0);
	MA[2]= instance:addInternalStream(MA[1]:first()+2, 0);
	MA[3]= instance:addInternalStream(MA[2]:first()+2, 0);
	MA[4]= instance:addInternalStream(MA[3]:first()+2, 0);
	MA[5]= instance:addInternalStream(MA[4]:first()+2, 0);
	MA[6]= instance:addInternalStream(MA[5]:first()+2, 0);
	MA[7]= instance:addInternalStream(MA[6]:first()+2, 0);
	MA[8]= instance:addInternalStream(MA[7]:first()+2, 0);
	MA[9]= instance:addInternalStream(MA[8]:first()+2, 0);
	MA[10]= instance:addInternalStream(MA[9]:first()+2, 0);
	
	SwingTrd[1]= instance:addInternalStream(MA[9]:first()+2, 0);
	SwingTrd[2]= instance:addInternalStream(MA[9]:first()+2, 0);
	SwingTrd[3]= instance:addInternalStream(MA[9]:first()+2, 0);
	
	EMA[1] = core.indicators:create("EMA", SwingTrd[1], Period[1]);
	EMA[2] = core.indicators:create("EMA", SwingTrd[2], Period[2]);
	EMA[3] = core.indicators:create("EMA", SwingTrd[1], Period[3]);
	
	
	

	
     
	    if Method == "Line" then
		RMO = instance:addStream("RMO", core.Line, name, "RMO", Neutral, MA[10]:first()+Period[1]+Period[2]+Period[3]);
		RMO:setWidth(instance.parameters.width1);
        RMO:setStyle(instance.parameters.style1);
		else
        RMO = instance:addStream("RMO", core.Bar, name, "RMO", Neutral, MA[10]:first()+Period[1]+Period[2]+Period[3]);
		end
		
		signal = core.indicators:create("EMA", RMO, Period4);
		Signal = instance:addStream("Signal", core.Line, name, "Signal", Neutral, signal.DATA:first());
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
		
		Background= instance:addInternalStream(RMO:first(), 0);
		
        RMO:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		

    instance:ownerDrawn(Show);
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", 9, core.H_Center, core.V_Bottom, Arrow, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", 9, core.H_Center, core.V_Top, Arrow, 0);
	 
end

local init = false;
 
function Draw(stage, context)
    if stage~=0 then
	return;
	end
        if not init then 
			context:createSolidBrush (1, Up);
			context:createSolidBrush (2, Down);
			context:createSolidBrush (3, Neutral);			
			
		    transparency= context:convertTransparency (instance.parameters.transparency)
            init = true;
        end
		
		
    for period = math.max(RMO:first(),context:firstBar ()) , math.min(source:size()-1, context:lastBar ()), 1 do
	
	  if Background:hasData(period) then
		   if Background[period]==1 then	 
		   brush=1;
		   elseif Background[period]==-1 then 
		   brush=2;   
		   else	    
		   brush=3;  
		   end
		   
			
			 
			y1=context:top (); 
			y2=context:bottom ();
			x, x1, x2 = context:positionOfBar (period);
			context:drawRectangle (-1, brush, x1, y1, x2, y2, transparency);
		end
	end
end
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    
	
	Background[period]=0;
	
	if period <  MA[1]:first()  then
	return;
	end	
	
	MA[1][period]= mathex.avg(source , period-2+1, period);
	
	if period < MA[2]:first()  then
	return;
	end	
	MA[2][period]= mathex.avg(MA[1], period-2+1, period);
	
	if period < MA[3]:first() then
	return;
	end
    MA[3][period]= mathex.avg(MA[2], period-2+1, period);
	
	if period < MA[4]:first() then
	return;
	end
    MA[4][period]= mathex.avg(MA[3], period-2+1, period);	
	
	if period < MA[5]:first() then
	return;
	end
	MA[5][period]= mathex.avg(MA[4], period-2+1, period);
	
	if period < MA[6]:first() then
	return;
	end
	MA[6][period]= mathex.avg(MA[5], period-2+1, period);
	
	if period < MA[7]:first() then
	return;
	end
	MA[7][period]= mathex.avg(MA[6], period-2+1, period);
	
	if period < MA[8]:first() then
	return;
	end
	MA[8][period]= mathex.avg(MA[7], period-2+1, period);
	
	if period < MA[9]:first() then
	return;
	end
	MA[9][period]= mathex.avg(MA[8], period-2+1, period);
	
	if period < MA[10]:first()+1 then
	return;
	end
	MA[10][period]= mathex.avg(MA[9], period-2+1, period);
	
	
	local min,max=mathex.minmax(source, period-10+1, period);	
	SwingTrd[1][period]=  100 * (source[period] - (MA[1][period]+MA[2][period]+MA[3][period]+MA[4][period]+MA[5][period]+MA[6][period]+MA[7][period]+MA[8][period]+MA[9][period]+MA[10][period])/10)/(max-min);
	
    
	
	EMA[1]:update(mode);
	if period  < EMA[1].DATA:first() then
	return;
	end
		
	SwingTrd[2][period] = EMA[1].DATA[period];
	
	EMA[2]:update(mode);
    if period  < EMA[2].DATA:first() then
	return;
	end
	
	SwingTrd[3][period] = EMA[2].DATA[period];
	
	EMA[3]:update(mode);
	if period  < EMA[3].DATA:first() then
	return;
	end 
	
	 RMO[period] =EMA[3].DATA[period];
	 
	 
	 if RMO[period]>0 then
	 Background[period]=1;
	 elseif RMO[period]<0 then 
	 Background[period]=-1;
	 else
	 Background[period]=0;
	 end
	 
	 local Impulse=0;
	 
	 if  SwingTrd[2][period] > 0 then
	 Impulse= 1;
	 elseif  SwingTrd[2][period] < 0 then
	  Impulse= -1;
	 end
	 
	 
	 if Impulse== 1  then
	 RMO:setColor(period,Up);
     elseif Impulse==-1 then
	  RMO:setColor(period,Down);
      else	 
	  RMO:setColor(period,Neutral);
	 end
	 
	 up:setNoData (period);
	 down:setNoData (period);
	 
	 if  core.crossesOver (SwingTrd[2],SwingTrd[3], period)  then
	  up:set(period, RMO[period], "\217" );
     elseif core.crossesUnder (SwingTrd[2],SwingTrd[3], period)  then
	  down:set(period, RMO[period], "\218" );
	 end
	 
	 signal:update(mode);
     if period < signal.DATA:first() then
	 return;
	 end
	 Signal[period]=signal.DATA[period];
   
 end
 