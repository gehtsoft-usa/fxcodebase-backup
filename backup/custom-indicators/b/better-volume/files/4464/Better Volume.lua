-- Id: 2094
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2161

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Better Plus");
    indicator:description("Better Plus");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("AVEREGE", "Show Averege", "", true);
	
	indicator.parameters:addString("SELECT", "Volume Type", "", "Regular");
	 indicator.parameters:addStringAlternative("SELECT" , "Regular", "", "Regular");
    indicator.parameters:addStringAlternative("SELECT" , "Up/Down", "", "Up");
    indicator.parameters:addStringAlternative("SELECT" , "Growt", "", "Growt");
	
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Frame", "Moving Averege Period","", 20, 2, 1000);
	 
	 indicator.parameters:addGroup("Volume Scale Mode"); 
	 indicator.parameters:addString("Scale", "Scale Type" , "", "Linear");
	 indicator.parameters:addStringAlternative("Scale" , "Linear", "", "Linear");
    indicator.parameters:addStringAlternative("Scale" , "Logarithmic ", "", "Logarithmic");
    indicator.parameters:addStringAlternative("Scale" , "Semi Logarithmic", "", "Semi");
	
	 indicator.parameters:addGroup("Volume Style");
	indicator.parameters:addString("MODE", "Volume Style", "", "BAR");
	 indicator.parameters:addStringAlternative("MODE" , "BAR", "", "BAR");	
    indicator.parameters:addStringAlternative("MODE" , "LINE", "", "LINE");
    indicator.parameters:addStringAlternative("MODE" , "DOT", "", "DOT");
	
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("VOLUME_color", "Color of VOLUME", "Color of VOLUME", core.rgb(0, 255, 0));
	
	indicator.parameters:addGroup("Averege Style");    
	indicator.parameters:addInteger("avgwidth", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("avgstyle", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("avgstyle", core.FLAG_LINE_STYLE);
	   indicator.parameters:addColor("AVEREGE_color", "Color of AVEREGE", "Color of AVEREGE", core.rgb(125, 125, 125));
	
	indicator.parameters:addGroup("Cursor Style");
	indicator.parameters:addBoolean("CURSOR", "Show Cursor", "", true);
	indicator.parameters:addInteger("CW", " Grid Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("CS", " Grid Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("CS", core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("CC", "Color of Grid", "", core.rgb(0, 0, 255))   
	
	indicator.parameters:addGroup("Grid Style");   
	indicator.parameters:addBoolean("GRID", "Show Grid", "", false);	
	indicator.parameters:addInteger("GW", " Grid Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("GS", " Grid Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("GS", core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("GC", "Color of Grid", "", core.rgb(255, 0, 0))   
	   
   indicator.parameters:addColor("Up", "Color of Up", "", core.rgb(0, 255, 0))   
   indicator.parameters:addColor("Down", "Color of Down", "", core.rgb(255, 0, 0))   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MODE;
local AVEREGE;
local SELECT;

local Up;
local Down;

local first;
local source = nil;

local MAX;
local CURSOR;

-- Streams block
local VOLUME = nil;
local Scale;
local GRID;
local RAW;
local  size;
local AVG;

-- Routine
 function Prepare(nameOnly)   
 
    CURSOR = instance.parameters.CURSOR;
    GRID = instance.parameters.GRID; 
    Scale = instance.parameters.Scale;
    MODE = instance.parameters.MODE;
	SELECT = instance.parameters.SELECT;
	AVEREGE = instance.parameters.AVEREGE;
	Frame = instance.parameters.Frame;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
    source = instance.source;
    first = source:first();
	
	 assert(  source:supportsVolume (), "Data Source does not support the trading volume");
	
	 local s, e;
    s, e = core.getcandle(source:barSize(), 0, 0);
	size=e-s;
	
	local name;
	
	if AVEREGE then
     name = profile:id() .. "(" .. source:name() .. ", ".. Frame.. ", " .. Scale  .. ")";
	else
	 name = profile:id() .. "(" .. source:name()   .. ")";
	end
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	RAW=instance:addInternalStream(first, 0);
	MVA = core.indicators:create("MVA", source.volume, Frame);
	
	 
	
	
				if MODE == "BAR" then
				VOLUME = instance:addStream("VOLUME", core.Bar, name, "VOLUME", instance.parameters.VOLUME_color, first);
				elseif MODE == "DOT" then
				VOLUME = instance:addStream("VOLUME", core.Dot, name, "VOLUME", instance.parameters.VOLUME_color, first);
				elseif MODE == "LINE" then
				VOLUME = instance:addStream("VOLUME", core.Line, name, "VOLUME", instance.parameters.VOLUME_color, first);
				end
				
				 VOLUME:setWidth(instance.parameters.width);
				 VOLUME:setStyle(instance.parameters.style);
	

	 
	 if AVEREGE then
	 AVG  = instance:addStream("OUT", core.Line, name, "AVEREGE", instance.parameters.AVEREGE_color, first);	
	 AVG:setWidth(instance.parameters.avgwidth);
     AVG:setStyle(instance.parameters.avgstyle);
	 else
	 AVG= instance:addInternalStream(0, 0);
	 end
	 
	VOLUME:setPrecision(math.max(2, instance.source:getPrecision()));
	AVG:setPrecision(math.max(2, instance.source:getPrecision()));
	 
end
local FLAG=0;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

       if source.volume[period] ~=0 then
		 if Scale == "Logarithmic" then
		 RAW[period]=math.log10(source.volume[period]);
		 elseif Scale == "Semi" then
		 RAW[period] =math.log(source.volume[period])/math.log(2);
		 else 
		 RAW[period]= source.volume[period];
		 end
	  else
	  RAW[period]=0;
      end	  
	 
	 
	 VOLUME[period] = RAW[period];
     
	 
	 
	     MVA:update(mode); 

       		 
		 
		 if  MVA.DATA:hasData(period) then
				 if Scale == "Logarithmic" then
				 AVG[period]=math.log10(MVA.DATA[period]);
				 elseif Scale == "Semi" then
				 AVG[period] =math.log(MVA.DATA[period])/math.log(2);
				 else 
				 AVG[period]= MVA.DATA[period];
				 end	
	     end
	 
	 
	   
	if SELECT == "Up"   then

		  
		   if source.close[period]>=source.close[period-1]  then
			
			 VOLUME:setColor(period, Up);	
			else
			 
			 VOLUME:setColor(period, Down);	
			end
	
	end
	 
	
	if SELECT == "Growt"  then
		if source.volume[period] >= source.volume[period-1]  then
		VOLUME:setColor(period, Up);	
		else	
		VOLUME:setColor(period, Down);	
		end
	end
	
	local price;
	     if Scale == "Logarithmic" then
         price= 10^RAW[period]; 		  
		 core.host:execute("drawLabel", 2001,  source:date(period)+size*12, RAW[period], tostring(price) );
		 elseif Scale == "Semi" then
		 price=2^RAW[period];
		 core.host:execute("drawLabel", 2001,  source:date(period)+size*12, RAW[period], tostring(price) );	
		else
		core.host:execute("drawLabel", 2001,  source:date(period)+size*12, RAW[period], tostring(RAW[period]) );		
		 end
		 
	if CURSOR then
	 core.host:execute("drawLine", 2002, source:date(first),RAW[period], source:date(period), RAW[period], instance.parameters:getInteger("CC"),instance.parameters:getInteger("CS"), instance.parameters:getInteger("CW"));
	end

	 if   Scale == "Linear" then
	 return;
	 end
 
			 MAX=core.max(RAW, core.range(first,period));
			 
			 local i;
			 local Level;
			 for i=1, 1000, 1 do
			 Level=i*1;
			 
			 if GRID then
			 core.host:execute("drawLine", i, source:date(first),Level, source:date(period), Level, instance.parameters:getInteger("GC"),instance.parameters:getInteger("GS"), instance.parameters:getInteger("GW"));
			 end				
							if Level >  MAX  then
							break;
							end
						
			 end
			 
			 
			  
			  core.host:execute("drawLine", 1001, source:date(period)+size*5,0, source:date(period)+size*5, MAX, core.rgb(125, 125, 125));
              LABEL(period, MAX);			  
			  
	 
end


function LABEL (p,m)
 
 local i,price 
 
		 for i = 1, 1000, 1 do
		 
		 if Scale == "Logarithmic" then
		  price= 10^(i*1);
		 else
		 price= 2^(i*1);
		 end
		
		 
		      if 1*i > m then
			  break;
			  end
		 
		 core.host:execute("drawLabel", 1001+i,  source:date(p)+size*6, i*1, tostring(price) );
				 
		 end
		 
		 
		 
		 
end

