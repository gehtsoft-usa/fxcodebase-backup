-- Id: 10742
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60142

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
 
local source;
local host;
local font1;
 local iTF={"m1","m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1" };
local size, color;
local Entry;
local name;
local iColor={};
-- Create the indicator's profile
function Init()
    indicator:name("Repository");
    indicator:description("Repository");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
       
	indicator.parameters:addGroup("Entry");  
     indicator.parameters:addString("Entry", "Text Entry", "", "");
     	
    indicator.parameters:addGroup("Display options");
     indicator.parameters:addBoolean("Use", "Use Date Tagging", "", true);	
    indicator.parameters:addString("format", "Date format", "", "DDMMYYYY");
    indicator.parameters:addStringAlternative("format", "Off", "", "Off");
    indicator.parameters:addStringAlternative("format", "DD/MM/YYYY", "", "DDMMYYYY");
    indicator.parameters:addStringAlternative("format", "MM/DD/YYYY", "", "MMDDYYYY");
    
    -- Colours and effects
    indicator.parameters:addGroup("Colours and effects");
    indicator.parameters:addColor("colour", "Colour", "", core.rgb(225, 225, 225));
    indicator.parameters:addString("fontName", "Font", "", "Arial Black");
    indicator.parameters:addInteger("fontSize1", "Font size for main text", "", 20);
	
	--local iTF={"m1", "m5", "m15",   "m30",    "H1",    "H2",    "H3",    "H4",    "H6",    "H8",    "D1",    "W1",    "M1"};
	for i= 1 ,13,1 do
	indicator.parameters:addColor(iTF[i],iTF [i] ..  " Time Frame Color", "", Coloring ((100/13)*i, 50));
	end

 
	 
end

function Coloring (value, mid)

local Color;

if value <= mid then
Color = core.rgb(255 * (value / mid), 255, 0) 
else 
Color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
end


return  Color;

end

-- local iTF={"m1","m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1" };
local db;
local Shift;
local Use;
local text={};
function Prepare(nameOnly)
   
    source = instance.source;
	Entry =instance.parameters.Entry;
    host = core.host;
	Use =instance.parameters.Use;
	
    name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
	

    if nameOnly then
        return
    end
	require("storagedb");
    db = storagedb.get_db(name);
    
	for i= 1, 13 , 1 do
	iColor[i]= instance.parameters:getDouble(iTF[i]);
	end
	
    -- Create font
    font1 = host:execute("createFont", instance.parameters.fontName, instance.parameters.fontSize1, false, false); 
	color = instance.parameters.colour;
    size = instance.parameters.size;
   

    instance:setLabelColor(color);
    instance:ownerDrawn(true);
	
	core.host:execute("addCommand", 1, "Add Entry", "");
	core.host:execute("addCommand", 2, "Delete Entry", "");
	core.host:execute("addCommand", 3, "Reset", ""); 
	
	text={};
	core.host:execute ("setTimer", 100, 1);
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


-- Update the indicator
function Update(period, mode)

         
   
end

-- Release the indicator
function ReleaseInstance()
    host:execute("deleteFont", font1);
    
end

local initDraw = false;
 
function AsyncOperationFinished(cookie, success, message)

     local itext="";
	 
     if Use then
     local date = core.dateToTable(core.now());
        if instance.parameters.format == "DDMMYYYY" then
            itext = Entry .. " : " .. string.format("%d/%d/%d", date.day, date.month, date.year);
        elseif instance.parameters.format == "MMDDYYYY" then
            itext = Entry .. " : " .. string.format("%d/%d/%d", date.month, date.day, date.year);
        end
    else
	itext= Entry;
	end
		
	if cookie == 1 then	 
	db:put(source:instrument() .. "/" .. source:barSize()  , itext); 	 
	elseif cookie == 2 then	
	db:put(source:instrument() .. "/" .. source:barSize()  , ""); 
	elseif cookie == 3 then	
	local i;
	for i= 1, 13 , 1 do
	db:put(source:instrument() .. "/" .. iTF[i]  , ""); 
	end
	end
	
	            if cookie == 100 then
						for i= 3, 15, 1 do
				 
					
					 
					   text[i]= db:get (source:instrument() .. "/" .. iTF[i-2], 0);
					
						if text[i]== nil or text[i]== 0 then
						text[i]="";				
						end
						
					end
			
			end

end

function Draw(stage, context)



    if stage ~= 2 then
        return ;
    end
        

        

            text[1] = string.format("%s (%s)", source:instrument(), source:barSize());
     
        
        local date = core.dateToTable(core.now());
        if instance.parameters.format == "DDMMYYYY" then
            text[2] = string.format("%d/%d/%d", date.day, date.month, date.year);
        elseif instance.parameters.format == "MMDDYYYY" then
            text[2] = string.format("%d/%d/%d", date.month, date.day, date.year);
        end
        
        local offset;
        local vPos, vAlign;
        local hPos, hAlign = core.CR_CENTER, core.H_Center;
       

            vPos, vAlign = core.CR_TOP, core.V_Center;    
			hPos, hAlign = core.CR_RIGHT, core.H_Left;
			
			
			Shift=0;
			
          
            for i= 1, 15, 1 do
		 
			
		 
			if   text[i]~="" and  text[i]~=nil then
			Shift=Shift+1;
		 
			
			
			offset= ((Shift-1) * instance.parameters.fontSize1/4 ) +((Shift-1) * instance.parameters.fontSize1)+ instance.parameters.fontSize1/2;
				if i > 2 then
				    if text[i]=="" then
					host:execute ("removeLabel", i)
					else
					
					host:execute("drawLabel1", i, 0, hPos, offset, vPos, hAlign, vAlign, font1, iColor[i-2],  text[i] .." : " .. iTF[i-2] );
					end
				else
				host:execute("drawLabel1", i, 0, hPos, offset, vPos, hAlign, vAlign, font1, instance.parameters.colour, text[i]);
				end
            end
        
	 
		 end
		
    
end	