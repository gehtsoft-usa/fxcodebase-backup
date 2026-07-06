-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72181

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Net Flows");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("Cumulative" , "Cumulative", "", false);	
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Count;
local Pair={"EUR/USD","GBP/USD","USD/JPY","USD/CHF","USD/CAD","NZD/USD","AUD/USD"};
local Point={};
local Source={};
local loading={};
local pdate = "(%a%a%a)/(%a%a%a)";
local InstrumentFirst, InstrumentSecond,Cumulative;
-- Routine
 function Prepare(nameOnly)   
 
    
	Cumulative= instance.parameters.Cumulative;
	
	source = instance.source
	first=source:first();
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 

	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	
    if   (nameOnly) then
        return;
    end
	
	
 
	InstrumentFirst, InstrumentSecond= string.match( source:instrument(), pdate);		 
	
	Count=0;
	for i= 1, 7 , 1 do	 	 
	row = core.host:findTable("offers"):find("Instrument",  Pair[i]);
	
	
	
	   if row == nil then 
	   assert(false , "You must be subscribe to ".. Pair[i] );
	   else
	   	 	  Count=Count+1; 
	          Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[i]).PointSize;	
	
	   end 
	end
				 
				 
     for i = 1, Count, 1 do	 
      Source[i]= core.host:execute("getSyncHistory", Pair[i], source:barSize(), source:isBid(), 0 ,20000 + i , 10000 +i);
	  loading[i] = true;   
	 end 
	
	
 
 
	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	 
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


function Update(period, mode)

	 
	 if period <= first then
	 return;
	 end
	
    local p={};	
	 
	 local FLAG=false 
	for i = 1, Count, 1 do
		 

        if loading [i] then
		FLAG= true; 
		end
				 
	p[i]= Initialization(i, period);	
		if p[i]== false then
		FLAG= true; 
		end	
				  
    end
	
	if FLAG then
    return;
    end
	
    if Cumulative then
	Line1[period]=Line1[period-1];
	Line2[period]=Line2[period-1];	
	else
	Line1[period]=0;
	Line2[period]=0;
	end
	
	
	local Delta;
	local First, Second;
	
	for i= 1,Count, 1 do
	
	        Delta= Source[i].volume[p[i]] * (Source[i].close[p[i]]-Source[i].open[p[i]])/Point[i];  
			
	
			 First, Second= string.match( Pair[i], pdate);
	  
		if  (InstrumentFirst== First  )  then          
			Line1[period]= Line1[period]+ Delta; 
		end	
		
		if  (InstrumentFirst== Second  )  then          
			Line1[period]= Line1[period]- Delta; 
		end	
		
		
		if  (InstrumentSecond== First  )  then          
			Line2[period]= Line2[period]+ Delta; 
		end	
		
		if  (InstrumentSecond== Second  )  then          
			Line2[period]= Line2[period]- Delta; 
		end	
		
	end
end


-- the function is called when the async operation is finished
 

	
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 
 
		 for i = 1, Count, 1 do	
			  if cookie == ( 10000 +  i) then
			  loading[i] = true;
		      elseif  cookie == (20000+ i) then
			  loading[i] = false;    
              end
              
		       
          end

	
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count, 1 do
		 

                 if loading [i] then
				 FLAG= true;
				 Number=Number+1;
				 end
				 
		 
		 
         
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count  - Number) .. " / " ..  Count  );	 
	else
	core.host:execute ("setStatus", "Loaded");
	 instance:updateFrom(0);		
	end
   
        
    return core.ASYNC_REDRAW ;
end

 
