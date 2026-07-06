-- Id: 16150
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63553

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
    indicator:name("Stochastic Convergence Divergence");
    indicator:description("Stochastic Convergence Divergence");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	

	indicator.parameters:addGroup("Selector");
	
	 indicator.parameters:addString("Mode", "Mode", "", "Indicator");
    indicator.parameters:addStringAlternative("Mode", "Indicator", "", "Indicator");
    indicator.parameters:addStringAlternative("Mode", "Divergence","", "Divergence");
	
	indicator.parameters:addGroup("Calculation");	
		
	Parameters (1,5,3,3  );
	Parameters (2,21,14,2  );
	

	
	indicator.parameters:addGroup("1.Indicator Style");

		
	indicator.parameters:addColor("colorK1", "K Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthK1", "Line Width ", "", 1, 1, 5);
    indicator.parameters:addInteger("styleK1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleK1", core.FLAG_LEVEL_STYLE);	
	
    indicator.parameters:addColor("colorD1", "D Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthD1", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleD1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleD1", core.FLAG_LEVEL_STYLE);	
 
	
	indicator.parameters:addGroup("2.Indicator Style");

		
	indicator.parameters:addColor("colorK2", "K Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthK2", "Line Width ", "", 5, 1, 5);
    indicator.parameters:addInteger("styleK2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleK2", core.FLAG_LEVEL_STYLE);	
	
    indicator.parameters:addColor("colorD2", "D Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthD2", "Line Width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleD2", "Line Style", "", core.LINE_DASH);
    indicator.parameters:setFlag("styleD2", core.FLAG_LEVEL_STYLE);	
	
	
	indicator.parameters:addGroup("Divergence Style");
	indicator.parameters:addColor("UpColor", "Up Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("DownColor", "Down Color", "", core.rgb(100, 100, 100));
end

function Parameters (id, S1, S2, S3 )
    
	indicator.parameters:addGroup(id .. ". Stochastic");
    indicator.parameters:addInteger("K"..id , "Number of periods for %K", "", S1,2, 1000);
    indicator.parameters:addInteger("D"..id, "The number of periods for %D.", "", S2, 2, 1000);
    indicator.parameters:addInteger("SD"..id, "%D slowing periods", "", S3, 2, 1000);

    indicator.parameters:addString("KS"..id, "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS"..id, "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS"..id, "MT4","", "FS");
    
    indicator.parameters:addString("DS"..id, "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("DS"..id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS"..id, "EMA", "", "EMA"); 	 
		

end

local UpColor, DownColor;
local K={};
local SD={};
local D={};
local KS={};
local DS={}; 
local source;
local Indicator= {};
local kLine= {};
local dLine= {};
local first;
local Mode;
local Divergence;
function Prepare(nameOnly)
    source = instance.source;
   
    local name =  profile:id()  ;
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Mode = instance.parameters.Mode;
	UpColor= instance.parameters.UpColor;
	DownColor= instance.parameters.DownColor;
	
	local i;
	for i = 1 , 2 , 1 do    
	
	K[i] = instance.parameters:getInteger ("K"..i);
	SD[i] = instance.parameters:getInteger  ("SD"..i);
	D[i] = instance.parameters:getInteger  ("D"..i);
	KS[i] = instance.parameters:getString ("KS"..i);
	DS[i] = instance.parameters:getString ("DS"..i);
	     
       
    Indicator[i]= core.indicators:create("STOCHASTIC", source,  K[i] , SD[i],D[i] , KS[i],DS[i]);	


    kLine[i]= instance:addStream("K"..i, core.Line, i.. ". K", i.. ". K", instance.parameters:getColor("colorK" .. i), Indicator[i].K:first());	   
    kLine[i]:setPrecision(math.max(2, instance.source:getPrecision()));
    kLine[i]:setWidth(instance.parameters:getInteger("widthK" .. i));
    kLine[i]:setStyle(instance.parameters:getInteger("styleK" .. i));	
	
		if Mode == "Indicator" then	
		dLine[i]= instance:addStream("D"..i, core.Line, i.. ". D", i.. ". D", instance.parameters:getColor("colorD" .. i), Indicator[i].D:first());	   
    dLine[i]:setPrecision(math.max(2, instance.source:getPrecision()));
		dLine[i]:setWidth(instance.parameters:getInteger("widthD" .. i));
		dLine[i]:setStyle(instance.parameters:getInteger("styleD" .. i));	
		else
		dLine[i] = instance:addInternalStream( Indicator[i].D:first(), 0);
		end
		
	
	end	
	 
	 
 
    kLine[1]:addLevel(20);
	kLine[1]:addLevel(50);
    kLine[1]:addLevel(80);	  
    kLine[1]:addLevel(0);
	kLine[1]:addLevel(100);
	
        if Mode ~= "Indicator" then	
		Divergence= instance:addStream("Divergence", core.Line, ". Divergence",   ". Divergence", UpColor, math.max(Indicator[1].D:first(),Indicator[2].D:first()));  
    Divergence:setPrecision(math.max(2, instance.source:getPrecision()));
		else
		Divergence = instance:addInternalStream( math.max(Indicator[1].D:first(),Indicator[2].D:first()), 0);
		end
	
	
end


function Update(period, mode)

    
	Indicator[1]:update(mode);
	Indicator[2]:update(mode);
	
		
		if 	Indicator[1].K:hasData(period)then	 				
		kLine[1][period]=Indicator[1].K[period]
		end
		
		if 	Indicator[2].K:hasData(period)then	 
		kLine[2][period]=Indicator[2].K[period]
		end
		
		if 	Indicator[1].D:hasData(period)then	 
		dLine[1][period]=Indicator[1].D[period]
		end
		
		if 	Indicator[2].D:hasData(period)then	 
		dLine[2][period]=Indicator[2].D[period]					  
	    end
		
		if 	Indicator[1].K:hasData(period) and Indicator[2].K:hasData(period) then	 
		Divergence[period]= kLine[1][period]-kLine[2][period]+50;
		
			if Divergence[period]> 50 then
			Divergence:setColor(period, UpColor);
			else
			Divergence:setColor(period, DownColor);
			end
		end
	
end
