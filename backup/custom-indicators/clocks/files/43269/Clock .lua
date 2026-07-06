-- Id: 7795
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=25168

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

function Add(id, Flag,TimeShift )
    local i;
	local Labels={ "EST", "UTC","Local","Chart", "Server", "Financial", "Sydney","Tokyo", "London", "New York", "Omsk", "Zagreb"};
	
    indicator.parameters:addGroup(id.. ". Clock");
	 
	
	indicator.parameters:addBoolean("USE".. id, "Use this Clock", "", Flag);	
	indicator.parameters:addInteger("Label" .. id , "Label", "" ,id);	
    for i = 1, 12, 1 do	
     indicator.parameters:addIntegerAlternative("Label" .. id,  Labels[i], "",  i);	
	end 
	if id > 6  then
	indicator.parameters:addInteger("TimeShift" .. id , "Shift", "" ,TimeShift);	
	end
end


function Init()
    indicator:name("Clock");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	
	
    Add(1, false,0);	
    Add(2, false,0);	
    Add(3, true ,0);	
    Add(4, false,0);
    Add(5, false,0);
	Add(6, true,0);	
    Add(7, true,15);	
    Add(8, true, 13);	
	Add(9, true,4);	
	Add(10, true,0);
    Add(11, true,11);
    Add(12, true,5);
	
	
    indicator.parameters:addGroup("Style");  
    indicator.parameters:addBoolean("Show", "Show Seconds", "", true);
	indicator.parameters:addColor("LabelColor", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("Size", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
   local Labels={ "EST", "UTC","Local","Chart", "Server", "Financial", "Sydney","Tokyo", "London", "New York", "Omsk", "Zagreb"};
	local source = nil;
	local L={};	
	local SourceData={};	
	local Size;
	local USE={};
	local Count=12;
    local Number;
    local id;
	local Size, LabelColor;
	local  Shift;
	local Hour={};
	local TimeShift={};
	local Label={};
	local Arial; 
	local Show;
	--()()()()()()Customized segment ()()()()()()()
     
	--()()()()()()()()()()()()()()()()()()()()()()()()
	

function ReleaseInstance()
       core.host:execute("deleteFont", Arial);
   end	
	
-- Routine
function Prepare(nameOnly)
   Show=instance.parameters.Show;
    source = instance.source;   
	local e,s;
	s, e = core.getcandle("H1", core.now(), 0, 0);
	Hour=e-s;
	
	LabelColor=instance.parameters.LabelColor;
    Shift=instance.parameters.Shift;
    Size=instance.parameters.Size;
	
   

    local i;
    local name = profile:id() .. "(" .. source:name() ;
	
	Number=0;
	
    for i = 1, Count, 1 do
	
	  
	
	    USE[i]=instance.parameters:getBoolean("USE" .. i);
		
		
	   
	     if USE[i]  then
		 Number=Number+1;
		 
		   Label[Number]=instance.parameters:getInteger("Label" .. i);
		   
		   if  i  >  6 then
		  TimeShift[Number]=instance.parameters:getInteger("TimeShift" .. i);
		  else
		  TimeShift[Number]=0;
		  end
		  -- Select[Number]=instance.parameters:getString("Select" .. i);
		 		   
		 			 
		   
		   L[Number] = Labels[Label[Number]];
		   name = name ..", " .."(" .. L[Number] ..")";
		 
		 end   
		   
	  
    end
    name = name .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	
	Arial = core.host:execute("createFont", "Arial", Size, true, false);
	core.host:execute ("setTimer", 1, 0)
	  
	
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


if period < source:size() -1 then
return;
end
	
	    
end

function Calculation (  i )

	 
	    local server= core.host:execute("getServerTime");
		local date = core.host:execute("convertTime", 5, Label[i], server) + TimeShift[i]*Hour; 
		local tab = core.dateToTable(date);
		local str;

		if  Show then
		 str = string.format("%02i:%02i:%02i", tab.hour, tab.min, tab.sec);
		 else
		  str = string.format("%02i:%02i", tab.hour, tab.min );
		 end

	  
		
       	 id = id+1;		
		 core.host:execute("drawLabel1", id, -i*75, core.CR_RIGHT,25+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,  Arial,  LabelColor , Labels[Label[i]]);	
		
	     
		 
		id = id+1;					
		 core.host:execute("drawLabel1", id, -i*75, core.CR_RIGHT,25+Shift+Size*2, core.CR_TOP, core.H_Right, core.V_Bottom,  Arial, LabelColor,   str );	
     
			
end


function AsyncOperationFinished(cookie, success, message)


  		
	 local i;


		id=0;
		
		for i = 1 ,Number , 1  do	
       
	 
		   Calculation( i );
		
		
		end	


	 if cookie == 1 then
	 return core.ASYNC_REDRAW ;
	 end	 
	
	return 0;
     
 end
 
 function ReleaseInstance()
    core.host:execute("killTimer", 1);
end
