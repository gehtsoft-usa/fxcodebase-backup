-- Id: 21361
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
    indicator:name("Arithmetic Mean");
    indicator:description("Arithmetic Mean");
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
 
	
    indicator.parameters:addColor("color1", "color", "color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end


function Add(id)
    local Pairs={"EUR/USD","USD/JPY","GBP/USD","USD/CHF","AUD/USD","NZD/USD","USD/CAD"};
    indicator.parameters:addGroup(id.. ". Pair");
	
	 
	indicator.parameters:addBoolean("On"..id, "Use this pair", "", true);
	
	indicator.parameters:addBoolean("Inverse"..id, "Use inverse rate", "", false);
	 
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
 
local dayoffset, weekoffset;
 
 
local SourceData={};
local Inverse={};
 
local pauto =  "(%a%a%a)/(%a%a%a)";
 local Index={};
local Number=0;
local N;
local loading={};
  
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
		Inverse[Number]=   instance.parameters:getBoolean ("Inverse"..i);
		end
	end
	
	N=Number;
	
	
	local InstrumentFlag=nil;
	for i = 1, Number, 1 do
	InstrumentFlag = core.host:findTable("offers"):find("Instrument", Select[i]);
	assert(InstrumentFlag ~= nil, "Subscribed to " ..  Select[i] );    
	end
	
	 
	Base=instance.parameters.Base;
	
	dayoffset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
   
    instrument=source:instrument();
	 
	Close = instance:addStream("Out", core.Line, "", Base, instance.parameters.color1, first);
    Close:setPrecision(math.max(2, instance.source:getPrecision()));
	Close:setWidth(instance.parameters.width);
    Close:setStyle(instance.parameters.style);
 
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
	 
	 local Flag=false;
	   
	 for i= 1, Number, 1 do	
	   p[i]= Initialization(period,i)	 

       if not p[i] then 
	   Flag= true;
	   end	   
     end
	 
	if Flag then
	return;
	end

		 
					       local iClose=0;	
					 	
						   
						   for i= 1, Number, 1 do	
						   
							   if Inverse[i] then
							   iClose= iClose+ (1/SourceData[i].close[p[i]]) *Index[i];
							   else						   
							   iClose= iClose+ SourceData[i].close[p[i]] *Index[i];		
							   end						   
						   
						   end
						   
				           Close[period]=iClose/Number;
				 
		 
						
		 		 
      
	   
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
