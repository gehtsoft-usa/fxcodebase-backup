-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69067

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
function Init()
    indicator:name("Multi Time Frame MACD Average");
    indicator:description("Multi Time Frame MACD Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector"); 
   indicator.parameters:addBoolean("InPips", "InPips", "", true); 
   indicator.parameters:addBoolean("Show_Components", "Show components of", "", true); 
 
    indicator.parameters:addBoolean("Show_Average_Line", "Show Average Line", "", true);
   
   Add(1, 12,26);
   Add(2, 12,26);
   Add(3, 12,26);
   Add(4, 12,26);
   Add(5, 12,26);


   	indicator.parameters:addGroup("Signal  Line Calculation");	
	indicator.parameters:addInteger("Signal_Period", "Signal Line Period", "Signal Line Period", 9, 2, 100000);
	

   
   AddStyle(1,  core.rgb(0, 255, 0) );
   AddStyle(2,  core.rgb(255, 0, 0) );
   AddStyle(3,  core.rgb(0, 0, 255) );
   AddStyle(4,  core.rgb(255, 128, 0) );
   AddStyle(5,  core.rgb(255, 128, 255) );  
   
   
    indicator.parameters:addGroup( "Average Line Style");
	 indicator.parameters:addColor("color", "MACD Line color", "Line Color", core.rgb(128, 128, 128));
   	indicator.parameters:addInteger("width", "MACD Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("style", "MACD Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("signal_color", "Signal Line color", "Line Color", core.rgb(100, 100, 100));
   	indicator.parameters:addInteger("signal_width", "Signal Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("signal_style", "Signal Line style", "", core.LINE_DASH);
    indicator.parameters:setFlag("signal_style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("histogram_color", "Histogram color", "Histogram Color", core.rgb(100, 100, 100));
    
	
end

function AddStyle(id, Color1)

    indicator.parameters:addGroup(id .. ". Line Style");
    indicator.parameters:addColor("color1"..id, "MACD Line color", "", Color1);
  
	
	indicator.parameters:addInteger("width1"..id, "MACD Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1"..id, "MACD Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1"..id, core.FLAG_LINE_STYLE);
	
 
	
 
	
end	
	

function Add(id,Fast, Slow)

    indicator.parameters:addGroup(id .. ". Line");
	
	
	indicator.parameters:addBoolean("Use_This".. id, "Use this slot", "", true);
	indicator.parameters:addBoolean("Inverse".. id, "Inverse this slot", "", false);	 
	
	indicator.parameters:addInteger("Divisor"..id, "Divisor", "", 1);
	
	
	local Instruments={"EUR/USD", "GBP/USD","AUD/USD","USD/JPY","USD/CHF"}
	
	indicator.parameters:addString("Instruments"..id , "Instruments", "", Instruments[id]);
    indicator.parameters:setFlag("Instruments"..id, core.FLAG_INSTRUMENTS);

    indicator.parameters:addInteger("Fast"..id, "Fast MA Period", "", Fast, 2,  100000);
    indicator.parameters:addInteger("Slow"..id, "Slow MA Period", "", Slow, 2,  100000);
	
end


-- Indicator local Flag;instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local MACD={};
local dayoffset,weekoffset;
local  Show_Components,Show_Average_Line;
local InPips;
local Signal_Period;
local source = nil; 
-- Streams block
local Indicator = {};
local Instruments={}; 
local Source={};
local loading={}; 
local Count;
local Average,Signal;
local Inverse={};
local Divisor={};
local Point={};
function Prepare(nameOnly) 
 
    source = instance.source;
	
	 
 
	Show_Components=instance.parameters.Show_Components;
	Show_Average_Line=instance.parameters.Show_Average_Line;
	InPips=instance.parameters.InPips;
	 
	
	Signal_Period=instance.parameters.Signal_Period;
  
	
	  dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
    local name = profile:id() .. "(" .. source:name().. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
   Count=0;
   
   for i= 1, 5, 1 do
   
        if instance.parameters:getBoolean("Use_This" .. i) then
				Count=Count+1;   
				
				
				if instance.parameters:getBoolean("Inverse" .. i) == true then
				Inverse[Count]=1;
				else
				Inverse[Count]=0;
				end
				
				Divisor[Count]=instance.parameters:getInteger("Divisor" .. i);
				Instruments[Count]=instance.parameters:getString("Instruments" .. i);
				
				Point[Count]= core.host:findTable("offers"):find("Instrument", Instruments[Count]).PointSize;	
				
				Source[Count] = core.host:execute("getSyncHistory", Instruments[Count], source:barSize(), source:isBid(),300,20000 + Count , 10000 +Count);
				loading [Count]=true;
				   
				Indicator[Count] = core.indicators:create("MACD", Source[Count].close, instance.parameters:getInteger("Fast" .. i), instance.parameters:getInteger("Slow" .. i) );

				 
				if   Show_Components  then
				MACD[Count] = instance:addStream("MACD"..Count, core.Line, name .. ".MACD", Count ..". MACD", instance.parameters:getColor("color1" .. i), 0);      
				MACD[Count]:setPrecision(math.max(2, instance.source:getPrecision()));
				MACD[Count]:setWidth(instance.parameters:getInteger("width1" .. i));
				MACD[Count]:setStyle(instance.parameters:getInteger("style1" .. i));
				else
				MACD[Count]= instance:addInternalStream(0, 0);
				end
			
		
		end
		
     
    end
	
	
	
	if Show_Average_Line then
	Average= instance:addStream("Average", core.Line , name .. ".Average", ". Average", instance.parameters:getColor("color"), 0);
    Average:setPrecision(math.max(2, instance.source:getPrecision()));
    Average:setWidth(instance.parameters:getInteger("width"));
    Average:setStyle(instance.parameters:getInteger("style"));
	
	

	
	Signal= instance:addStream("Signal", core.Line , name .. ".Signal", ". Signal", instance.parameters:getColor("signal_color"), 0);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters:getInteger("signal_width"));
    Signal:setStyle(instance.parameters:getInteger("signal_style"));
	
	Histogram= instance:addStream("Histogram", core.Line , name .. ".Histogram", ". Histogram", instance.parameters:getColor("histogram_color"), 0);
	
	else
	Average= instance:addInternalStream(0, 0);
	Signal= instance:addInternalStream(0, 0);
	Histogram= instance:addInternalStream(0, 0);
	 
	end
	

end

-- Indicator calculation routine
function Update(period, mode)
 
    
	
	
	local p;
	local Sum=0;
	local LocalCount=0;
        for i= 1, Count, 1 do 
	 
	     p=Initialization(i, period);
		 
		      if p~= false and not loading[i] then
				 Indicator[i]:update(mode);
				 
				 
				 
							 if Indicator[i].DATA:hasData(p) then
							 
									 if Inverse[Count]==1 then
									 
											 MACD[i][period]=(0-Indicator[i].DATA[p])/Divisor[i];
											 
											 if InPips then
											 MACD[i][period]=MACD[i][period]/Point[i];
											 end
											 
											 Sum=Sum+MACD[i][period];
											 LocalCount=LocalCount+1;
									 
									 else
									 
									 
											 MACD[i][period]=(Indicator[i].DATA[p])/Divisor[i];
											 if InPips then
											 MACD[i][period]=MACD[i][period]/Point[i];
											 end
											 Sum=Sum+MACD[i][period];
											 LocalCount=LocalCount+1;
									 end		 
											 
							 end
							 
				 end
				 
			if i==Count then
             Average[period]=Sum/LocalCount;
             end
			 
		 end
		 
		
		 
		
		 if period  < source:first()+Signal_Period then
		 return;
		 end
		 
		 
 
		 
		 Signal[period]=mathex.avg( Average, period-Signal_Period+1, period);
		 Histogram[period]=Average[period] -Signal[period];
		 
		 
	 
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 
 
		 for i = 1, Count, 1 do	
		  
			  
			  if cookie == ( 10000 +  i) then
			  loading[i]  = true;
		      elseif  cookie == (20000+ i) then
			  loading[i]  = false;  
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
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " ..  Count );	 
	else
	core.host:execute ("setStatus", "Loaded") 
	   instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
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

