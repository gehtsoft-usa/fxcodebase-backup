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
    indicator:name("Multi Time Frame Stochastic Average");
    indicator:description("Multi Time Frame Stochastic Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector");
   indicator.parameters:addBoolean("Show_K", "Show K Line", "", true);	 
   indicator.parameters:addBoolean("Show_D", "Show D Line", "", false);	
   
   indicator.parameters:addBoolean("Show_Components", "Show components of", "", true);
    indicator.parameters:addBoolean("Show_Average_Line", "Show Average Line", "", true);
   
   Add(1, 5,3,3);
   Add(2, 5,3,3);
   Add(3, 5,3,3);
   Add(4, 5,3,3);
   Add(5, 5,3,3);


   	indicator.parameters:addGroup("D Line Calculation");
	
	
	indicator.parameters:addInteger("D_Period", "Smoothing period for %D", "Smoothing period for %D", 3, 2, 100000);
	

   
   AddStyle(1,  core.rgb(0, 255, 0),  core.rgb(0, 255, 0));
   AddStyle(2,  core.rgb(255, 0, 0),  core.rgb(255, 0, 0));
   AddStyle(3,  core.rgb(0, 0, 255),  core.rgb(0, 0, 255));
   AddStyle(4,  core.rgb(255, 128, 0),  core.rgb(255, 128, 0));
   AddStyle(5,  core.rgb(255, 128, 255),  core.rgb(255, 128, 255));  
   
   
    indicator.parameters:addGroup( "Average Line Style");
	 indicator.parameters:addColor("color", "K Line color", "Line Color", core.rgb(128, 128, 128));
   	indicator.parameters:addInteger("width", "K Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("style", "K Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("signal_color", "D Line color", "Line Color", core.rgb(100, 100, 100));
   	indicator.parameters:addInteger("signal_width", "D Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("signal_style", "D Line style", "", core.LINE_DASH);
    indicator.parameters:setFlag("signal_style", core.FLAG_LINE_STYLE);
	
end

function AddStyle(id, Color1,Color2)

    indicator.parameters:addGroup(id .. ". Line Style");
    indicator.parameters:addColor("color1"..id, "%K line color", "The color of the %K line.", Color1);
    indicator.parameters:addColor("color2"..id, "%D line color", "The color of the %D line.", Color2);
	
	indicator.parameters:addInteger("K_width"..id, "K Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("K_style"..id, "K Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("K_style"..id, core.FLAG_LINE_STYLE);
	
	indicator.parameters:addInteger("D_width"..id, "D Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("D_style"..id, "D Line style", "", core.LINE_DASH);
    indicator.parameters:setFlag("D_style"..id, core.FLAG_LINE_STYLE);
	
end	
	

function Add(id,K,SD,D, MVAT_K, MVAT_D)

    indicator.parameters:addGroup(id .. ". Line");
	
	
	indicator.parameters:addBoolean("Use_This".. id, "Use this slot", "", true);
	indicator.parameters:addBoolean("Inverse".. id, "Inverse this slot", "", false);	 
	
	
	local Instruments={"EUR/USD", "GBP/USD","AUD/USD","USD/JPY","USD/CHF"}
	
	indicator.parameters:addString("Instruments"..id , "Instruments", "", Instruments[id]);
    indicator.parameters:setFlag("Instruments"..id, core.FLAG_INSTRUMENTS);

    indicator.parameters:addInteger("K"..id, "Stochastic Period", "Stochastic Period", K, 2,  100000);
    indicator.parameters:addInteger("SD"..id, "Smoothing period for %K", "Smoothing period for %K", SD, 1, 100000);
    indicator.parameters:addInteger("D"..id, "Smoothing period for %D", "Smoothing period for %D", D, 2, 100000);

    indicator.parameters:addString("MVAT_K"..id, "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K"..id, "Fast Smoothed", "Fast Smoothed.", "FS");
    
    indicator.parameters:addString("MVAT_D"..id, "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D"..id, "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D"..id, "EMA", "EMA", "EMA");
	
end

local Flag;
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local K={};
local D={};
local dayoffset,weekoffset;
local Show_K, Show_D,Show_Components,Show_Average_Line;

local source = nil; 
-- Streams block
local Stochastic = {};
local Instruments={}; 
local Source={};
local loading={}; 
local Count;
local Average,Signal;
local Inverse={};

function Prepare(nameOnly) 
 
    source = instance.source;
	
	Show_K=instance.parameters.Show_K;
	Show_D=instance.parameters.Show_D;
	Show_Components=instance.parameters.Show_Components;
	Show_Average_Line=instance.parameters.Show_Average_Line;
	 
    Flag=true;
	
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
				
				Instruments[Count]=instance.parameters:getString("Instruments" .. i);
				
				Source[Count] = core.host:execute("getSyncHistory", Instruments[Count], source:barSize(), source:isBid(),300,20000 + Count , 10000 +Count);
				loading [Count]=true;
				   
				Stochastic[Count] = core.indicators:create("STOCHASTIC", Source[Count], instance.parameters:getInteger("K" .. i), instance.parameters:getInteger("SD" .. i) , instance.parameters:getInteger("D" .. i), instance.parameters:getString("MVAT_K" .. i), instance.parameters:getString("MVAT_D" .. i));

				 
				if Show_K  and Show_Components then
				K[Count] = instance:addStream("K"..Count, core.Line, name .. ".K", Count ..". K", instance.parameters:getColor("color1" .. i), Stochastic[Count].K:first());      
				K[Count]:setPrecision(math.max(2, instance.source:getPrecision()));
				K[Count]:setWidth(instance.parameters:getInteger("K_width" .. i));
				K[Count]:setStyle(instance.parameters:getInteger("K_style" .. i));
				else
				K[Count]= instance:addInternalStream(Stochastic[Count].K:first(), 0);
				end
				
				if Show_D  and Show_Components  then
				D[Count]= instance:addStream("D"..Count, core.Line , name .. ".D", Count.. ". D", instance.parameters:getColor("color2" .. i), Stochastic[Count].D:first());
				D[Count]:setPrecision(math.max(2, instance.source:getPrecision()));
				D[Count]:setWidth(instance.parameters:getInteger("D_width" .. i));
				D[Count]:setStyle(instance.parameters:getInteger("D_style" .. i));
				else
				D[Count]= instance:addInternalStream(Stochastic[Count].D:first(), 0);
				end
		
		end
		
    
		 if Flag then
		 Flag=false;
		 D[Count]:addLevel(20);
		 D[Count]:addLevel(80);
		 end
		
    end
	
	
	
	if Show_Average_Line then
	Average= instance:addStream("Average", core.Line , name .. ".Average", ". Average", instance.parameters:getColor("color"), Stochastic[Count].K:first());
    Average:setPrecision(math.max(2, instance.source:getPrecision()));
    Average:setWidth(instance.parameters:getInteger("width"));
    Average:setStyle(instance.parameters:getInteger("style"));
	
	

	
	Signal= instance:addStream("Signal", core.Line , name .. ".Signal", ". Signal", instance.parameters:getColor("signal_color"), Stochastic[Count].K:first()+instance.parameters.D_Period);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters:getInteger("signal_width"));
    Signal:setStyle(instance.parameters:getInteger("signal_style"));
	
	else
	Average= instance:addInternalStream(0, 0);
	Signal= instance:addInternalStream(0, 0);
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
				 Stochastic[i]:update(mode);
				 
				 
				 
							 if Stochastic[i].K:hasData(p) then
							 
							 if Inverse[Count]==1 then
							 
							       K[i][period]=100-Stochastic[i].K[p];
									 Sum=Sum+K[i][period];
									 LocalCount=LocalCount+1;
							 
							 else
							 
							 
									 K[i][period]=Stochastic[i].K[p];
									 Sum=Sum+K[i][period];
									 LocalCount=LocalCount+1;
							 end		 
									 
							 end
							 if Stochastic[i].D:hasData(p) then
							 
									 if Inverse[Count]==1 then
									  D[i][period]=100-Stochastic[i].D[p];
									 else
									 D[i][period]=Stochastic[i].D[p];
									 end
							 end	 
				 end
				 
			if i==Count then
             Average[period]=Sum/LocalCount;
             end
			 
		 end
		 
		
		 
		
		 if period  < Stochastic[Count].K:first() +instance.parameters.D_Period then
		 return;
		 end
		 
		 
 
		 
		 Signal[period]=mathex.avg( Average, period-instance.parameters.D_Period+1, period);
		 
		 
		 
	 
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

