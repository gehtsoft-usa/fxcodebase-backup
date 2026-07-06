
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20

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


-- initializes the indicator
function Init()
    -- indicator:fail()
    indicator:name("Donchian Channel")
    indicator:description("The simple trend-following indicator. Shows highest high and lowest low for the specified number of periods.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	    indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
   

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 2, 10000);    
	 indicator.parameters:addString("MD", "Show Close or High/Low", "", "Close");
    indicator.parameters:addStringAlternative("MD", "Close", "", "Close");
    indicator.parameters:addStringAlternative("MD", "High/Low", "", "HighLow");
	
	indicator.parameters:addGroup("Selector");
    indicator.parameters:addString("SHL", "Show High/Low lines", "Show High/Low lines", "Both"); 
    indicator.parameters:addStringAlternative("SHL", "Both lines", "", "Both"); 
    indicator.parameters:addStringAlternative("SHL", "High only", "", "High"); 
    indicator.parameters:addStringAlternative("SHL", "Low only", "", "Low"); 
	indicator.parameters:addBoolean("SM", "Show middle line", "", true);  
	indicator.parameters:addBoolean("SUB", "Show Sub Levels", "", true);
	indicator.parameters:addBoolean("AC", "Analyze the current period", "", true);  
	
	indicator.parameters:addGroup("Style");		
	indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("widthDU", "Up Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDU", "Up Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDU", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("widthDN", "Down Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDN", "Down Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDN", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(255, 255, 0));
	
	indicator.parameters:addInteger("widthDM", "Middle Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleDM", "Middle Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleDM", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("clrSUB", "Color of the Sub Level lines", "", core.rgb(255, 255, 0));
	
	indicator.parameters:addInteger("widthSUB", "Sub Level Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSUB", "Sub Level Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSUB", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	Parameters (1, "Upper Outer Line");
	Parameters (2, "Upper Inner Line");
	Parameters (3, "Central Line");
	Parameters (4, "Lower Inner Line");
	Parameters (5, "Lower Outer Line");

end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 5;
local Out={};
local first = 0;
local n = 0;
local ac;
local sm;
local source = nil;
local dn = nil;
local du = nil;
local dm = nil;
local MODE=nil;
local SUB;
local SHL;
local low, high;

--////////////////
local Up={};
local Down={};
local Label={};
local ON={};
 
local Line;
local up={};
local down={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local Indicator;
local PlaySound;
local Live;
local FIRST=true;
local U={};
local D={};



-- initializes the instance of the indicator
function Prepare(nameOnly) 

    FIRST=true;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
    SUB = instance.parameters.SUB;
    SHL = instance.parameters.SHL;
    source = instance.source;
    n = instance.parameters.N;
	MODE=instance.parameters.MD; 
    ac =instance.parameters.AC;
    sm = instance.parameters.SM;

    first = n + source:first() - 1;
    if (not ac) then
        first = first + 1;
    end
    local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
    if (SHL == "High" or SHL == "Both") then
        Out[1] = instance:addStream("DU", core.Line, name .. ".DU", "U", instance.parameters.clrDU,  first)
        Out[1]:setWidth(instance.parameters.widthDU);
        Out[1]:setStyle(instance.parameters.styleDU);
    else
        Out[1] = instance:addInternalStream(0, 0)
    end
    
    if SHL == "Low" or SHL == "Both"  then
        Out[5] = instance:addStream("DN", core.Line, name .. ".DN", "D", instance.parameters.clrDN,  first)
        Out[5]:setWidth(instance.parameters.widthDN);
        Out[5]:setStyle(instance.parameters.styleDN);
    else
        Out[5] = instance:addInternalStream(0, 0)
    end
    
    if (sm) then
        Out[3] = instance:addStream("DM", core.Line, name .. ".DM", "M", instance.parameters.clrDM,  first)
		Out[3]:setWidth(instance.parameters.widthDM);
        Out[3]:setStyle(instance.parameters.styleDM);
	else
	    Out[3] = instance:addInternalStream(0, 0)
    end
	
	if SUB then
	   Out[2] = instance:addStream("high", core.Line, name .. ".DMU", "S", instance.parameters.clrSUB,  first)
	    Out[2]:setWidth(instance.parameters.widthSUB);
        Out[2]:setStyle(instance.parameters.styleSUB);
	    Out[4] = instance:addStream("low", core.Line, name .. ".DMD", "S", instance.parameters.clrSUB,  first)
	    Out[4]:setWidth(instance.parameters.widthSUB);
        Out[4]:setStyle(instance.parameters.styleSUB);
	else
	     Out[2] = instance:addInternalStream(0, 0);
		 Out[4] = instance:addInternalStream(0, 0);
		  
	end
	
	Initialization();
end



function  Initialization ()
     Size=instance.parameters.Size;
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	 end
	 
	 
	 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  Up[i]=instance.parameters:getString("Up" .. i);
	  Down[i]=instance.parameters:getString("Down" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Up[i]=nil;
	  Down[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;
	
		if ON[i] then
		up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
		down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
		end
	end
		
	

	
end	

-- calculate the value
function Update(period)
 
 Calculation(period);
 
 
 
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
   
   if period < first then
return;
end
	
    Activate (1, period);
	Activate (2, period);
	Activate (3, period);
	Activate (4, period);
	Activate (5, period);
 
end


function Calculation(period)

    if (period < first) then
	return;
	end
        local range;
        if (ac) then
            range = core.rangeTo(period, n);
        else
            range = core.rangeTo(period - 1, n);
        end
		
		if  MODE=="Close" then
            Out[1][period] = core.max(source.close, range); 
            Out[5][period] = core.min(source.close, range); 
		else
            Out[1][period] = core.max(source.high, range); 
             Out[5][period] = core.min(source.low, range); 
		end
         
            Out[3][period] = (Out[1][period] +  Out[5][period]) / 2;
       
		
		 
            Out[2][period]=  (Out[1][period] + Out[3][period]) / 2;
            Out[4][period]=   ( Out[5][period] + Out[3][period]) / 2;
	 
   
	
	
end




function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if  ON[id]  then
	  
	       
			if source.close[period] >  Out[id][period]
			and source.close[period-1] <= Out[id][period-1]
			then
			           
						     up[id]:set(period , Out[id][period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  source.close[period] < Out[id][period]
			and source.close[period-1] >= Out[id][period-1]
            then			
			
			            			 
			               down[id]:set(period , Out[id][period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end


function Pop(label , note)

   core.host:execute ("prompt", 1, label ,
   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );


end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  terminal:alertSound(Sound, RecurrentSound);
end
 

function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

 
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();    
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
	 
 terminal:alertEmail(Email, profile:id(), text);
end
	 


