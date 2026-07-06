-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24282
-- Id: 7650

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()

    local ARRAY= {"USD","EUR", "JPY", "GBP","CHF", "AUD", "CAD","NZD" };
    indicator:name("Ratio Adjusted Net Advances");
    indicator:description("Ratio Adjusted Net Advances");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Base", "Base Currency", "", "USD");	
	local i;
	for i =1, 8, 1 do
    indicator.parameters:addStringAlternative("Base", ARRAY[i],"", ARRAY[i]);
	end

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("A_color", "Color of RANA", "Color of RANA", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	 
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
 
local List={};
local  Count;
local INVERS={};
    --local BS;
	local host;
	local offset;
	local weekoffset;
	local SourceData={};
local loading={};


-- Routine
function Prepare(nameOnly)
    Base = instance.parameters.Base;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Base) .. ")";
    instance:name(name);
	if nameOnly then
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
	
	if Count ~= 0 then
	
			for i = 1, Count, 1 do
			SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), source:barSize(), source:isBid(), 0, 200+i,100+i);
			loading[i]= true;
			end
			
    end  
 
    if (not (nameOnly)) then
        RANA = instance:addStream("RANA", core.Line, name, "RANA", instance.parameters.A_color, first);
		RANA:setWidth(instance.parameters.width);
        RANA:setStyle(instance.parameters.style);
		RANA:setPrecision (2); 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) or Count == 0 then
	end
	
	local FLAG= true;
	
	local p= {};
	
	   for i = 1, Count, 1 do
	     p[i]=  Initialization(period, i) ;
	  	 
     
	    if not p[i] then
		FLAG= false;
		end
	
	  end
	  
	  if not FLAG then
	  return;
	  end
	  
	  
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
	
	
	 if R+F  == 0 then
	 RANA[period]=0;
	 return;
	 end
	
	
        RANA[period] = (R -F)/ (R+F);
       
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



 for i = 1, Count, 1 do 
 
    if cookie == 200+i then
        loading[i] = false;
       
    elseif cookie == 100+i then 
        loading[i] = true;
    end
 end
 
 local Flag= true;
  for i = 1, Count, 1 do 
 
    if  loading[i]  then
	Flag=false;
    end   
   
 end

  if Flag then
   core.host:execute("setStatus", ""); 
  instance:updateFrom(0);  
  else
  core.host:execute("setStatus", "Loading");
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


