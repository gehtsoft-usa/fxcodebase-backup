-- Id: 3531
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2073


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
    indicator:name("Three Currency Spread");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
		indicator.parameters:addGroup("Type of Spread");
	 indicator.parameters:addString("Type", "Spread Type", "", "TWO");
    indicator.parameters:addStringAlternative("Type", "Two Currency Spread", "", "TWO");
    indicator.parameters:addStringAlternative("Type", "Three Currency Spread", "", "THREE");
	
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addString("p1", "1. Instrumet", "", "");
    indicator.parameters:setFlag("p1", core.FLAG_INSTRUMENTS );
	
	indicator.parameters:addString("p2", "2. Instrumet", "", "");
    indicator.parameters:setFlag("p2", core.FLAG_INSTRUMENTS );
	
	indicator.parameters:addString("p3", "3. Instrumet", "", "");
    indicator.parameters:setFlag("p3", core.FLAG_INSTRUMENTS );
	
	
		indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("ShowTwo", "Show Two", "" , true);
	indicator.parameters:addBoolean("ShowThree", "Show Three", "" , true);
	

	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(0,255, 0));
	 indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	
	local first;
	local source = nil;
	local BS;
	local host;
	local offset;
	local weekoffset;
	local SourceData={};
	local loading ={};   
	local Indicator;
-- Streams block
    local Spread ={};
	local Type;
	
	local ShowThree;
local ShowTwo;
	
local p1, p2, p3;

-- Routine
function Prepare(nameOnly) 
    
    source = instance.source;
    first = source:first();
	
	p1 = instance.parameters.p1;
	p2  = instance.parameters.p2;	
    p3  = instance.parameters.p3;	
	
	 ShowThree= instance.parameters.ShowThree;
    ShowTwo= instance.parameters.ShowTwo;
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    BS = source:barSize();
	
	
	 local name;
	 
	
	if Type == "TWO" then
	name = profile:id() .. "(" .. source:name().. ", " .. p1..", " ..p2.."  ".. "Two Currency Spread" ..")";
	else
	name = profile:id() .. "(" .. source:name() ..", " .. p1..", " ..p2.. ", "..p3.. "  ".."Three Currency Spread" ..")";	end
	
	 instance:name(name);


   if   (nameOnly) then
        return;
    end
	
	
	SourceData[1]=core.host:execute("getSyncHistory", p1, BS, source:isBid(), 0, 100, 101);
	SourceData[2]=core.host:execute("getSyncHistory", p2, BS, source:isBid(), 0, 200, 201);
	SourceData[3]=core.host:execute("getSyncHistory", p3, BS, source:isBid(), 0, 300, 301);
	loading[1]=true;
	loading[2]=true;
	loading[3]=true;
	   
	   
	   
	   
	   if Type == "TWO" then
	        Spread[1] = instance:addStream("Spread1", core.Line, name, "Spread1", instance.parameters.color1, first);
    		Spread[1]:setWidth(instance.parameters.width1);
			Spread[1]:setStyle(instance.parameters.style1);
			Spread[1]:setPrecision(math.max(2, instance.source:getPrecision()));
		else
	   
	     if ShowTwo then
	   
			Spread[1] = instance:addStream("Spread1", core.Line, name, "Spread1", instance.parameters.color1, first);
			Spread[1]:setWidth(instance.parameters.width1);
			Spread[1]:setStyle(instance.parameters.style1);
			Spread[1]:setPrecision(math.max(2, instance.source:getPrecision()));
		else
		 
		   Spread[1] = instance:addInternalStream(0, 0);
        end	

         if ShowThree then		 
		
			Spread[2] = instance:addStream("Spread2", core.Line, name, "Spread2", instance.parameters.color2, first);
    Spread[2]:setPrecision(math.max(2, instance.source:getPrecision()));
			Spread[2]:setWidth(instance.parameters.width2);
			Spread[2]:setStyle(instance.parameters.style2);
		else
		
		    Spread[2] = instance:addInternalStream(0, 0);
        end		
			
	end

       
   
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(BS, source:date(period), offset, weekoffset);

  
    if loading[1] or loading[2] or loading[3] or SourceData[1]:size() == 0  or SourceData[2]:size() == 0  or SourceData[3]:size() == 0  then
        return false, false, false ;
    end

    
	
    if period < source:first() then
        return false, false, false;
    end

    local r1 = core.findDate(SourceData[1], Candle, false);
	local r2 = core.findDate(SourceData[2], Candle, false);
	local r3 = core.findDate(SourceData[3], Candle, false);

    -- candle is not found
    if r1 < 0 or r2 < 0  or r3 < 0 then
        return false, false, false;
	else return r1, r2, r3;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

        local r1,r2,r3;
		r1,r2, r3=  Initialization(period) 
     
	    if not r1 or not r2  or not r3  then
		return;
		end		
		
		
		if Type == "TWO" then
		
		        if  SourceData[1].close:hasData(r1)  and  SourceData[2].close:hasData(r2)then
				Spread[1][period]= SourceData[1].close[r1]-SourceData[2].close[r2];
				end
	  
     	else    
		
		    if  SourceData[1].close:hasData(r1)  and  SourceData[2].close:hasData(r2)  and  SourceData[3].close:hasData(r3) then
		       
				Spread[1][period]= Spread[1][period]-SourceData[2].close[r2];
				Spread[2][period]= Spread[1][period]-SourceData[3].close[r3];
				
			end
		end	
			
	end
	
	  
    
	  

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100  then
        loading[1]= false;
	elseif cookie == 200  then
        loading[2]= false;
	elseif cookie == 300  then
        loading[3]= false;	
    elseif cookie == 101  then 
	loading[1]= true;
	elseif cookie == 201  then
    loading[2]= true; 
    elseif cookie == 301  then
    loading[3]= true; 	
    end
	
	
	if loading[1]== false and loading[2]== false and loading[3]== false then
	instance:updateFrom(0);
	end
end


