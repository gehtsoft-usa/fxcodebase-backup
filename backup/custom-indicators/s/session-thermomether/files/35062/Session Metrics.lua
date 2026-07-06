
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=19447

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Session Metrics");
    indicator:description("Session Metrics");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    
    
	AddSession(1,"Sidney", -7, 9 , core.rgb(0, 255, 0))
	AddSession(2,"Tokyo", -5, 9 ,core.rgb(255, 0, 0));
	AddSession(3,"London", 3, 9 ,core.rgb(0, 0, 255));
	AddSession(4,"New York", 8, 9,core.rgb(128, 128, 128) );
	 indicator.parameters:addGroup("Style"); 
    indicator.parameters:addInteger("Size", "Font Size", "", 10);
   indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0);
   
   
   indicator.parameters:addColor("Label" , "label Color", "Label Color", core.rgb(0, 0, 0)); 
 
end

 

function AddSession(id,Name,From, Length,Color) 

     indicator.parameters:addGroup(id .. ". Session");	
  

    indicator.parameters:addString("Name"..id, "Session Name", "Session Name", Name); 
	indicator.parameters:addDouble("From"..id, "Session Start Time", "Session Start Time", From); 
	indicator.parameters:addDouble("Length"..id, "Session Length", "Session Length", Length);
    indicator.parameters:addColor("Color"..id, "Session Color", "Session Color", Color);
    
end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Name={};
local From={};
local Length={};
local first;
local Transparency;
local source = nil;
--local ShowPriceTarget;
local Color = {};
 local Count;
 local Size;
 local Label,Up,Down,Neutral; 
 local Open={};
 local Close={};
 
 local Source;
 local loading;
 
local Last={0,0,0,0}; 
local Sum={0,0,0,0}
local SessionCount={0,0,0,0};
local Shift;
local font1;
	
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();  
	
	
    Size= instance.parameters.Size; 
	Shift= instance.parameters.Shift;
	Label= instance.parameters.Label;  
	
	font1 = core.host:execute("createFont", "Arial", Size, false, false);
	
	Count=0;
	local i;
	
	for i= 1, 4,1 do	
	    
	   Count=Count+1;
		Color[Count]=instance.parameters:getDouble("Color" .. i);
		Name[Count]=instance.parameters:getString("Name" .. i);
		From[Count]=instance.parameters:getDouble("From" .. i);
		Length[Count]=instance.parameters:getDouble("Length" .. i);
	 
	end
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
 
  
	Source = core.host:execute("getSyncHistory", source:instrument(), "H1", source:isBid(), 300, 100, 101);
	loading=true;

	  
 

end
 
 function ReleaseInstance()
  core.host:execute("deleteFont", font1); 
 end 

function Process(session, period)
 
 local date = Source:date(period);       -- bar date;
  

   local sfrom, sto;

    -- 1) calculate the session to which the specified date belongs
    local t;
    t = math.floor(date * 86400 + 0.5);     -- date/time in seconds

    -- shift the date so it is in the virtual time zone in which 0:00 is the begin of the session
    t = t - From[session] * 3600;
    -- truncate to the day only.
    t = math.floor(t / 86400 + 0.5) * 86400;
    -- and shift it back to est time zone
    t = t + From[session] * 3600;

    sfrom = t;                          -- begin of the session
    sto = sfrom + Length[session] * 3600;   -- end of the session
	
	sfrom = sfrom / 86400;
    sto = sto / 86400;
	
    if Open[session]== nil  then
	p1= core.findDate (Source, sfrom, false);
	p2= core.findDate (Source, sto, false); 
	
		if p1~=-1 and p2~=-1 and ( p1~= p2) then
		Open[session]=p1;
		Close[session]=p2;
		end
	end
	
end
 
function Update(period)

    
	if loading or period < source:size()-1 then
	core.host:execute("setStatus","Loading");
	return;
	end
	
   	Open={};
	Close={};
    Sum={0,0,0,0}
    SessionCount={0,0,0,0}
    Last={0,0,0,0};
	
	
	
	for period= Source:size()-1 , Source:first(), -1 do
	
				        
		 
						
						for session= 1, Count ,1 do 
						
						
						 Process(session,period ); 
						     if Open[session]~=-1 and Close[session]~=-1  and Close[session]~=nil  and Open[session]~=nil then
								if Last[session]~= Close[session] then
								Last[session]= Close[session];	
								Sum[session]= Sum[session]+math.abs( Source.close[Close[session]]-Source.open[Open[session]]);
								SessionCount[session]= SessionCount[session]+1;		
								end							
							end
						
						end		 
						
						
							
      end				
				
    
		
	core.host:execute ("removeAll")	;
	id=1;

	
	local i;
	for i = 1, 4 , 1 do
  
		 	if SessionCount[i]~=0 then
			core.host:execute("drawLabel1", id, -Size*5-(i-1)*Size*1.1*5 ,  core.CR_RIGHT, Size*1.1*3  +Shift, core.CR_TOP, core.H_Left, core.V_Center, font1, Color[i],  Name[i]);		
			id=id+1;
			
		 
			core.host:execute("drawLabel1", id, - Size*5*5 ,  core.CR_RIGHT,Size*1.1*3  +Shift +Size*1.1*2 , core.CR_TOP, core.H_Left, core.V_Center, font1,  Label,  "Avg");	
			id=id+1;
			
			local Value=(Sum[i]/SessionCount[i])/source:pipSize();
			
			core.host:execute("drawLabel1", id, -Size*5-(i-1)*Size*1.1*5 ,  core.CR_RIGHT, Size*1.1*3  +Shift +Size*1.1*2    +Shift, core.CR_TOP, core.H_Left, core.V_Center, font1, Label,  win32.formatNumber(Value, false, 2) );	
			id=id+1;
			 end
  
    end

    
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


