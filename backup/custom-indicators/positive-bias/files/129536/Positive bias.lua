-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69081


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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Positive bias");
    indicator:description("");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Inverse", "Inverse", "", false);		
 
	
    indicator.parameters:addGroup("Selector");
 
	
	local Default={"USD", "EUR", "GBP","JPY", "CHF",  "AUD", "NZD", "CAD"};
	indicator.parameters:addString("Default", "Index  Default", "", "USD");
	for i= 1, 8, 1 do
    indicator.parameters:addStringAlternative("Default", Default[i], Default[i],Default[i]);
    end
	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	
	

	for i= 1 ,10, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end 
	
 
 
	indicator.parameters:addGroup("Line Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);



end






 
function Add(id)

    local Init={"EUR/USD","USD/JPY", "GBP/USD", "USD/CHF", "USD/CAD", "AUD/USD", "NZD/USD", "BTC/USD",  "BCH/USD", "ETH/USD", "LTC/USD", "XRP/USD",
	"XAU/USD", "XAG/USD", "USD/SEK" ,"USD/NOK" ,"USD/MXN"	,"USD/ZAR",  "USD/HKD","USD/TRY"  };
	
    
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		
 
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
 
local pauto =  "(%a%a%a)/(%a%a%a)";
local Color;
local Source={};
local loading={}; 
local source;
local Pair={};
local  Count; 
local Type;  
local Dodaj={};   
local Point={};
local Use={}; 
local Default;  
local First={};
local Second={};
local pdate = "(%a%a%a)/(%a%a%a)";
local Oscillator;
local weekoffset;
local SourceData;
local Inverse;
-- Routine


function getInstrumentList()
    local list={};
	local point={};
	
    local count = 0;	
    local row, enum;
	local Instrument1, Instrument2;
	
	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
	
	       Instrument1, Instrument2 = string.match( row.Instrument, pdate);
	    
			if (Instrument1== Default or Instrument2== Default) then
			count = count + 1;
			list[count] = row.Instrument;
			point[count] = row.PointSize;
			row = enum:next();
			
			 First[count], Second[count]= Instrument1, Instrument2;
			end
    end
	
	 
    return list, count,point;
end


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Inverse = instance.parameters.Inverse;
	
	 dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");

    local Instrument1, Instrument2;
    
	Type= instance.parameters.Type;  
	source = instance.source; 
	
	Default= instance.parameters.Default;
	 
	if Type== "Multiple currency pair" then 
	
	Count=0;
				 for i= 1, 10 , 1 do	 
					 Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
					 
					 Instrument1, Instrument2 = string.match(  instance.parameters:getString ("Pair"..i), pdate);
						 
					 if Dodaj[i] and (Instrument1== Default or Instrument2== Default) then					
					 Count=Count+1;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					 Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;
					 
					 First[Count], Second[Count]= Instrument1, Instrument2;
					 end
				   
				 end
				 
	elseif Type== "All currency pair" then 
	
	
	          Pair, Count,Point = getInstrumentList();
				 
	else

	           Pair[1]=source:instrument();
			   Point[1]=source:pipSize ();
			   First[1], Second[1] = string.match(  source:instrument(), pdate);
			   
			   Count=1;
	end
	
	 
 
	local ID=0;
	Color= instance.parameters.Color; 
	
	 
	  
	 for i = 1, Count, 1 do	 
		  
		    ID=ID+1;  
			
	 
 
		   Source[i] = core.host:execute("getSyncHistory", Pair[i], source:barSize() , source:isBid(),300,20000 + ID , 10000 +ID);
		   loading [i] =true;
		   
		 
	 end 
	  

     
    Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, source:first());
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
   
    Oscillator:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
end

function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading[id] or Source[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 local ID=0;
 
		 for i = 1, Count, 1 do	
		     
			  ID=ID+1;
			  if cookie == ( 10000 +  ID) then
			  loading[i]  = true;
		      elseif  cookie == (20000+ ID) then
			  loading[i]  = false;  
			  end
			  
		     
          end

	
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count, 1 do
		 

                 if loading [i]  then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
        
    end
	
	
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count  - Number) .. " / " ..  Count  );	 
	else
	core.host:execute ("setStatus", "Loaded") 
	  instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end
 




-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 


    if period < source:first() then
	return;
	end
	
	
	local FLAG=false;	
	local i;
	
		 for i = 1, Count, 1 do	

                 if loading[i] then
				 FLAG= true;				
				 end         	
         end
	
	if FLAG then 
	return;
	end
	
	
	
	
	Oscillator[period]=0;
	local ItIs=0;
	local p;
	
	for i = 1, Count, 1 do
	
	      p =  Initialization(i, period) 
     
	      if p~= false then 
		     if Inverse then
			         if Second [i]== Default  and  Source[i].close[p]> Source[i].open[p] then
					 ItIs=ItIs+1;
					 elseif First [i]== Default  and  Source[i].close[p]< Source[i].open[p] then
					 ItIs=ItIs+1; 
					 end
			 else			 
					 if First [i]== Default  and  Source[i].close[p]> Source[i].open[p] then
					 ItIs=ItIs+1;
					 elseif Second [i]== Default  and  Source[i].close[p]< Source[i].open[p] then
					 ItIs=ItIs+1; 
					 end
			 end
			 
		   end	 
	end
	
	  
	 Oscillator[period]=ItIs/(Count/100);
	  
end

 