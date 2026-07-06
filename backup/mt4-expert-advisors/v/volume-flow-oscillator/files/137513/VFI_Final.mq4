//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

input int Length=130;
input double Coeff=0.2;
input double VCoeff=2.5;
input int Smoothing_Length=3;
input string symbols = "EURUSD, GBPUSD, USDJPY, AUDUSD"; // Symbols
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input int BarsCount = 200; // History Bars Count

double VFI[];
string Currencies[];

int init()
{
   IndicatorShortName("Volume Flow oscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,VFI);
   

   double temp = iCustom(NULL, 0, "VFI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'VFI' indicator");
      return INIT_FAILED;
   }
   if(StringLen(symbols)<1) return INIT_FAILED;
   getCurrencies();
   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   int counted_bars = IndicatorCounted();
   int minBars = 1;
   int limit = BarsCount;
   double sum[];
   ArrayResize(sum, limit+1);
   for(int j=0;j<ArrayRange(Currencies,0); j++)
   {
       string symbol = Currencies[j];
       //limit = iBars(symbol, tf);
       for (int i = limit; i >= 0; i--)
       {      
         int pos = iBarShift(symbol, tf, Time[i]);
         if (pos < 0)
         {
            continue;
         }
         sum[i] = iCustom(symbol, tf, "VFI", Length, Coeff, VCoeff, Smoothing_Length, 0, pos);
        
      }         
   }
  
  for (int i = limit; i >= 0; i--)
  {
      VFI[i] = sum[i]/ArrayRange(Currencies,0);
  }
   
      
   return(0);
}


void getCurrencies()
{
   
 
   string sep=",";                
   ushort u_sep;                     
  
   u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(symbols,u_sep,Currencies);
   
   for(int i=0;i<ArrayRange(Currencies,0); i++)
   {
      Currencies[i] = StringTrimRight(StringTrimLeft(Currencies[i]));
      Print("Currency "+Currencies[i]);
   
   }
}