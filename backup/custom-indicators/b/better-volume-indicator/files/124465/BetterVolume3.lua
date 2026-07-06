-- Id: 24197
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Better Volume 3");
    indicator:description("Better Volume 3");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("AVEREGE", "Show Averege", "", true);
	
	indicator.parameters:addString("SELECT", "Volume Type", "", "Regular");
	 indicator.parameters:addStringAlternative("SELECT" , "Regular", "", "Regular");
    indicator.parameters:addStringAlternative("SELECT" , "Up", "", "Up");
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
	indicator.parameters:addColor("VOLUME_color", "Color of VOLUME", "Color of VOLUME", core.rgb(255, 0, 0));
	
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
	   
	if AVEREGE then 
	end
end

local MODE;
local AVEREGE;
local SELECT;

local UP;
local DOWN;

local first;
local source = nil;

local MAX;
local CURSOR;

local VOLUME = nil;
local Scale;
local GRID;
local RAW;
local  size;
local AVG;

function Prepare()
    CURSOR = instance.parameters.CURSOR;
    GRID = instance.parameters.GRID; 
    Scale = instance.parameters.Scale;
    MODE = instance.parameters.MODE;
	SELECT = instance.parameters.SELECT;
	AVEREGE = instance.parameters.AVEREGE;
	Frame = instance.parameters.Frame;
    source = instance.source;
    first = source:first();
	
	 assert(  source:supportsVolume (), "Data Source does not support the trading volume");
	
	 local s, e;
    s, e = core.getcandle(source:barSize(), 0, 0);
	size=e-s;
	
	local name;
	RAW=instance:addInternalStream(first, 0);
	MVA = core.indicators:create("MVA", source.volume, Frame);
	if AVEREGE then
     name = profile:id() .. "(" .. source:name() .. ", ".. Frame.. ", " .. Scale  .. ")";
	else
	 name = profile:id() .. "(" .. source:name()   .. ")";
	end
    instance:name(name);
	 
	if SELECT == "Regular" or MODE == "LINE" then
	
				if MODE == "BAR" then
				VOLUME = instance:addStream("VOLUME", core.Bar, name, "VOLUME", instance.parameters.VOLUME_color, first);
				elseif MODE == "DOT" then
				VOLUME = instance:addStream("VOLUME", core.Dot, name, "VOLUME", instance.parameters.VOLUME_color, first);
				elseif MODE == "LINE" then
				VOLUME = instance:addStream("VOLUME", core.Line, name, "VOLUME", instance.parameters.VOLUME_color, first);
				end
				VOLUME:setPrecision(math.max(2, instance.source:getPrecision()));
				
				 VOLUME:setWidth(instance.parameters.width);
				 VOLUME:setStyle(instance.parameters.style);
	 else 
			 if MODE == "BAR" then
			UP = instance:addStream("UP", core.Bar, name, "VOLUME UP", core.rgb(0, 255, 0), first);	
			DOWN = instance:addStream("DOWN", core.Bar, name, "VOLUME DOWN", core.rgb(255, 0, 0), first);	
			elseif MODE == "DOT" then
			UP = instance:addStream("UP", core.Dot, name, "VOLUME UP", core.rgb(0, 255, 0), first);	
			DOWN = instance:addStream("DOWN", core.Dot, name, "VOLUME DOWN", core.rgb(255, 0, 0), first);
			elseif MODE == "LINE" then
			UP = instance:addStream("UP", core.Line, name, "VOLUME UP", core.rgb(0, 255, 0), first);	
			DOWN = instance:addStream("DOWN", core.Line, name, "VOLUME DOWN", core.rgb(255, 0, 0), first);
			end
			UP:setPrecision(math.max(2, instance.source:getPrecision()));
			DOWN:setPrecision(math.max(2, instance.source:getPrecision()));
			UP:setWidth(instance.parameters.width);
	UP:setStyle(instance.parameters.style);
	 DOWN:setWidth(instance.parameters.width);
	DOWN:setStyle(instance.parameters.style);
	 end
	 
	 if AVEREGE then
	 AVG  = instance:addStream("OUT", core.Line, name, "AVEREGE", instance.parameters.AVEREGE_color, first);	
    AVG:setPrecision(math.max(2, instance.source:getPrecision()));
	 AVG:setWidth(instance.parameters.avgwidth);
     AVG:setStyle(instance.parameters.avgstyle);
	 end
	 
	 
	 
end
local FLAG=0;

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
	 
     
	 if  AVG ~=nil then
	 
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
	 end
	   
	if SELECT == "Up" and MODE ~= "LINE"  then
		if period >= first and source:hasData(period) then
		
		   if source.close[period]>=source.close[period-1] and period > first then
			UP[period] = RAW[period];
			DOWN[period] = nil;
			else
			DOWN[period] = RAW[period];
			UP[period] = nil;
			end
		end
	end
	
	if SELECT == "Regular"  or MODE == "LINE" then
		if period >= first and source:hasData(period) then
			VOLUME[period] = RAW[period];
		end
	end
	
	if SELECT == "Growt"  and MODE ~= "LINE" then
		if source.volume[period] >= source.volume[period-1] and period > first then
			UP[period] = RAW[period];
			DOWN[period] = nil;
		else	
			DOWN[period] = RAW[period];
			UP[period] = nil;
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

	 
	 if period > 2 and Scale ~= "Linear" then
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
			 
			 
			  if period == source:size()-1 then
			  core.host:execute("drawLine", 1001, source:date(period)+size*5,0, source:date(period)+size*5, MAX, core.rgb(125, 125, 125));
              LABEL(period, MAX);			  
			  end
	 end
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

