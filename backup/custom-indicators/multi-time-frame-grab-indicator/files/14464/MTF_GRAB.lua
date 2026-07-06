-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6256

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
    indicator:name("Multi Time Frame GRAB");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

   
	Parameters (1 , "H1" );
	Parameters (2 , "H4" );
	Parameters (3 , "H8" );
    Parameters (4 , "D1" );
	Parameters (5 , "W1" );
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("Size", "ArrowSize", "", 10);
	
	 indicator.parameters:addInteger("Position", "Vertical Position", "", 0 );
	 
	
	
		indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
    indicator.parameters:addColor("Short_Up", "Color of Short Up", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Short_Down", "Color of Short Down", "", core.rgb(200, 0, 0));
    indicator.parameters:addColor("Long_Up", "Color of Long Up", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Long_Down", "Color of Long Down", "", core.rgb(0, 200, 0));
    indicator.parameters:addColor("Range_Up", "Color of Range Up", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Range_Down", "Color of Range Down", "", core.rgb(100, 100, 100));
	
end


function Parameters (id , FRAME )

	
	 indicator.parameters:addGroup(id ..". Time Frame"); 
    indicator.parameters:addInteger("Period"..id, "Period", "Period", 34);   
	
	indicator.parameters:addString("Method"..id, "Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");
	
  
    indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
end

local Label;
local Short_Up, Short_Down;
local Long_Up, Long_Down;
local Range_Up, Range_Down;
local Number=5; 
local  Size;
local source;
local Indicator={};
local day_offset, week_offset;
local SourceData={};
local host;
--local alive;
local first={};
local loading={}; 
local font1, font2,font3; 
local Position;
local TF={};
local id;
function ReleaseInstance()
       core.host:execute("deleteFont", font1);
       core.host:execute("deleteFont", font2);
	  core.host:execute ("killTimer", 1);
   end

function Prepare(nameOnly)
   
    Label=instance.parameters.Label;	
    Position=instance.parameters.Position;  
   Size=instance.parameters.Size;  
	
	Short_Up=instance.parameters.Short_Up;
	Short_Down=instance.parameters.Short_Down;
   Long_Up=instance.parameters.Long_Up;
   Long_Down=instance.parameters.Long_Down;
   Range_Up=instance.parameters.Range_Up;
   Range_Down=instance.parameters.Range_Down;
   
    source = instance.source;
	
    local name =  profile:id() .. ","  .. instance.source:name() ;	
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
  
	 local TMP; 
	local i; 
	 assert(core.indicators:findIndicator("GRAB") ~= nil, "Please, download and install GRAB.LUA indicator");
	local ID=0;
	for i= 1, 5, 1 do
	ID=ID+1;
	 
	
	TF[i]=instance.parameters:getString ("TF"..i);
	TMP = core.indicators:create("GRAB", source, instance.parameters:getInteger ("Period".. i), instance.parameters:getString ("Method".. i));
	
	first= TMP.DATA:first()*2;
	SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(),  math.min(first,300), 20000 +ID , 10000 + ID);
	Indicator[i] = core.indicators:create("GRAB", SourceData[i], instance.parameters:getInteger ("Period".. i), instance.parameters:getString ("Method".. i),true);
	loading[i] = true;
	end
	
	
	   font1 = core.host:execute("createFont", "Arial", Size, true, false);
       font2 = core.host:execute("createFont", "Wingdings", Size, false, false);
	 
	
	       core.host:execute ("setTimer", 1, 1);
	
end


function Update(period, mode)

 
 
 if period < source:size()-1 then
 return;
 end
 
 local Flag= false;
   
	 for j = 1, Number, 1 do
		
			  
		if loading[j] then  
		Flag=true;
		end	 
		
	end
	
	if Flag then
	 return; 
	end
  
	local i;
	id=0;
	for i = 1, 5, 1  do 
	Draw(i, period );
	end
	  
	
end

function AsyncOperationFinished(cookie)
    local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	local ID=0;
    for j = 1, Number, 1 do
		      ID=ID+1;
			  if cookie == (10000+ID) then
			  loading[j] = true;
		      elseif  cookie == (20000+ID) then
			  loading[j] = false; 	 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 
		
		if not Flag and cookie==1 then
	     	for i = 1, Number, 1 do
			Indicator[i]:update(core.UpdateLast);
			end
		end

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded");		 
		instance:updateFrom(0);	
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end

function Draw(i, period )


			
		  
					
						
						
						if not Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1)   then	
                         return; 
                        end	

                     
					
						
					
							
							 id=id+1;
							      core.host:execute("drawLabel1", id, -i*Size*2, core.CR_RIGHT,Position+Size*2, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font1, Label, TF[i]);
							 
						   local Color=Label;
						   
						                                     
							                                     	if SourceData[i].open[SourceData[i].open:size()-1]   <= SourceData[i].close[SourceData[i].close:size()-1]  and SourceData[i].close[SourceData[i].close:size()-1]  > Indicator[i].High[Indicator[i].High:size()-1]  then
	                                                                        Color = Long_Up;
																	elseif 	SourceData[i].open[SourceData[i].open:size()-1]   >= SourceData[i].close[SourceData[i].close:size()-1]  and SourceData[i].close[SourceData[i].close:size()-1]  > Indicator[i].High[Indicator[i].High:size()-1]  then
																	   
																	
																	 Color = Long_Down;
																		
																	end	
																	
																	
																	if  SourceData[i].open[SourceData[i].open:size()-1]  <= SourceData[i].close[SourceData[i].close:size()-1]  and SourceData[i].close[SourceData[i].close:size()-1]  <  Indicator[i].Low[Indicator[i].Low:size()-1] then
																	
																	   Color = Short_Up;
																	elseif SourceData[i].open[SourceData[i].open:size()-1]   >= SourceData[i].close[SourceData[i].close:size()-1]  and SourceData[i].close[SourceData[i].close:size()-1]  <  Indicator[i].Low[Indicator[i].Low:size()-1] then
																	
																	Color = Short_Down;
																	end	
																	
																	
																	if  SourceData[i].open[SourceData[i].open:size()-1]   <=   SourceData[i].close[SourceData[i].close:size()-1] and SourceData[i].close[SourceData[i].close:size()-1]  < Indicator[i].High[Indicator[i].High:size()-1]  and SourceData[i].close[SourceData[i].close:size()-1]  > Indicator[i].Low[Indicator[i].Low:size()-1] then
																	
																	  Color = Range_Up;
																	elseif SourceData[i].open[SourceData[i].open:size()-1]   >= SourceData[i].close[SourceData[i].close:size()-1] and SourceData[i].close[SourceData[i].close:size()-1]  < Indicator[i].High[Indicator[i].High:size()-1]  and SourceData[i].close[SourceData[i].close:size()-1] > Indicator[i].Low[Indicator[i].Low:size()-1] then
																	
																	Color = Range_Down;
																		
																	end	
												 id=id+1;
												core.host:execute("drawLabel1",  id, -i*Size*2, core.CR_RIGHT, Position+ Size*4, core.CR_TOP, core.H_Right, core.V_Bottom,
														font2, Color, "\108");	
									      
										
							
					
	 
			
end
  