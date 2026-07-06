-- Id: 10022
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59518

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
    indicator:name("Expanded Trailing Relative Currency Strength");
    indicator:description("Trailing Relative Currency Strength");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "Method", "Method" , "Pairs");
    indicator.parameters:addStringAlternative("Method", "Pairs", "Pairs" , "Pairs");
    indicator.parameters:addStringAlternative("Method", "Index", "Index" , "Index");
	indicator.parameters:addBoolean("Show" , "Shown Labels", "", true);	 

	
    indicator.parameters:addInteger("Period", "Period", "Period", 24);
	indicator.parameters:addString("TF", "Time frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	
	
	local i;
	local Coloring={core.rgb(255, 0, 0),core.rgb(0,255, 0), core.rgb(0, 0, 100),core.rgb(0 , 0, 0), core.rgb(128, 128, 128), core.rgb(255, 128, 0) , core.rgb(128, 255, 0) , core.rgb( 0, 128, 255), core.rgb(0, 255, 128), core.rgb(255, 0, 128), 
	core.rgb(255, 0, 0),core.rgb(0,255, 0), core.rgb(0, 0, 100),core.rgb(0 , 0, 0), core.rgb(128, 128, 128), core.rgb(255, 128, 0) , core.rgb(128, 255, 0) , core.rgb( 0, 128, 255), core.rgb(0, 255, 128), core.rgb(255, 0, 128),
	core.rgb(255, 0, 0),core.rgb(0,255, 0), core.rgb(0, 0, 100),core.rgb(0 , 0, 0), core.rgb(128, 128, 128), core.rgb(255, 128, 0) , core.rgb(128, 255, 0) , core.rgb( 0, 128, 255), core.rgb(0, 255, 128), core.rgb(255, 0, 128),
	};
    local Pairs={"EUR/USD","GBP/USD","USD/JPY","AUD/USD","EUR/GBP","EUR/JPY","EUR/AUD",	"GBP/JPY","GBP/AUD","AUD/JPY", 
	"EUR/CHF","EUR/NZD","EUR/CAD",
	"GBP/NZD","GBP/CAD","GBP/CHF",
	"AUD/CHF",	"AUD/NZD","AUD/CAD",
	"NZD/JPY",	"CAD/JPY","CHF/JPY",
	"USD/CHF","USD/CAD","NZD/USD",
	"NZD/CAD","CAD/CHF",
	"NZD/CHF" 	 
	};
	local Indexes={"USD","EUR","JPY","GBP","AUD", "NZD", "CAD",  "CHF"};
	
	indicator.parameters:addGroup("Pairs Style");
	 for i = 1 ,28, 1 do
	 AddPairs(i, Pairs[i], Coloring[i]);
	 end
	 
	 
	 indicator.parameters:addGroup("Indexes Style");
	 for i = 1 , 8, 1 do	 
	 AddIndexes(i, Indexes[i], Coloring[i])
	end
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0);
	indicator.parameters:addDouble("custom","Custom Level","", 0);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

function AddPairs(id, Pair, Color)

    indicator.parameters:addBoolean("pOn"..id , "Shown ".. Pair, "", true);	 
    indicator.parameters:addColor("pColor".. id, Pair .. " Line Color", "", Color);
end 

function AddIndexes(id, Pair, Color)
 indicator.parameters:addBoolean("iOn"..id , "Shown ".. Pair, "", true);	 
    indicator.parameters:addColor("iColor".. id, Pair .. " Line Color", "", Color);
end 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
	local Coloring={core.rgb(255, 0, 0),core.rgb(0,255, 0), core.rgb(0, 0, 100),core.rgb(0 , 0, 0), core.rgb(128, 128, 128), core.rgb(255, 128, 0) , core.rgb(128, 255, 0) , core.rgb( 0, 128, 255), core.rgb(0, 255, 128), core.rgb(255, 0, 128), 
	core.rgb(255, 0, 0),core.rgb(0,255, 0), core.rgb(0, 0, 100),core.rgb(0 , 0, 0), core.rgb(128, 128, 128), core.rgb(255, 128, 0) , core.rgb(128, 255, 0) , core.rgb( 0, 128, 255), core.rgb(0, 255, 128), core.rgb(255, 0, 128),
	core.rgb(255, 0, 0),core.rgb(0,255, 0), core.rgb(0, 0, 100),core.rgb(0 , 0, 0), core.rgb(128, 128, 128), core.rgb(255, 128, 0) , core.rgb(128, 255, 0) , core.rgb( 0, 128, 255), core.rgb(0, 255, 128), core.rgb(255, 0, 128),
	};
    local Pairs={"EUR/USD","GBP/USD","USD/JPY","AUD/USD","EUR/GBP","EUR/JPY","EUR/AUD",	"GBP/JPY","GBP/AUD","AUD/JPY", 
	"EUR/CHF","EUR/NZD","EUR/CAD",
	"GBP/NZD","GBP/CAD","GBP/CHF",
	"AUD/CHF",	"AUD/NZD","AUD/CAD",
	"NZD/JPY",	"CAD/JPY","CHF/JPY",
	"USD/CHF","USD/CAD","NZD/USD",
	"NZD/CAD","CAD/CHF",
	"NZD/CHF" 	 
	};
	local Indexes={"USD","EUR","JPY","GBP","AUD", "NZD", "CAD",  "CHF"};
	
local first;
local source = nil;


