-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26274

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
    indicator:name("Correlation Table");
    indicator:description("Correlation Table");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	indicator.parameters:addString("TF",  "Time frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
 	 
   
    Add(1);
	Add(2);
	Add(3);
	Add(4);
	Add(5);
    Add(6);
    Add(7);
    Add(8);	 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Font Size", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
    indicator.parameters:addColor("Label", "Label Color", "Label Color", core.rgb(0, 0, 0));
end

function Add(id, L, C)

    --if L[id] == nil then
    --L[id] ="Nil"
    --end

    local P={"EUR/USD", "USD/JPY", "GBP/USD", "USD/CHF", "EUR/CHF", "AUD/USD", "USD/CAD", "NZD/USD"};	
	
   
    indicator.parameters:addString("L" .. id , id.. ". Pair", " " , P[id]);	    
    indicator.parameters:setFlag("L" .. id, core.FLAG_INSTRUMENTS);


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
local  List,  Size;
local Count=8;
local TF;
local Label;
local SourceData={};
local Shift, FSize;
local host;
local offset;
local weekoffset;
local SUM={};
local font;
local id; 
local L={};
local Data={};
-- Routine
function Prepare(nameOnly)
    TF = instance.parameters.TF;
	Shift = instance.parameters.Shift;
	Size = instance.parameters.Size;
	Label = instance.parameters.Label;
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
		
	local i;
	
		
	for i = 1, Count, 1 do
	
	L[i]=  instance.parameters:getString("L" .. i)
	 
	if L[i] ~= "Nil" then
	SourceData[i] = core.host:execute("getSyncHistory", L[i], TF, source:isBid(), Period+1, 200+i, 100+i);
	loading[i]= true;
	else
	Count=Count-1;
	end
	
	end

    
	
	font = core.host:execute("createFont", "Courier", Size , false, true);
   
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);	
 end  

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < source:size()-1 or not source:hasData(period) then
	return;
	end
	
	core.host:execute ("setStatus", "")

	local i, j;
	
	local FLAG=false;
	
	for i = 1, Count, 1 do
	   if loading[i] then
	   FLAG= true;
	   end
	 
	   
	end
	
	
	  
	
	if FLAG then	
	core.host:execute ("setStatus", "Loading")
	return;	
	end
	

	id =1;
	

	
	
	for i = 1, Count, 1 do
	Data[i]={};
        	
		   Calculate(i);
		    Draw(i);
    end	

 
end

function Draw (i)

  core.host:execute("drawLabel1", id, Size*10 ,  core.CR_LEFT, Size*5*1.1+(i-1)*Size*1.1+Shift  , core.CR_TOP, core.H_Left, core.V_Center, font, Label,  tostring( L[i]));			  
  id = id+1;	
  
   core.host:execute("drawLabel1", id, Size*10+ Size* 10* i ,  core.CR_LEFT, Size*5*1.1 +(Count )*Size*1.1  , core.CR_TOP, core.H_Left, core.V_Center, font, Label,  tostring( L[i]));			  
  id = id+1;	
  
  for j= 1, Count, 1 do
  
    core.host:execute("drawLabel1", id, Size*10 + Size* 10 *i ,  core.CR_LEFT,  Size*5*1.1+(j-1)*Size*1.1+Shift  , core.CR_TOP, core.H_Left, core.V_Center, font, Label,string.format("%." .. 2 .. "f", Data[i][j]*100 ))		  
  id = id+1;
  
  end
  


end

function Calculate(i)

    
			
		 for j = 1, Count, 1 do
		 		    Data[i][j] = mathex.correl(SourceData[i].close, SourceData[j].close, SourceData[i].close:size()-1 -Period, SourceData[i].close:size()-1, SourceData[j].close:size()-1 -Period, SourceData[j].close:size()-1);

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
   
   
    for i = 1, Count, 1 do
		 
			  if cookie == 100+i then
			  loading[i] = true;
		      elseif  cookie == 200+i then
			  loading[i] = false;  
			  
			  end
		  
	end    
	
	          if not loading[1] 
			  and  not loading[2]
			  and  not loading[3]
			  and  not loading[4]
			  and  not loading[5]
			  and  not loading[6]
			  and  not loading[7]
			  and  not loading[8]
			  then
			  instance:updateFrom(0);
              end
        
     return core.ASYNC_REDRAW;
end
