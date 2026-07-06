// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73665

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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




#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 LightBlue
#property indicator_color2 Blue
#property indicator_color3 DarkGreen
#property indicator_color4 Red
#property indicator_color5 Magenta
//---- input parameters
extern int       Formula=0;
int i=1, shift;
double FP=0.0;
double FH=0.0, FL=0.0;
bool result;
//---- buffers
double ResBuffer2[];
double ResBuffer[];
double ExtMapBuffer1[];
double SupBuffer[];
double SupBuffer2[];

//+------------------------------------------------------------------+
//| Проверка нового дня                                              |
//+------------------------------------------------------------------+
bool isNewDay(int _shift)
  {
//---- 
   result=false;
   if (  (TimeHour(Time[_shift])==0)  && (TimeMinute(Time[_shift])==0)   ) result=true;

//----
   return(result);
  }
//+------------------------------------------------------------------+
//| Получить уровни FP,Res1,Sup1,Res2 и Sup2 прошедшего дня          |
//+------------------------------------------------------------------+
void GetRSofDay(int _shift)
  {
  int prevDay=TimeDay(Time[_shift+1]);
//---- 
   i=1;
   while (TimeDay(Time[_shift+i])==prevDay) i++;
   i--;
   FH=High[Highest(NULL,0,MODE_HIGH,i,_shift+1)];
   FL=Low[Lowest(NULL,0,MODE_LOW,i,_shift+1)];
   if (Formula==0) FP=NormalizeDouble((FH+FL+Close[_shift+1])/3.0,Digits); else FP=NormalizeDouble((FH+FL+2*Close[_shift+1])/4.0,Digits);
   ExtMapBuffer1[_shift]=FP;
   ResBuffer[_shift]=NormalizeDouble(FP+(FP-FL),Digits);
   SupBuffer[_shift]=NormalizeDouble(FP-(FH-FP),Digits);
   ResBuffer2[_shift]=NormalizeDouble(FP+(FH-FL),Digits);
   SupBuffer2[_shift]=NormalizeDouble(FP-(FH-FL),Digits);
//----
  }

//+------------------------------------------------------------------+
//| Копировать FP,Res1,Sup1,Res2 и Sup2 прошедшего дня               |
//+------------------------------------------------------------------+
void CopyLevelsDay(int _shift)
  {
   ExtMapBuffer1[_shift]=ExtMapBuffer1[_shift+1];
   ResBuffer[_shift]=ResBuffer[_shift+1];
   SupBuffer[_shift]=SupBuffer[_shift+1];
   ResBuffer2[_shift]=ResBuffer2[_shift+1];
   SupBuffer2[_shift]=SupBuffer2[_shift+1];
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if (Formula!=0)Formula=1;
   string label1="Pivot_Res2("+Formula+")";
   string label2="Pivot_Res("+Formula+")";
   string label3="Pivot_Point("+Formula+")";
   string label4="Pivot_Sup("+Formula+")";
   string label5="Pivot_Sup2("+Formula+")";
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,160); 
   SetIndexBuffer(0,ResBuffer2);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,label1);

   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,160); 
   SetIndexBuffer(1,ResBuffer);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(1,label2);

   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,160); 
   SetIndexBuffer(2,ExtMapBuffer1);
   SetIndexEmptyValue(2,0.0);
   SetIndexLabel(2,label3);

   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,160); 
   SetIndexBuffer(3,SupBuffer);
   SetIndexEmptyValue(3,0.0);
   SetIndexLabel(3,label4);

   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,160); 
   SetIndexBuffer(4,SupBuffer2);
   SetIndexEmptyValue(4,0.0);
   SetIndexLabel(4,label5);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit,firstDay;
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) return(0);
   if (counted_bars==0) 
      {
      limit=Bars-1;
      i=1;
      firstDay=TimeDay(Time[limit]);
      while (TimeDay(Time[limit-i])==firstDay) i++;
      limit=limit-i-PERIOD_D1/Period();
      }
   if (counted_bars>0) limit=Bars-counted_bars;
//---- 
   if (Period()>PERIOD_H4) return;
   for (shift=limit;shift>=0;shift--)
      {
      if (isNewDay(shift)) GetRSofDay(shift); else CopyLevelsDay(shift);
      }
//----
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