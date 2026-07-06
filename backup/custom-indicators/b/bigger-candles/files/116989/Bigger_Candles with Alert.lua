-- Id: 21611
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65623

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


function Init()
    indicator:name("Bigger candles indicator");
    indicator:description("Bigger candles indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("TF", "Time frame for candles", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "Color", core.rgb(255,0, 0));
	indicator.parameters:addColor("Line", "Line Color", "Color", core.rgb(0,0, 0));

    indicator.parameters:addInteger("Transparency", "Transparency", "0 - opaque, 100 - transparent", 85, 0, 100);

    
    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("AlertCandle","Show alert for new candle", "Show alert on new candle appears.", true);
	
	 indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addFile("Sound",   "Alert Sound", "", "");
    indicator.parameters:setFlag("Sound", core.FLAG_SOUND);
 
	
end

local first;
local source = nil;
local TF;
local TradingDayOffset, TradingWeekOffset;
local Transparency;
local LastEndCandle;
local AlertCandle;
local last_period;
 
local Sound;
local  RecurrentSound ,SoundFile  ;
local PlaySound;

local Source, loading;

function Prepare(onlyName)
    TF=instance.parameters.TF;
    AlertCandle=instance.parameters.AlertCandle; 
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.TF .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
	
	
 
	RecurrentSound= instance.parameters.RecurrentSound;
    Show= instance.parameters.Show; 
	PlaySound = instance.parameters.PlaySound;
	
    if PlaySound then 
	  Sound=instance.parameters.Sound; 
    else  
      Sound=nil;
	 end
	 
	 
	  assert(not(PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen"); 
	
	
	local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	
    instance:ownerDrawn(true);
    TradingDayOffset = core.host:execute("getTradingDayOffset");
    TradingWeekOffset = core.host:execute("getTradingWeekOffset");
    instance:setLabelColor(instance.parameters.Up);
    
	
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), first, 100, 101);
	loading=true;
	
end

function Update(period, mode)


if period < source:size()-1 then
last_period = source:size()-1;
return;
end

if not AlertCandle then
return;
end

    local beginCandle, endCandle = core.getcandle(TF, source:date(period), TradingDayOffset, TradingWeekOffset);
  
      
        if source:date(period) >= beginCandle  and  source:date(period-1)< beginCandle then
        ShowAlertOnNewCandleAppears(source:instrument(), source.close[period], source:date(period),period); 
		end
end

local init = false;

function Draw(stage, context)
    if stage ~=0
	or loading
	then
    return;
	end
        if not init then
            
            context:createSolidBrush(1, instance.parameters.Up);					 
            context:createSolidBrush(2, instance.parameters.Down);	
			context:createPen(3, context.SOLID, 3, instance.parameters.Line); 
			
			
            Transparency=context:convertTransparency(instance.parameters.Transparency); 
            init = true;
        end

        local firstIndex = context:firstBar();
        local lastIndex = context:lastBar();

     
	 
	  
               for Index= Source:first(), Source:size()-1 , 1 do
              
					  
						if Source:date(Index)> source:date(firstIndex) then
					      local beginCandle, endCandle = core.getcandle(TF, Source:date(Index), TradingDayOffset, TradingWeekOffset);            
					
					      visible, H =context:pointOfPrice (Source.high[Index]);
						  visible, L =context:pointOfPrice (Source.low[Index]);
						  visible, O =context:pointOfPrice (Source.open[Index]);
						  visible, C =context:pointOfPrice (Source.close[Index]);
					  
					   
					
					
						      X1, x = context:positionOfDate (beginCandle);
							  X2, x = context:positionOfDate (endCandle);
							 
							  if Source.close[Index] > Source.open[Index] then
							  context:drawRectangle(-1, 1, X1, H, X2, L,Transparency);						 
							  else
							  context:drawRectangle(-1, 2, X1, H, X2, L,Transparency);		
							  end
							  
							  
							  context:drawLine (3, X1, O, X2, O );
							  context:drawLine (3, X1, C, X2, C );
						
						 end
				end
          
       
     
end

function ShowAlertOnNewCandleAppears(instrument, price, time,period)
    if   last_period== period then
	return;
	end
	
	    last_period= period;
		
        terminal:alertMessage (instrument, price, "New higher time frame candle appears.", time);    

        if PlaySound then 
        terminal:alertSound(Sound, RecurrentSound);   
        end		
	 
end


function AsyncOperationFinished(cookie)


  if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end

end
