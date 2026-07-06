-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=638
-- Id: 16048

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("OHLC Bar Chart");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FM", "AC/AO fast moving average", "No description", 5);
    indicator.parameters:addInteger("SM", "AC/AO slow moving average", "No description", 35);
    indicator.parameters:addInteger("AM", "A/C moving average", "No description", 5);
	indicator.parameters:addGroup("Zone Trade or AO and AC Separately");
	indicator.parameters:addInteger("MT" , "Zone Trade", "" , 1);	
    indicator.parameters:addIntegerAlternative("MT", "Awesome oscillator(AO)", "ZONE" , 2);
    indicator.parameters:addIntegerAlternative("MT", "Acceleration/Deceleration (AC)", "" , 3);
	indicator.parameters:addIntegerAlternative("MT", "B.W. Zone AC + AO", "" , 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPcolor", "UP color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNcolor", "DN color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutralcolor", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1 , 5);
end

local init;
local UPcolor, DNcolor,Neutralcolor;
local source;
local first;
local open, high, low, close;

local FM;
local SM;
local AM;

local Method=nil;

local AO;
local AC;
local Color;

-- initializes the instance of the indicator
function Prepare(onlyName)

    FM = instance.parameters.FM;
    SM = instance.parameters.SM;
    AM = instance.parameters.AM;
	Method= instance.parameters.MT;
	
    source=instance.source;
    instrument = instance.parameters.instrument;
    frame = instance.parameters.frame;
    UPcolor = instance.parameters.UPcolor;
    DNcolor = instance.parameters.DNcolor;
    Neutralcolor = instance.parameters.Neutralcolor;
	

    local name = profile:id() .. "(" .. source:name() .. ", "  .. FM .. ", " .. SM .. ", " .. AM .. ")";
    instance:name(name);
	

    if onlyName then
        return ;
    end
	Color= instance:addInternalStream(0, 0);
	
	AC = core.indicators:create("AC", source, FM, SM, AM);
    AO = core.indicators:create("AO", source, FM, SM);
    first = math.max( AC.DATA:first(), AO.DATA:first());	
    
    instance:setLabelColor(instance.parameters.UPcolor);
    
    instance:ownerDrawn(true);
    init=false;
    open = instance:addStream("open", core.Dot, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Dot, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Dot, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Dot, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "ZONE", open, high, low, close);
    open:setVisible(false);
    high:setVisible(false);
    low:setVisible(false);
    close:setVisible(false);
end

function Update(period, mode)
  
 AC:update(mode);
 AO:update(mode); 
 
 
 open[period]=source.open[period];
 high[period]=source.high[period];
 low[period]=source.low[period];
 close[period]=source.close[period];
 
 
   	if period < first  or not source:hasData(period) then
	Color[period]=0;		
    return;
    end 
  
         local acdir, aodir;      
		
        if AO.DATA[period] > AO.DATA[period - 1] then
            aodir = true;
        elseif AO.DATA[period] < AO.DATA[period - 1] then
            aodir = false;
        end
        if AC.DATA[period] > AC.DATA[period - 1] then
            acdir = true;
        elseif AC.DATA[period] < AC.DATA[period - 1] then
            acdir = false;
        end
		
		
		if   Method== 1 then
				if aodir  and acdir then 
				Color[period]=1;
				elseif  not aodir  and  not acdir then
				Color[period]=-1;
				else
				Color[period]=0;
				end
		elseif 	Method== 2 then
		            
				if aodir   then
				Color[period]=1;
				elseif  not aodir then
				Color[period]=-1;			  
		        end
		  
		elseif  Method== 3 then
		
		        if  acdir then
				Color[period]=1;
				elseif  not acdir then
				Color[period]=-1;
			    end 
		end	              
				   
end

function Draw(stage, context)
    if stage == 2 then
        if not init then
            context:createPen(1, context.SOLID,  instance.parameters.width, UPcolor);
            context:createPen(2, context.SOLID,  instance.parameters.width, DNcolor);
			 context:createPen(3, context.SOLID,  instance.parameters.width, Neutralcolor);
            init = true;
        end
        
        local m, po, pc, ph, pl;
        local m2, p2;
        local Hbegin, Hend;
        local Points;
        
        local firstBar=context:firstBar();
        
        context:startEnumeration();
        while true do
            index, x, x1, x2, c1, c2 = context:nextBar();
            if index == nil then
                break;
            end
            
            m, po = context:pointOfPrice(source.open[index]);
            m, ph = context:pointOfPrice(source.high[index]);
            m, pl = context:pointOfPrice(source.low[index]);
            m, pc = context:pointOfPrice(source.close[index]);
            
            Points = context:createPoints();
            Points:add(x1, po);
            Points:add(x, ph);
            Points:add(x2, pc);
            Points:add(x, pl);
            
            if Color[index]== 1 then            
             context:drawLine(1, x, ph, x, pl);
             context:drawLine(1, x, pc, x2, pc);
              context:drawLine(1, x1, po, x, po);
 
            elseif Color[index]== -1 then     
             context:drawLine(2, x, ph, x, pl);
             context:drawLine(2, x, pc, x2, pc);
             context:drawLine(2, x1, po, x, po);
             else
			  context:drawLine(3, x, ph, x, pl);
             context:drawLine(3, x, pc, x2, pc);
             context:drawLine(3, x1, po, x, po);
	        end 
            
        end
    end

end
