-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7459

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+



function Init()
    indicator:name("Multi Time Frame Heiken Ashi List");
    indicator:description("Multi Time Frame Heiken Ashi List");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	Parameters (1 , "m30"  );
	Parameters (2 , "H1"  );
	Parameters (3 , "H4" );
	Parameters (4 , "H8"   );
	Parameters (5 , "D1"  );
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , FRAME , DEFAULT )
    indicator.parameters:addGroup(id ..". Time Frame");
	
	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);	
end

local loading={};
local SourceData={};
local Indicator={};
local Pair;
local font, Wingdings, Bold;
local  Size;
local source;
local TF={};
local host;
local first;
local Test;
local Count;
local Up, Down, No, LabelColor;
local N={};
local Shift;

function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
		 core.host:execute ("killTimer", 1);
 end  

function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
	Shift=instance.parameters.Shift; 
    source = instance.source;
	 
    host = core.host;	
	
    Size=instance.parameters.ArrowSize;   
   
	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	No = instance.parameters.No;
	LabelColor = instance.parameters.Label;
	
	
	 
	 Pair, Count = getInstrumentList();
	  

	
	for i = 1 , 5 , 1 do   
	   TF[i]=  instance.parameters:getString ("TF"..i);
     
	end	
	 
	
		
   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	
	
	
	Test = core.indicators:create("HA", source );   
	first= Test.DATA:first() ;
	
	
		
	
	for j = 1, Count, 1 do
	
	         SourceData[j] = {};
			 Indicator[j] = {};	
             loading[j] = {};	
	   
	   
		 for i = 1, 5, 1 do	
		 
		 					  
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(first*2,300) , 2000 + j*10+i , 1000 + j*10+i);
			   loading[j][i] = true;  
			  
			   Indicator[j][i] = core.indicators:create("HA", SourceData[j][i] );

             			  
			  
		end
	end
    
	
	
	core.host:execute ("setTimer", 1, 1);
	 
end




function Update(period, mode)

core.host:execute ("setStatus", "")


 if period < source:size()-1 then
 return
 end
 
   
 
  
    local FLAG=false;
	
	local i,j;
	local id =0;
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, 5, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*5) - Number) .. " / " .. (Count*5) );
	return;
	end
	
  
  for i = 1, 5 , 1 do
  
  core.host:execute("drawLabel1", id, 100+(i-1)*50 ,  core.CR_LEFT, Size*2  +Shift, core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  TF[i]);			  
    id = id+1;	
				
  end

  for j = 1, Count, 1 do
  
  core.host:execute("drawLabel1", id, 50 ,  core.CR_LEFT, Size*3+(j-1)*Size+Shift  , core.CR_TOP, core.H_Left, core.V_Center, Bold, LabelColor,  Pair[j]);			  
  id = id+1;	
				
	for i = 1, 5, 1  do

				
			
				
				
				if Indicator[j][i].DATA:hasData(Indicator[j][i].DATA:size()-1)  then					

				local Color =nil;			
				local Style = nil;				

                 if Indicator[j][i].close[Indicator[j][i].close:size()-1] >  Indicator[j][i].open[Indicator[j][i].open:size()-1] then
								
									
									Color = Up;
									Style= "\225";
				elseif Indicator[j][i].close[Indicator[j][i].close:size()-1] <  Indicator[j][i].open[Indicator[j][i].open:size()-1] then
									
	                                  Color = Down;									
										Style= "\226";	
										
				else
 				
				                       Color = No;									
										Style= "\158";	
				 end 				
                
				
				if Style ~= nil then
				core.host:execute("drawLabel1", id, 100+(i-1)*50,  core.CR_LEFT, Size*3+(j-1)*Size+Shift , core.CR_TOP, core.H_Left, core.V_Center, Wingdings, Color,   Style );			  
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



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
 
 
   local Flag=false;

    for j = 1, Count, 1 do
		 for i = 1, 5, 1 do	
			  if cookie == (1000 + j*10+i) then
			  loading[j][i] = true;
			  Flag=true;
		      elseif  cookie == (2000 + j*10+i) then
			  loading[j][i] = false;  
			  
			  end
		       
          end
	end    
	
	if not Flag and cookie== 1  then
		 for j = 1, Count, 1 do
		 for i = 1, 5, 1 do	
		Indicator[j][i]:update(core.UpdateLast);
		end	
        end		
	end

   if not Flag then
   instance:updateFrom(0);	
   end
        
    return core.ASYNC_REDRAW;
end



