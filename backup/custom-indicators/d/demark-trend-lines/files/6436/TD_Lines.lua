-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=2483&hilit=TD_Lines&start=50


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
    indicator:name("TD Lines indicator");
    indicator:description("TD Lines indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addBoolean("FractalAsTD", "FractalAsTD", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrL1", "Color L1", "Color L1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrL2", "Color L2", "Color L2", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local FractalAsTD;
local buffUp;
local buffDn;
local up=nil;
local down=nil;
local TOP;
local BOTTOM;

function Prepare(nameOnly)
    source = instance.source;
    FractalAsTD=instance.parameters.FractalAsTD;
    first = source:first()+6;
    up = instance:addInternalStream(first, 0);
    down = instance:addInternalStream(first, 0);
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    buffUp = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Center, instance.parameters.clrUP, first);
    buffDn = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Center, instance.parameters.clrDN, first);
	TOP = instance:addInternalStream(0, 0);
	BOTTOM = instance:addInternalStream(0, 0);
end

 

function Update(period, mode)
   if (period>first) then
    if FractalAsTD==false then
     if source.high[period-3]<source.high[period-2] and source.high[period-1]<source.high[period-2] then
      up[period-2]=source.high[period-2];
      buffUp:set(period-2, source.high[period-2], "\159", "");
     end
     if source.high[period-4]<source.high[period-2] and source.high[period-3]==source.high[period-2] and source.high[period-1]<source.high[period-2] then
      up[period-2]=source.high[period-2];
      buffUp:set(period-2, source.high[period-2], "\159", "");
     end
     if source.high[period-5]<source.high[period-2] and source.high[period-4]==source.high[period-2] and source.high[period-3]==source.high[period-2] and source.high[period-1]<source.high[period-2] then
      up[period-2]=source.high[period-2];
      buffUp:set(period-2, source.high[period-2], "\159", "");
     end
     if source.high[period-6]<source.high[period-2] and source.high[period-5]==source.high[period-2] and source.high[period-4]==source.high[period-2] and source.high[period-3]==source.high[period-2] and source.high[period-1]<source.high[period-2] then
      up[period-2]=source.high[period-2];
      buffUp:set(period-2, source.high[period-2], "\159", "");
     end
     
     if source.low[period-3]>source.low[period-2] and source.low[period-1]>source.low[period-2] then
      down[period-2]=source.low[period-2];
      buffDn:set(period-2, source.low[period-2], "\159", "");
     end
     if source.low[period-4]>source.low[period-2] and source.low[period-3]==source.low[period-2] and source.low[period-1]>source.low[period-2] then
      down[period-2]=source.low[period-2];
      buffDn:set(period-2, source.low[period-2], "\159", "");
     end
     if source.low[period-5]>source.low[period-2] and source.low[period-4]==source.low[period-2] and source.low[period-3]==source.low[period-2] and source.low[period-1]>source.low[period-2] then
      down[period-2]=source.low[period-2];
      buffDn:set(period-2, source.low[period-2], "\159", "");
     end
     if source.low[period-6]>source.low[period-2] and source.low[period-5]==source.low[period-2] and source.low[period-4]==source.low[period-2] and source.low[period-3]==source.low[period-2] and source.low[period-1]>source.low[period-2] then
      down[period-2]=source.low[period-2];
      buffDn:set(period-2, source.low[period-2], "\159", "");
     end
    else
     if source.high[period-3]>source.high[period-2] and source.high[period-3]>source.high[period-1] and source.high[period-3]>source.high[period-4] and source.high[period-3]>source.high[period-5] then
      up[period-3]=source.high[period-3];
      buffUp:set(period-3, source.high[period-3], "\159", "");
     end
     if source.low[period-3]<source.low[period-2] and source.low[period-3]<source.low[period-1] and source.low[period-3]<source.low[period-4] and source.low[period-3]<source.low[period-5] then
      down[period-3]=source.low[period-3];
      buffDn:set(period-3, source.low[period-3], "\159", "");
     end
    end
	
	 local H1=nil;
    local H2=nil;
    local L1=nil;
    local L2=nil;
    
  
    if period==source:size()-1 then
    local i=period;
    while (H2==nil or L2==nil) and i>first do
    
     if up[i]==source.high[i] then
      if H1==nil then
       H1=i;
      elseif up[i]>up[H1] and H2==nil then 
       H2=i;
      end
     end
     
     if down[i]==source.low[i] then
      if L1==nil then
       L1=i;
      elseif down[i]<down[L1] and L2==nil then 
       L2=i;
      end
     end
     
     i=i-1;
    end

    if (H1~=nil and H2~=nil) or (L1~=nil and L2~=nil) then
     core.host:execute("removeAll");
    end
    
	local MIN, MAX;
	
    if H1~=nil and H2~=nil then
     core.host:execute("drawLine", 1, source:date(H2), up[H2]-0.5*(up[H1]-up[H2])/(H1-H2), source:date(period), up[H2]+(period-H2-0.5)*(up[H1]-up[H2])/(H1-H2),instance.parameters.clrUP,instance.parameters.styleLinReg,instance.parameters.widthLinReg);
     core.drawLine(TOP, core.range(H2, period), up[H2]-0.5*(up[H1]-up[H2])/(H1-H2), H2,  up[H2]+(period-H2-0.5)*(up[H1]-up[H2])/(H1-H2), period);
			for i= H2, period, 1 do
				if i== H2 then
				MAX= TOP[i] -source.low[i];
				end
				if MAX <  TOP[i] -source.low[i] then
				MAX =  TOP[i] -source.low[i]
				end
			end
	BOTTOM[H2-1]= 666;		
	end
    if L1~=nil and L2~=nil then
     core.host:execute("drawLine", 2, source:date(L2), down[L2]-0.5*(down[L1]-down[L2])/(L1-L2), source:date(period), down[L2]+(period-L2-0.5)*(down[L1]-down[L2])/(L1-L2),instance.parameters.clrDN,instance.parameters.styleLinReg,instance.parameters.widthLinReg);
    core.drawLine(BOTTOM, core.range(L2, period), down[L2]-0.5*(down[L1]-down[L2])/(L1-L2), L2,  down[L2]+(period-L2-0.5)*(down[L1]-down[L2])/(L1-L2), period);
            for i= L2, period, 1 do
				if i== L2 then
				MIN= source.high[i]-BOTTOM[i];
				end
				if MIN <  source.high[i]-BOTTOM[i] then
				MIN =  source.high[i]-BOTTOM[i]
				end
			end 
	BOTTOM[L2-1]= 666;		
    end
	
	if MAX ~= nil then 
	
	      for i = period-1 , first , -1 do
	    	 
	
				 if TOP[i]== 666 then               			  
				  break;
				 end
				 
				 if core.crossesOver(source.close, TOP, i) then
				 core.host:execute("drawLine", 3, source:date(i), TOP[i] +MAX, source:date(period), TOP[i] +MAX ,instance.parameters.clrUP,instance.parameters.styleLinReg,instance.parameters.widthLinReg);	
                 break;
				 end  
		 end 
		 
	end
    
	if MIN ~= nil then 
				for i = period-1 , first , -1 do 
			
					 if BOTTOM[i]== 666 then					
					  break;
					 end
					 
					 if core.crossesUnder(source.close, BOTTOM, i) then
					   core.host:execute("drawLine", 4, source:date(i), BOTTOM[i]-MIN, source:date(period), BOTTOM[i]-MIN  ,instance.parameters.clrUP,instance.parameters.styleLinReg,instance.parameters.widthLinReg);		 
					 break;
					 end    
			 end 
	   end
   end
   end 
    
end

