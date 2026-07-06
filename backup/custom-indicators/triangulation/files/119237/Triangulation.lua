-- Id: 21395
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66125

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
    indicator:name("Triangulation");
    indicator:description("Triangulation");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup( "Calculation");
	indicator.parameters:addString("Base", "Base", "Base" , "JPY");
    indicator.parameters:addStringAlternative("Base", "USD", "USD" , "USD");
	
    indicator.parameters:addStringAlternative("Base", "EUR", "EUR" , "EUR");
	indicator.parameters:addStringAlternative("Base", "JPY", "JPY" , "JPY");
    indicator.parameters:addStringAlternative("Base", "GBP", "GBP" , "GBP");
	indicator.parameters:addStringAlternative("Base", "CHF", "CHF" , "CHF");
	
	indicator.parameters:addStringAlternative("Base", "AUD", "AUD" , "AUD");
	indicator.parameters:addStringAlternative("Base", "NZD", "NZD" , "NZD");
	indicator.parameters:addStringAlternative("Base", "CAD", "CAD" , "CAD");
 
	

	
 
	

 
    indicator.parameters:addGroup( 1 .. ". Style");

	
    indicator.parameters:addColor("color1", "Line Color", "color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup( 2 .. ". Style");

	
    indicator.parameters:addColor("color2", "Line Color", "color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	
	indicator.parameters:addGroup( 3 .. ". Style");

	
    indicator.parameters:addColor("color3", "Line Color", "color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end



-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local host;

local Select={};
local Base;
local dayoffset, weekoffset;
local Out={};

local FISRT1, FISRT2, FISRT3;
 
local SourceData={};
local Count=0;
 
local pauto =  "(%a%a%a)/(%a%a%a)";
local Number=2;

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
	
	
	Base=instance.parameters.Base;
	
	dayoffset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
   

	

	
	 
   
    local crncy1, crncy2 = string.match(source:instrument(), pauto);
	
	Count=0;
	
	
	local enum, row;
   enum = core.host:findTable("Offers"):enumerator();
   while true do
      row = enum:next();
      if row == nil or
      row == NULL then
         break;
      end
      if row.Instrument ~= source:instrument() then
	  
	     crncy3, crncy4 = string.match(row.Instrument, pauto);
		 
		 
		 if (crncy3 == Base and  crncy4 == crncy1  )
		 or (crncy4 == Base and  crncy3 == crncy1  )		 
		 or  (crncy3 == Base and  crncy4 == crncy2  )
		 or (crncy4 == Base and  crncy3 == crncy2  )
		 
		 then
		 Count=Count+1; 
         Select[Count]=row.Instrument;
         end
   end
   
 end

   
	   for i= 1, Count , 1 do
	   
	   SourceData[i] = core.host:execute("getSyncHistory",Select[i], source:barSize(), source:isBid(), 0, 200 +i, 100+i);
	   loading[i]=true;
	   
	   end
	   
	   
	Out[1] = instance:addStream("Out".. 1, core.Line, "", source:instrument(), instance.parameters.color1, first);
    Out[1]:setPrecision(math.max(2, instance.source:getPrecision()));
	Out[1]:setWidth(instance.parameters.width1);
    Out[1]:setStyle(instance.parameters.style1);
	
	Out[2] = instance:addStream("Out".. 2, core.Line, "", Select[1], instance.parameters.color2, first);
    Out[2]:setPrecision(math.max(2, instance.source:getPrecision()));
	Out[2]:setWidth(instance.parameters.width2);
    Out[2]:setStyle(instance.parameters.style2);
	
	
	Out[3] = instance:addStream("Out".. 3, core.Line, "", Select[2], instance.parameters.color3, first);
    Out[3]:setPrecision(math.max(2, instance.source:getPrecision()));
	Out[3]:setWidth(instance.parameters.width3);
    Out[3]:setStyle(instance.parameters.style3);

end

-- Indicator calculation routine
 
function Update(period )

 
	
    if period  < source:first()	
	then
    return;		
    end	
     
	  local Flag=false;
	for i= 1, Count, 1 do	
		if loading[i] then		
		Flag=true;
		end
	end
		
	
	if Flag then
	return;
	end	
			
	 local p={}
	 
	 for i= 1, Count, 1 do	
	   p[i]= Initialization(period,i)	 
	   
	   if not p[i] then
	   return;
	   end
     end
	 
	 if period == first then
	 FISRT1= period;
	 FISRT2=p[1];
	 FISRT3=p[2];
	 end
	 
	 
	 Out[1][period]= source.close[period]/source.close[FISRT1];
	 Out[2][period]= SourceData[1].close[p[1]]/SourceData[1].close[FISRT2];
	 Out[3][period]= SourceData[2].close[p[2]]/SourceData[2].close[FISRT3];	
 
    
		
			 
	   
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
	local iCount=0;	
	
	
	
    for j = 1, Count, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;		 
              end
			  
		if loading[j] then
		iCount=iCount+1;
		Flag=true;
		end	 

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Count-iCount) .."/" .. Count);
		else
		instance:updateFrom(0);
		core.host:execute ("setStatus", " Loaded ".. (Count-iCount) .."/" .. Count);
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end
