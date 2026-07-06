// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=17&t=70882

//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   | 
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |                    
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------+

//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |  
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |   
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |  
//+------------------------------------------------------------------------+


#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

extern int Length = 14;
extern int Price = 0; // Applied price
                      // 0 - Close
                      // 1 - Open
                      // 2 - High
                      // 3 - Low
                      // 4 - Median
                      // 5 - Typical
                      // 6 - Weighted

double CMA[], Prediction[];
int Length2;
int Odd;

int init()
{
   IndicatorShortName("Centred moving average");
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, CMA);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Prediction);
   Length2 = MathFloor(Length / 2);
   if (Length2 * 2 < Length)
      Odd = 1;
   else
      Odd = 0;
   return (0);
}

int deinit()
{

   return (0);
}

int start()
{
   if (Bars <= Length)
      return (0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return (-1);
   int limit = Bars - 2;
   if (ExtCountedBars > 2)
      limit = Bars - ExtCountedBars - 1;
   int pos;
   pos = limit;
   while (pos >= 0)
   {
      if (pos > Length2)
      {
         CMA[pos] = iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos - Length2);
         Prediction[pos] = EMPTY_VALUE;
      }
      else
      {
         CMA[pos] = (iMA(NULL, 0, pos + Length2, 0, MODE_SMA, Price, pos) * (Length2 + pos + 1) 
            + iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) * (Length2 - pos - 1 + Odd)) / Length;
         Prediction[pos] = CMA[pos];
      }
      pos--;
   }
   return (0);
}
