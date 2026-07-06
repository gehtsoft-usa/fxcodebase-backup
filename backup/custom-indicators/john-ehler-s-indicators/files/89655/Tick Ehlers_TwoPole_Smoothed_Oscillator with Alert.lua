-- Id: 10447

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1262

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
    indicator:name("Ehlers TwoPole smoothes oscillator");
    indicator:description("Ehlers TwoPole smoothes oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
	
	
	
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("CuttOff", "CuttOff", "", 15);
    indicator.parameters:addDouble("alpha", "alpha", "", 0.15);
    indicator.parameters:addInteger("shift", "shift", "", 0);

    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("UpColor", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DownColor", "Color of Down", "Color of Down", core.rgb(255,0, 0));
    indicator.parameters:addInteger("widthLinReg1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg1", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg1", core.FLAG_LINE_STYLE);
	
	
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
	
	Parameters (1, "Zero Line");
	Parameters (2, "Slope Change");
end


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 2;


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
local Price2, Price1;

local U={};
local D={};


local first;
local source = nil;
local CuttOff;
local alpha;
local Buff1=nil;
local Buff2=nil;
local BuffLine=nil;
local Ind;

function Prepare(nameOnly)   

    
    FIRST=true;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
    source = instance.source;
    CuttOff=instance.parameters.CuttOff;
    alpha=instance.parameters.alpha;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.CuttOff .. ", " .. instance.parameters.alpha  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("TICK EHLERS_TWOPOLE_SMOOTHED_FILTER") ~= nil, "Please, download and install TICK EHLERS_TWOPOLE_SMOOTHED_FILTER.LUA indicator");    
	
    Ind = core.indicators:create("TICK EHLERS_TWOPOLE_SMOOTHED_FILTER", source, CuttOff);
    first = Ind.DATA:first()+3;
   
     
    BuffLine = instance:addStream("BuffLine", core.Line, name .. ".BuffLine", "BuffLine", instance.parameters.Up, first);
    BuffLine:addLevel(0);
	BuffLine:setWidth(instance.parameters.widthLinReg1);
    BuffLine:setStyle(instance.parameters.styleLinReg1);
	
	BuffLine:setPrecision(math.max(2, instance.source:getPrecision()));
	
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

function Update(period, mode)

	
	Claculation (period, mode);   
   
   
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
end

function Claculation (period, mode)
    if (period>first) then
     Ind:update(mode);
     local Val=Ind.DATA[period]-Ind.DATA[period-1];
     local Val1=Ind.DATA[period-1]-Ind.DATA[period-2];
     local Val2=Ind.DATA[period-2]-Ind.DATA[period-3];
     BuffLine[period]=(alpha-(alpha*alpha/4.))*Val+(alpha*alpha/2.)*Val1-(alpha-3.*alpha*alpha/4.)*Val2+2.*(1-alpha)*BuffLine[period-1]-(1-alpha)*(1-alpha)*BuffLine[period-2];
     
	 if BuffLine[period]<BuffLine[period-1] then
      BuffLine:setColor(period, instance.parameters.UpColor);
     else
      BuffLine:setColor(period, instance.parameters.DownColor);
     end
     
    end 
	
end



function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if BuffLine[period] > 0
			and BuffLine[period-1] <= 0
			then
			           
						     up[id]:set(period , 0, "\108");	
						   
			
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
			elseif  BuffLine[period] < 0
			and BuffLine[period-1] >= 0
            then			
			
			            			 
			               down[id]:set(period , 0, "\108");	  						   
						   
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
	  
	  
	  	  if id == 2  and ON[id]  then
	  
	       
			if BuffLine[period] > BuffLine[period-1]
			and BuffLine[period-1] <= BuffLine[period-2]
			then
			           
						     up[id]:set(period ,  BuffLine[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up Slope", period);
							    
							        if Show then
									Pop(Label[id], " Up Slope " );  	
								    end
								 
							  end
			elseif  BuffLine[period] < BuffLine[period-1]
			and BuffLine[period-1] >= BuffLine[period-2]
            then			
			
			            			 
			               down[id]:set(period ,  BuffLine[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Slope", period);	
								 if Show then
									Pop(Label[id], " Down Slope " );  	
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
   " ( " .. source:instrument() .. " : "   .. " ) "  ..   label .. " : " .. note );


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
 
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
   
     local text= profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL  ;
   terminal:alertEmail(Email,  Subject, text);
end
	 



