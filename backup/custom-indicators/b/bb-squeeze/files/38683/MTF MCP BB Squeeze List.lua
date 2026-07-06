-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22407

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
    indicator:name("MTF MCP BB Squeeze List");
    indicator:description("MTF MCP BB Squeeze List");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m1"  );
	Parameters (2 , "m15"    );
	Parameters (3 , "m30"   );
	Parameters (4 , "H1"    );
	Parameters (5 , "H2"    );
	Parameters (6 , "H3"   );
	Parameters (7 , "H4"   );
	Parameters (8 , "H8"  );
	Parameters (9 , "D1"     );
	Parameters (10 , "W1"    );	
	Parameters (11 , "M1"    );
	
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 15);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(0, 0, 255));
	
    indicator.parameters:addColor("Yes", "BBS Squeeze Color", " ", core.rgb(0, 0, 255));
	indicator.parameters:addColor("No", "No BBS Squeeze Color", " ", core.rgb(128, 128, 128));
end


function Parameters (id , FRAME, Method )
    indicator.parameters:addGroup(id ..". Time Frame");
	indicator.parameters:addBoolean("On"..id , "Show  This Time Frame", "", true);	

	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
	
	 indicator.parameters:addInteger("BP"..id, "Bollinger Period", " ", 20);
	indicator.parameters:addDouble("BD"..id, "Bollinger Deviations", " ", 2);
	
	indicator.parameters:addInteger("KP"..id, "Keltner Period", " ", 20);
	indicator.parameters:addDouble("KF"..id, "Keltner Factor", " ", 1.5);
	
	indicator.parameters:addDouble("MP"..id, "Momentum Period", " ", 12);
	 indicator.parameters:addString("MS"..id, "Momentum smoothing method", "", "MVA");
	  indicator.parameters:addStringAlternative("MS"..id, "No smoothing", "", "NO");
    indicator.parameters:addStringAlternative("MS"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MS"..id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MS"..id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MS"..id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MS"..id, "Wilders", "", "WMA");
	indicator.parameters:addDouble("MSP"..id, "Momentum Smoothing Period", " ", 20);
	 
	
end
local BP={};
local BD={};
local KP={};
local KF={};
local MP={};
local MS={};
local MSP={};
local loading={};
local SourceData={};
local Indicator={};
local Pair;
local font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first={};
local Test={};
local Count;
local Up, Down, Neutral, LabelColor;
local Xes,No;
local N={};
local Shift;
local On={};
local Num;
local  iprofile= {};	
local  iparams= {};
local SC={};
local  tprofile= {};	
local  tparams= {};
 
function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings1);
	   core.host:execute("deleteFont", Wingdings2);
	     core.host:execute("deleteFont", Bold);
 end  

function Prepare(nameOnly)     
	Shift=instance.parameters.Shift; 
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
		instance:name(name);

	if   (nameOnly) then
        return;
    end

	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
	Yes = instance.parameters.Yes;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;
	
	assert(core.indicators:findIndicator("BBSQUEEZE") ~= nil, "Please, download and install BBSQUEEZE.LUA indicator");	
	 
	 Pair, Count = getInstrumentList();
	  

	Num=0;
	
	for i = 1 , 11 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1; 
	   TF[Num]=  instance.parameters:getString ("TF"..i);
	     BP[Num]=  instance.parameters:getString ("BP"..i);
		 BD[Num]=  instance.parameters:getString ("BD"..i);
		 KP[Num]=  instance.parameters:getString ("KP"..i);
		 KF[Num]=  instance.parameters:getString ("KF"..i);
		 MP[Num]=  instance.parameters:getString ("MP"..i);
		 MS[Num]=  instance.parameters:getString ("MS"..i);
		 MSP[Num]=  instance.parameters:getString ("MSP"..i);
	 

        Temp = core.indicators:create("BBSQUEEZE", source, BP[Num],BD[Num],KP[Num],KF[Num],MP[Num],  MS[Num],MSP[Num], true);
	    first[Num]= math.max(Temp:getStream(0):first(),Temp:getStream(1):first()) +1;	
			    
	
	  end
	end	
	
	
		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings1  = core.host:execute("createFont", "Wingdings", Size  , false, false);
	Wingdings2  = core.host:execute("createFont", "Wingdings", Size  , false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	
	 
	

	
	Id=0;
		
	
	for j = 1, Count, 1 do
	
	         SourceData[j] = {};
			 
             loading[j] = {};  	 
			 Indicator[j] = {};
			 
			
	   
	   
		 for i = 1, Num, 1 do	 
		 Id=Id+1;
		 					  
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(300,first[i]) , 20000 + Id , 10000 +Id);
			   loading[j][i] = true;  
			  
			   Indicator[j][i] = core.indicators:create("BBSQUEEZE", SourceData[j][i], BP[i],BD[i],KP[i],KF[i],MP[i],  MS[i],MSP[i], true,  Up,  Down);
             			  
			  
		end
	end
    
	
 
	 
