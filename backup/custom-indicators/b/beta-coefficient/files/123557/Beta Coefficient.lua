-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67303

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Beta Coefficient");
    indicator:description("Beta Coefficient");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);	   

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 21);
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	
	indicator.parameters:addGroup("Selector");	
	
	
	
    local i;
	local Default={"USD", "EUR", "GBP","JPY", "CHF",  "AUD", "NZD", "CAD", "Any"};
	indicator.parameters:addString("Default", "Index  Default", "", "Any");
	for i= 1, 9, 1 do
    indicator.parameters:addStringAlternative("Default", Default[i], Default[i],Default[i]);
    end
	 
	
	indicator.parameters:addGroup("Style");		
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
end


 
local Price;
local loading={};
local SourceData={};
local Instrument={};

local Num;
local Index; 
 
local Default;
local pdate = "(%a%a%a)/(%a%a%a)";


local dayoffset, weekoffset;
 
local Period;

function getInstrumentList()
    local list={};
	local point={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
        row = enum:next();
    end
	
	 
    return list, count,point;
end
 
function Prepare(nameOnly)      
	
    source = instance.source;
	Default = instance.parameters.Default;
	Period = instance.parameters.Period;
	Price = instance.parameters.Price;
	 
	
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	local Pair, Count,Point = getInstrumentList();
		
 
	Num=0;
	local First, Second;
	for i = 1 , Count , 1 do   
	
	  
	   
	    First, Second= string.match( Pair[i], pdate);
	   
	   
			  if First== Default or Second== Default or    Default == "Any" then
			  Num = Num+1;	

              Instrument[Num]=Pair[i];	


			  end
	  
	end	
	
	
	
		
	local i;
			 
		 for i = 1, Num, 1 do	
		 
			   SourceData[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), 0  ,20000 +i , 10000 + i);
			   loading[i] = true;  
			  
			 
		end
 
	 
		Index = instance:addStream("Beta", core.Line, Default .. " Beta Coefficient",  Default.." Beta Coefficient",  instance.parameters.color, source:first());
		Index:setWidth(instance.parameters.width);
        Index:setStyle(instance.parameters.style);
       	Index:setPrecision(math.max(2, instance.source:getPrecision()));
end




function Update(period)

 if period < source:first()+Period then
 return
 end
 
 
local p={};
 
    local FLAG=false;	
	local i;
	
		 for i = 1, Num, 1 do	
		 
		       
			     p[i]= Initialization(i, period);

                 if loading[i] or p[i]== false then
				 FLAG= true;				
				 end         	
         end
	
	if FLAG then 
	return;
	end
 
	local i;
	
						
	local Value=0;
    local Count=0;
             			
			 
							  for i = 1, Num, 1 do
									 
									 
								if SourceData[i].close:hasData(p[i]-Period) and p[i]> Period then	 
								 
								 Count=Count+1;
								 Value=Value+mathex.stdev(SourceData[i][Price],p[i]-Period+1, p[i] );
								 
								 end	 
									 
							  end
						 

							  
	local StdDev=mathex.stdev(source,period-Period+1, period );
	
    Index[period]= StdDev / (Value/Count); 					
	
end


function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i;
 

		 for i = 1, Num, 1 do	
			  if cookie == ( 10000 +  i) then
			  loading[i] = true;
		      elseif  cookie == (20000+ i) then
			  loading[i] = false;   
			  
			  end
		       
          end
	
	
	
    local FLAG=false; 
	local Number=0;
	
	
		 for i = 1, Num, 1 do	

                 if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Num - Number) .. " / " .. (Num) ));	 
	else
	core.host:execute ("setStatus", "Loaded")
  	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end




