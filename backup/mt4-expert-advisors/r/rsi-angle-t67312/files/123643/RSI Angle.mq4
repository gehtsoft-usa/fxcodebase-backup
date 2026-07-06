// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67312

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
#property version   "1.0"
#property strict

extern int RSI_Period = 14; // RSI Period
extern int FirstAngle = -50; // First angle
extern int SecondAngle = -30; // Second angle
extern int ThirdAngle = -25; // Third angle
extern int RSIValue = 25; // RSI Value

#define Pi 3.141592653589793238462643

double out[];

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_label1 "BUY"
#property indicator_label2 "SELL"

double buy[], sell[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init()
{
   IndicatorName = GenerateIndicatorName("RSI Angle");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexArrow(0, 217);
   SetIndexBuffer(0, buy);
   SetIndexStyle(1, DRAW_ARROW, 0, 2);
   SetIndexArrow(1, 218);
   SetIndexBuffer(1, sell);
   SetIndexBuffer(2, out);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1

int GetDirection(const int period)
{
   double rsi = iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, period);
   if (out[period] < FirstAngle && out[period + 1] < SecondAngle && out[period + 2] < ThirdAngle && rsi > RSIValue)
      return ENTER_BUY_SIGNAL;

   return 0;
}

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - 1;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      double val = iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, pos);
      double val1 = iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, pos + 1);
      double A = val1 - val;
      double C = 5;
   //hipotenusa
      double H = MathSqrt(MathPow ( A, 2 ) + MathPow ( C, 2 ));
   //hipotenusa
      out[pos] = (MathArctan(A / C)*180.0/Pi)*(-1);

      int direction = GetDirection(pos);
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            buy[pos] = Low[pos];
            sell[pos] = EMPTY_VALUE;
            break;
         case ENTER_SELL_SIGNAL:
            buy[pos] = EMPTY_VALUE;
            sell[pos] = High[pos];
            break;
      }
      pos--;
   } 
   return(0);
}

