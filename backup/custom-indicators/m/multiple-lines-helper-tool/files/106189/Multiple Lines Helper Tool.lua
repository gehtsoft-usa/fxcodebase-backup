
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=63461

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
    indicator:name("Multiple Lines Helper Tool");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
 

   Add(1, true, 8,0,0);
   Add(2, true, 9,0,0);
   Add(3, true, 8,0,1);
   Add(4, true, 9,0,1);
   Add(5, false, 0,0,0);
   Add(6, false, 0,0,0);
   Add(7, false, 0,0,0);
   Add(8, false, 0,0,0);
   Add(9, false, 0,0,0);
   Add(10, false, 0,0,0);
   
end

function Add(id, On, Hours, Minutes, Shift)

indicator.parameters:addGroup(id ..". Line");
indicator.parameters:addBoolean("on"..id , "Show  This Line", "", On);

indicator.parameters:addInteger("Hours"..id, "Hours", "", Hours);
indicator.parameters:addInteger("Minutes"..id, "Minutes", "", Minutes);
indicator.parameters:addInteger("Shift"..id, "Shift", "", Shift);

indicator.parameters:addString("Price"..id, "Price Source", "", "close");
indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	 

indicator.parameters:addColor("color"..id , "Line Color", "", core.rgb(0, 255, 0));
indicator.parameters:addInteger("width"..id , "Indicator Line Width", "", 1, 1, 5);
indicator.parameters:addInteger("style"..id , "Indicator Line Style", "", core.LINE_SOLID);
indicator.parameters:setFlag("style"..id , core.FLAG_LINE_STYLE);
 
end
 
local color={};
local style={};
local width={};
local on={};
local data={};
local Price={};

local first;
local source;
local Source;
local loading;


function Prepare(onlyName)
     
	source = instance.source; 
	first=source:first();
    local name;
    name = profile:id() .. "(" .. instance.source:name()  .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end 
	
	Source = core.host:execute("getSyncHistory", source:instrument(), "m30", source:isBid(), 300, 100, 101);
	loading=true;
	
	for i= 1, 10 , 1 do
	on[i]=instance.parameters:getBoolean("on" .. i);
	color[i]=instance.parameters:getColor("color" .. i);
	width[i]=instance.parameters:getInteger("width" .. i);
    style[i]=instance.parameters:getInteger("style" .. i);
	Price[i]=instance.parameters:getString("Price" .. i);	
	end
	
   instance:ownerDrawn(true);

end

function ParseTime(i)
local Hours = instance.parameters:getInteger("Hours" .. i);
local Minutes = instance.parameters:getInteger("Minutes" .. i);
local Shift= instance.parameters:getInteger("Shift" .. i);
local s, e = core.getcandle("D1", core.now(), core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));
local Day= (e-s);
local date = core.dateToTable(source:date(source:size()-1));
local tdate = {year = date.year, month = date.month, day = date.day, hour = Hours, min = Minutes, sec = 0};
local ReturnValue=core.tableToDate (tdate );
return (ReturnValue-Day*Shift);
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


function Update(period)     
end 


local init = false;
local Index1={};
local Index2={};
function Draw(stage, context)
    if stage ~= 2 
	or loading
	then
	return;
	end
        if not init then
		    for i=1, 10 , 1 do
            context:createPen (i, context:convertPenStyle (style[i]), width[i], color[i]);
			end
            init = true;
         end
	local y={};
	
	
	for i= 1, 10 , 1 do 
	data[i]= ParseTime(i);
	Index1[i] = core.findDate(source, data[i], false);	
	Index2[i] = core.findDate(Source, data[i], false);	
	end
	
	
	for i=1, 10 , 1 do
		if on[i] and Index1[i]~= -1 and Index1[i]~=nil  and Index2[i]~=nil    then
		x, x1, x2 = context:positionOfBar (Index1[i]);
		 
		visible, y[i] = context:pointOfPrice (Source[Price[i]][Index2[i]]);
		 
		context:drawLine (i, x, y[i], context:right (), y[i]);
		end
    end
	
end