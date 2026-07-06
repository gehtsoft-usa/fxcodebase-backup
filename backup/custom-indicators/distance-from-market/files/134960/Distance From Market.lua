-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70022

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Distance From Market");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Account", "Account", "Account to monitor open positions for.", "")
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT)
	
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Size", "Font Size", "", 9);
 
end

local source; 
 local Size;
 local Account;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
  

    if   (nameOnly) then
        return;
    end

   
    source = instance.source; 
	 
	
    if nameOnly then
        return
    end
    
	Size=instance.parameters.Size;
	Account=instance.parameters.Account;
	 
    instance:setLabelColor(instance.parameters.Up);
    instance:ownerDrawn(true);
	 
	
end

-- Update the indicator
function Update(period, mode)
   
end

 

local init = false;

function Draw(stage, context)
 
    if stage ~= 2 then
        return ;
    end
	
	
	
	  if not init then
	  init= true;
	  context:createFont(1, "Arial", Size, Size, context.NORMAL);
	  end			 

    local Value, Level;
	local enum = core.host:findTable("orders"):enumerator()
    local row = enum:next();
	local Color=instance.parameters.Up;
    while   (row ~= nil) do
	
        if row.AccountID == Account 
		and row.Instrument ==  source:instrument() 		
		then
		    visible, y =  context:pointOfPrice (row.Rate);
		    Value = win32.formatNumber( row.Distance, false, 2);        
			width, height = context:measureText (1,  Value , context.NORMAL);	 
		
		    if row.Distance > 0 then  			
			Color=instance.parameters.Up;
			else
			Color=instance.parameters.Down;
            end		
            context:drawText(1,  Value , Color, -1, context:right()-width, y-height ,context:right() , y, context.NORMAL);	
					 

        end
		
	   row = enum:next()
    end	
 
	local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next();
	
    while   (row ~= nil) do
	
        if row.AccountID == Account 
		and row.Instrument ==  source:instrument() 		
		then
		    visible, y =  context:pointOfPrice (row.Open);
			Value= math.abs(row.Open- row.Close)/source:pipSize();
			
		    Value = win32.formatNumber( Value, false, 2);        
			width, height = context:measureText (1,  Value , context.NORMAL);	

            if row.GrossPL < 0 then  			
			Color=instance.parameters.Up;
			else
			Color=instance.parameters.Down;
            end		
            context:drawText(1,  Value , Color, -1, context:right()-width, y-height ,context:right() , y, context.NORMAL);			

        end	
	 	
        row = enum:next()
    end
	
		
    
end	