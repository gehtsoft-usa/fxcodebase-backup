-- Id: 18159
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64660

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
    indicator:name("Majors Interaction Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 1);
	indicator.parameters:addString("TF",  "Time frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);

	
	indicator.parameters:addGroup("Style");
	--indicator.parameters:addInteger("LabelSize", "Font Size", "", 20, 0, 100); 
    indicator.parameters:addColor("Label1", "1. Line Color", "Label Color", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Label2", "2. Line Color", "Label Color", core.rgb(255, 0, 0));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local loading={};
local  List={};
local  Count;
local  RawList, RawCount;
local TF;
local Label;
local SourceData={};
--local Shift;
local host;
local offset;
local weekoffset;
local pauto =  "(%a%a%a)/(%a%a%a)";
--local Majors={"USD"};
local For={};
local Value={};
 
local Pip={};
local X;
local xKey;
local MIO, Dollar;
local Text1, Text2;
-- Routine
function Prepare(nameOnly)
    TF = instance.parameters.TF;

	Label1 = instance.parameters.Label1;
	Label2 = instance.parameters.Label2;
	 
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();
	
	
	    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
	RawList, RawCount=getInstrumentList();
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);
    s2, e2 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e1 - s1) > (e2 - s2), "The chosen time frame should be smaller than the chart time frame!");
	
	
	Count=0;
	
	 crncy1, crncy2 = string.match(source:instrument(), pauto);		
	
	
	for i=1,   RawCount, 1 do
	
	crncy3, crncy4 = string.match(RawList[i], pauto);	
	
	
	  ItIs =false;
	  

	  
		  if (crncy3=="USD"
		  or crncy4=="USD"
		  )		   
		  then
		  ItIs=true;
		  end
	 	  
	  if ItIs 
	  then
	  Count=Count+1;
	  List[Count]=RawList[i];
	  end
	  
	  
	
	end
	
 
	
	local i; 
	for i = 1, Count, 1 do
	SourceData[i] = core.host:execute("getSyncHistory", List[i], TF, source:isBid(), math.min(300,Period*2), 200+i, 100+i);
	Pip[i]   = core.host:findTable("offers"):find("Instrument", List[i]).PipCost;	
	loading[i]= true;
	
	
	 crncy3, crncy4 = string.match(List[i], pauto);	
	

     	if (crncy1== crncy3  )
		then
		Text1=crncy1;
		end
		
		if (crncy1== crncy4  )	
        then
		Text1=crncy1;
		end		
		
		if (crncy2== crncy3   )
		then
		Text2=crncy2;
		end
		
		if (crncy2== crncy4 )
		then
		Text2=crncy2;
		end
	 
	 
	 
	end


	
	 if Text1~= nil then
	 MIO1 = instance:addStream("MIO1", core.Line, name, Text1, Label1, source:first());
    MIO1:setPrecision(math.max(2, instance.source:getPrecision()));
	 end
	 if Text2~= nil then
	 MIO2 = instance:addStream("MIO2", core.Line, name, Text2, Label2, source:first());
    MIO2:setPrecision(math.max(2, instance.source:getPrecision()));
	 end
	 
end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	
	 local ItIs=false; 
   
    for i = 1, Count, 1 do
		 
			  if  loading[i] then 
			  ItIs=true; 
			  end
		  
	end    
	
    
	if ItIs then
	return;
	end
	
	
	
		--j
				 X=0;			
				
				
				for i=1, Count,  1 do
				
				
				  p= core.findDate (SourceData[i], source:date(period), false);
				  
				  if  p > Period  then
				  
					 crncy3, crncy4 = string.match(List[i], pauto);	
					  
					  if crncy3=="USD" then
					  X= X+1 
					  Value[X]=-( SourceData[i].close[p] - SourceData[i].close[p-Period]  )/Pip[i];
					  elseif crncy4=="USD" then
					  X= X+1; 
					  Value[X]= (  SourceData[i].close[p] -SourceData[i].close[p-Period] )/Pip[i];
					  end
					  
					  
					  
	
				  
				  end
				end
	
	
	
 
	
	xKey= BubbleSortKey();
	
	
	
	local XXX=1;
	for i= 2, X, 1 do
	
	if Value[xKey[i]] >0
	and Value[xKey[i-1]] <0
	then
	XXX=i;
	end
	
	
	end
	 
	for i= 1, X, 1 do
	
	
	   crncy3, crncy4 = string.match(List[xKey[i]], pauto);	
		 
		if MIO1~= nil then
		if (crncy1== crncy3   )
		or (crncy1== crncy4    )
        or   (crncy1== "USD"    )	
		then	
		   if (crncy1== "USD")  then 
		   
			MIO1[period]=XXX;
			else
			  
				 if i>= XXX  then
				MIO1[period]=i+1;
				else
				MIO1[period]=i;
				end
				 
				 
			end 
		end
		end
		
		if MIO2~= nil then
		if (crncy2== crncy3   )
		or (crncy2== crncy4    )	
		or  (crncy2== "USD"    )
		then
			if (crncy2== "USD")  then
		 
			MIO2[period]=XXX;
			else
			    if i>= XXX  then
				MIO2[period]=i+1;
				else
				MIO2[period]=i;
				end
			end 
		end
		end
	end
	

   
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





function AsyncOperationFinished(cookie)

   local i;
   local ItIs=false;
   local Num=0;
    for i = 1, Count, 1 do
		 
			  if cookie == 100+i then
			  loading[i] = true;
			  Num=Num+1;
			  ItIs=true;
		      elseif  cookie == 200+i then
			  loading[i] = false;  
			  end
		  
	end    
	
	
	
	
 
   
   if not ItIs then
   instance:updateFrom(0);
   core.host:execute ("setStatus", "");
   else
    core.host:execute ("setStatus", "  Loading "..((Count) - Num) .. " / " .. (Count) );	 
   end
   
  
   
        
     return core.ASYNC_REDRAW;
end




function BubbleSortKey()
 
 local Key={};
 local Temp;
 local Sort=true;
   
   
   for i=1, X, 1 do
   Key[i]=i;
   end
   
   

     while Sort do
    Sort=false;
   ---j
            for i = 2,  X , 1 do
                  
                    if Value[Key[i]] <  Value[Key[i-1]] then
                     Sort=true;                  
                     
                            Temp= Key[i];                     
                     Key[i]=Key[i-1];
                     Key[i-1]=Temp;                       
                    end
           
          end
    
    end
  
  return Key;
end
 
