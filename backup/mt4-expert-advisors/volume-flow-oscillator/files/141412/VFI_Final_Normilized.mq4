// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=61253

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
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
input int normalizationPeriod = 10; // Normalization period
input string symbols = "EURUSD, GBPUSD, USDJPY, AUDUSD"; // Symbols
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input int BarsCount = 200; // History Bars Count

double VFI[];
double VFI_data[];
string Currencies[];

int init()
{
   IndicatorShortName("Volume Flow oscillator");
   IndicatorDigits(Digits);
   
   IndicatorBuffers(2);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,VFI);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, VFI_data);

   double temp = iCustom(NULL, 0, "VFI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'VFI' indicator");
      return INIT_FAILED;
   }
   if(StringLen(symbols)<1) 
      return INIT_FAILED;
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
      VFI_data[i] = sum[i] / ArrayRange(Currencies,0);
      int VFI_dataLowestIndex = ArrayMinimum(VFI_data, normalizationPeriod, i);
      double VFI_dataLowest = VFI_data[VFI_dataLowestIndex];
      int VFI_dataHighestIndex = ArrayMaximum(VFI_data, normalizationPeriod, i);
      double VFI_dataHighest = VFI_data[VFI_dataHighestIndex];
      double VFI_dataRange = VFI_dataHighest - VFI_dataLowest;
      VFI[i] = VFI_dataRange == 0 ? 0 : (VFI_data[i] - VFI_dataLowest) / VFI_dataRange;
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