end




function Update(period, mode)

 

 if period < source:size()-1 then
 return
 end
 
   
 
  
    local FLAG=false;
	
	local i,j;
	local id =1;
	 
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				  
				 end
		 
         end  	
    end
	
	if FLAG then
   return;
	end
	
  
  for i = 1, Num , 1 do
  
  core.host:execute("drawLabel1", id, Size*5+(i)*Size*3 ,  core.CR_LEFT, Size  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, Size*5 ,  core.CR_LEFT, (j+1)*Size+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	for i = 1, Num, 1  do
--close
				
				Indicator[j][i]:update(core.UpdateLast);
				
				
				if  Indicator[j][i]:getStream(1):hasData(Indicator[j][i]:getStream(1):size()-1) 				
                and Indicator[j][i]:getStream(1):hasData(Indicator[j][i]:getStream(1):size()-1) then	
						local Color1 =nil;			
						local Style1 = nil 
				 
						local Color2 =nil;			
						local Style2 = nil;
						
						 if Indicator[j][i]:getStream(0)[Indicator[j][i]:getStream(1):size()-1] ==  100 then
						  Style2 = "\176";
						 Color2= Yes;
						 else
						 Color2= No;
						 end
					 		

						 if Indicator[j][i]:getStream(1):colorI(Indicator[j][i]:getStream(1):size()-1) ==  Up then
										
											
											Color1 = Up;
											Style1= "\221";
						elseif Indicator[j][i]:getStream(1):colorI(Indicator[j][i]:getStream(1):size()-1) == Down then
											
											  Color1 = Down;									
												Style1= "\222";	
												
						 else				
                                              Style1= "\108";							 
											 Color1 = Neutral;
						 end 			
						 
						 

                        if Style2 ~= nil then
						core.host:execute("drawLabel1", id, Size*5+(i)*Size*3+Size,  core.CR_LEFT, (j+1)*Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, Wingdings2, Color2,   Style2 );			  
						id = id+1;
						end
  
						
						
						if Style1 ~= nil then
						core.host:execute("drawLabel1", id, Size*5+(i)*Size*3,  core.CR_LEFT, (j+1)*Size +Shift , core.CR_TOP, core.H_Left, core.V_Center, Wingdings1, Color1,   Style1 );			  
						id = id+1;
						end

				end
				
				end
        end
    
end




function getInstrumentList()
    local list={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end


function AsyncOperationFinished(cookie)

	
	local i,j;
    local Id=0;
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		      Id=Id+1;
			  if cookie == (10000 + Id) then
			  loading[j][i] = true;
		      elseif  cookie == (20000 + Id) then
			  loading[j][i] = false;   
			  end
		       
          end
	end    
	
	
	
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	 
	 else
	  core.host:execute ("setStatus", "  Loaded "..((Count*Num) - Number) .. " / " .. (Count*Num) );	
	          
			  instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end








