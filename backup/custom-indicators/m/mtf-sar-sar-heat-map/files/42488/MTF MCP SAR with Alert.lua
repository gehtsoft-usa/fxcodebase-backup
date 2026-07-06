
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15356

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
    indicator:name("MTF MCP  SAR with Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	
	Parameters (1 , "H1" , "EUR/USD"); 
	Parameters (2 , "H4", "EUR/USD" );
	Parameters (3 , "H8", "EUR/USD" );
    Parameters (4 , "D1" , "EUR/USD");
	Parameters (5 , "W1" , "EUR/USD");
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("Size", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 25, 0 , 10000);
	indicator.parameters:addColor("Up1", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down1", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral1", "No Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Label1", "Label Color", "", core.rgb(0, 0, 0));
	
	Style (1 );
	Style (2 );
	Style (3 );
	Style (4 );
	Style (5 );
	
	
	indicator.parameters:addGroup("Alert Style");  
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	Parameters1 (1,  1 .. ". Time Frame");
	Parameters1 (2,  2 .. ". Time Frame");
	Parameters1 (3,  3 .. ". Time Frame");
	Parameters1 (4,  4 .. ". Time Frame");
	Parameters1 (5,  5 .. ". Time Frame");
	
	
end


function Parameters1 ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);


    indicator.parameters:addFile("Upx"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Upx"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Downx"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Downx"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Labelx"..id, "Label", "", Label);

end 

function Style (id)
    
  	indicator.parameters:addGroup(id.. ".  Time Frame Style Options"); 
    indicator.parameters:addBoolean("Show"..id, "Show Line", "", true);
    indicator.parameters:addInteger("widht"..id, "Line widht", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);
--	indicator.parameters:addColor("color"..id, "Color", "", core.rgb(0, 255, 0));
end


function Parameters (id, frame , Def )

    indicator.parameters:addGroup(id..".  Time Frame"); 
	indicator.parameters:addString("TF" .. id, id.. ". Time frame", "", frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Pair" .. id, id.. ". Pair", "", Def);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	--()()()()()()Customized segment ()()()()()()()

  	
    indicator.parameters:addDouble("Step"..id, "Step", "", 0.02, 0.001, 1);
    indicator.parameters:addDouble("Max"..id, "Max", "", 0.2, 0.001, 10);
	

  
end

local Upx={};
local Downx={};
local Label={};
local ON={};

local Line;
--local up={};
--local down={};
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Alert; 
local PlaySound;
local 	Number = 5;
local U={};
local D={};

--**********************


local TF={};
local widht={};
local style={};
local source; 
local day_offset, week_offset;
local host;
local first;
local Up1, Down1, Neutral1, Label1;
local Shift;
 local font1;
 local font2;
local Show={};	
local Pair={}; 
local SourceData={};
local loading={};
local Size;
local Test;

	--()()()()()()Customized segment ()()()()()()()
    	local Indicator={};
        local Period={};
		local Mode={};
		local Step={};
		local Max={};
		--local color={};
	--()()()()()()()()()()()()()()()()()()()()()()()()
	

	
function Prepare(nameOnly)  

  	
    source = instance.source;	
	
    host = core.host;
	day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    
    Up1=instance.parameters.Up1;
	Down1=instance.parameters.Down1;
	Neutral1=instance.parameters.Neutral1;
	Label1=instance.parameters.Label1;
    Shift=instance.parameters.Shift;
	 Size=instance.parameters.Size; 
	
   	local i;
	
    for i= 1, Number, 1 do	
	 -- color[i]= instance.parameters:getColor ("color"..i);
	 Show[i]= instance.parameters:getBoolean ("Show"..i);
	 style[i]= instance.parameters:getDouble ("style"..i);
	 widht[i]= instance.parameters:getDouble ("widht"..i);	
     TF[i]= instance.parameters:getString ("TF"..i);
	 Pair[i]= instance.parameters:getString("Pair" .. i);	
	 
	 --()()()()()()Customized segment ()()()()()()()
	 Step[i]= instance.parameters:getDouble ("Step"..i);
	 Max[i]= instance.parameters:getDouble ("Max"..i);
	 
	  --()()()()()()()()()()()()()()()()()()()()()()()()
	end
      
   
	
    local name = "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")" ;


	for i= 1, Number, 1 do
	name = name..", (" .. TF[i]..", " ..Pair[i]..", " ..Step[i]..", ".. Max[i] ..  ")";   
	end
	name = name .. ")";
	instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	Test = core.indicators:create("SAR", source ,Step[1],  Max[1]);   
	first=math.min(Test.UP:first()-1, Test.DN:first()-1);

	  font1 = core.host:execute("createFont", "Arial", Size, true, false);
       font2 = core.host:execute("createFont", "Wingdings", Size, false, false);
	   
	  
	   
	 for i = 1, Number, 1 do	
	
	  
	    SourceData[i] = core.host:execute("getSyncHistory", Pair[i], TF[i], source:isBid(), math.min(first*2,300), 200+i, 100+i);
		  loading[i] = true;   
	   
	   
	   	--()()()()()()Customized segment ()()()()()()()
		 
		 
		Indicator[i] = core.indicators:create("SAR", SourceData[i] ,Step[i],  Max[i]);   		
		
		  --()()()()()()()()()()()()()()()()()()()()()()()()
	end
	
	Initialization();
