-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=66178

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

-- Indicator profile initialization routine

function Init()
    indicator:name("Three time frames RSI Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. RSI Calculation"); 
	
	indicator.parameters:addString("TF1", "Bar Size", "", "H1");
	indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);
    indicator.parameters:addInteger("Period1", "Period", "", 14, 2, 2000);
 
	indicator.parameters:addString("Price1", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");
 
	
	indicator.parameters:addGroup("2. RSI Calculation"); 
	
	indicator.parameters:addString("TF2", "Bar Size", "", "H4");
	indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);
    indicator.parameters:addInteger("Period2", "Period", "", 28, 2, 2000);
 
	indicator.parameters:addString("Price2", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addGroup("3. RSI Calculation"); 
	
	indicator.parameters:addString("TF3", "Bar Size", "", "D1");
	indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);
    indicator.parameters:addInteger("Period3", "Period", "", 14, 2, 2000);
 
	indicator.parameters:addString("Price3", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price3","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price3", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price3", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price3", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price3", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price3", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price3", "WEIGHTED", "", "weighted");
 
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));  
	
	 indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",0, 0, 50);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local   Price1, Period1;
local  Price2, Period2; 
local  Price3, Period3; 
local first;
local source = nil;
local Up,Down,Neutral;
local Signal;  
local Indicator={};
local dayoffset,weekoffset;
local TF={};
local VSpace, HSpace;
local loading={};
local SourceData={};
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	
	source = instance.source;
	first=source:first();
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF[1] = instance.parameters.TF1;
	TF[2] = instance.parameters.TF2;
	TF[3] = instance.parameters.TF3;
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF[1], 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	s2, e2 = core.getcandle(TF[2], 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");	
	
	s2, e2 = core.getcandle(TF[3], 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	local Test1 = core.indicators:create("RSI", source.close ,Period1);   
	first1= Test1.DATA:first() ; 

    local Test2 = core.indicators:create("RSI", source.close ,Period2);   
	first2= Test2.DATA:first() ; 

    local Test3 = core.indicators:create("RSI", source.close ,Period3);   
	first3= Test3.DATA:first() ; 	
	
	SourceData[1] = core.host:execute("getSyncHistory", source:instrument(), TF[1], source:isBid(), first1, 100, 101);
	loading[1]=true;
	
	SourceData[2] = core.host:execute("getSyncHistory", source:instrument(), TF[2], source:isBid(), first1, 200, 201);
	loading[2]=true;
	
	SourceData[3] = core.host:execute("getSyncHistory", source:instrument(), TF[3], source:isBid(), first1, 300, 301);
	loading[3]=true;

    Period1= instance.parameters.Period1; 
    Price1 = instance.parameters.Price1;
	
	Period2= instance.parameters.Period2; 
    Price2 = instance.parameters.Price2;
	
	Period3= instance.parameters.Period3; 
    Price3 = instance.parameters.Price3;
			
  
    Signal = instance:addInternalStream(0, 0);
  
    Indicator[1] = core.indicators:create("RSI", SourceData[1][Price1], Period1);
    Indicator[2] = core.indicators:create("RSI", SourceData[2][Price2], Period2);
	Indicator[3] = core.indicators:create("RSI", SourceData[3][Price2], Period3);
 
	 
   
    instance:ownerDrawn(true);
    core.host:execute ("setTimer", 1, 1);
	
	
end


function   Initialization(id,period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), dayoffset, weekoffset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
function Update(period, mode)

 
 
 
	
	p1= Initialization(1,period);
	p2= Initialization(2,period);
    p3= Initialization(3,period);	
	
	 
	
	
    if period < first
	or not p1
	or not p2
	or not p3
	or loading[2]
	or loading[1]
	or loading[3]
	or not Indicator[1].DATA:hasData(p1) 
	or not Indicator[2].DATA:hasData(p2)
	or not Indicator[3].DATA:hasData(p3)
	then
	Signal[period]=0;
	return;
	end
	
	if Indicator[1].DATA[p1]  > 50
	and Indicator[2].DATA[p2]  > 50
	and Indicator[3].DATA[p3]  > 50
	then
	Signal[period]=1;
	elseif Indicator[1].DATA[p1]  < 50
	and Indicator[2].DATA[p2]  < 50
	and Indicator[3].DATA[p3]  < 50
	then
	Signal[period]=-1;
	else
	Signal[period]=0;
	end
 
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading[1] = false;
        
    elseif cookie == 101 then
        loading[1] = true;
    end
	
	if cookie == 200 then
        loading[2]= false;
        
    elseif cookie == 201 then
        loading[2] = true;
    end
	
	
	if cookie == 300 then
        loading[3] = false;
        
    elseif cookie == 301 then
        loading[3] = true;
    end
	
	
	 if  not loading[1] and not loading[2] and not loading[3]
	 and cookie== 1
	 then
		 
		 	  Indicator[1]:update(core.UpdateLast );
			   Indicator[2]:update(core.UpdateLast );
			    Indicator[3]:update(core.UpdateLast );
	end
		
	
	if not loading[1] and not loading[2] and not loading[3]then
	core.host:execute ("setStatus", "Loaded")
	instance:updateFrom(0);
	else
	core.host:execute ("setStatus", "Loading")
	end
	
end



local init = false;

function Draw (stage, context)

    if stage  ~= 0 
	or loading[1] 
    or loading[2] 
	or loading[3]
	then
	return;
	end
	 
	 
 
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		   
	 
			
	     
			context:createSolidBrush(12, Up); 
			context:createSolidBrush(22, Down); 
			context:createSolidBrush(32, Neutral);
	        context:createPen (11, context.SOLID, 3, Up)  
			context:createPen (21, context.SOLID, 3, Down)  
			context:createPen (31, context.SOLID, 3, Neutral)  
		 
		  
            init = true;
        end
     
        local j=1;
        local firstX = math.max(source:first(), context:firstBar ());
        local lastX = math.min (context:lastBar (), source:size()-1);
		
        
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =(X2-X1)*HSpace;
		 VCellSize = (context:bottom() -context:top()) ; 
	
       
			    for i= firstX, lastX, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
			   
				  
				  
				 
				                          if Signal:hasData(i)  then	
			 
										
												    if Signal[i] == 1 then		 
															 
															C1=12;
															C2=11; 
															 
												 
												    elseif Signal[i] == -1 then		  
													        
														 
														    C2=21; 
															C1=22;
													else		 												
													       C1=32;
														   C2=31; 
													end
										
										 else
 										         C2=31; 
												 C1=32;
											 
										 end		 
			 
                 				
				   context:drawRectangle (C2, C1, x1+HCellSize, context:top()+VCellSize * (j-1) +VCellSize* VSpace, x2-HCellSize, context:top() + VCellSize * (j)-VCellSize* VSpace);
				   
				   
				 
									

					 end  				 
				 
				 
			 
	 
	   
	
end
