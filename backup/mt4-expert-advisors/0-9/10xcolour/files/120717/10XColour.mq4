// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66581

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

#property indicator_chart_window
#property indicator_buffers 22
#property strict

extern int MVAVPeriod = 20; // Periods of Volume SMA
extern double VPercent = 50; // Percentage of Volume above the SMA
extern int ADXPeriod = 14; // Period ADX
extern double ADXLevel = 20; // ADX Strength level
extern int DMIPeriod = 14; // Period DMI
extern int History_limit = 1000; // Limit number of processed bars
extern color clrA = clrGreen; // Ascending color
extern color clrD = clrRed; // Descending color
extern color clrAC = 0x80FFFF; // Ascending conviction color
extern color clrDC = 0xFF80FF; // Descending conviction color
extern color clrR = 0xFFFF00; // Range color

// Candles stream v.1.0.0
class CandleStreams
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
   }

   int RegisterStreams(const int id, const color clr)
   {
      SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 0, OpenStream);
      SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 1, CloseStream);
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 3, LowStream);
      return id + 4;
   }

   void Set(const int index, const double open, const double high, const double low, const double close)
   {
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};


CandleStreams A;
CandleStreams D;
CandleStreams AC;
CandleStreams DC;
CandleStreams R;

double vol[];
double color_code[];

int n;

int init()
{
   n = MathMax(MathMax(MVAVPeriod, ADXPeriod), DMIPeriod);
   IndicatorShortName("10X Bars indicator");
   IndicatorDigits(Digits);

   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, color_code);
   int id = A.RegisterStreams(1, clrA);
   id = D.RegisterStreams(id, clrD);
   id = AC.RegisterStreams(id, clrAC);
   id = DC.RegisterStreams(id, clrDC);
   id = R.RegisterStreams(id, clrR);
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, vol);
   
   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit = Bars - 2;
   if (ExtCountedBars > 2)
      limit = Bars - ExtCountedBars - 1;
   if (limit > History_limit)
      limit = History_limit;

   int pos = limit;
   while (pos >= 0)
   {
      A.Clear(pos);
      D.Clear(pos);
      AC.Clear(pos);
      DC.Clear(pos);
      R.Clear(pos);

      vol[pos] = (double)Volume[pos];
      double MVAV = iMAOnArray(vol, 0, n, 0, MODE_SMA, pos);
      if (MVAV == 0)
      {
         pos--;
         continue;
      }
      double volpercent = MVAV < Volume[pos] ? (Volume[pos] - MVAV / MVAV) * 100 : 0;
      if (pos < limit)
      {
         if (iADX(NULL, 0, ADXPeriod, PRICE_CLOSE, 0, pos) <= ADXLevel)
         {
            R.Set(pos, Open[pos], Open[pos], Close[pos], Close[pos]);
            color_code[pos] = 0;
         }
         else
         {
            double DIP = iADX(NULL, 0, DMIPeriod, PRICE_CLOSE, 1, pos);
            double DIM = iADX(NULL, 0 ,DMIPeriod, PRICE_CLOSE, 2, pos);
            if (DIP > DIM)
            {
               if (volpercent > VPercent)
               {
                  AC.Set(pos, Open[pos], Open[pos], Close[pos], Close[pos]);
                  color_code[pos] = 1;
               }
               else
               {
                  A.Set(pos, Open[pos], Open[pos], Close[pos], Close[pos]);
                  color_code[pos] = 2;
               }
            }
            else
            {
               if (volpercent > VPercent)
               {
                  DC.Set(pos, Open[pos], Open[pos], Close[pos], Close[pos]);
                  color_code[pos] = 3;
               }
               else
               {
                  D.Set(pos, Open[pos], Open[pos], Close[pos], Close[pos]);
                  color_code[pos] = 4;
               }
            }
         }
      }        
   
      pos--;
   }
   return(0);
}