end


function  Initialization ()
     Size=instance.parameters.Size;
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Labelx" .. i);
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
	  Upx[i]=instance.parameters:getString("Upx" .. i);
	  Downx[i]=instance.parameters:getString("Downx" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Upx[i]=nil;
	  Downx[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Upx[i] ~= "") or (PlaySound and Upx[i] ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and Downx[i] ~= "") or (PlaySound and Downx[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	
	end
		
	

	
end	


function Update(period)


    core.host:execute ("setStatus", "")
 
    if  period <  source:size() - 1 then	
       return;
	end
	
	
	if loading[1] or loading[2] or loading[3] or loading[4] or loading[5] then	
	core.host:execute ("setStatus", "Loading")
	--return;	
	end
	
	
			
	   local i, color;
		
		
		local date = source:date(period);
		
		for i = 1 ,Number , 1  do			
			
		Calculation( i );	
		
		
		 
		     if Show[i]  then
			 
			     
				 local  fromLevel;
				 
				 if Indicator[i].DN:hasData(Indicator[i].DN:size()-1)   then
				 fromLevel=  Indicator[i].DN[Indicator[i].DN:size()-1];
				 color = Up1;
				 elseif Indicator[i].UP:hasData(Indicator[i].UP:size()-1)   then
				 fromLevel=  Indicator[i].UP[Indicator[i].UP:size()-1];
				  color = Down1;
				 end
				 
				                           if fromLevel~= nil  then
				                                local fromDate, toDate;
											   fromDate, toDate = core.getcandle( TF[i], date, day_offset, week_offset);
											   core.host:execute ("drawLine", 200 + i, fromDate, fromLevel, toDate, fromLevel, color, style[i], widht[i]);
											   
											   core.host:execute("drawLabel1", i+300,  toDate, core.CR_CHART, fromLevel, core.CR_CHART, core.H_Right, core.V_Bottom,
                                                font1, Label1,  string.format("%." .. 5 .. "f", fromLevel ) .. " ("  .. TF[i] ..  ")");
											end	
			 end
												
		 
		 
		end	
 
    Activate (1, period);
	Activate (2, period);
	Activate (3, period);
	Activate (4, period);
	Activate (5, period);
	
end


function ReleaseInstance()
       core.host:execute("deleteFont", font1);
       core.host:execute("deleteFont", font2);
 end
   
function Calculation ( i)

        
     
	
		
			
			--  if Mode[i] == 1 then
				 
			
				--*************************************************************************
				
				local color;
						Indicator[i]:update(core.UpdateLast);
						
						
						if  Indicator[i].UP:hasData( Indicator[i].UP:size()-1)  or   Indicator[i].DN:hasData(Indicator[i].DN:size()-1)then	
                        
                            
                     							
							 
							      core.host:execute("drawLabel1", i+200, -i*70, core.CR_RIGHT,Size*1+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label1,TF[i]);
							 
						
											   if Indicator[i].DN:hasData(Indicator[i].DN:size()-1)   then
												
												core.host:execute("drawLabel1", i, -i*70, core.CR_RIGHT, Size*2+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Up1, "\225");
												
													core.host:execute("drawLabel1", i+100, -i*70, core.CR_RIGHT, Size*3+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, Label1,  string.format("%." .. 5 .. "f", Indicator[i].DN[Indicator[i].DN:size()-1] ));
											
												color=Up1;
												
												elseif Indicator[i].UP:hasData(Indicator[i].UP:size()-1)  then
												
                                                core.host:execute("drawLabel1", i, -i*70,core.CR_RIGHT, Size*2+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Down1, "\226");
												
													core.host:execute("drawLabel1", i+100, -i*70, core.CR_RIGHT, Size*3+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font1, Label1,  string.format("%." .. 5 .. "f", Indicator[i].UP[Indicator[i].UP:size()-1] ));
												
												color=Down1;
												else
													
                                               core.host:execute("drawLabel1", i, -i*70 ,core.CR_RIGHT, Size*2+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Neutral1, "\223");												
												
												end 		
												
												
											 
									
					 
				
			end
				
	 
   
end

function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	       
			if 	Indicator[id].DN:hasData(Indicator[id].DN:size()-1)
			and not Indicator[id].DN:hasData(Indicator[id].DN:size()-2)
			then
			           
						  
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Upx[id]);
							  EmailAlert(  Label[id] .." UpTrend");
							  end
			elseif Indicator[id].UP:hasData(Indicator[id].UP:size()-1)		
			and not  Indicator[id].UP:hasData(Indicator[id].UP:size()-2)	
            then			
			
			          				   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Downx[id]);			 
							 EmailAlert( Label[id] .. " DownTrend");								   
			                     end			   
	         end
		
		--**********************************************************
		
		elseif id == 2  and ON[id]  then
	  
	       
			if Indicator[id].DN:hasData(Indicator[id].DN:size()-1)
			and not Indicator[id].DN:hasData(Indicator[id].DN:size()-2)
			then
			           
						  
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Upx[id]);
							  EmailAlert(  Label[id] .." UpTrend");
							  end
			elseif Indicator[id].UP:hasData(Indicator[id].UP:size()-1)		
			and not  Indicator[id].UP:hasData(Indicator[id].UP:size()-2)		
            then			
			
			          				   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Downx[id]);			 
							 EmailAlert( Label[id] .. " DownTrend");								   
			                     end			   
	         end
				 
		--**********************************************************
		
		elseif id == 3  and ON[id]  then
	  
	       
			if 	Indicator[id].DN:hasData(Indicator[id].DN:size()-1)
			and not Indicator[id].DN:hasData(Indicator[id].DN:size()-2)
			then
			           
						  
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Upx[id]);
							  EmailAlert(  Label[id] .." UpTrend");
							  end
			elseif Indicator[id].UP:hasData(Indicator[id].UP:size()-1)		
			and not  Indicator[id].UP:hasData(Indicator[id].UP:size()-2)			
            then			
			
			          				   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Downx[id]);			 
							 EmailAlert( Label[id] .. " DownTrend");								   
			                     end			   
	         end

