-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75715

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trend Line Oscillator Helper");
    indicator:description("Trend Line Oscillator Helper");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("1. Point");	
	
	
    indicator.parameters:addString("Price1", "Price Source", "", "open");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
    indicator.parameters:addStringAlternative("Price1", "User Input", "", "Input");	
	
	indicator.parameters:addDouble("Level1", "1. Point Level", "", 0);
	
	indicator.parameters:addDate ("Date1", "1. Point Date", "Date", 0);
	indicator.parameters:setFlag ("Date1",core.FLAG_DATETIME);
	
	indicator.parameters:addGroup("2. Point");
	
    indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
    indicator.parameters:addStringAlternative("Price2", "User Input", "", "Input");	

	
	indicator.parameters:addDouble("Level2", "2. Point Level", "", 0);
	
	indicator.parameters:addDate ("Date2", "2. Point Date", "Date", 0);
	indicator.parameters:setFlag ("Date2",core.FLAG_DATETIME);
	
	indicator.parameters:addBoolean("Extend" , "Extend", "Extend",true);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color1", "Color of Line", "Color of Line", core.rgb(0, 0, 255));
	indicator.parameters:addColor("color2", "Color of Line Extend", "Color of Line", core.rgb(128, 128, 128));
	indicator.parameters:addColor("color3", "Color of Oscillator Up", "Color of Bar", core.rgb(0, 255, 0));	 
	indicator.parameters:addColor("color4", "Color of Oscillator Down", "Color of Bar", core.rgb(255, 0, 0));	 
	 
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Level={};
local Date={};
-- Streams block
local Line = nil;
local Extend;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Level[1]= instance.parameters.Level1;
	Level[2]= instance.parameters.Level2;
	
	Date[1]= instance.parameters.Date1;
	Date[2]= instance.parameters.Date2;
	
	Extend= instance.parameters.Extend;
	
	Price1= instance.parameters.Price1;
	Price2= instance.parameters.Price2;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if nameOnly then 
	return;
	end
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color1, first);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);	
    Line:setPrecision(math.max(2, instance.source:getPrecision()));	
	core.host:execute ("attachOuputToChart", "Line")
		
		
    Delta = instance:addStream("Delta", core.Bar, name, "Line", instance.parameters.color3, first);
    Delta:setPrecision(math.max(2, instance.source:getPrecision()));
    Delta:addLevel(0);		 		
end


local LastLine, LastSerial;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 	
	
	if period < source:size()-1 then
	return;
	end
	
	
	local p1=core.findDate (source, Date[1], false);
	local p2=core.findDate (source, Date[2], false);
	 
	if p1==-1
	or p2==-1
	or p1== p2 
	or p1< first
	or p1> (source:size()-1)
	or p2< first
	or p2> (source:size()-1)
	then
	return;
	end
	
	if p1 > p2 then
	Temp=p1;
	p1= p2;
    p2=Temp;
	
		if Price1 == "Input" then
			Start= Level[2];
			Stop=Level[1];
		else
			Start= source[Price1][p2];
			Stop=source[Price2][p1];	
		end	
	else
	
		if Price1 == "Input" then
		Start= Level[1];
		Stop=Level[2];
		else
			Start= source[Price1][p1];
			Stop=source[Price2][p2];		
		end
	end
	
	
	
	core.host:execute ("setStatus", p1.. " / ".. p2)
	core.drawLine(Line, core.range(p1, p2),Start, p1, Stop,  p2, instance.parameters.color1);
	
	if Extend then
	
	a= (Stop - Start) / (p2 - p1);
    b= Start - a * p1;
	
	Level[3]=a * first + b; 
	Level[4]=a * p1 + b; 
	Level[5]=a * p2 + b; 
	Level[6]=a * (source:size()-1)+ b; 
	core.drawLine(Line, core.range(first, p1)           ,Level[3] , first, Level[4],  p1              , instance.parameters.color2);	
	core.drawLine(Line, core.range(p2, source:size()-1) ,Level[5] , p2   , Level[6],   source:size()-1, instance.parameters.color2);
	end
	
	if  (LastSerial ~= source:serial(period) or LastLine ~= Line[period] )  then		
	
	  LastSerial = source:serial(period)
	  LastLine = Line[period]
	  
		for i= first, source:size()-1 , 1 do
		Delta[i]=source.close[i]-Line[i];
			if Delta[i] > 0 then
			   Delta:setColor(i,  instance.parameters.color3);		
			else
			   Delta:setColor(i,  instance.parameters.color4);			
			end
		end
	end
    
end

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75715

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 