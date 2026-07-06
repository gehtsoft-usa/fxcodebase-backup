-- Id: 21358
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66105

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

function Init()
    indicator:name("Average rates");
    indicator:description("Average rates");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup( "Calculation");
	indicator.parameters:addString("Base", "Base", "Base" , "USD");
    indicator.parameters:addStringAlternative("Base", "USD", "USD" , "USD");
	
    indicator.parameters:addStringAlternative("Base", "EUR", "EUR" , "EUR");
	indicator.parameters:addStringAlternative("Base", "JPY", "JPY" , "JPY");
    indicator.parameters:addStringAlternative("Base", "GBP", "GBP" , "GBP");
	indicator.parameters:addStringAlternative("Base", "CHF", "CHF" , "CHF");
	
	indicator.parameters:addStringAlternative("Base", "AUD", "AUD" , "AUD");
	indicator.parameters:addStringAlternative("Base", "NZD", "NZD" , "NZD");
	indicator.parameters:addStringAlternative("Base", "CAD", "CAD" , "CAD");
 
	
	
	for i= 1, 7, 1 do 
	Add(i);
	end
	
 
	

 
    indicator.parameters:addGroup( "Style");
	
	indicator.parameters:addString("Method", "Index Method", "Method" , "Line");
    indicator.parameters:addStringAlternative("Method", "Line", "Line" , "Line");
    indicator.parameters:addStringAlternative("Method", "Candle", "Candle" , "Candle");
	
    indicator.parameters:addColor("color1", "color", "color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end


function Add(id)
    local Pairs={"EUR/USD","USD/JPY","GBP/USD","USD/CHF","AUD/USD","NZD/USD","USD/CAD"};
    indicator.parameters:addGroup(id.. ". Pair");
	
	 
	indicator.parameters:addBoolean("On"..id, "Use this pair", "", true);
	 
    indicator.parameters:addString("Select"..id ,  "Pair", "", Pairs[id]);
    indicator.parameters:setFlag("Select"..id, core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addDouble("Weight"..id , "Weight", "", 1);
end


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local host;

local Weight={};
local Select={};
local Base;

local last;
local data;
local instrument;
local dummy = nil;
local dayoffset, weekoffset;


local SCALEFACTOR;
local Denominator;

local Close;
local Open;
local High;
local Low;
local tmp={}; 
 
local SourceData={};

 
local pauto =  "(%a%a%a)/(%a%a%a)";
 local Index={};
local Number=0;
local N;
local loading={};
local Method;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
    host = core.host;  
   

    local name = profile:id() .. "()";
    instance:name(name);
	
	if nameOnly then
		return;
	end
	
	
	Number=0;
	
	for i =1, 7, 1 do	
		if instance.parameters:getBoolean ("On"..i) then		
		Number=Number+1;
		Select[Number]=   instance.parameters:getString ("Select"..i);
		Weight[Number]=   instance.parameters:getDouble ("Weight"..i);
		end
	end
	
	N=Number;
	
	
	local InstrumentFlag=nil;
	for i = 1, Number, 1 do
	InstrumentFlag = core.host:findTable("offers"):find("Instrument", Select[i]);
	assert(InstrumentFlag ~= nil, "Subscribed to " ..  Select[i] );    
	end
	
	Method=instance.parameters.Method;	
	Base=instance.parameters.Base;
	
	dayoffset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
   
    instrument=source:instrument();
	if Method == "Line" then
	Close = instance:addStream("Out", core.Line, "", Base, instance.parameters.color1, first);
    Close:setPrecision(math.max(2, instance.source:getPrecision()));
	Close:setWidth(instance.parameters.width);
    Close:setStyle(instance.parameters.style);
	else
	Open = instance:addInternalStream(0, 0);
    High  = instance:addInternalStream(0, 0);
    Low = instance:addInternalStream(0, 0);
    Close = instance:addInternalStream(0, 0);
	 instance:createCandleGroup(Base, Base, Open, High, Low, Close);
	 end
   
   for i= 1, Number , 1 do
    crncy1, crncy2 = string.match(Select[i], pauto);
	if crncy1== Base then
	Index[i]= Weight[i];
	elseif crncy2== Base then
	Index[i]= -Weight[i];
	else
	assert(true, Select[i]  .. "is NOT based on the base currency" );    
	end
   
   SourceData[i] = core.host:execute("getSyncHistory",Select[i], source:barSize(), source:isBid(), 0, 200 +i, 100+i);
   loading[i]=true;
   end
   
   
end

-- Indicator calculation routine
 
function Update(period )

 
   
	
    if period  < source:first()	
	then
    return;		
    end	
     
	  local Flag=false;
	for i= 1, Number, 1 do	
		if loading[i] then		
		Flag=true;
		end
	end
		
	
	if Flag then
	return;
	end	
			
	 local p={}
	 
	 for i= 1, Number, 1 do	
	   p[i]= Initialization(period,i)	 
	   
	   if not p[i] then
	   Close[period]=nil
	   return;
	   end
     end
		
 
    
		
			     if period == source:first() then
					          
				 Close[period]=100; 
				 Denominator=1;
				 
				  for i= 1, Number, 1 do	
				  tmp[i]=SourceData[i].close[p[i]];
                  Denominator= Denominator *	(SourceData[i].close[p[i]]/tmp[i])^(Index[i]/N);			  
				  end 
				  
				  SCALEFACTOR=100/Denominator;
				  
				 else
						  
					       local NumeratorClose=1;	
						   local NumeratorOpen=1;	
						   local NumeratorHigh=1;	
						   local NumeratorLow=1;	
						   
						   for i= 1, Number, 1 do	
						   NumeratorClose=NumeratorClose*((SourceData[i].close[p[i]]/tmp[i])^(Index[i]/N));
						   NumeratorOpen=NumeratorOpen*((SourceData[i].open[p[i]]/tmp[i])^(Index[i]/N));
						   NumeratorHigh=NumeratorHigh*((SourceData[i].high[p[i]]/tmp[i])^(Index[i]/N));
						   NumeratorLow=NumeratorLow*((SourceData[i].low[p[i]]/tmp[i])^(Index[i]/N));
						   end
						   
				           Close[period]=NumeratorClose*SCALEFACTOR;
						   
						   if Method ~= "Line" then
						     Open[period]=NumeratorOpen*SCALEFACTOR;
							 High[period]=NumeratorHigh*SCALEFACTOR;
						     Low[period]=NumeratorLow*SCALEFACTOR;
				           end
			     end		
						
		 		 
      
	   
end





function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
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

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		instance:updateFrom(0);
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end
