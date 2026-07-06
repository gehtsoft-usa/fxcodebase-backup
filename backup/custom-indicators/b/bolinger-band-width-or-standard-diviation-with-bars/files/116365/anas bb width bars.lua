-- Id: 19905
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65434&p

--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC | 
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
indicator:name("Anas BB width"); -- ����� 
     indicator:description("Anas full up and down Oscillator  "); --�����
     indicator:requiredSource(core.Bar);-- ��� ��������� ���� ������ � ��������� ������ ������
     indicator:type(core.Oscillator);-- ��� ����� �� �� ���� �� ���� 
     indicator.parameters:addInteger("N", " No. of periods  ", " No. of periods ", 20, 1, 1000);
     indicator.parameters:addColor("osg", "Color of line", "Color of  line ", core.rgb(0, 255, 0));
     indicator.parameters:addColor("osr", "Color of line", "Color of  line ", core.rgb(255, 0, 0));
     
     end
local first = 0;
local n = 0;
local bbwg = nil;
local bbwr = nil;
local bbl = nil;



function Prepare(nameOnly)
     source = instance.source;
     
     n= instance.parameters.N;
   
     local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
     instance:name(name);
	 
	 if   (nameOnly) then
        return;
    end
	
	
     first = n + source:first()+1 ;

     bbwg = instance:addStream("bbw", core.Bar,"bbw" , "osline", instance.parameters.osg , first);
    bbwg:setPrecision(math.max(2, instance.source:getPrecision()));
     bbwr = instance:addStream("bbw", core.Bar,"bbw" , "osline", instance.parameters.osr , first);
    bbwr:setPrecision(math.max(2, instance.source:getPrecision()));
     bbl = instance:addStream("bbl", core.Line,"bbl" , "osline", instance.parameters.osr , first);
    bbl:setPrecision(math.max(2, instance.source:getPrecision()));
     end
     
function Update(period, mode)
        if (period >= first) then 
        
        local s = mathex.stdev(source.close, period-n+1 , period );
         bbl[period] = s;
         
        local sp = mathex.stdev(source.close, period-n , period-1 );
        if s > sp then 
        bbwg[period] = s;
         bbwr[period] = nil;
        else 
        bbwr[period] = s;
        bbwg[period] = nil;
        end
      
end
end
    