-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1721

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
    indicator:name("NonLagDot indicator");
    indicator:description("NonLagDot indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "Length", 10);
    indicator.parameters:addInteger("Filter", "Filter", "Filter", 0);
    indicator.parameters:addInteger("ColorBarBack", "ColorBarBack", "ColorBarBack", 2);
    indicator.parameters:addDouble("Deviation", "Deviation", "Deviation", 0);
	

    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("clrUP", "UP color", "UP color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("clrDN", "DN color", "DN color", core.rgb(255, 0, 0));
	
    indicator.parameters:addInteger("Width", "Line Width", "", 3, 1, 5);
end

local first;
local source = nil;
local Length;
local Filter;
local ColorBarBack;
local Deviation;
local buffUP=nil;
local buffDN=nil;
local trend;
local buff;
local Coeff;
local Phase;
local Len;
local  Signal;
local SIGNAL;
function Prepare(nameOnly)
    Signal=instance.parameters.Signal;
    source = instance.source;
    Length=instance.parameters.Length;
    Filter=instance.parameters.Filter;
    ColorBarBack=instance.parameters.ColorBarBack;
    Deviation=instance.parameters.Deviation;
    trend = instance:addInternalStream(0, 0);
    buff = instance:addInternalStream(0, 0);
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Length .. ", " .. instance.parameters.Filter .. ", " .. instance.parameters.ColorBarBack .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
	
    if   (nameOnly) then
        return;
    end
	    	
    Coeff=3.*math.pi;
    Phase=Length-1;
    Len=Length*4.+Phase;
	first = source:first()+Len;
	
	SIGNAL= instance:addStream("SIGNAL", core.Dot, name, "SIGNAL", core.rgb(0, 0, 0), first);	
    SIGNAL:setWidth(instance.parameters.Width);
end

function Update(period, mode)
     if (period<first ) then
	return;
	end
     local Weight=0;
     local Sum=0;
     local t=0;
     for i=0,Len-1,1 do
      local g=1./(Coeff*t+1.);
      if t<=0.5 then
       g=1.;
      end
      local beta=math.cos(math.pi*t);
      local alpha=g*beta;
      Sum=Sum+alpha*source[period-i];
      Weight=Weight+alpha;
      if t<1. then
       t=t+1./(Phase-1.);
      elseif t<Len-1. then
       t=t+7./(4.*Length-1.);
      end
     end
     if Weight>0. then
      buff[period]=(1.+Deviation/100.)*Sum/Weight;
     end
     if Filter>0. then
      if math.abs(buff[period]-buff[period-1])<Filter*source:pipSize() then
       buff[period]=buff[period-1];
      end
     end
     trend[period]=trend[period-1];
     if buff[period]-buff[period-1]>Filter*source:pipSize() then
      trend[period]=1;
     end
     if buff[period-1]-buff[period]>Filter*source:pipSize() then
      trend[period]=-1;
     end
	
	 
	
	 
		 if trend[period]>0 then
		
			  SIGNAL:setColor(period, instance.parameters.clrUP);	  
			  SIGNAL[period]= buff[period];
		  
			  if trend[period-ColorBarBack]<0 then

				   SIGNAL[period-ColorBarBack]= buff[period-ColorBarBack];
				  SIGNAL:setColor(period-ColorBarBack, instance.parameters.clrUP);	  		
			  end
		 end
	 
		 if trend[period]<0 then      
				  SIGNAL:setColor(period, instance.parameters.clrDN);	  
				   SIGNAL[period]= buff[period];  
				   
			  if trend[period-ColorBarBack]>0 then 	  
				  SIGNAL:setColor(period-ColorBarBack, instance.parameters.clrDN);	  
				  SIGNAL[period-ColorBarBack]= buff[period-ColorBarBack];
			  end
		 end

   
end

