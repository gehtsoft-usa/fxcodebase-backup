// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=147779#p147779

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrNONE
#property indicator_color2 clrNONE
#property indicator_color3 clrDeepPink
#property indicator_color4 clrLimeGreen
#property indicator_color5 clrDeepPink
#property indicator_color6 clrLimeGreen
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 4
#property indicator_width4 4

ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;
input ENUM_TIMEFRAMES _TimeFrame = PERIOD_CURRENT; // Time frame
input int MaPeriod = 25;
input ENUM_MA_METHOD MaMetod = 1;
input int Step = 0;
input bool BetterFormula = false;
input bool jurik = false;
input int Length = 34;
input double Phase = 0;
input int FillWidth = 0;
input bool alertsOn = true;
input bool alertsOnCurrent = false;
input bool alertsMessage = true;
input bool alertsSound = false;
input bool alertsEmail = false;
input bool Interpolate = true; // Interpolate in mtf mode

double Buffer1[], Buffer2[], Buffer3[], Buffer4[], trend[], count[], Buffer6[], Buffer7[];
string indicatorFileName;
#define _mtfCall(_buff, _ind) iCustom(NULL, TimeFrame, indicatorFileName, PERIOD_CURRENT, MaPeriod, MaMetod, Step, BetterFormula, jurik, Length, Phase, alertsOn, alertsOnCurrent, alertsMessage, alertsSound, alertsEmail, _buff, _ind)

int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0, Buffer1);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(1, Buffer2);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(2, Buffer3);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(3, Buffer4);
   SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexBuffer(4, Buffer6);
   SetIndexStyle(4, DRAW_HISTOGRAM, EMPTY, FillWidth);
   SetIndexBuffer(5, Buffer7);
   SetIndexStyle(5, DRAW_HISTOGRAM, EMPTY, FillWidth);

   SetIndexBuffer(6, trend);
   SetIndexBuffer(7, count);

   indicatorFileName = WindowExpertName();
   TimeFrame = fmax(_TimeFrame, _Period);

   return (0);
}

