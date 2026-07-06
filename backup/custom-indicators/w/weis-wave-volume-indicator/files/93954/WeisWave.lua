-- Id: 11713
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59573

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Weis Wave Oscillator");
    indicator:description("Weis Wave Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("dif", "dif", "", 1);
    indicator.parameters:addBoolean("Absolute", "Absolute", "", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
	indicator.parameters:addBoolean("ShowLabel", "Show Label", "", true);
	indicator.parameters:addColor("Label", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addBoolean("ShowOverlay", "Show Overlay", "", true);
	indicator.parameters:addColor("Overlay", "Overlay Color", "Overlay Color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Size", "", 10);
	
	
	indicator.parameters:addGroup("Divisor Calculation");
	indicator.parameters:addInteger("Divisor", "Divisor", "", 1);
	indicator.parameters:addIntegerAlternative("Divisor", "1", "", 1);
    indicator.parameters:addIntegerAlternative("Divisor", "100", "", 100);
    indicator.parameters:addIntegerAlternative("Divisor", "1000", "", 1000);
    indicator.parameters:addIntegerAlternative("Divisor","10000", "", 10000)
	indicator.parameters:addIntegerAlternative("Divisor","100000", "", 100000)
	indicator.parameters:addIntegerAlternative("Divisor","1000000", "", 1000000)
end

local first;
local source = nil;
local dif;
local Absolute;
local difPip;
local mov, trend, wave, vol;
local Wave=nil;
local Up,Down,Size;
local Overlay;
local ShowLabel;
local ShowOverlay;
local Last;
local Divisor;
function Prepare(nameOnly)
    source = instance.source;
	Size=instance.parameters.Size;
	ShowLabel=instance.parameters.ShowLabel;
	ShowOverlay=instance.parameters.ShowOverlay;
	Divisor=instance.parameters.Divisor;
    dif=instance.parameters.dif;
    Absolute=instance.parameters.Absolute;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.dif .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    mov = instance:addInternalStream(first, 0);
    trend = instance:addInternalStream(first, 0);
    wave = instance:addInternalStream(first, 0);
    vol = instance:addInternalStream(first, 0);
    Wave = instance:addStream("Wave", core.Bar, name .. ".Wave", "Wave", instance.parameters.UPclr, first);
    Wave:setPrecision(math.max(2, instance.source:getPrecision()));
    difPip=dif*source:pipSize();
    Up = instance:createTextOutput("Up", "Up", "Arial", Size, core.H_Center, core.V_Top, instance.parameters.Label, 0);
	Down = instance:createTextOutput("Down", "Down", "Arial", Size, core.H_Center, core.V_Bottom, instance.parameters.Label, 0);
    core.host:execute ("attachTextToChart", "Up");
	core.host:execute ("attachTextToChart", "Down");
    if ShowOverlay  then
	Overlay = instance:addStream("Overlay", core.Line, name .. ".Overlay", "Overlay", instance.parameters.Overlay, first);
    Overlay:setPrecision(math.max(2, instance.source:getPrecision()));
	core.host:execute ("attachOuputToChart", "Overlay");
	else
	Overlay = instance:addInternalStream(first, 0);
	end
	
	  instance:ownerDrawn(true);
end

function Update(period )
  
   Calculation (period );
end


function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end
	
	 context:setClipRectangle (  context:left (), context:top(), context:right (), context:bottom());  
	 
	   local iFirst = math.max(first, context:firstBar ())+3;
        local iLast = math.min (context:lastBar (), source:size()-1);
	
    Last=nil;
    for period= 	iFirst, iLast, 1 do	
    Label(period,iFirst); 
    end
 end
 

function Label(period,iFirst)

  	
    Up:setNoData (period-2);
    Down:setNoData (period-2);
	
	
   
   if Last== nil
   then
	   if ( wave[period-2]==1 and  wave[period-1]~=1 )  then  
	   Last=period-2;
	   Overlay[Last]= source.close[Last];
	   Up:set(period-2, source.high[period-2],   win32.formatNumber(  math.abs(Wave[period-2]), false, 2));
	   elseif (wave[period-2]==-1 and  wave[period-1]~=-1)     then  
	   Last=period-2;
	   Overlay[Last]= source.close[Last];
	    Down:set(period-2, source.low[period-2], win32.formatNumber(    math.abs(Wave[period-2]), false, 2));
	   end
	   
	   return;
   end
   
   
   if Last== nil then
   return;
   end
   
   if  wave[period-2]==1 and  wave[period-1]~=1  then
	   if ShowLabel then
	   Up:set(period-2, source.high[period-2],  win32.formatNumber( math.abs(Wave[period-2]), false, 2));
	 
	    core.drawLine(Overlay, core.range(Last, period-2), Overlay[Last], Last, math.max(source.open[period-2],source.close[period-2]), period-2);
		 
        Last=  period-2;	   
	   end
   elseif  wave[period-2]==-1 and  wave[period-1]~=-1  then	  
       if  ShowLabel    then
	   Down:set(period-2, source.low[period-2],   win32.formatNumber( math.abs(Wave[period-2]), false, 2));	
	    
        core.drawLine(Overlay, core.range(Last, period-2), Overlay[Last], Last, math.min(source.open[period-2],source.close[period-2]), period-2);
		 
        Last= period-2;	   
       end 	   
   end
    
    
end

function Calculation (period, mode)
if period>first then
    if source.close[period]>source.close[period-1] then
     mov[period]=1;
    elseif source.close[period]<source.close[period-1] then
     mov[period]=-1;
    else
     mov[period]=0;
    end
    if mov[period]~=0 and mov[period]~=mov[period-1] then
     trend[period]=mov[period];
    else
     trend[period]=trend[period-1];
    end
    if trend[period]~=wave[period-1] and math.abs(source.close[period]-source.close[period-1])>=difPip then
     wave[period]=trend[period];
    else
     wave[period]=wave[period-1];
    end
    if wave[period]==wave[period-1] then
     vol[period]=vol[period-1]+source.volume[period]/Divisor;
    else
     vol[period]=source.volume[period]/Divisor;
    end
    if wave[period]==1 then
     Wave[period]=vol[period];    
     Wave:setColor(period, instance.parameters.UPclr); 	 
    elseif wave[period]==-1 then
     if Absolute then
      Wave[period]=  vol[period] ;
     else
      Wave[period]= -vol[period];
     end  
	 Wave:setColor(period, instance.parameters.DNclr); 
    end
   end 
 

end