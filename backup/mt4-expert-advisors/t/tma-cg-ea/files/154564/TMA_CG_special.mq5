// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74662

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |
//|                                                                         mario.jemic@gmail.com  |
//|                                                        https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"


#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots 8
#property indicator_color1  C'76,76,76' //DimGray
#property indicator_color2  DimGray //Maroon
#property indicator_color3  DimGray //DarkBlue
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT

#property indicator_label4 "Arrow Up"
#property  indicator_type4  DRAW_ARROW
#property indicator_color4 clrBlue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Arrow Down"
#property  indicator_type5  DRAW_ARROW
#property indicator_color5 clrOrange
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Strong Up"
#property  indicator_type6  DRAW_ARROW
#property indicator_color6 clrGreen
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Strong Down"
#property  indicator_type7  DRAW_ARROW
#property indicator_color7 clrRed
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1

input int    HalfLength      = 20;
input ENUM_APPLIED_PRICE Price=PRICE_WEIGHTED; // Price
input double BandsDeviations = 2.3; //2.7; //1.618;

double tmBuffer[];
double upBuffer[];
double dnBuffer[];
double wuBuffer[];
double wdBuffer[];

double arrowUp[];
double arrowDn[];
double strongUp[];
double strongDn[];

bool   calculatingTma = false;
bool   returningBars  = false;

input int bars_limit = 1000; // Bars limit

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};

interface IBarStream : public IStream
{
public:
   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close) = 0;

   virtual bool FindDatePeriod(const datetime date, int& period) = 0;

   virtual bool GetOpen(const int period, double &open) = 0;
   virtual bool GetHigh(const int period, double &high) = 0;
   virtual bool GetLow(const int period, double &low) = 0;
   virtual bool GetClose(const int period, double &close) = 0;
   
   virtual bool GetHighLow(const int period, double &high, double &low) = 0;
   virtual bool GetOpenClose(const int period, double &open, double &close) = 0;

   virtual bool GetDate(const int period, datetime &dt) = 0;

   virtual int Size() = 0;

   virtual void Refresh() = 0;
};

#ifndef PriceStream_IMP
#define PriceStream_IMP

class PriceStream : public IStream
{
   ENUM_APPLIED_PRICE _price;
   IBarStream* _source;
   int _references;
public:
   PriceStream(IBarStream* source, const ENUM_APPLIED_PRICE __price)
   {
      _source = source;
      _source.AddRef();
      _price = __price;
      _references = 1;
   }

   ~PriceStream()
   {
      _source.Release();
   }

   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   int Size()
   {
      return _source.Size();
   }

   virtual bool GetSeriesValues(const int period, const int count, double &values[])
   {
      for (int i = 0; i < count; ++i)
      {
         double val;
         switch (_price)
         {
            case PRICE_CLOSE:
               if (!_source.GetClose(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_OPEN:
               if (!_source.GetOpen(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_HIGH:
               if (!_source.GetHigh(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_LOW:
               if (!_source.GetLow(period + i, val))
               {
                  return false;
               }
               break;
            case PRICE_MEDIAN:
               {
                  double high, low;
                  if (!_source.GetHighLow(period + i, high, low))
                  {
                     return false;
                  }
                  val = (high + low) / 2.0;
               }
               break;
            case PRICE_TYPICAL:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period + i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close) / 3.0;
               }
               break;
            case PRICE_WEIGHTED:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period + i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close * 2) / 4.0;
               }
               break;
         }
         values[i] = val;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = Size();
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

class ABaseStream : public IStream
{
protected:
   int _references;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   ABaseStream(string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _references = 1;
   }

   ~ABaseStream()
   {
   }

   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }
   
   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

class SimplePriceStream : public ABaseStream
{
   ENUM_APPLIED_PRICE _price;
   double _pipSize;
public:
   SimplePriceStream(string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_PRICE price)
      :ABaseStream(symbol, timeframe)
   {
      _price = price;

      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      int mult = digit == 3 || digit == 5 ? 10 : 1;
      _pipSize = point * mult;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         switch (_price)
         {
            case PRICE_CLOSE:
               val[i] = iClose(_symbol, _timeframe, period + i);
               break;
            case PRICE_OPEN:
               val[i] = iOpen(_symbol, _timeframe, period + i);
               break;
            case PRICE_HIGH:
               val[i] = iHigh(_symbol, _timeframe, period + i);
               break;
            case PRICE_LOW:
               val[i] = iLow(_symbol, _timeframe, period + i);
               break;
            case PRICE_MEDIAN:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i)) / 2.0;
               break;
            case PRICE_TYPICAL:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i) + iClose(_symbol, _timeframe, period + i)) / 3.0;
               break;
            case PRICE_WEIGHTED:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i) + iClose(_symbol, _timeframe, period + i) * 2) / 4.0;
               break;
         }
         val[i] += _shift * _pipSize;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

#endif
SimplePriceStream* price;

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("tmacd");
   IndicatorSetString(INDICATOR_SHORTNAME, "TMA + CG");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   price = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, Price);

   SetIndexBuffer(0, tmBuffer, INDICATOR_DATA); 
   SetIndexBuffer(1, upBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, dnBuffer, INDICATOR_DATA);
   
   SetIndexBuffer(3, arrowUp, INDICATOR_DATA);
   SetIndexBuffer(4, arrowDn, INDICATOR_DATA);
   SetIndexBuffer(5, strongUp, INDICATOR_DATA);
   SetIndexBuffer(6, strongDn, INDICATOR_DATA);
   
   SetIndexBuffer(7, wuBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, wdBuffer, INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE); 
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,STYLE_SOLID); 
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrBlue); 
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,1); 
   
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE); 
   PlotIndexSetInteger(1,PLOT_LINE_STYLE,STYLE_DOT); 
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrGray); 
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,1); 

   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE); 
   PlotIndexSetInteger(2,PLOT_LINE_STYLE,STYLE_DOT); 
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,clrGray); 
   PlotIndexSetInteger(2,PLOT_LINE_WIDTH,1); 
   
}

