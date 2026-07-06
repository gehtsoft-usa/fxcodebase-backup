--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Advanced fractal with Alert");
    indicator:description("Advanced fractal with Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 
  
    indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
    indicator.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 3,99);
    indicator.parameters:addInteger("FontSize", "Size of font", "Size of font", 10);
	
	
	
	indicator.parameters:addGroup("Alert Style");
   -- indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
--	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	Parameters (1, "Fractal Alert")
 
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

local 	Number = 1;


local source;
local frame=0;
local Rez=0;
local UpText;
local DnText;
local first;
local UpBuff;
local DnBuff;

 
local Up={};
local Down={};
local Label={};
local ON={};
--local up={};
--local down={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST=true;
local Price2, Price1;

local U={};
local D={};

function Prepare()
   Show = instance.parameters.Show;
     FIRST=true;
    source = instance.source;
    first=source:first();
    UpBuff=instance:addInternalStream(first, 0);
    DnBuff=instance:addInternalStream(first, 0);
    
    UpText=instance:createTextOutput ("UpText", "UpText", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.UP, first);
    DnText=instance:createTextOutput ("DnText", "DnText", "Arial", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.DOWN, first);
	
	frame=instance.parameters.Frame
  	
  		 if math.mod(frame, 2) ~= 0 then
		 frame=frame+1;
		 end
 
  
  local name = profile:id() .. " ( " .. frame-1 .. " )";
    instance:name(name);
	
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
	
	--	if ON[i] then
		--up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
	--	down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
		--end
	end
		
	

	
end	

function Update(period, mode)
  
Calculation (period, mode);

end


function Calculation (period, mode)
  local test=0;
   
	     local hof=frame;
	     local i;
	     local count=0;
	 
		 for  i= 1 , frame , 1 do
		 
			 if hof >1 then
			 hof= hof-2;
			 count = count +1;
			 else
			 count=count-1;
			 break;
			 end
		 
		 end 
 
    if (period > frame) then
	
	     local x = period - count*2;
	
        local curr = source.high[period - count];
	
	UpBuff[period-count]=UpBuff[period-count-1];
	DnBuff[period-count]=DnBuff[period-count-1];
		
		
         for i= x, period, 1 do
		
		     if  curr > source.high[i] and i ~=(period - count) then
			 test=test+1;
			 end
			
		 end	
		 
		 if test == period-x then
		   UpBuff[period-count]=source.high[period - count];
		   if DnBuff[period-count]~=nil then
		    UpText:set(period - count, source.high[period - count], "" .. math.floor((UpBuff[period-count]-DnBuff[period-count])/source:pipSize()));
			 Activate (1, period, count, true );
		   end
		 end

        test=0;		 
       
	     curr = source.low[period - count];
		
		  
          for i= x , period, 1 do
		
		     if  curr < source.low[i] and i ~=(period -count) then
			 test=test+1;
			 end
			
		 end	
	   
	      if test ==period-x then
	      DnBuff[period-count]=source.low[period - count];
	      if UpBuff[period-count]~=nil then
	       DnText:set(period - count, source.low[period - count], "" .. math.floor((UpBuff[period-count]-DnBuff[period-count])/source:pipSize()));
		   Activate (1, period , count, false);
	      end
	  end
		  
    elseif period>first and period<=frame then
    	UpBuff[period]=nil;
    	DnBuff[period]=nil;
        
    end
end


function Activate (id, period,Shift , flag )
 
 if period < Shift then 
 return;
 end
 
	  if id == 1  and ON[id]  then
	  
	        if flag  then
		 
			           
						    -- up[id]:set(period-Shift , source.high[period-Shift], "\108");	
						   
			
		--	 D[id] = nil;
						   
							  if U[id]~=source:serial(period-Shift) 
							  and period == source:size()-1
							  and not FIRST 
							  then
							  U[id]=source:serial(period-Shift);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Down ", period-Shift);
							    
							        if Show then
									Pop(Label[id], " Down" );  	
								    end
								 
		
                 		end
		
			
		
			else 
			
				            			 
			             --  down[id]:set(period-Shift , source.low[period-Shift], "\108");	  						   
						   
		  --   U[id] = nil;
		  
			                 if  D[id]~=source:serial(period-Shift)
							 and period == source:size()-1
							 and not FIRST 
							 then
							 D[id]=source:serial(period-Shift);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Up", period-Shift);	
								 if Show then
									Pop(Label[id], " Up " );  	
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
   
     local text = Note  .. delim ..  Symbol .. delim .. TF .. delim   .. delim .. Time;
	
 
  terminal:alertEmail(Email, profile:id(), text);
end
	 