int start()
{
   double maOpen, maClose, maLow, maHigh;
   double haOpen, haClose, haLow, haHigh;

   int i, pointModifier, counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   int limit = fmin(Bars - 1 - counted_bars, Bars - 2);
   count[0] = limit;
   if (_Digits == 3 || _Digits == 5)
      pointModifier = 10;
   else
      pointModifier = 1;
   if (TimeFrame != _Period)
   {
      limit = (int)fmax(limit, fmin(Bars - 1, _mtfCall(5, 0) * TimeFrame / _Period));
      for (i = limit; i >= 0 && !_StopFlag; i--)
      {
         int y = iBarShift(NULL, TimeFrame, Time[i]);
         Buffer1[i] = _mtfCall(0, y);
         Buffer2[i] = _mtfCall(1, y);
         Buffer3[i] = _mtfCall(2, y);
         Buffer4[i] = _mtfCall(3, y);
         Buffer6[i] = _mtfCall(4, y);
         Buffer7[i] = _mtfCall(5, y);

         if (!Interpolate || (i > 0 && y == iBarShift(NULL, TimeFrame, Time[i - 1])))
            continue;
#define _interpolate(buff) buff[i + k] = buff[i] + (buff[i + n] - buff[i]) * k / n
         int n, k;
         datetime time = iTime(NULL, TimeFrame, y);
         for (n = 1; (i + n) < Bars && Time[i + n] >= time; n++)
            continue;
         for (k = 1; k < n && (i + n) < Bars && (i + k) < Bars; k++)
         {
            _interpolate(Buffer1);
            _interpolate(Buffer2);
            _interpolate(Buffer3);
            _interpolate(Buffer4);
         }
      }
      return (0);
   }

   for (int pos = limit; pos >= 0; pos--)
   {
      if (jurik)
      {
         maOpen = iSmooth(Open[pos], Length, Phase, pos, 0);
         maClose = iSmooth(Close[pos], Length, Phase, pos, 10);
         maLow = iSmooth(Low[pos], Length, Phase, pos, 20);
         maHigh = iSmooth(High[pos], Length, Phase, pos, 30);
      }
      else
      {
         maOpen = iMA(NULL, 0, MaPeriod, 0, MaMetod, PRICE_OPEN, pos);
         maClose = iMA(NULL, 0, MaPeriod, 0, MaMetod, PRICE_CLOSE, pos);
         maLow = iMA(NULL, 0, MaPeriod, 0, MaMetod, PRICE_LOW, pos);
         maHigh = iMA(NULL, 0, MaPeriod, 0, MaMetod, PRICE_HIGH, pos);
      }

      if (BetterFormula)
      {
         if (maHigh != maLow)
            haClose = (maOpen + maClose) / 2 + (((maClose - maOpen) / (maHigh - maLow)) * MathAbs((maClose - maOpen) / 2));
         else
            haClose = (maOpen + maClose) / 2;
      }
      else
         haClose = (maOpen + maHigh + maLow + maClose) / 4;
      haOpen = (Buffer3[pos + 1] + Buffer4[pos + 1]) / 2;
      haHigh = fmax(maHigh, fmax(haOpen, haClose));
      haLow = fmin(maOpen, fmin(haOpen, haClose));

      if (haOpen < haClose)
      {
         Buffer1[pos] = haLow;
         Buffer2[pos] = haHigh;
      }
      else
      {
         Buffer1[pos] = haHigh;
         Buffer2[pos] = haLow;
      }
      Buffer3[pos] = haOpen;
      Buffer4[pos] = haClose;

      if (Buffer3[pos] != 0)
      {
         Buffer6[pos] = Buffer3[pos];
         Buffer7[pos] = High[pos];
      }
      if (pos == 1)
         Print(" Buffer6[pos] " + Buffer6[pos] + " Buffer7[pos] " + Buffer7[pos]);

      if (Step > 0)
      {
         if (MathAbs(Buffer1[pos] - Buffer1[pos + 1]) < Step * pointModifier * _Point)
            Buffer1[pos] = Buffer1[pos + 1];
         if (MathAbs(Buffer2[pos] - Buffer2[pos + 1]) < Step * pointModifier * _Point)
            Buffer2[pos] = Buffer2[pos + 1];
         if (MathAbs(Buffer3[pos] - Buffer3[pos + 1]) < Step * pointModifier * _Point)
            Buffer3[pos] = Buffer3[pos + 1];
         if (MathAbs(Buffer4[pos] - Buffer4[pos + 1]) < Step * pointModifier * _Point)
            Buffer4[pos] = Buffer4[pos + 1];
      }
      trend[i] = trend[i + 1];
      if (Buffer1[i] > Buffer2[i])
         trend[i] = -1;
      if (Buffer1[i] < Buffer2[i])
         trend[i] = 1;
   }

   //
   //
   //
   //
   //

   if (alertsOn)
   {
      if (alertsOnCurrent)
         int whichBar = 0;
      else
         whichBar = 1;

      //
      //
      //
      //
      //

      if (trend[whichBar] != trend[whichBar + 1])
         if (trend[whichBar] == 1)
            doAlert("up");
         else
            doAlert("down");
   }
   return (0);
}

double workLsma[][2];
double iLsma(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workLsma, 0) != Bars)
      ArrayResize(workLsma, Bars);
   r = Bars - r - 1;

   //
   //
   //
   //
   //

   period = MathMax(period, 1);
   workLsma[r][instanceNo] = price;
   double lwmw = period;
   double lwma = lwmw * price;
   double sma = price;
   for (int k = 1; k < period && (r - k) >= 0; k++)
   {
      double weight = period - k;
      lwmw += weight;
      lwma += weight * workLsma[r - k][instanceNo];
      sma += workLsma[r - k][instanceNo];
   }

   return (3.0 * lwma / lwmw - 2.0 * sma / period);
}

//
//
//

void doAlert(string doWhat)
{
   static string previousAlert = "nothing";
   static datetime previousTime;
   string message;

   if (previousAlert != doWhat || previousTime != Time[0])
   {
      previousAlert = doWhat;
      previousTime = Time[0];

      //
      //
      //
      //
      //

      message = timeFrameToString(_Period) + " " + _Symbol + " at " + TimeToStr(TimeLocal(), TIME_SECONDS) + " heiken ashi jurik smoothed trend changed to " + doWhat;
      if (alertsMessage)
         Alert(message);
      if (alertsEmail)
         SendMail(_Symbol + " heiken ashi jurik smoothed ", message);
      if (alertsSound)
         PlaySound("alert2.wav");
   }
}

