-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 18223

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Two Source Ratio BB");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Inverse", "Inverse", "", false);
	
	
	
	 
	indicator.parameters:addString("TF", "Time frame", "", "Chart");
    indicator.parameters:addStringAlternative("TF", "Chart", "", "Chart");
	indicator.parameters:addStringAlternative("TF", "m1", "", "m1");
	indicator.parameters:addStringAlternative("TF", "m5", "", "m5");
	indicator.parameters:addStringAlternative("TF", "m15", "", "m15");
	indicator.parameters:addStringAlternative("TF", "m30", "", "m30");
	indicator.parameters:addStringAlternative("TF", "H1", "", "H1");
	indicator.parameters:addStringAlternative("TF", "H2", "", "H2");
	indicator.parameters:addStringAlternative("TF", "H3", "", "H3");
	indicator.parameters:addStringAlternative("TF", "H4", "", "H4");
	indicator.parameters:addStringAlternative("TF", "H6", "", "H6");
	indicator.parameters:addStringAlternative("TF", "H8", "", "H8");
	indicator.parameters:addStringAlternative("TF", "D1", "", "D1");
	indicator.parameters:addStringAlternative("TF", "W1", "", "W1");
	indicator.parameters:addStringAlternative("TF", "M1", "", "M1");
   
   
    indicator.parameters:addGroup("1. Source");
   
    indicator.parameters:addString("Src", "1. Source Price", "", "close");
    indicator.parameters:addStringAlternative("Src", "open", "", "open");
    indicator.parameters:addStringAlternative("Src", "high", "", "high");
    indicator.parameters:addStringAlternative("Src", "low", "", "low");
    indicator.parameters:addStringAlternative("Src", "close", "", "close");
    indicator.parameters:addStringAlternative("Src", "median", "", "median");
    indicator.parameters:addStringAlternative("Src", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Src", "weighted", "", "weighted"); 
	
    indicator.parameters:addString("Pair1", "1. instrument", "", "EUR/USD");
    indicator.parameters:setFlag("Pair1", core.FLAG_INSTRUMENTS);
	
	
	indicator.parameters:addGroup("2. Source");
	
	indicator.parameters:addString("Dst", "2. Source Price", "", "close");
    indicator.parameters:addStringAlternative("Dst", "open", "", "open");
    indicator.parameters:addStringAlternative("Dst", "high", "", "high");
    indicator.parameters:addStringAlternative("Dst", "low", "", "low");
    indicator.parameters:addStringAlternative("Dst", "close", "", "close");
    indicator.parameters:addStringAlternative("Dst", "median", "", "median");
    indicator.parameters:addStringAlternative("Dst", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Dst", "weighted", "", "weighted");
	
	
	indicator.parameters:addString("Pair2", "2. instrument", "", "EUR/JPY");
    indicator.parameters:setFlag("Pair2", core.FLAG_INSTRUMENTS);
	
	
    indicator.parameters:addGroup("BB Calculation"); 
    indicator.parameters:addInteger("BB_Period", "Period", "", 20);
	indicator.parameters:addDouble("BB_Deviaton", "BB Deviaton", "", 2);
    
	indicator.parameters:addGroup("Ratio Style");
	indicator.parameters:addColor("clr", "Line Color", "", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("width", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("BB Style");
	indicator.parameters:addColor("clr1", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width1", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
   

end
local Src, Dst;
local source;   
local loading={};
local Pair={};
local Source={};
local Inverse;
local Ratio;
local Number=2;
local dayoffset, weekoffset;
local TF;
local BB_Period, BB_Deviaton,BB,TL,BL,CL;
function Prepare(onlyName)
    source = instance.source;   
    price_first = source:first();
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
 
    Inverse = instance.parameters.Inverse;
	TF= instance.parameters.TF;
    Pair[1] = instance.parameters.Pair1;
	Pair[2] = instance.parameters.Pair2;
	
	Src = instance.parameters.Src;
	Dst = instance.parameters.Dst;
	
	if TF == "Chart" then
	TF=source:barSize();
	end

    local name;
    name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
	
    if onlyName then
        return ;
    end

   
    for i= 1, Number, 1 do
            Source[i] = core.host:execute("getSyncHistory",Pair[i], TF, source:isBid(), 0, 200+i, 100+i);
			loading[i]=true;	  
    end
    Ratio = instance:addStream("Ratio", core.Line, name, "Ratio", instance.parameters.clr, source:first());
    Ratio:setWidth(instance.parameters.width);
    Ratio:setStyle(instance.parameters.style);
    Ratio:setPrecision(2);
	
	BB = core.indicators:create("BB", Ratio, BB_Period,BB_Deviaton);
	
	
	
	TL = instance:addStream("TL", core.Line, name, "TL", instance.parameters.clr1, source:first());
    TL:setPrecision(math.max(2, instance.source:getPrecision()));
    TL:setWidth(instance.parameters.width1);
    TL:setStyle(instance.parameters.style1);
	
	BL = instance:addStream("BL", core.Line, name, "BL", instance.parameters.clr1, source:first());
    BL:setPrecision(math.max(2, instance.source:getPrecision()));
    BL:setWidth(instance.parameters.width1);
    BL:setStyle(instance.parameters.style1);
    
	CL = instance:addStream("CL", core.Line, name, "CL", instance.parameters.clr1, source:first());
    CL:setPrecision(math.max(2, instance.source:getPrecision()));
    CL:setWidth(instance.parameters.width1);
    CL:setStyle(instance.parameters.style1);
   
end

function Update(period,mode )
   
   
    if period < source:first() then
	return;
	end
	
    local p={};
	local Flag = false;	
 
	 
    for j = 1, Number, 1 do
		 
		p[j]= Initialization(period,j)
			  
		if loading[j] or p[j] == false or  p[j] <=0  then
		Flag=true;
		end	 

		  
		
	end    
	
	    if Flag then
		return;
		end
		
 

  
        if not Inverse	then
	 	Ratio[period] = Source[1][Src][p[1]]/Source[2][Dst][p[2]] ; 
		else
         Ratio[period] = Source[2][Dst][p[2]]/Source[1][Src][p[1]];      
        end		
		
		
		BB:update(mode);
		
		TL[period]=BB.TL[period];
		BL[period]=BB.BL[period];
		CL[period]=BB.AL[period];

end

	
	
	
function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
  
    if loading[id] or Source[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(Source[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = true;	
	local Count=0;	
	
	
	    local id=0;
		
    for j = 1, Number, 1 do
		id=id+1;
			  if cookie == (100+id) then
			  loading[j] = true;
		      elseif  cookie == (200+id) then
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

 