local Index = {};
local Pair={};
local Method;
local offset,weekoffset;
local SourceData={};
local  TF;
local host; 
local loading={};
local Last,last;
local p1={};
local p2={};
local Label;
local pColor={};
local iColor={};
local iOn={};
local pOn={};
local Raw={};
local max;
local Type;
local pauto =  "(%a%a%a)/(%a%a%a)";
local Show;





 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    Period = instance.parameters.Period;
	Method= instance.parameters.Method;	
	TF= instance.parameters.TF;
    source = instance.source;
    first = source:first();
	Show= instance.parameters.Show;
	
	
 
	
	host=core.host;	
	offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");	

	
	local i, C, On;
	for  i = 1, 28, 1 do
    Raw[i]=	instance:addInternalStream(0, 0);
    pColor[i]= instance.parameters:getDouble("pColor" .. i);
	pOn[i]= instance.parameters:getBoolean("pOn" .. i);
		if i <= 8 then
		iColor[i]= instance.parameters:getDouble("iColor" .. i);
		iOn[i]= instance.parameters:getBoolean("iOn" .. i);
		end
		
		
			local Flag =  FindInstrument(Pairs[i]);	
			 
			
			assert(   Flag , "Please Subscribe to " .. Pairs[i] ) ;
			
			if not Flag then
			error( "Please Subscribe to " .. Pairs[i]);
			end
			
			if  Flag then	 				
			SourceData[i] = core.host:execute("getSyncHistory",Pairs[i], TF, source:isBid(), math.min(300,Period), 200+i, 100+i);
			loading[i]=true;
			  
			end
     end
    if (not (nameOnly)) then
	 if Method == "Index" then
	 max= 8;
	 Label=Indexes;
	 C=iColor;
	 On=iOn;
	 else
	 max= 28;
	 Label=Pairs;
	 C=pColor;
	 On=pOn;
	 end
	 
     local Off=true;
	 
	    for i = 1, max , 1 do
			if On[i] then
			if i <= 10 then
			Pair[i] = instance:addStream("Pair".. i, core.Line, name,  Label[i], C[i], first);
			Pair[i]:setStyle(core.LINE_SOLID);		
				if Off then			
				Pair[i]:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				Pair[i]:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  			
				Pair[i]:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				Pair[i]:addLevel(instance.parameters.custom, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				Off = false;
				end
			elseif i <= 20 then
			Pair[i] = instance:addStream("Pair".. i, core.Line, name,  Label[i], C[i], first);
			Pair[i]:setStyle(core.LINE_DASH);
				if Off then			
				Pair[i]:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				Pair[i]:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  			
				Pair[i]:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				Pair[i]:addLevel(instance.parameters.custom, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				Off = false;
				end
			else
			Pair[i] = instance:addStream("Pair".. i, core.Line, name,  Label[i], C[i], first);
			Pair[i]:setStyle(core.LINE_DASHDOT);
				if Off then			
				Pair[i]:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				Pair[i]:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  			
				Pair[i]:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				Pair[i]:addLevel(instance.parameters.custom, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
				Off = false;
				end
			end
			Pair[i]:setPrecision(math.max(2, instance.source:getPrecision()));
			else
			Pair[i]= instance:addInternalStream(0, 0);
			end
		end
    end
	
	core.host:execute ("setTimer",1,  5);
end

function FindInstrument(Instrument)
  
   
    local row, enum;   
	local Flag= false;
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
       
        if Instrument == row.Instrument then
		Flag= true;
		break;
		end
         row = enum:next(); 
    end

    return Flag;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	local i;
	
	
	local Flag = false;
	
	for i = 1, 28 , 1 do
		if loading[i] then
		Flag = true;
		end
	end
	
	if Flag then
	return;
	end
	
	for i = 1, 28 , 1 do
    p1[i]= Initialization(period,i);	
		if   p1[i] ~= false  then
		
		 if  p1[i] > Period then
		 p2[i]= p1[i]-Period;
		 
				 Raw[i][period] = ( SourceData[i].close[p1[i]]-SourceData[i].close[p2[i]]) /(SourceData[i].close[p2[i]]/100);
					 		 
		 end
		 
		 
		 
		end
	end
	
  
 
   
     
end

function CalculateIndex(i, period)

local crncy1, crncy2, j ;
local iCount=0;
local iSum=0;
	for j = 1 , 28 , 1 do 
	crncy1, crncy2 = string.match(Pairs[j], pauto);

		if crncy1== Indexes[i] then
		iCount=iCount+1;
		iSum=iSum+Raw[j][period];
		end

		if crncy2== Indexes[i] then
		iSum=iSum-Raw[j][period];
		iCount=iCount+1;
		end

	end

 

return iSum/iCount;

end

function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
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


function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, 28, 1 do
		
			  if cookie == (100 +j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  	              		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 
     end
	 
	 
	 
	   
	    
		if cookie == 1 and  not Flag then
		
				  for period = first, source:size()-1, 1 do
				  
				        for i = 1, 28 , 1 do
								 if Method == "Pairs" then
								 Pair[i][period]= Raw[i][period];
								 else
								 Pair[i][period]= CalculateIndex( i , period);
								 end
								 
								 if period==source:size()-1 and Show then
								 core.host:execute ("drawLabel", i, source:date(source:size()-1), Pair[i][period], Label[i]) ;
								 end
						 end 
						 
					  end
		 end
		 
		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (28-Count) .."/" .. 28);
		else
		core.host:execute ("setStatus","Loaded");		
		instance:updateFrom(0);
		end
  
 
   
        
		return core.ASYNC_REDRAW ;
end