//
//
//

double wrk[][40];
#define bsmax 5
#define bsmin 6
#define volty 7
#define vsum 8
#define avolty 9

//
//
//
//
//

double iSmooth(double price, double length, double phase, int i, int s = 0)
{
   if (length <= 1)
      return (price);
   if (ArrayRange(wrk, 0) != Bars)
      ArrayResize(wrk, Bars);

   int r = Bars - i - 1;
   if (r == 0)
   {
      for (int k = 0; k < 7; k++)
         wrk[r][k + s] = price;
      for (; k < 10; k++)
         wrk[r][k + s] = 0;
      return (price);
   }

   //
   //
   //
   //
   //

   double len1 = MathMax(MathLog(MathSqrt(0.5 * (length - 1))) / MathLog(2.0) + 2.0, 0);
   double pow1 = MathMax(len1 - 2.0, 0.5);
   double del1 = price - wrk[r - 1][bsmax + s];
   double del2 = price - wrk[r - 1][bsmin + s];
   double div = 1.0 / (10.0 + 10.0 * (MathMin(MathMax(length - 10, 0), 100)) / 100);
   int forBar = MathMin(r, 10);

   wrk[r][volty + s] = 0;
   if (MathAbs(del1) > MathAbs(del2))
      wrk[r][volty + s] = MathAbs(del1);
   if (MathAbs(del1) < MathAbs(del2))
      wrk[r][volty + s] = MathAbs(del2);
   wrk[r][vsum + s] = wrk[r - 1][vsum + s] + (wrk[r][volty + s] - wrk[r - forBar][volty + s]) * div;

   //
   //
   //
   //
   //

   wrk[r][avolty + s] = wrk[r - 1][avolty + s] + (2.0 / (MathMax(4.0 * length, 30) + 1.0)) * (wrk[r][vsum + s] - wrk[r - 1][avolty + s]);
   if (wrk[r][avolty + s] > 0)
      double dVolty = wrk[r][volty + s] / wrk[r][avolty + s];
   else
      dVolty = 0;
   if (dVolty > MathPow(len1, 1.0 / pow1))
      dVolty = MathPow(len1, 1.0 / pow1);
   if (dVolty < 1)
      dVolty = 1.0;

   //
   //
   //
   //
   //

   double pow2 = MathPow(dVolty, pow1);
   double len2 = MathSqrt(0.5 * (length - 1)) * len1;
   double Kv = MathPow(len2 / (len2 + 1), MathSqrt(pow2));

   if (del1 > 0)
      wrk[r][bsmax + s] = price;
   else
      wrk[r][bsmax + s] = price - Kv * del1;
   if (del2 < 0)
      wrk[r][bsmin + s] = price;
   else
      wrk[r][bsmin + s] = price - Kv * del2;

   //
   //
   //
   //
   //

   double R = MathMax(MathMin(phase, 100), -100) / 100.0 + 1.5;
   double beta = 0.45 * (length - 1) / (0.45 * (length - 1) + 2);
   double alpha = MathPow(beta, pow2);

   wrk[r][0 + s] = price + alpha * (wrk[r - 1][0 + s] - price);
   wrk[r][1 + s] = (price - wrk[r][0 + s]) * (1 - beta) + beta * wrk[r - 1][1 + s];
   wrk[r][2 + s] = (wrk[r][0 + s] + R * wrk[r][1 + s]);
   wrk[r][3 + s] = (wrk[r][2 + s] - wrk[r - 1][4 + s]) * MathPow((1 - alpha), 2) + MathPow(alpha, 2) * wrk[r - 1][3 + s];
   wrk[r][4 + s] = (wrk[r - 1][4 + s] + wrk[r][3 + s]);

   //
   //
   //
   //
   //

   return (wrk[r][4 + s]);
}

//
//
//
//

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

string timeFrameToString(int tf)
{
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tf == iTfTable[i])
         return (sTfTable[i]);
   return ("");
}
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=147779#p147779

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 