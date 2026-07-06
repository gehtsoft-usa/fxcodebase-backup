
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
    indicator:name("MTF SAR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	
	Parameters (1 , "m1", false );
	Parameters (2 , "m5" , false);
	Parameters (3 , "m15", false );
    Parameters (4 , "m30", false );
	Parameters (5 , "H1" , true);
	Parameters (6 , "H2" , false);
	Parameters (7 , "H3" , false);
	Parameters (8 , "H4" , false);
    Parameters (9 , "H6" , false);
	Parameters (10 , "H8", true );
	Parameters (11 , "D1", true );
	Parameters (12 , "W1", true );
	Parameters (13 , "M1", true );
  
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 10);
	indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "No Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
		indicator.parameters:addInteger("VShift", "Vertical Shift", "", 25);
	
	
	Style (1 );
	Style (2 );
	Style (3 );
	Style (4 );
	Style (5 );
	Style (6 );
	Style (7 );
	Style (8 );
	Style (9 );
	Style (10 );
	Style (11 );
	Style (12 );
	Style (13 );
 
	
	
end

function Style (id)
    
  	indicator.parameters:addGroup(id.. ".  Time Frame Style Options"); 
    indicator.parameters:addBoolean("Show"..id, "Show Line", "", true);
    indicator.parameters:addInteger("widht"..id, "Line widht", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);
 
end


function Parameters (id , FRAME, Flag )


  	indicator.parameters:addGroup(id..".  Time Frame"); 
	
	 indicator.parameters:addBoolean("On"..id, "Show This Time Frame", "", Flag);
    indicator.parameters:addDouble("Step"..id, "Step", "", 0.02, 0.001, 1);
    indicator.parameters:addDouble("Max"..id, "Max", "", 0.2, 0.001, 10);
  
    indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
end

local On={};
local Step={};
local Max={};
local TF={};
--local color={};
local widht={};
local style={};

local  ArrowSize;
local source;
local Indicator={};
local day_offset, week_offset; 
local Source={};
local host;
--local alive;
local first;
local Up, Down, Neutral, Label;
local loading={};
 local font;
 local font2;
local Show={};
local Number;
local VShift;
function Prepare(nameOnly) 
    Number=0;
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Label=instance.parameters.Label;
	VShift=instance.parameters.VShift;

    	local i;
    for i= 1, 13, 1 do
	 On[i]= instance.parameters:getBoolean ("On"..i);
	 if On[i] then
	 Number=Number+1;
	 Show[Number]= instance.parameters:getBoolean ("Show"..i);
	 style[Number]= instance.parameters:getDouble ("style"..i);
	 widht[Number]= instance.parameters:getDouble ("widht"..i);
	 Step[Number]= instance.parameters:getDouble ("Step"..i);
	 Max[Number]= instance.parameters:getDouble ("Max"..i);
     TF[Number]= instance.parameters:getString ("TF"..i);
	 end
	end
      
    ArrowSize=instance.parameters.ArrowSize; 
	
    local name =  profile:id() .. ","  .. instance.source:name() ;
	
    source = instance.source;
	
    host = core.host;

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");	

	
    dummy = instance:addInternalStream(0, 0);

	for i= 1, Number, 1 do
	name = name..", (" .. TF[i]..", " ..Step[i]..", ".. Max[i] ..  ")";      
	end
	name = name .. ")";
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	local Test;
	 
	
	  font = core.host:execute("createFont", "Arial", ArrowSize, true, false);
       font2 = core.host:execute("createFont", "Wingdings", ArrowSize, false, false);

	   
	  

		for i = 1, Number , 1 do	 
		    Test = core.indicators:create("SAR", source ,  Step[i], Max[i]);   
	        first= math.max(Test:getStream(0):first(), Test:getStream(1):first()) ;  
			Source[i] = core.host:execute("getSyncHistory",source:instrument(), TF[i], source:isBid(), math.min(first+1,300), 200+i, 100+i);
			loading[i]=true;
			Indicator[i] = core.indicators:create("SAR", Source[i],Step[i],  Max[i]);
		end  
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  			  
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 

		   
			  
	end    
   
   
         if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loadeded");
		instance:updateFrom(0);		
        return core.ASYNC_REDRAW ;		
		end
        
		
end


function Update(period, mode)


 
 if  period <  source:size() - 1 then	
 return;
end
 
			for i = 1, Number, 1  do 
			Calculate(i, period,mode )  
			 end 
 end
 
 function Calculate(i, period, mode)
 


		if loading[i] then		
		return;
		end
	
		
	

	

               local fromLevel= nil;
				local fromDate, toDate;
				local date = source:date(period);
				local color;
						Indicator[i]:update(mode);
						
						
						if  not Indicator[i].UP:hasData( Indicator[i].UP:size()-1)  
						and   not Indicator[i].DN:hasData(Indicator[i].DN:size()-1)
						then	
				      	return;
						end
                        
                              
                     							
							 
							      core.host:execute("drawLabel1", i+200, -i*5*ArrowSize, core.CR_RIGHT,VShift, core.CR_TOP, core.H_Right, core.V_Bottom, font, Label, TF[i]);
							 
						
											   if Indicator[i].DN:hasData(Indicator[i].DN:size()-1)   then
												
												core.host:execute("drawLabel1", i, -i*5*ArrowSize, core.CR_RIGHT, VShift+ArrowSize, core.CR_TOP, core.H_Right, core.V_Bottom, font2, Up, "\225");
												
													core.host:execute("drawLabel1", i+100, -i*5*ArrowSize, core.CR_RIGHT, VShift+2*ArrowSize, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font, Label,  string.format("%." ..  source:getPrecision() .. "f", Indicator[i].DN[Indicator[i].DN:size()-1] ));
												fromLevel=  Indicator[i].DN[Indicator[i].DN:size()-1];
												color=Up;
												
												elseif Indicator[i].UP:hasData(Indicator[i].UP:size()-1)  then
												
                                                core.host:execute("drawLabel1", i, -i*5*ArrowSize,core.CR_RIGHT, VShift+ArrowSize, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Down, "\226");
												
													core.host:execute("drawLabel1", i+100, -i*5*ArrowSize, core.CR_RIGHT, VShift+2*ArrowSize, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font, Label,  string.format("%." ..  source:getPrecision() .. "f", Indicator[i].UP[Indicator[i].UP:size()-1] ));
												fromLevel=  Indicator[i].UP[Indicator[i].UP:size()-1];
												color=Down;
												else
													
                                               core.host:execute("drawLabel1", i, -i*5*ArrowSize ,core.CR_RIGHT, VShift+ArrowSize, core.CR_TOP, core.H_Right, core.V_Bottom,
                                                font2, Neutral, "\223");												
												
												end 		
												
												
											   if Show[i] and fromLevel~= nil  then
											   fromDate, toDate = core.getcandle( TF[i], date, core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));
											   core.host:execute ("drawLine", 200 + i, fromDate, fromLevel, toDate, fromLevel, color, style[i], widht[i]);
											   
											   core.host:execute("drawLabel1", i+300,  toDate, core.CR_CHART, fromLevel, core.CR_CHART, core.H_Right, core.V_Bottom,
                                                font, Label,  string.format("%." ..  source:getPrecision() .. "f", fromLevel ) .. "("  .. TF[i] ..  ")");
												
											   end
 
 end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
       core.host:execute("deleteFont", font2);
   end


