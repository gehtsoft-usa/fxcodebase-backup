// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67015

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

// Trading arrows template v.1.0.0

extern int LIN = 29; // LIN
extern int WHB = 6; // WHB
extern int WHS = 6; // WHS
extern int BIB = 6; // BIB
extern int BIS = 6; // BIS
extern double PPKKS = 0.994; // PPKKS
extern double PPKKB = 0.994; // PPKKB
extern double RES = 3; // RES
extern double SUP = 3; // SUP
extern color UpColor = Green; // Up color
extern color DnColor = Red; // Down color

#property indicator_chart_window
#property indicator_buffers 10
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_label1 "BUY"
#property indicator_label2 "SELL"

double buy[], sell[], whitenoiseB[], whitenoise[], filtB[], pkB[], resultB[], filt[], pk[], resultS[];

double a11, b11, c22, c33, c11, a1, b1, c2, c3, c1;

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

double RESISTENCE, SUPPORT;
int init()
{
   IndicatorName = GenerateIndicatorName("Scalping indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   double _point = MarketInfo(_Symbol, MODE_POINT);
   double _digits = (int)MarketInfo(_Symbol, MODE_DIGITS); 
   double _mult = _digits == 3 || _digits == 5 ? 10 : 1;
   double _pipSize = _point * _mult;
   RESISTENCE = RES * _pipSize;
   SUPPORT = SUP * _pipSize;

   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexArrow(0, 217);
   SetIndexBuffer(0, buy);
   SetIndexStyle(1, DRAW_ARROW, 0, 2);
   SetIndexArrow(1, 218);
   SetIndexBuffer(1, sell);
   SetIndexEmptyValue(2, 0);
   SetIndexEmptyValue(3, 0);
   SetIndexEmptyValue(4, 0);
   SetIndexEmptyValue(5, 0);
   SetIndexEmptyValue(6, 0);
   SetIndexEmptyValue(7, 0);
   SetIndexEmptyValue(8, 0);
   SetIndexEmptyValue(9, 0);
   SetIndexBuffer(2, whitenoiseB);
   SetIndexBuffer(3, whitenoise);
   SetIndexBuffer(4, filtB);
   SetIndexBuffer(5, pkB);
   SetIndexBuffer(6, resultB);
   SetIndexBuffer(7, filt);
   SetIndexBuffer(8, pk);
   SetIndexBuffer(9, resultS);

   a11 = MathExp(-1.414 * 3.14159 / BIS);
   b11 = 2 * a11 * MathCos(1.414 * 180 / BIS);
   c22 = b11;
   c33 = -a11 * a11;
   c11 = 1 - c22 - c33;

   // super smoother filter
   a1 = (-1.414 * 3.14159 / BIB);
   b1 = 2 * a1 * MathCos(1.414 * 180 / BIB);
   c2 = b1;
   c3 = -a1 * a1;
   c1 = 1 - c2 - c3;
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - MathMax(WHS, WHB) - 2;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   int period = limit;
   while (period >= 0)
   {
      whitenoiseB[period] = Close[period] - Close[period + WHS - 1];
      whitenoise[period] = Close[period] - Close[period + WHB - 1];

      // MODIFIED UNIVERSAL OSCILLATOR 1
      filtB[period] = c11 * (whitenoiseB[period] + whitenoiseB[period + 1]) / 2 + c22 * filtB[period + 1] + c33 * filtB[period + 1];
      pkB[period] = MathAbs(filtB[period]) > pkB[period + 1] ? MathAbs(filtB[period]) : PPKKS * pkB[period + 1];
      resultB[period] = pkB[period] == 0 ? resultB[period + 1] : filtB[period] / pkB[period];

      // MODIFIED UNIVERSAL OSCILLATOR 2
      filt[period] = c1 * (whitenoise[period] + whitenoise[period + 1]) / 2 + c2 * filt[period + 1] + c3 * filt[period + 1];
      pk[period] = MathAbs(filt[period]) > pk[period + 1] ? MathAbs(filt[period]) : PPKKB * pk[period + 1];
      resultS[period] = pk[period] == 0 ? resultS[period + 1] : filt[period] / pk[period];

      if (resultS[period] < -0.5 && resultS[period] > resultB[period] && resultS[period + 1] <= resultB[period + 1])
      {
         sell[period] = High[period] + RESISTENCE;
         string id = IndicatorObjPrefix + "sell_trend" + TimeToStr(Time[period]);
         ObjectCreate(id, OBJ_TREND, 0, Time[MathMin(Bars - 1, period + LIN)], High[period] + RESISTENCE, Time[period], High[period] + RESISTENCE);
         ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false); 
         ObjectSet(id, OBJPROP_COLOR, UpColor);
      }
      else
      {
         sell[period] = EMPTY_VALUE;
      }

      if (resultS[period] > 0.5 && resultS[period] < resultB[period] && resultS[period + 1] >= resultB[period + 1])
      {
         buy[period] = Low[period] - SUPPORT;
         string id = IndicatorObjPrefix + "buy_trend" + TimeToStr(Time[period]);
         ObjectCreate(id, OBJ_TREND, 0, Time[MathMin(Bars - 1, period + LIN)], buy[period], Time[period], buy[period]);
         ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false); 
         ObjectSet(id, OBJPROP_COLOR, DnColor);
      }
      else
      {
         buy[period] = EMPTY_VALUE;
      }
      period--;
   } 
   return(0);
}

