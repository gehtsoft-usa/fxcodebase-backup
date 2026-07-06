-- Id: 8541
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32247

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
    indicator:name("ADVANCING-DECLINING ISSUES");
    indicator:description("ADVANCING-DECLINING ISSUES");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Selector");	
	
	local Currency={"USD", "EUR", "GBP", "CHF", "JPY", "AUD", "NZD", "CAD"};
	 
	 
	local i; 
    indicator.parameters:addString("Currency" , "Base Currency ", "",Currency[1]);
	for i =1, 8 , 1 do
    indicator.parameters:addStringAlternative("Currency", Currency[i], "", Currency[i]);
    end
	
	
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color", "Color of ADI", "Color of ADI", core.rgb(255, 0, 0));
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
-- Streams block
local Out={};
local Currency;

local loading={};
local List={};
local  Count;
local RawList, RawCount;
local SourceData={};
local pauto =  "(%a%a%a)/(%a%a%a)";
local Color;



	local host;
	local offset;
	local weekoffset;



local MA={};
-- Routine
function Prepare(nameOnly) 
    Method = instance.parameters.Method;	
    Color = instance.parameters.color;
	Currency = instance.parameters.Currency;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. Currency .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	local crncy1, crncy2;
	 
	RawList, RawCount= getInstrumentList();
		
	
	local i ;
	local FLAG= false;
	Count=0;

	
	for i = 1, RawCount, 1 do	
	
	FLAG= false;
	
	crncy1, crncy2 = string.match(RawList[i], pauto);
	
		   
			 if  (crncy1== Currency) or (crncy2== Currency )then
			 FLAG= true;
			 end
		   
		   
		 if FLAG then
		 Count = Count+ 1;
		 List[Count]= RawList[i]	 
		 end
	
	end
	
	
	
	for i = 1, Count, 1 do
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), 0 , 200+i , 100+i);
	 loading[i] = true;  	 
	end
	

    
       CVI = instance:addStream("ADI", core.Line, name, "ADI",  Color, first);	
    CVI:setPrecision(math.max(2, instance.source:getPrecision()));
      CVI:setWidth(instance.parameters.width);
       CVI:setStyle(instance.parameters.style)	   
  
end

local  Advancing =0;
local Declining=0; 
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

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	 for i = 1, Count, 1 do	 
		 if loading[i] then
		 return;
		 end
	 end
	
	local i;		 
	local p;
	 Advancing =0;
    Declining=0; 	
	for i = 1, Count, 1 do	
	   
					p= Initialization(i, period) 
				    Calculate(i, p, period);
				  
					
	end
		
	   
end	
		
		
function Calculate(i,p, period)

if not p then
 return;
end

 


local j;
local crncy1, crncy2;


	 
		
				 crncy1, crncy2 = string.match(List[i], pauto);
					
					if crncy1 == Currency then
							if SourceData[i].close[p] > SourceData[i].close[p-1] then
							Advancing= Advancing+ 1;
							elseif SourceData[i].close[p] < SourceData[i].close[p-1] then
							Declining= Declining + 1;
							end
					elseif crncy2 == Currency then
					       	if SourceData[i].close[p] > SourceData[i].close[p-1] then
							Declining= Declining + 1;
							elseif SourceData[i].close[p] < SourceData[i].close[p-1] then
							Advancing= Advancing+ 1;
							end                 
	                end					 
		 
	 	
	 
		CVI[period]= ( Advancing - Declining);
end		
		
 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

   local i;
   
   
    for i = 1, Count, 1 do
		 
			  if cookie == 100+i then
			  loading[i] = true;
		      elseif  cookie == 200+i then
			  loading[i] = false;    
			  end
		  
	end    
   
   
    for i = 1, Count, 1 do	 
		 if loading[i] then
		 return;
		 end
	 end
	 
    instance:updateFrom(0);    
     return core.ASYNC_REDRAW;
end


function   Initialization(i,period)

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

