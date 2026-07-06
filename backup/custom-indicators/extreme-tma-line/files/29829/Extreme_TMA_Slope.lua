-- Id: 9913

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59406

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
    indicator:name("Extreme TMA line Slope indicator");
    indicator:description("Extreme TMA line Slope indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("TMA_Period", "TMA period", "", 56);
    indicator.parameters:addInteger("ATR_Period", "ATR period", "", 100);  
    indicator.parameters:addDouble("TrendThreshold", "TrendThreshold", "", 0.5);
    indicator.parameters:addBoolean("Redraw", "Redraw", "", true);
	 indicator.parameters:addBoolean("Show", "Show Threshol Level", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TMA_NEclr", "Slop Line neutral Color", "Neutral Color", core.rgb(128, 128, 128));
    indicator.parameters:addColor("TMA_UPclr", "Slop Line UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("TMA_DNclr", "Slop Line DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("TMAwidth", "Width", "Width", 2, 1, 5);
    indicator.parameters:addInteger("TMAstyle", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("TMAstyle", core.FLAG_LINE_STYLE);
	
	
	
    indicator.parameters:addGroup("OB/OS Levels");	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

end

local first;
local source = nil;
local TMA_Period;
local ATR_Period;
local ATR_Mult;
local TrendThreshold;
local Redraw;
local TMA=nil;
local ATR;
local Slope;

local Show;
function Prepare(nameOnly)
    source = instance.source;
    TMA_Period=instance.parameters.TMA_Period;
    ATR_Period=instance.parameters.ATR_Period;
    TrendThreshold=instance.parameters.TrendThreshold;    
	Show=instance.parameters.Show;
    Redraw=instance.parameters.Redraw;
   
    ATR=core.indicators:create("ATR", source, ATR_Period);
	 first = math.max(source:first() ,ATR.DATA:first(),2*TMA_Period);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.TMA_Period .. ", " .. instance.parameters.ATR_Period  .. ", " .. instance.parameters.TrendThreshold .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
 
 
    TMA= instance:addInternalStream(0, 0);
    Slope = instance:addStream("Slope", core.Line, name .. ".Slope", "Slope", instance.parameters.TMA_NEclr, first+TMA_Period);
    Slope:setWidth(instance.parameters.TMAwidth);
    Slope:setStyle(instance.parameters.TMAstyle);
	if Show then
    
    Slope:addLevel(instance.parameters.TrendThreshold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Slope:addLevel(-instance.parameters.TrendThreshold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
	
    end
	
	Slope:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

function Update(period, mode)

 
   
 
   
    ATR:update(mode);
	
	if period < ATR.DATA:first() then
	return;
	end
	
	   if period < TMA_Period then
	return;
	end
	
	if period == source:size()-2 then
		for i = first, period , 1 do
		Logic(i, mode);  
		end
	elseif period == source:size()-1 then
	Logic(period, mode);  
	end
	
 
	 
end


function Logic (period, mode)

  
   
    
    local i;
    local ii=TMA_Period;
    local LastPeriod;
		if period==source:size()-1 then
		 LastPeriod=true;
		else
		 LastPeriod=false;
		end
		while ii>0 do
			if not(LastPeriod) then
			 ii=0;
			else
			 ii=ii-1; 
			end
		local Sum=0;
		local SumW=(TMA_Period+2)*(TMA_Period+1)/2;
			for i=0,TMA_Period,1 do
			 Sum=Sum+(TMA_Period-i+1)*source.close[period-i];
			 if Redraw then
			  if i<=source:size()-1-period and i>0 then
			   Sum=Sum+(TMA_Period-i+1)*source.close[period+i];
			   SumW=SumW+(TMA_Period-i+1);
			  end
			 end 
			end
		TMA[period]=Sum/SumW;
			 Slope[period]=(TMA[period]-TMA[period-1])/(0.1*ATR.DATA[period]);
			
			if Slope[period]>TrendThreshold then
			 Slope:setColor(period,instance.parameters.TMA_UPclr);
			elseif Slope[period]<-TrendThreshold then
			 Slope:setColor(period,instance.parameters.TMA_DNclr);
			else
			 Slope:setColor(period,instance.parameters.TMA_NEclr);
			end
			 
	   end 
    
	

end