void OnDeinit(const int reason)
{
   price.Release();
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   double FullLength = 2.0*HalfLength+1.0;
   
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(tmBuffer, EMPTY_VALUE);
      ArrayInitialize(upBuffer, EMPTY_VALUE);
      ArrayInitialize(dnBuffer, EMPTY_VALUE);
      ArrayInitialize(wuBuffer, EMPTY_VALUE);
      ArrayInitialize(wdBuffer, EMPTY_VALUE);
   }
   
   int first = 0;
   int veryFirst = rates_total - 1 - bars_limit;
   
   for (int pos = MathMax(veryFirst, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;

      double val[1];
      if (!price.GetValues(pos, 1, val))
      {
         continue;
      }
      double sum = (HalfLength + 1) * val[0];
      double sumw = (HalfLength + 1);
      
      for(int j = 1; j <= HalfLength; j++)
      {
         int k = HalfLength + 1 - j;
         if (!price.GetValues(pos - j, 1, val))
         {
            continue;
         }
         sum  += k * val[0];
         sumw += k;

         if (pos + j < rates_total)
         {
            if (!price.GetValues(pos + j, 1, val))
            {
               continue;
            }
            sum  += k * val[0];
            sumw += k;
         }
      }
      tmBuffer[pos] = sum / sumw;
      
      if (!price.GetValues(pos, 1, val))
      {
         continue;
      }
      double diff = val[0] - tmBuffer[pos];
      
      if (upBuffer[pos - 1] == EMPTY_VALUE)
      {
         upBuffer[pos] = tmBuffer[pos];
         dnBuffer[pos] = tmBuffer[pos];
         wuBuffer[pos] = MathPow(diff, 2);
         wdBuffer[pos] = MathPow(diff, 2);         
      }
      else
      {
         if(diff >= 0)
         {
            wuBuffer[pos] = (wuBuffer[pos - 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
            wdBuffer[pos] =  wdBuffer[pos - 1] * (FullLength - 1) / FullLength;
         }
         else
         {
            wdBuffer[pos] = (wdBuffer[pos - 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
            wuBuffer[pos] =  wuBuffer[pos - 1] * (FullLength - 1) / FullLength;
         }
         
         upBuffer[pos] = tmBuffer[pos] + BandsDeviations * MathSqrt(wuBuffer[pos]);
         dnBuffer[pos] = tmBuffer[pos] - BandsDeviations * MathSqrt(wdBuffer[pos]);
      }
   
      // buy signal
      if(close[pos-1]>upBuffer[pos-1]) { 
         if(upBuffer[pos-2]<upBuffer[pos-1]) {
            arrowDn[pos-1]=upBuffer[pos-1]; 
         } 
         if(upBuffer[pos-2]>upBuffer[pos-1]) {
            strongDn[pos-1]=upBuffer[pos-1];
         }
      }
   
      // sell signal
      if(close[pos-1]<dnBuffer[pos-1]) { 
         if(dnBuffer[pos-2]>dnBuffer[pos-1]) { // dnline going dn
            arrowUp[pos-1]=dnBuffer[pos-1]; 
         }
         if(dnBuffer[pos-2]<dnBuffer[pos-1]) {
            strongUp[pos-1]=dnBuffer[pos-1]; 
         }
      }
      
   }
   return rates_total;
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+
