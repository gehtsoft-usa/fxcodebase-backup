-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66889

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
    indicator:name("Custom ROC Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("PeriodMA0", "Period", "", 13, 1, 2000);
	indicator.parameters:addInteger("PeriodMA1", "Period of calculated MA", "", 21, 1, 2000);
	indicator.parameters:addInteger("BarsV", "Amount of bars for calc. rate", "", 13, 1, 2000);
	indicator.parameters:addInteger("AverBars", "Amount of bars for smoothing", "", 5, 1, 2000);
	indicator.parameters:addDouble("K1", "Amplifier gain", "", 2);
	indicator.parameters:addDouble("K2", "K2", "", 2);
	indicator.parameters:addDouble("K3", "K3", "", 12);
	
 

 
 
 
	for i= 1, 6 , 1 do
	local Color={core.rgb(255, 0, 0),core.rgb(0, 255, 0),core.rgb(0, 0, 255),core.rgb(128, 128, 128),core.rgb(255, 0, 255),core.rgb(0, 255, 255)}
	Add(i, Color[i])
    end
	
end

function Add(id, Color)

	indicator.parameters:addGroup(id..". Line Style"); 	
    indicator.parameters:addColor("color"..id, "Line Color", "", Color);
	indicator.parameters:addInteger("style"..id, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width"..id, "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local PeriodMA0,PeriodMA1,BarsV,AverBars,K1,K2,K3;
local Sh1, Sh2, Sh3, PeriodMA2, PeriodMA3,PeriodMA02, PeriodMA03; 	
local first;
local source = nil;
 
local MA={};  
local Line={};

local width={};
local style={};
local color={};
-- Routine
 function Prepare(nameOnly)   
 
 
 
    PeriodMA0= instance.parameters.PeriodMA0;
	PeriodMA1= instance.parameters.PeriodMA1;
	BarsV= instance.parameters.BarsV;
	AverBars= instance.parameters.AverBars;
	K1= instance.parameters.K1;
	K2= instance.parameters.K2;
	K3= instance.parameters.K3;
	
	
	color[1]= instance.parameters.color1;
	color[2]= instance.parameters.color2;
	color[3]= instance.parameters.color3;
	color[4]= instance.parameters.color4;
	color[5]= instance.parameters.color5;
	color[6]= instance.parameters.color6;
    
	style[1]= instance.parameters.style1;
	style[2]= instance.parameters.style2;
	style[3]= instance.parameters.style3;
	style[4]= instance.parameters.style4;
	style[5]= instance.parameters.style5;
	style[6]= instance.parameters.style6;
	
	width[1]= instance.parameters.width1;
	width[2]= instance.parameters.width2;
	width[3]= instance.parameters.width3;
	width[4]= instance.parameters.width4;
	width[5]= instance.parameters.width5;
    width[6]= instance.parameters.width6;
	
	local Parameters= PeriodMA0 ..", " .. PeriodMA1 ..", " ..BarsV ..", " ..AverBars ..", " ..K1 ..", " ..K2 ..", " ..K3;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	Sh1=BarsV               -- Period of rate calcul. (bars)
	Sh2=K2*Sh1                 -- Calc. period for nearest TF
	Sh3=K3*Sh1                 -- Calc. period for next TF
	PeriodMA2 =K2*PeriodMA1    -- Calc. period of MA for nearest TF
	PeriodMA3 =K3*PeriodMA1    -- Calc. period of MA for next TF
	PeriodMA02=K2*PeriodMA0    -- Period of supp. MA for nearest TF
	PeriodMA03=K3*PeriodMA0    -- Period of supp. MA for next TF
    
			
    source = instance.source; 
	
   MA[1] = core.indicators:create("WMA", source.typical, PeriodMA0); 
   MA[2] = core.indicators:create("WMA", source.typical, PeriodMA1);
   MA[3] = core.indicators:create("WMA", source.typical, PeriodMA2);   
   MA[4] = core.indicators:create("WMA", source.typical, PeriodMA3);   
 
   MA[5] = core.indicators:create("WMA", source.typical, PeriodMA02);
   MA[6] = core.indicators:create("WMA", source.typical, PeriodMA03); 


     
	first={
	source:first()+ PeriodMA0,
	MA[2].DATA:first()+Sh1, 
	math.max(MA[3].DATA:first()+Sh2, MA[5].DATA:first()),
	math.max(MA[4].DATA:first()+Sh2, MA[6].DATA:first()),
	math.max(MA[4].DATA:first()+Sh2, MA[6].DATA:first()),
	math.max(MA[4].DATA:first()+Sh3, MA[6].DATA:first()) + AverBars
	}  
   
    for i= 1, 6, 1 do
	Line[i] = instance:addStream(i.."Line" , core.Line, i..".Line", i..".Line", color[i], first[i]);
	Line[i]:setWidth(width[i]);
    Line[i]:setStyle(style[i]);
    end
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 for i= 1, 6 ,1 do
    MA[i]:update(mode);
 end
	
 
	
	

   if period <= source:first()+ PeriodMA0 then
	return;
	end 
 
 
Line[1][period]=MA[1].DATA[period]-- Value of supp. MA
 
 
   if period < MA[2].DATA:first()+Sh1 then
	return;
	end 
  
 
local MAc=MA[2].DATA[period];
local MAp=MA[2].DATA[period-Sh1+1];
 
Line[2][period]=Line[1][period]+K1*(MAc-MAp) -- Value of 1st rate line 
 
 
   if period < math.max(MA[3].DATA:first()+Sh2, MA[5].DATA:first()) then
	return;
	end 
 
local MAc=MA[3].DATA[period];
local MAp=MA[3].DATA[period-Sh2+1];
 
Line[3][period]= MA[5].DATA[period]+K1*(MAc-MAp) -- Value of 2nd rate line


    if period < math.max(MA[4].DATA:first()+Sh3, MA[6].DATA:first()) then
	return;
	end
	

local MAc=MA[4].DATA[period];
local MAp=MA[4].DATA[period-Sh3+1];
 
Line[4][period]= MA[6].DATA[period]+K1*(MAc-MAp) -- Value of 3nd rate line



   
	
Line[5][period]=(Line[2][period]+Line[3][period]+Line[4][period])/3 -- Summary array


    if period < math.max(MA[4].DATA:first()+Sh3, MA[6].DATA:first()) + AverBars then
	return;
	end
	
Line[6][period]=mathex.avg(Line[5], period-AverBars+1, period);

	  
end

