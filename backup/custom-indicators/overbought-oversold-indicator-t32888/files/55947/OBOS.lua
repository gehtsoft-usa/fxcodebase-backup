-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32888

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

    local ARRAY= {"USD","EUR", "JPY", "GBP","CHF", "AUD", "CAD","NZD" };
    indicator:name("Overbought/Oversold Indicator");
    indicator:description("Overbought/Oversold Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 	 
	 indicator.parameters:addInteger("Period", "Period", "Period", 10);

	
	indicator.parameters:addString("Base", "Base Currency", "", "USD");	
	local i;
	for i =1, 8, 1 do
    indicator.parameters:addStringAlternative("Base", ARRAY[i],"", ARRAY[i]);
	end

    indicator.parameters:addGroup("Style"); 	 
    indicator.parameters:addColor("A_color", "Color of OB/OS Oscillator", "Color of OB/OS", core.rgb(0, 255, 0));
		 indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	 indicator.parameters:addGroup("Over Bought/Sold Style"); 
	  indicator.parameters:addDouble("Percentage", "As Percentage of Total Number of Instruments ", "", 20, 0, 100);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Base;

local first;
local source = nil;
local pauto =  "(%a%a%a)/(%a%a%a)";
-- Streams block
local RANA;
local loading={};
local List={};
local  Count;
local INVERS={};
    --local BS;
	local host;
	local offset;
	local weekoffset;
	local SourceData={};
 
	local SD;
	local OBOS;
	local Percentage;
local Period;

-- Routine
function Prepare(nameOnly)
    Base = instance.parameters.Base;
	Percentage = instance.parameters.Percentage;
	Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name().. ", " .. tostring(Period) .. ", " .. tostring(Base) .. ")";
    instance:name(name);
	
	
   if nameOnly  then
   return;
   end
	
	Count=0;
	
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	local rawlist, rawcount;
	
	rawlist, rawcount = getInstrumentList();
	
	local i;
	local  crncy1, crncy2;
	
	for i =1, rawcount, 1 do
	 crncy1, crncy2 = string.match(rawlist[i], pauto);
	 if crncy1== Base or  crncy2== Base then
	 Count=Count+1;
	 List[Count]= rawlist[i];
			 if  crncy1== Base then
			 INVERS[Count]= false; 
			 else
			 INVERS[Count]= true;
			 end
	 end
	
	end
	local Id=0;
	if Count ~= 0 then
	
			for i = 1, Count, 1 do
			Id=Id+1;
			SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), 300, 2000+Id, 1000+Id);
			loading[i]=true;
			end
			
    end  
 
        RANA = instance:addInternalStream(first,  0);
		
		SD= core.indicators:create("EMA", RANA, Period);
	
		OBOS = instance:addStream("OBOS", core.Line, name, "OBOS", instance.parameters.A_color,  SD.DATA:first() );
		OBOS:setPrecision (2);
		OBOS:setWidth(instance.parameters.width);
        OBOS:setStyle(instance.parameters.style);
		
		OBOS:addLevel((Count/100)*Percentage, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		OBOS:addLevel(-(Count/100)*Percentage, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
		 
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)



   
	
	 if Count == 0 then
	return;
	end


  local FLAG=false; 

   for j = 1, Count, 1 do
		       
			
                 if loading[j] then
				 FLAG= true;
				 end
	end    
   
 
	   

	

	
	local p= {};
	
	   for i = 1, Count, 1 do
	     p[i]=  Initialization(period, i) ;
		  if not p[i] then
		  FLAG= true;
		 end
	  end
	  
     if FLAG then
	return;
	end
	core.host:execute ("setStatus", "Instrument Count :" ..Count );
	
	
	  
	  
	local R=0;
    local F=0;	
	
	
	   for i = 1, Count, 1 do
	   
	   
	     if  not INVERS[i]  then
			   if SourceData[i].close[p[i]] > SourceData[i].open[p[i]] then
			   R=R+1;
			   end
			   if SourceData[i].close[p[i]] < SourceData[i].open[p[i]] then
			   F=F+1;
		   end
		 else
		 
				if SourceData[i].close[p[i]] > SourceData[i].open[p[i]] then
			  F=F+1;
			   end
			   if SourceData[i].close[p[i]] < SourceData[i].open[p[i]] then
			   R=R+1; 
			   end   
		   
		 end  
		   
	   end
	
	  
	
        RANA[period] = (R -F);
		
		SD:update(mode);
      
		
		if period <  SD.DATA:first() then
		return;
		end
		
		OBOS[period]= SD.DATA[period];
end


function getInstrumentList()
    local list={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
local j;
local FLAG=false; 
local Number=0;
local Id=0;


   for j = 1, Count, 1 do
	 Id=Id+1;	       
			  if cookie == (1000 + Id) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + Id ) then
			  loading[j]  = false;
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Number=Number+1;
				 end
	end    
   
 
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Count) .. " / " .. (Count) );	 
	else
	core.host:execute ("setStatus", "Loaded");	     
	 instance:updateFrom(0);
	end
	
	
   
        
    return core.ASYNC_REDRAW ;
end


function   Initialization(period, i)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);

  
    if loading[i] or SourceData[i]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[i], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


