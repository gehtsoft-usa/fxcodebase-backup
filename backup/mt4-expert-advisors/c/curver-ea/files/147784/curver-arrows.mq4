// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72813

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Green
//---- input parameters
extern int SSP       = 6;     //период линейного разворота индикатора
extern int CountBars = 2250;  //расчетный период 
extern int SkyCh     = 13;    //чувствительность к пробою канала 
//Должна быть в диапазоне 0-50. 0 - нет стрелок. Больше 50 - перерегулирование
int    i;
double high, low, smin, smax;
double val1[];      // буфер для бай
double val2[];      // буфер для селл
double Sky_BufferH[];
double Sky_BufferL[];
bool   uptrend, old;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 233);        // стрелка для бай
   SetIndexBuffer(0, val1);      // индекс буфера для бай
   SetIndexDrawBegin(0, 2*SSP);
   //
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 234);        // стрелка для селл
   SetIndexBuffer(1, val2);      // индекс буфера для селл
   SetIndexDrawBegin(1, 2*SSP);
   //
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Sky_BufferH);
   SetIndexLabel(2, "High");
   SetIndexDrawBegin(2, 2*SSP);
   //
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, Sky_BufferL);
   SetIndexLabel(3, "Low");
   SetIndexDrawBegin(3, 2*SSP);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Calculation of SilverTrend lines                                 | 
//+------------------------------------------------------------------+
int start()
  {   
   int counted_bars = IndicatorCounted();
//---- последний посчитанный бар будет пересчитан
   if(counted_bars > 0) counted_bars--;
//----
   if(Bars <= SSP + 1)        return(0);
//---- initial zero
   uptrend       =false;
   old           =false;
   GlobalVariableSet("goSELL", 0); // задали существование и обнулили goSELL=0
   GlobalVariableSet("goBUY", 0);  // задали существование и обнулили goBUY =0
//----
   for(i = CountBars - SSP; i >= 0; i--) // уменьш значение shift на 1 за проход;
     { 
       high = High[iHighest(Symbol(),0,MODE_HIGH,SSP,i)]; 
       low = Low[iLowest(Symbol(),0,MODE_LOW,SSP,i)]; 
       smax = high - (high - low)*SkyCh / 100; // smax ниже high с учетом коэфф.SkyCh
       smin = low + (high - low)*SkyCh / 100;  // smin выше low с учетом коэфф.SkyCh
	    val1[i] = 0;  
       val2[i] = 0;
       if(Close[i] < smin && i!=0 )	// выключено мерцание стрелок (i!=0)
       {
       uptrend = false;
       }
	    if(Close[i] > smax && i!=0 )	// выключено мерцание стрелок (i!=0)	
	    {
	    uptrend = true;       
       }       
       if(uptrend != old && uptrend == false)
         {
           val2[i] = high; // если условия выполнены то рисуем val1
           if(i == 0)                GlobalVariableSet("goBUY",1);
         }
       if(uptrend != old && uptrend == true ) 
         {
           val1[i] = low; // если условия выполнены то рисуем val2
           if(i == 0)                GlobalVariableSet("goSELL",1);
         }
       old=uptrend;
       Sky_BufferH[i]=high - (high - low)*SkyCh / 100;
       Sky_BufferL[i]=low +  (high - low)*SkyCh / 100;
     }
   return(0);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+