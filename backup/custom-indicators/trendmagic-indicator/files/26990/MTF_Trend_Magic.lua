-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=563&start=10

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
    indicator:name("MTF Trend_Magic");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	
	Parameters (1 , "H1" );
	Parameters (2 , "H4" );
	Parameters (3 , "H8" );
    Parameters (4 , "D1" );
	Parameters (5 , "W1" );
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 20);
	indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "No Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	
	
end


function Parameters (id , FRAME )


  	indicator.parameters:addGroup(id..".  Time Frame");

	
    indicator.parameters:addInteger("CCI"..id, "CCI", "", 50);
    indicator.parameters:addInteger("ATR"..id, "ATR", "", 5);
	
	
  
    indicator.parameters:addString("B"..id, " Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
end


local CCI={};
local ATR={};
 
local B={};

local  ArrowSize;
local source;
local Indicator={};
local day_offset, week_offset;
 
local host;
--local alive;
local first;
local Up, Down, Neutral, Label;

 local font;
 local font2;

 local Number=5;
 local loading={};
 local Source={};
 local TMI={};
function Prepare(nameOnly) 

    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Label=instance.parameters.Label;

   
      
    ArrowSize=instance.parameters.ArrowSize; 
	
    local name =  profile:id() .. ","  .. instance.source:name() ;
	
    source = instance.source;
	first= source:first();
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");	

	
    

	for i= 1, 5, 1 do
	name = name..", (" ..instance.parameters:getInteger ("CCI"..i)..", "..  instance.parameters:getInteger ("ATR"..i) ..  ")";      
	end
	name = name .. ")";
	instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
	 	local i;
    for i= 1, 5, 1 do	
	
	 CCI[i]= instance.parameters:getInteger ("CCI"..i);
	 ATR[i]= instance.parameters:getInteger ("ATR"..i);
     B[i]= instance.parameters:getString ("B"..i);
	end
	
 
    assert(core.indicators:findIndicator("TMI") ~= nil, "Please, download and install TMI.LUA indicator");    
	
	
	  font = core.host:execute("createFont", "Arial", ArrowSize, true, false);
       font2 = core.host:execute("createFont", "Wingdings", ArrowSize, false, false);
	
	
	   local x=0;
   for i = 1, Number, 1 do
	x=x+1;
		 
	
	Source[i] = core.host:execute("getSyncHistory",source:instrument(), B[i], source:isBid(), math.min(300,math.max(CCI[i], ATR[i])), 200+x, 100+x);	 
	loading[i]= true;
	
		TMI[i] = core.indicators:create("TMI", Source[i] ,CCI[i],  ATR[i],  core.rgb(0, 255, 0),  core.rgb(255, 0, 0));
	end
end


function Update(period, mode)

 
 
 
   if  period <  source:size() - 1 then	
                            return;
	end
 
	 
 	 
	local Flag = false;	
	 
		
    for j = 1, Number, 1 do 
		if loading[j] then 
		Flag=true;
		end	  
	end    
	
	    if Flag then
		return;
		end
	 
	
	
	
	
			for i = 1, 5, 1  do
		  
						TMI[i]:update(mode);
						
						
						if  TMI[i].DATA:hasData( TMI[i].DATA:size()-1)  and  TMI[i].DATA:hasData( TMI[i].DATA:size()-2)then	
                        

                     							
							 
							      core.host:execute("drawLabel1", i+200, -(i+1)*ArrowSize*3, core.CR_RIGHT, ArrowSize*2, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font, Label, instance.parameters:getString ("B"..i));
							 
						
											   if TMI[i].DATA:colorI(TMI[i].DATA:size()-1) ==  core.rgb(0, 255, 0)   then
												
												core.host:execute("drawLabel1", i,  -(i+1)*ArrowSize*3, core.CR_RIGHT, ArrowSize*3, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Up, "\225");
												
													core.host:execute("drawLabel1", i+100,  -(i+1)*ArrowSize*3, core.CR_RIGHT, ArrowSize*4, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font, Label,  string.format("%." .. 4 .. "f", TMI[i].DATA[TMI[i].DATA:size()-1] ));
												
												elseif TMI[i].DATA:colorI(TMI[i].DATA:size()-1) ==  core.rgb(255, 0, 0) then
												
                                                core.host:execute("drawLabel1", i,  -(i+1)*ArrowSize*3,core.CR_RIGHT, ArrowSize*3, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Down, "\226");
												
													core.host:execute("drawLabel1", i+100,  -(i+1)*ArrowSize*3, core.CR_RIGHT, ArrowSize*4, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font, Label,  string.format("%." .. 4 .. "f", TMI[i].DATA[TMI[i].DATA:size()-1] ));
												
												else
													
                                               core.host:execute("drawLabel1", i,  -(i+1)*ArrowSize*3 ,core.CR_RIGHT, ArrowSize*3, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Neutral, "\223");												
												
												end 		
												
											
												
						end					
					 
				
			end
	 
	  
	end


function ReleaseInstance()
       core.host:execute("deleteFont", font);
       core.host:execute("deleteFont", font2);
 end
 
 
 -- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = true;	
	local Count=0;	
	
	
	    local x=0;
		
    for j = 1, Number, 1 do
		x=x+1;
			  if cookie == (100+x) then
			  loading[j] = true;
		      elseif  cookie == (200+x) then
			  loading[j] = false;			  		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=false;
		end	 

		  
		
	end    
	
	    if Flag then
		core.host:execute ("setStatus", " ");
		instance:updateFrom(0);
		else
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		end
			     
        
		return core.ASYNC_REDRAW ;
end
