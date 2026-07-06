-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72642

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trade Count Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 	indicator.parameters:addGroup("Selector");	
    indicator.parameters:addBoolean("OfferFilter", "Use Offer Filter", "", false);	
    indicator.parameters:addBoolean("CustomIdentifier", "Use Custom Identifier Filter", "", false);
	indicator.parameters:addString("Direction", "Trade Direction Filter", "" , "Any");
    indicator.parameters:addStringAlternative("Direction", "Long", "Long" , "B");
    indicator.parameters:addStringAlternative("Direction", "Short", "Short" , "S");	
    indicator.parameters:addStringAlternative("Direction", "Any", "Any" , "Any");		
  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("TotalNumberOfPosition", "Total number of trades executed by the strategy", "", 5, 1, 10000)	
    indicator.parameters:addDouble("TotalNumberOfPositionTime", "Total number of trades executed by the strategy (Time in Days)", "", 1, 1, 10000)	
    indicator.parameters:addString(
        "CustomID",
        "Custom Identifier",
        "The identifier that can be used to distinguish strategy instances",
        "CSS"
    )

    indicator.parameters:addString("Account", "Account to trade on", "", "")
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT)
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label1", "Open Trade Color", "", core.rgb(0, 255, 0)); 
    indicator.parameters:addColor("Label2", "Closed Trade Color", "", core.rgb(255, 0, 0));   
   indicator.parameters:addInteger("Size", "Font Size", "", 20); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 
local Closed;
local Opened;
local Direction;	
-- Routine
 function Prepare(nameOnly)   
 
    
    CustomID = instance.parameters.CustomID 
	TotalNumberOfPosition = instance.parameters.TotalNumberOfPosition;
	TotalNumberOfPositionTime= instance.parameters.TotalNumberOfPositionTime;
	CustomIdentifier= instance.parameters.CustomIdentifier;
	OfferFilter= instance.parameters.OfferFilter;
	Direction= instance.parameters.Direction;
	
	
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label1=instance.parameters.Label1;
    Label2=instance.parameters.Label2;	
	Size=instance.parameters.Size;   
	
   
	source = instance.source
	first=source:first() 
	
    local name = profile:id() .. "(" ..  instance.source:name()     .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	 
    Account = instance.parameters.Account 
    Offer = core.host:findTable("offers"):find("Instrument", source:instrument()).OfferID
 
    instance:ownerDrawn(true);
end

function NumberOfOpened(BuySell)
    local enum, row
    local count = 0
	
	if BuySell == "Any" then
	BuySell=nil;
	end
	
	
    enum = core.host:findTable("trades"):enumerator()
    row = enum:next()
    while row ~= nil do
        if  row.AccountID == Account 
			and (row.OfferID == Offer or not OfferFilter)
			and (row.QTXT == CustomID or not CustomIdentifier) 
			and (row.BS == BuySell or BuySell == nil) 
			and row.Time >=  (source:date(NOW) - TotalNumberOfPositionTime)
         then
            count = count + 1
        end

        row = enum:next()
    end
    return count	
end
	
function NumberOfClosed(BuySell)

    local enum, row
    local count = 0
	
	if BuySell == "Any" then
	BuySell=nil;
	end
 
    enum = core.host:findTable("closed trades"):enumerator()
    row = enum:next()
    while row ~= nil do
        if  row.AccountID == Account
		and (row.OfferID == Offer or not OfferFilter)
		and (row.QTXT == CustomID or not CustomIdentifier) 
		and (row.BS == BuySell or BuySell == nil)
		and row.OpenTime >=  (source:date(NOW) - TotalNumberOfPositionTime)
        then
            count = count + 1
        end

        row = enum:next()
    end	

    return count
end
	
	


function Update(period, mode)

	 

	 if period <= first then
	 return;
	 end
	  
	Opened = NumberOfOpened(Direction);
	Closed = NumberOfClosed(Direction);
	
end


local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	
			
	local Text1=  "Opened : " .. tostring(Opened);
	 
   local i=1;	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label1, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0   );	
   
  	local Text2=  "Closed : " .. tostring(Closed); 
   local i=2;	 
   width, height = context:measureText (1, Text2, 0);
   context:drawText (1,  Text2, Label2, -1,  iX(context,width,0,1) ,  iY(context,height,i,0) ,iX(context,width,0,2),iY(context,height,i,1), 0  );	
end		
 
 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Index , Line)

	if Y== "Top" then
		return context:top()+Index*height +ShiftY*height + Line *height;
	else
		if Line== 1 then
		return context:bottom()-(Index+1)*height -ShiftY*height + height;
		else
		return context:bottom()-(Index+1)*height -ShiftY*height;
		end
	end
end
