// Id: 10971
// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;
extern int Kperiod=8;
extern int Dperiod=3;
extern int Slowing=3;
extern int MA_Method=0;
extern int IndicatorLineIndex=0;
extern int Price_Field=0;
extern int ROC_Period=1;
extern int Type=0;
double ROC[];
 
int init()
{
   IndicatorDigits(Digits + 1);
   IndicatorShortName("Stochastic_ROC");
   SetIndexStyle(0,DRAW_LINE);  
   SetIndexBuffer(0,ROC); 
   SetIndexDrawBegin(0,ROC_Period);
 
   if(! (MA_Method >= 0 && MA_Method <= 3  )  ) 
   {
      Alert("Permitted MA_Method are between 0 and 3");
      return(-1);
   }
   
   if(! (Price_Field >= 0 && Price_Field <= 1  )  ) 
   {
      Alert("Permitted Price_Field are between 0 and 1");
      return(-1);
   }
   
   if(! (IndicatorLineIndex >= 0 && IndicatorLineIndex <= 1  )  ) 
   {
      Alert("Permitted IndicatorLineIndex are between 0 and 1");
      return(-1);
   }
   
   if(! (Type >= 0 && Type <= 1  )  ) 
   {
      Alert("Permitted Type are between 0 and 1");
      return(-1);
   }
   return(0);
}

int deinit()
{
   int Window=WindowFind("Stochastic_ROC");
   if (Window!=-1)
      ObjectsDeleteAll(Window, OBJ_TREND);
   return(0);
}

int start()
{
   if(Bars<=3)
      return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) 
      return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) 
      limit=Bars-ExtCountedBars-1;
   
   double Now;
   double Prev;
   int pos;
   pos=limit;    
   while(pos>=0)
   {
      int index = pos == 0 ? 0 : iBarShift(_Symbol, Timeframe, Time[pos]);
      if (index >= 0)
      {
         Now = iStochastic(_Symbol, Timeframe, Kperiod, Dperiod, Slowing, MA_Method, Price_Field, IndicatorLineIndex, index);
         Prev = iStochastic(_Symbol, Timeframe, Kperiod, Dperiod, Slowing, MA_Method, Price_Field, IndicatorLineIndex, index + ROC_Period);
         if (Type != 0)
         {
            if (Prev != 0)  
               ROC[pos] = ((Now - Prev) / Prev) * 100; 
         }
         else
         ROC[pos] = Now - Prev; 
      }
      pos--;
   } 
   return(0);
}