--**********************************************************
		
		elseif id == 4  and ON[id]  then
	  
	       
			if 	Indicator[id].DN:hasData(Indicator[id].DN:size()-1)
			and not Indicator[id].DN:hasData(Indicator[id].DN:size()-2)
			then
			           
						  
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Upx[id]);
							  EmailAlert(  Label[id] .." UpTrend");
							  end
			elseif Indicator[id].UP:hasData(Indicator[id].UP:size()-1)		
			and not  Indicator[id].UP:hasData(Indicator[id].UP:size()-2)		
            then			
			
			          				   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Downx[id]);			 
							 EmailAlert( Label[id] .. " DownTrend");								   
			                     end			   
	         end

--**********************************************************
		
		elseif id == 5  and ON[id]  then
	  
	       
			if Indicator[id].DN:hasData(Indicator[id].DN:size()-1)
			and not Indicator[id].DN:hasData(Indicator[id].DN:size()-2)
			then
			           
						  
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Upx[id]);
							  EmailAlert(  Label[id] .." UpTrend");
							  end
			elseif Indicator[id].UP:hasData(Indicator[id].UP:size()-1)		
			and not  Indicator[id].UP:hasData(Indicator[id].UP:size()-2)	
            then			
			
			          				   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Downx[id]);			 
							 EmailAlert( Label[id] .. " DownTrend");								   
			                     end			   
	         end			 
			
	
        end

end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     if cookie == 101 then
        loading[1] = true;
    elseif cookie == 102 then
        loading[2] = true;
    elseif cookie == 103 then
        loading[3] = true;
    elseif cookie == 104 then
        loading[4] = true;
    elseif cookie == 105 then
        loading[5] = true;
    elseif cookie == 201 then
        loading[1] = false;
        instance:updateFrom(0);
    elseif cookie == 202 then
        loading[2] = false;
        instance:updateFrom(0);
    elseif cookie == 203 then
        loading[3] = false;
        instance:updateFrom(0);
    elseif cookie == 204 then
        loading[4] = false;
        instance:updateFrom(0);
    elseif cookie == 205 then
        loading[5] = false;
        instance:updateFrom(0);
    else
        return 0;
    end
    return core.ASYNC_REDRAW;
end



function SoundAlert(Sound)

  if not PlaySound then
 return;
 end
 
 terminal:alertSound(Sound, RecurrentSound);
end



function EmailAlert( Subject)

if not SendEmail then
return
end
 
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 

  local text= profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL ;
 terminal:alertEmail(Email, Subject, text);
end
	 


