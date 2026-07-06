-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=39802&start=30

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
    indicator:name("Higher Time Frame Support Resistance");
    indicator:description("Higher Time Frame Support Resistance");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

   indicator.parameters:addGroup("Calculation");	
   indicator.parameters:addString("Method", "Current / Previous Period ", "Current / Previous" , "Previous");
    indicator.parameters:addStringAlternative("Method", "Current Period", "Current" , "Current");
    indicator.parameters:addStringAlternative("Method", "Previous Period", "Previous" , "Previous");	
	
	indicator.parameters:addGroup("Selector");	
	local TF={"m1" , "m5" ,"m15" ,"m30" , "H1" , "H2", "H3" , "H4",  "H6","H8" , "D1" , "W1", "M1"};

	local i;
	for i= 1, 13,1 do
		indicator.parameters:addBoolean("On"..i , "Show " ..  TF[i] .. " Frame", "", true);	
    end
	
	indicator.parameters:addGroup("Common Parameters");	
	indicator.parameters:addInteger("Size", "Size", "", 10);
	indicator.parameters:addBoolean("Show" , "Show Labels","", true);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	 indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "High Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Low Color", "", core.rgb(255, 0, 0));
 
 
end
local source;
local ATF={};
local loading={};
local On={};
local SourceData={};
local font, Wingdings, Bold;
local  Size;  
local Up, Down, No, LabelColor;
local TF={"m1" , "m5" ,"m15" ,"m30" , "H1" , "H2", "H3" , "H4",  "H6","H8" , "D1" , "W1", "M1"};
local Method;
 local Num;
 local Show;
 local offset, weekoffset;
function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   core.host:execute("deleteFont", Wingdings);
	     core.host:execute("deleteFont", Bold);
 end  

 function Prepare(nameOnly) 
    
	Method= instance.parameters.Method;
	Show= instance.parameters.Show;
    source = instance.source;
    Size= instance.parameters.Size;
	offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
     
    local name =  "(" .. profile:id() .. ","  .. instance.source:name() .. ","  .. Method.. ")"
	
	local i,j ;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;	 
	LabelColor = instance.parameters.Label;	
 	
	instance:name(name);
	
	if nameOnly then
        return;
    end
	
	
	Num=0;   	
	font = core.host:execute("createFont", "Courier", Size , false, false);
	Wingdings  = core.host:execute("createFont", "Wingdings", Size +1, false, false);
	Bold  = core.host:execute("createFont", "Courier", Size +1, false, true);   
	 	
	  for j = 1, 13, 1 do
	  
	         On[j]=  instance.parameters:getBoolean ("On"..j);
	         local s,e, s1, s2; 
            s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
            s1, e1 = core.getcandle(TF[j], core.now(), 0, 0);
			
	 		 if ((e-s)< (e1-s1)) and On[j] then	
			   Num=Num+1;					
               ATF[Num]= TF[j];				
			   SourceData[Num]  = core.host:execute("getSyncHistory", source:instrument(),  ATF[Num], source:isBid(), 2 , 200 + Num , 100 +Num);
			   loading[Num]  = true;  
			 end 	  
			  
		end
	 
end


function Update(period )

 if period < source:size()-1 then
 return
 end
 
   
 
  
    local FLAG=false;
	
	local   j;
	local id =1;
	
	for j = 1, Num, 1 do
		 

                 if loading[j]  then
				 FLAG= true;
				 end
		  
           	
    end
	
	if FLAG then	
	return;
	end

   local HShift;
   
   if Method == "Previous" then
   HShift=1;
   else
   HShift=0;
   end
   
   local Now;
   
  for j = 1, Num, 1 do
          local s1, e1;
		 Now= SourceData[j].close:size()-1;
	
			  s1, e1 = core.getcandle(ATF[j], source:date(period),offset, weekoffset);
			   core.host:execute("drawLine", 100+ j, s1, SourceData[j].high[Now-HShift], e1, SourceData[j].high[Now-HShift],Up);
			   core.host:execute("drawLine", 200+ j, s1, SourceData[j].low[Now-HShift], e1, SourceData[j].low[Now-HShift],Down);
			   if Show then
			  core.host:execute("drawLabel1", 300+j, e1 ,  core.CR_CHART, SourceData[j].high[Now-HShift], core.CR_CHART, core.H_Left, core.V_Top, Bold, LabelColor, ATF[j]);  
			  core.host:execute("drawLabel1", 400+j, e1 ,  core.CR_CHART, SourceData[j].low[Now-HShift], core.CR_CHART, core.H_Left, core.V_Top, Bold, LabelColor, ATF[j]); 
			  end		  
		 	
  end

  
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Number=0;

    for j = 1, Num, 1 do
		  
			  if cookie == (100 + j) then
			  loading[j]  = true;
		      elseif  cookie == (200 + j ) then
			  loading[j]  = false;           
			  
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Number=Number+1;
				 end
	end    
   
           
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Num) - Number) .. " / " .. (Num) );	 
	else
	core.host:execute ("setStatus", "Loaded")
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
	
	
end



