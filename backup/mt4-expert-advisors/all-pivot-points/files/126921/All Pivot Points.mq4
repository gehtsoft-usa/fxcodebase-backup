// Id: 25308
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68577

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

#property indicator_chart_window
#property indicator_buffers 9

//--- indicator buffers
double         PivotBuffer[];
double         S1Buffer[];
double         S2Buffer[];
double         S3Buffer[];
double         S4Buffer[];
double         R1Buffer[];
double         R2Buffer[];
double         R3Buffer[];
double         R4Buffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_CALC_MODE
  {
   CALC_MODE_CLASSIC1=0,// Classic 1
   CALC_MODE_CLASSIC2=1,// Classic 2
   CALC_MODE_CAMARILLA=2,// Camarilla
   CALC_MODE_WOODIE=3,// Woodie
   CALC_MODE_FIBONACCI=4,// Fibonacci
   CALC_MODE_FLOOR=5,// Floor
   CALC_MODE_FIBONACCI_RETRACEMENT=6,// Fibonacci Retracement
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_SHOW_MODE
  {
   SHOW_MODE_TODAY,// Today
   SHOW_MODE_HISTORICAL,// Historical
  };
input ENUM_TIMEFRAMES         InpTimeframe         = PERIOD_D1;                                    // Timeframe
input int TimeframePeriods = 1; // Timeframe periods
input ENUM_CALC_MODE          CalculationMode      = CALC_MODE_CLASSIC1;                           // Calculation Mode
input ENUM_SHOW_MODE          InpShowMode          = SHOW_MODE_HISTORICAL;                         // Displaying Mode
input int                     InpHistoricalBars    = 0;                                            // Historical Bars (0=All)
input bool                    InpShowLabels        = true;                                         // Show Labels
input bool                    InpShowPriceTags     = true;                                         // Show Price Tags
input bool                    InpIncludeSundays    = true;                                         // Include Sundays
input string                  InpDesc1             = "********* Fibonacci Levels *********";       // Description
input double                  InpFibR1S1           = 38.2;                                         // R1/S1
input double                  InpFibR2S2           = 61.8;                                         // R2/S2
input double                  InpFibR3S3           = 100.0;                                        // R3/S3
input double                  InpFibR4S4           = 161.8;                                        // R4/S4
input string                  InpDesc2             = "*********** Active Lines ***********";       // Description
input bool                    InpShowPivot         = true;                                         // Pivot
input bool                    InpShowS1            = true;                                         // S1
input bool                    InpShowS2            = true;                                         // S2
input bool                    InpShowS3            = true;                                         // S3
input bool                    InpShowS4            = true;                                         // S4
input bool                    InpShowR1            = true;                                         // R1
input bool                    InpShowR2            = true;                                         // R2
input bool                    InpShowR3            = true;                                         // R3
input bool                    InpShowR4            = true;                                         // R4
input string                  InpDesc3             = "*********** Line Color ***********";         // Description
input color                   InpPivotColor        = clrLightGray;                                 // Pivot
input color                   InpS1Color           = clrRed;                                       // S1
input color                   InpS2Color           = clrCrimson;                                   // S2
input color                   InpS3Color           = clrFireBrick;                                 // S3
input color                   InpS4Color           = clrMaroon;                                    // S4
input color                   InpR1Color           = clrLime;                                      // R1
input color                   InpR2Color           = clrLimeGreen;                                 // R2
input color                   InpR3Color           = clrMediumSeaGreen;                            // R3
input color                   InpR4Color           = clrSeaGreen;                                  // R4
input string                  InpDesc4             = "*********** Line Style ***********";         // Description
input ENUM_LINE_STYLE         InpPivotStyle        = STYLE_SOLID;                                  // Pivot
input ENUM_LINE_STYLE         InpS1Style           = STYLE_SOLID;                                  // S1
input ENUM_LINE_STYLE         InpS2Style           = STYLE_SOLID;                                  // S2
input ENUM_LINE_STYLE         InpS3Style           = STYLE_SOLID;                                  // S3
input ENUM_LINE_STYLE         InpS4Style           = STYLE_SOLID;                                  // S4
input ENUM_LINE_STYLE         InpR1Style           = STYLE_SOLID;                                  // R1
input ENUM_LINE_STYLE         InpR2Style           = STYLE_SOLID;                                  // R2
input ENUM_LINE_STYLE         InpR3Style           = STYLE_SOLID;                                  // R3
input ENUM_LINE_STYLE         InpR4Style           = STYLE_SOLID;                                  // R4
input string                  InpDesc5             = "*********** Line Width ***********";         // Description
input int                     InpPivotWidth        = 1;                                            // Pivot
input int                     InpS1Width           = 1;                                            // S1
input int                     InpS2Width           = 1;                                            // S2
input int                     InpS3Width           = 1;                                            // S3
input int                     InpS4Width           = 1;                                            // S4
input int                     InpR1Width           = 1;                                            // R1
input int                     InpR2Width           = 1;                                            // R2
input int                     InpR3Width           = 1;                                            // R3
input int                     InpR4Width           = 1;                                            // R4

// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};
interface IBarStream : public IStream
{
public:
   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close) = 0;

   virtual double GetOpen(const int period, double &open) = 0;
   virtual double GetHigh(const int period, double &high) = 0;
   virtual double GetLow(const int period, double &low) = 0;
   virtual double GetClose(const int period, double &close) = 0;
   
   virtual bool GetHighLow(const int period, double &high, double &low) = 0;

   virtual bool GetIsAscending(const int period, bool &res) = 0;

   virtual bool GetIsDescending(const int period, bool &res) = 0;

   virtual bool GetDate(const int period, datetime &dt) = 0;

   virtual int Size() = 0;

   virtual void Refresh() = 0;
};
class CustomTimeframeBarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _timeframeMult;
   
   datetime _dates[];
   double _open[];
   double _close[];
   double _high[];
   double _low[];
   int _size;
   int _references;
public:
   CustomTimeframeBarStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int timeframeMult)
   {
      _references = 1;
      _size = 0;
      _symbol = symbol;
      _timeframe = timeframe;
      _timeframeMult = timeframeMult;
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

   virtual bool GetValue(const int period, double &val)
   {
      if (period >= _size)
         return false;
      val = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (period >= _size)
         return false;
      dt = _dates[_size - 1 - period];
      return true;
   }

   virtual double GetOpen(const int period, double &open)
   {
      if (_size <= period)
         return false;
      open = _open[_size - 1 - period];
      return true;
   }

   virtual double GetHigh(const int period, double &high)
   {
      if (_size <= period)
         return false;
      high = _high[_size - 1 - period];
      return true;
   }

   virtual double GetLow(const int period, double &low)
   {
      if (_size <= period)
         return false;
      low = _low[_size - 1 - period];
      return true;
   }

   virtual double GetClose(const int period, double &close)
   {
      if (_size <= period)
         return false;
      close = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (period >= _size)
         return false;
      high = _high[_size - 1 - period];
      low = _low[_size - 1 - period];
      open = _open[_size - 1 - period];
      close = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      if (period >= _size)
         return false;
      high = _high[_size - 1 - period];
      low = _low[_size - 1 - period];
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      if (period >= _size)
         return false;
      res = _open[_size - 1 - period] < _close[_size - 1 - period];
      return true;
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      if (period >= _size)
         return false;
      res = _open[_size - 1 - period] > _close[_size - 1 - period];
      return true;
   }

   virtual int Size()
   {
      return _size;
   }

   virtual void Refresh()
   {
      int start = iBars(_symbol, _timeframe) - 1;
      if (_size > 0)
         start = iBarShift(_symbol, _timeframe, _dates[_size - 1]);

      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      for (int i = start; i >= 0; --i)
      {
         datetime barStart = (iTime(_symbol, _timeframe, i) / periodLength) * periodLength;
         if (_size == 0 || barStart != _dates[_size - 1])
         {
            ++_size;
            ArrayResize(_dates, _size);
            ArrayResize(_open, _size);
            ArrayResize(_high, _size);
            ArrayResize(_low, _size);
            ArrayResize(_close, _size);
            _dates[_size - 1] = barStart;
            _open[_size - 1] = iOpen(_symbol, _timeframe, i);
            _high[_size - 1] = iHigh(_symbol, _timeframe, i);
            _low[_size - 1] = iLow(_symbol, _timeframe, i);
         }
         else
         {
            _high[_size - 1] = MathMax(iHigh(_symbol, _timeframe, i), _high[_size - 1]);
            _low[_size - 1] = MathMin(iLow(_symbol, _timeframe, i), _low[_size - 1]);
         }
         _close[_size - 1] = iClose(_symbol, _timeframe, i);
         while (barStart == _dates[_size - 1] && i >= 0)
         {
            barStart = (iTime(_symbol, _timeframe, --i) / periodLength) * periodLength;
         }
      }
   }
};
//+------------------------------------------------------------------+
//| Global Variables                                                        |
//+------------------------------------------------------------------+
datetime StartTime,StopTime;
double   R1,R2,R3,R4,S1,S2,S3,S4,PP;
double   NextDayR1,NextDayR2,NextDayR3,NextDayR4,NextDayS1,NextDayS2,NextDayS3,NextDayS4,NextDayPP;
string   prefix=StringConcatenate(EnumToString(CalculationMode),"_",EnumToString(InpTimeframe),"_");
string   CalcTypeAbb;
bool     Status=true;
bool     IsChartLoaded=false;
int      CurrentCandleIndex=0;
int      PrevCandleIndex=1;
CustomTimeframeBarStream* stream;

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

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   Status=true;
   IsChartLoaded=false;
   if(Period()>InpTimeframe)
   {
      Alert("Loading failed, please set a higher timeframe.");
      Status=false;
   }
   stream = new CustomTimeframeBarStream(_Symbol, InpTimeframe, TimeframePeriods);
   IndicatorBuffers(9);
   SetIndexBuffer(0,PivotBuffer);
   SetIndexBuffer(1,S1Buffer);
   SetIndexBuffer(2,S2Buffer);
   SetIndexBuffer(3,S3Buffer);
   SetIndexBuffer(4,S4Buffer);
   SetIndexBuffer(5,R1Buffer);
   SetIndexBuffer(6,R2Buffer);
   SetIndexBuffer(7,R3Buffer);
   SetIndexBuffer(8,R4Buffer);
   SetIndexStyle(0,DRAW_LINE,InpPivotStyle,InpPivotWidth,InpPivotColor);
   SetIndexStyle(1,DRAW_LINE,InpS1Style,InpS1Width,InpS1Color);
   SetIndexStyle(2,DRAW_LINE,InpS2Style,InpS2Width,InpS2Color);
   SetIndexStyle(3,DRAW_LINE,InpS3Style,InpS3Width,InpS3Color);
   SetIndexStyle(4,DRAW_LINE,InpS4Style,InpS4Width,InpS4Color);
   SetIndexStyle(5,DRAW_LINE,InpR1Style,InpR1Width,InpR1Color);
   SetIndexStyle(6,DRAW_LINE,InpR2Style,InpR2Width,InpR2Color);
   SetIndexStyle(7,DRAW_LINE,InpR3Style,InpR3Width,InpR3Color);
   SetIndexStyle(8,DRAW_LINE,InpR4Style,InpR4Width,InpR4Color);
   IndicatorDigits(Digits);
   ArraySetAsSeries(S1Buffer,true);
   ArraySetAsSeries(S2Buffer,true);
   ArraySetAsSeries(S3Buffer,true);
   ArraySetAsSeries(S4Buffer,true);
   ArraySetAsSeries(R1Buffer,true);
   ArraySetAsSeries(R2Buffer,true);
   ArraySetAsSeries(R3Buffer,true);
   ArraySetAsSeries(R4Buffer,true);
   ArraySetAsSeries(PivotBuffer,true);
   ExtractCalculationType();
   SetIndexLabel(0,"Pivot ("+CalcTypeAbb+")");
   SetIndexLabel(1,"S1 ("+CalcTypeAbb+")");
   SetIndexLabel(2,"S2 ("+CalcTypeAbb+")");
   SetIndexLabel(3,"S3 ("+CalcTypeAbb+")");
   SetIndexLabel(4,"S4 ("+CalcTypeAbb+")");
   SetIndexLabel(5,"R1 ("+CalcTypeAbb+")");
   SetIndexLabel(6,"R2 ("+CalcTypeAbb+")");
   SetIndexLabel(7,"R3 ("+CalcTypeAbb+")");
   SetIndexLabel(8,"R4 ("+CalcTypeAbb+")");
   IndicatorName = GenerateIndicatorName("All Pivot Points");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete stream;
   stream = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}

int FindDateIndex(datetime dt, int start)
{
   for (int i = start; i < stream.Size(); ++i)
   {
      datetime date;
      if (!stream.GetDate(i, date))
         return -1;
      if (date <= dt)
         return i;
   }
   return -1;
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
   if (!Status)
      return 0;
   stream.Refresh();
   int limit;
   if (prev_calculated==0)
   {
      if (InpShowMode==SHOW_MODE_HISTORICAL && InpHistoricalBars!=0)
         limit=InpHistoricalBars;
      else
         limit=rates_total-1;
   }
   else
      limit=rates_total-prev_calculated+1;

   if(rates_total>prev_calculated)
   {
      if(!IsChartLoaded())  
         return prev_calculated;
      UpdateCandlesIndex();
      if (InpShowMode == SHOW_MODE_HISTORICAL)
      {
         if (CalculationMode == CALC_MODE_CAMARILLA)
         {
            int j=0;
            for(int i=0;i<limit;i++)
            {
               j = FindDateIndex(time[i], j);
               if (j == -1)
                  return prev_calculated;

               calculateHistCamarilla(i, j + 1);
            }
            calculateCamarilla();
         }
         else if(CalculationMode==CALC_MODE_CLASSIC1)
         {
            int j=0;
            for(int i=0;i<limit;i++)
            {
               j = FindDateIndex(time[i], j);
               if (j == -1)
                  return prev_calculated;
               calculateHistClassic1(i,j+1);
            }
            calculateClassic1();
         }
         else if(CalculationMode==CALC_MODE_CLASSIC2)
         {
            int j=0;
            for(int i=0;i<limit;i++)
            {
               j = FindDateIndex(time[i], j);
               if (j == -1)
                  return prev_calculated;
               calculateHistClassic2(i,j+1);
            }
            calculateClassic2();
         }
         else if(CalculationMode==CALC_MODE_WOODIE)
         {
            int j=0;
            for(int i=0;i<limit;i++)
            {
               j = FindDateIndex(time[i], j);
               if (j == -1)
                  return prev_calculated;
               calculateHistWoodie(i,j+1);
            }
            calculateWoodie();
         }
         else if(CalculationMode==CALC_MODE_FIBONACCI)
         {
            int j=0;
            for(int i=0;i<limit;i++)
            {
               j = FindDateIndex(time[i], j);
               if (j == -1)
                  return prev_calculated;
               calculateHistFibonacci(i,j+1);
            }
            calculateFibonacci();
         }
         else if(CalculationMode==CALC_MODE_FLOOR)
         {
            int j=0;
            for(int i=0;i<limit;i++)
            {
               j = FindDateIndex(time[i], j);
               if (j == -1)
                  return prev_calculated;
               calculateHistFloor(i,j+1);
            }
            calculateFloor();
         }
         else if(CalculationMode==CALC_MODE_FIBONACCI_RETRACEMENT)
         {
            int j=0;
            for(int i=0;i<limit;i++)
            {
               j = FindDateIndex(time[i], j);
               if (j == -1)
                  return prev_calculated;
               calculateHistFibonacciRet(i,j+1);
            }
            calculateFibonacciRet();
         }
      }
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         if(CalculationMode==CALC_MODE_CLASSIC1)                  calculateClassic1();
         if(CalculationMode==CALC_MODE_CLASSIC2)                  calculateClassic2();
         if(CalculationMode==CALC_MODE_CAMARILLA)                 calculateCamarilla();
         if(CalculationMode==CALC_MODE_WOODIE)                    calculateWoodie();
         if(CalculationMode==CALC_MODE_FIBONACCI)                 calculateFibonacci();
         if(CalculationMode==CALC_MODE_FLOOR)                     calculateFloor();
         if(CalculationMode==CALC_MODE_FIBONACCI_RETRACEMENT)     calculateFibonacciRet();
      }
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
void calculateHistFibonacciRet(int index,int barIndex)
{
   double prevOpen, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(barIndex, prevOpen, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   PivotBuffer[index]=NormalizeDouble(prevLow+(0.50*prevRange),Digits);
   R1Buffer[index] = NormalizeDouble(prevLow +(0.618 * prevRange),Digits);
   R2Buffer[index] = NormalizeDouble(prevLow +(0.786 * prevRange),Digits);
   R3Buffer[index] = NormalizeDouble(prevHigh,Digits);
   R4Buffer[index] = NormalizeDouble(prevLow +(1.382 * prevRange),Digits);

   S1Buffer[index] = NormalizeDouble(prevLow +(0.382 * prevRange),Digits);
   S2Buffer[index] = NormalizeDouble(prevLow +(0.236 * prevRange),Digits);
   S3Buffer[index] = NormalizeDouble(prevLow,Digits);
   S4Buffer[index] = NormalizeDouble(prevLow -(0.382 * prevRange),Digits);
   checkVisiblity(index);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateFibonacciRet()
{
   double open, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(1, open, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   PP = NormalizeDouble(prevLow +(0.50 * prevRange),Digits);
   R1 = NormalizeDouble(prevLow +(0.618 * prevRange),Digits);
   R2 = NormalizeDouble(prevLow +(0.786 * prevRange),Digits);
   R3 = NormalizeDouble(prevHigh,Digits);
   R4 = NormalizeDouble(prevLow +(1.382 * prevRange),Digits);
   S1 = NormalizeDouble(prevLow +(0.382 * prevRange),Digits);
   S2 = NormalizeDouble(prevLow +(0.236 * prevRange),Digits);
   S3 = NormalizeDouble(prevLow,Digits);
   S4 = NormalizeDouble(prevLow -(0.382 * prevRange),Digits);
   DrawOnChart();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateHistFloor(int index,int barIndex)
{
   double open, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(barIndex, open, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   PivotBuffer[index]=NormalizeDouble((prevHigh+prevLow+prevClose)/3,Digits);
   R1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevLow,Digits);
   S1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevHigh,Digits);
   R2Buffer[index] = NormalizeDouble(PivotBuffer[index] + prevHigh - prevLow,Digits);
   S2Buffer[index] = NormalizeDouble(PivotBuffer[index] - prevHigh + prevLow,Digits);
   R3Buffer[index] = NormalizeDouble(R1Buffer[index] + (prevHigh-prevLow),Digits);
   S3Buffer[index] = NormalizeDouble(prevLow - 2 * (prevHigh-PivotBuffer[index]),Digits);
   checkVisiblity(index);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateFloor()
{
   double open, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(PrevCandleIndex, open, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   PP = NormalizeDouble((prevHigh+prevLow+prevClose)/3,Digits);
   R1 = NormalizeDouble((PP * 2)-prevLow,Digits);
   S1 = NormalizeDouble((PP * 2)-prevHigh,Digits);
   R2 = NormalizeDouble(PP + prevHigh - prevLow,Digits);
   S2 = NormalizeDouble(PP - prevHigh + prevLow,Digits);
   R3 = NormalizeDouble(R1 + (prevHigh-prevLow),Digits);
   S3 = NormalizeDouble(prevLow - 2 * (prevHigh-PP),Digits);
   DrawOnChart();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateHistFibonacci(int index,int barIndex)
{
   double prevOpen, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(barIndex, prevOpen, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   PivotBuffer[index]=NormalizeDouble((prevHigh+prevLow+prevClose)/3,Digits);
   R1Buffer[index] = NormalizeDouble(PivotBuffer[index] + ((InpFibR1S1/100) * (prevHigh - prevLow)),Digits);
   R2Buffer[index] = NormalizeDouble(PivotBuffer[index] + ((InpFibR2S2/100) * (prevHigh - prevLow)),Digits);
   R3Buffer[index] = NormalizeDouble(PivotBuffer[index] + ((InpFibR3S3/100) * (prevHigh - prevLow)),Digits);
   R4Buffer[index] = NormalizeDouble(PivotBuffer[index] + ((InpFibR4S4/100) * (prevHigh - prevLow)),Digits);
   S1Buffer[index] = NormalizeDouble(PivotBuffer[index] - ((InpFibR1S1/100) * (prevHigh - prevLow)),Digits);
   S2Buffer[index] = NormalizeDouble(PivotBuffer[index] - ((InpFibR2S2/100) * (prevHigh - prevLow)),Digits);
   S3Buffer[index] = NormalizeDouble(PivotBuffer[index] - ((InpFibR3S3/100) * (prevHigh - prevLow)),Digits);
   S4Buffer[index] = NormalizeDouble(PivotBuffer[index] - ((InpFibR4S4/100) * (prevHigh - prevLow)),Digits);
   checkVisiblity(index);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateFibonacci()
{
   double open, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(PrevCandleIndex, open, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   PP = NormalizeDouble((prevHigh+prevLow+prevClose)/3,Digits);
   R1 = NormalizeDouble(PP + ((InpFibR1S1/100) * (prevHigh - prevLow)),Digits);
   R2 = NormalizeDouble(PP + ((InpFibR2S2/100) * (prevHigh - prevLow)),Digits);
   R3 = NormalizeDouble(PP + ((InpFibR3S3/100) * (prevHigh - prevLow)),Digits);
   R4 = NormalizeDouble(PP + ((InpFibR4S4/100) * (prevHigh - prevLow)),Digits);
   S1 = NormalizeDouble(PP - ((InpFibR1S1/100) * (prevHigh - prevLow)),Digits);
   S2 = NormalizeDouble(PP - ((InpFibR2S2/100) * (prevHigh - prevLow)),Digits);
   S3 = NormalizeDouble(PP - ((InpFibR3S3/100) * (prevHigh - prevLow)),Digits);
   S4 = NormalizeDouble(PP - ((InpFibR4S4/100) * (prevHigh - prevLow)),Digits);
   DrawOnChart();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateHistCamarilla(int index,int barIndex)
{
   double prevOpen, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(barIndex, prevOpen, prevHigh, prevLow, prevClose))
      return;
   double camRange = prevHigh - prevLow;
   R1Buffer[index] = NormalizeDouble(((1.1 / 12) * camRange) + prevClose,Digits);
   R2Buffer[index] = NormalizeDouble(((1.1 / 6) * camRange) + prevClose,Digits);
   R3Buffer[index] = NormalizeDouble(((1.1 / 4) * camRange) + prevClose,Digits);
   R4Buffer[index] = NormalizeDouble(((1.1 / 2) * camRange) + prevClose,Digits);
   S1Buffer[index] = NormalizeDouble(prevClose - ((1.1 / 12) * camRange),Digits);
   S2Buffer[index] = NormalizeDouble(prevClose - ((1.1 / 6) * camRange),Digits);
   S3Buffer[index] = NormalizeDouble(prevClose - ((1.1 / 4) * camRange),Digits);
   S4Buffer[index] = NormalizeDouble(prevClose - ((1.1 / 2) * camRange),Digits);
   PivotBuffer[index]=NormalizeDouble((R1Buffer[index]+S1Buffer[index])/2,Digits);
   checkVisiblity(index);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateHistClassic1(int index,int barIndex)
{
   double prevOpen, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(barIndex, prevOpen, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   PivotBuffer[index]=NormalizeDouble((prevHigh+prevLow+prevClose)/3,Digits);
   R1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevLow,Digits);
   R2Buffer[index] = NormalizeDouble(PivotBuffer[index] + prevRange,Digits);
   R3Buffer[index] = NormalizeDouble(R2Buffer[index] + prevRange,Digits);
   R4Buffer[index] = NormalizeDouble(R3Buffer[index] + prevRange,Digits);
   S1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevHigh,Digits);
   S2Buffer[index] = NormalizeDouble(PivotBuffer[index] - prevRange,Digits);
   S3Buffer[index] = NormalizeDouble(S2Buffer[index] - prevRange,Digits);
   S4Buffer[index] = NormalizeDouble(S3Buffer[index] - prevRange,Digits);
   checkVisiblity(index);
}
void calculateHistClassic2(int index,int barIndex)
{
   double prevOpen, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(barIndex, prevOpen, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   PivotBuffer[index]=NormalizeDouble((prevHigh+prevLow+prevClose+prevOpen)/4,Digits);
   R1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevLow,Digits);
   R2Buffer[index] = NormalizeDouble(PivotBuffer[index] + prevRange,Digits);
   R3Buffer[index] = NormalizeDouble(PivotBuffer[index] + (prevRange*2),Digits);
   R4Buffer[index] = NormalizeDouble(PivotBuffer[index] + (prevRange*3),Digits);
   S1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevHigh,Digits);
   S2Buffer[index] = NormalizeDouble(PivotBuffer[index] - prevRange,Digits);
   S3Buffer[index] = NormalizeDouble(PivotBuffer[index] - (prevRange*2),Digits);
   S4Buffer[index] = NormalizeDouble(PivotBuffer[index] - (prevRange*3),Digits);
   checkVisiblity(index);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateHistWoodie(int index,int barIndex)
{
   double prevOpen, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(barIndex, prevOpen, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   double todayOpen;
   if (!stream.GetOpen(barIndex - 1, todayOpen))
      return;
   PivotBuffer[index]=NormalizeDouble((prevHigh+prevLow+(todayOpen*2))/4,Digits);
   R1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevLow,Digits);
   R2Buffer[index] = NormalizeDouble(PivotBuffer[index] + prevRange,Digits);
   R3Buffer[index] = NormalizeDouble(prevHigh + 2*(PivotBuffer[index]-prevLow),Digits);
   R4Buffer[index] = NormalizeDouble(R3Buffer[index] + prevRange,Digits);
   S1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevHigh,Digits);
   S2Buffer[index] = NormalizeDouble(PivotBuffer[index] - prevRange,Digits);
   S3Buffer[index] = NormalizeDouble(prevLow - 2*(prevHigh - PivotBuffer[index]),Digits);
   S4Buffer[index] = NormalizeDouble(S3Buffer[index] - prevRange,Digits);
   checkVisiblity(index);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateWoodie()
{
   double open, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(PrevCandleIndex, open, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   double todayOpen;
   if (!stream.GetOpen(CurrentCandleIndex, todayOpen))
      return;
   PP = NormalizeDouble((prevHigh+prevLow+(todayOpen*2))/4,Digits);
   R1 = NormalizeDouble((PP * 2)-prevLow,Digits);
   R2 = NormalizeDouble(PP + prevRange,Digits);
   R3 = NormalizeDouble(prevHigh + 2*(PP-prevLow),Digits);
   R4 = NormalizeDouble(R3 + prevRange,Digits);
   S1 = NormalizeDouble((PP * 2)-prevHigh,Digits);
   S2 = NormalizeDouble(PP - prevRange,Digits);
   S3 = NormalizeDouble(prevLow - 2*(prevHigh - PP),Digits);
   S4 = NormalizeDouble(S3 - prevRange,Digits);
   DrawOnChart();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateClassic1()
{
   double open, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(PrevCandleIndex, open, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   PP = NormalizeDouble((prevHigh+prevLow+prevClose)/3,Digits);
   R1 = NormalizeDouble((PP * 2)-prevLow,Digits);
   R2 = NormalizeDouble(PP + prevRange,Digits);
   R3 = NormalizeDouble(R2 + prevRange,Digits);
   R4 = NormalizeDouble(R3 + prevRange,Digits);
   S1 = NormalizeDouble((PP * 2)-prevHigh,Digits);
   S2 = NormalizeDouble(PP - prevRange,Digits);
   S3 = NormalizeDouble(S2 - prevRange,Digits);
   S4 = NormalizeDouble(S3 - prevRange,Digits);
   DrawOnChart();
}
void calculateClassic2()
{
   double prevOpen, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(PrevCandleIndex, prevOpen, prevHigh, prevLow, prevClose))
      return;
   double prevRange = prevHigh - prevLow;
   PP = NormalizeDouble((prevHigh+prevLow+prevClose+prevOpen)/4,Digits);
   R1 = NormalizeDouble((PP * 2)-prevLow,Digits);
   R2 = NormalizeDouble(PP + prevRange,Digits);
   R3 = NormalizeDouble(PP + (prevRange*2),Digits);
   R4 = NormalizeDouble(PP + (prevRange*3),Digits);
   S1 = NormalizeDouble((PP * 2)-prevHigh,Digits);
   S2 = NormalizeDouble(PP - prevRange,Digits);
   S3 = NormalizeDouble(PP - (prevRange*2),Digits);
   S4 = NormalizeDouble(PP - (prevRange*3),Digits);
   DrawOnChart();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateCamarilla()
{
   double prevOpen, prevHigh, prevLow, prevClose;
   if (!stream.GetValues(PrevCandleIndex, prevOpen, prevHigh, prevLow, prevClose))
      return;
   double camRange = prevHigh - prevLow;
   double todayOpen;
   if (!stream.GetOpen(CurrentCandleIndex, todayOpen))
      return;
   R1 = NormalizeDouble(((1.1 / 12) * camRange) + prevClose,Digits);
   R2 = NormalizeDouble(((1.1 / 6) * camRange) + prevClose,Digits);
   R3 = NormalizeDouble(((1.1 / 4) * camRange) + prevClose,Digits);
   R4 = NormalizeDouble(((1.1 / 2) * camRange) + prevClose,Digits);
   S1 = NormalizeDouble(prevClose - ((1.1 / 12) * camRange),Digits);
   S2 = NormalizeDouble(prevClose - ((1.1 / 6) * camRange),Digits);
   S3 = NormalizeDouble(prevClose - ((1.1 / 4) * camRange),Digits);
   S4 = NormalizeDouble(prevClose - ((1.1 / 2) * camRange),Digits);
   PP = NormalizeDouble((R4+S4)/2,Digits);
   DrawOnChart();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawOnChart()
{
   StartTime=iTime(Symbol(),InpTimeframe,0);
   datetime OneCandleGap=iTime(Symbol(),InpTimeframe,0)-iTime(Symbol(),InpTimeframe,1);
   datetime OneCandle=Time[0]-Time[1];
   while(TimeDayOfWeek(StartTime)==0 || TimeDayOfWeek(StartTime)==SATURDAY || (!InpIncludeSundays && TimeDayOfWeek(StartTime)==SUNDAY))
   {
      StartTime=StartTime+(24*60*60);
   }
   MqlDateTime TimeStruct;
   TimeToStruct(StartTime,TimeStruct);
   if(InpTimeframe==PERIOD_M1)
   {
      StopTime= StartTime+(1*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_M5)
   {
      StopTime= StartTime+(5*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_M15)
   {
      StopTime= StartTime+(15*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_M30)
   {
      StopTime= StartTime+(30*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_H1)
   {
      StopTime= StartTime+(60*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_H4)
   {
      StopTime= StartTime+(4*60*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_D1)
   {
      StopTime = StartTime + (24*60*60);
      StopTime = StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_W1)
   {
      StopTime= StartTime+(7*24*60*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_MN1)
   {
      TimeStruct.mon+=1;
      StopTime= StructToTime(TimeStruct);
      StopTime=StopTime-OneCandle;
   }
   if(InpShowR1==true)
   {
      DrawTrendLine(0,"R1",InpR1Color,InpR1Style,InpR1Width,StartTime,StopTime,R1,R1,"R1 ("+CalcTypeAbb+")");
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         R1Buffer[2]=EMPTY_VALUE;
         R1Buffer[1]=R1;
      }
   }
   if(InpShowR2==true)
   {
      DrawTrendLine(0,"R2",InpR2Color,InpR2Style,InpR2Width,StartTime,StopTime,R2,R2,"R2 ("+CalcTypeAbb+")");
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         R2Buffer[2]=EMPTY_VALUE;
         R2Buffer[1]=R2;
      }
   }
   if(InpShowR3==true)
   {
      DrawTrendLine(0,"R3",InpR3Color,InpR3Style,InpR3Width,StartTime,StopTime,R3,R3,"R3 ("+CalcTypeAbb+")");
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         R3Buffer[2]=EMPTY_VALUE;
         R3Buffer[1]=R3;
      }
   }
   if(InpShowR4==true)
   {
      DrawTrendLine(0,"R4",InpR4Color,InpR4Style,InpR4Width,StartTime,StopTime,R4,R4,"R4 ("+CalcTypeAbb+")");
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         R4Buffer[2]=EMPTY_VALUE;
         R4Buffer[1]=R4;
      }
   }
   if(InpShowS1==true)
   {
      DrawTrendLine(0,"S1",InpS1Color,InpS1Style,InpS1Width,StartTime,StopTime,S1,S1,"S1 ("+CalcTypeAbb+")");
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         S1Buffer[2]=EMPTY_VALUE;
         S1Buffer[1]=S1;
      }
   }
   if(InpShowS2==true)
   {
      DrawTrendLine(0,"S2",InpS2Color,InpS2Style,InpS2Width,StartTime,StopTime,S2,S2,"S2 ("+CalcTypeAbb+")");
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         S2Buffer[2]=EMPTY_VALUE;
         S2Buffer[1]=S2;
      }
   }
   if(InpShowS3==true)
   {
      DrawTrendLine(0,"S3",InpS3Color,InpS3Style,InpS3Width,StartTime,StopTime,S3,S3,"S3 ("+CalcTypeAbb+")");
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         S3Buffer[2]=EMPTY_VALUE;
         S3Buffer[1]=S3;
      }
   }
   if(InpShowS4==true)
   {
      DrawTrendLine(0,"S4",InpS4Color,InpS4Style,InpS4Width,StartTime,StopTime,S4,S4,"S4 ("+CalcTypeAbb+")");
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         S4Buffer[2]=EMPTY_VALUE;
         S4Buffer[1]=S4;
      }
   }
   if(InpShowPivot==true)
   {
      DrawTrendLine(0,"Pivot",InpPivotColor,InpPivotStyle,InpPivotWidth,StartTime,StopTime,PP,PP,"P ("+CalcTypeAbb+")");
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         PivotBuffer[2]=EMPTY_VALUE;
         PivotBuffer[1]=PP;
      }
   }
   if(InpShowLabels)
   {
      if(InpShowR1) DrawLabel(0,"LR1","R1",clrGray,R1,StartTime,"R1 ("+CalcTypeAbb+")");
      if(InpShowR2) DrawLabel(0,"LR2","R2",clrGray,R2,StartTime,"R2 ("+CalcTypeAbb+")");
      if(InpShowR3) DrawLabel(0,"LR3","R3",clrGray,R3,StartTime,"R3 ("+CalcTypeAbb+")");
      if(InpShowR4) DrawLabel(0,"LR4","R4",clrGray,R4,StartTime,"R4 ("+CalcTypeAbb+")");
      if(InpShowS1) DrawLabel(0,"LS1","S1",clrGray,S1,StartTime,"S1 ("+CalcTypeAbb+")");
      if(InpShowS2) DrawLabel(0,"LS2","S2",clrGray,S2,StartTime,"S2 ("+CalcTypeAbb+")");
      if(InpShowS3) DrawLabel(0,"LS3","S3",clrGray,S3,StartTime,"S3 ("+CalcTypeAbb+")");
      if(InpShowS4) DrawLabel(0,"LS4","S4",clrGray,S4,StartTime,"S4 ("+CalcTypeAbb+")");
      if(InpShowPivot) DrawLabel(0,"LPivot","P",clrGray,PP,StartTime,"P ("+CalcTypeAbb+")");
   }
   if(InpShowPriceTags)
   {
      datetime PriceTagTime=StopTime;
      if(InpShowR1) DrawPriceTag("R1",PriceTagTime,R1,InpR1Color,InpR1Style,InpR1Width);
      if(InpShowR2) DrawPriceTag("R2",PriceTagTime,R2,InpR2Color,InpR2Style,InpR2Width);
      if(InpShowR3) DrawPriceTag("R3",PriceTagTime,R3,InpR3Color,InpR3Style,InpR3Width);
      if(InpShowR4) DrawPriceTag("R4",PriceTagTime,R4,InpR4Color,InpR4Style,InpR4Width);
      if(InpShowS1) DrawPriceTag("S1",PriceTagTime,S1,InpS1Color,InpS1Style,InpS1Width);
      if(InpShowS2) DrawPriceTag("S2",PriceTagTime,S2,InpS2Color,InpS2Style,InpS2Width);
      if(InpShowS3) DrawPriceTag("S3",PriceTagTime,S3,InpS3Color,InpS3Style,InpS3Width);
      if(InpShowS4) DrawPriceTag("S4",PriceTagTime,S4,InpS4Color,InpS4Style,InpS4Width);
      if(InpShowPivot) DrawPriceTag("Pivot",PriceTagTime,PP,InpPivotColor,InpPivotStyle,InpPivotWidth);
   }
   ChartRedraw(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void checkVisiblity(int index)
{
   if(InpShowR1==false) R1Buffer[index]=0;
   if(InpShowR2==false) R2Buffer[index]=0;
   if(InpShowR3==false) R3Buffer[index]=0;
   if(InpShowR4==false) R4Buffer[index]=0;
   if(InpShowS1==false) S1Buffer[index]=0;
   if(InpShowS2==false) S2Buffer[index]=0;
   if(InpShowS3==false) S3Buffer[index]=0;
   if(InpShowS4==false) S4Buffer[index]=0;
   if(InpShowPivot==false) PivotBuffer[index]=0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTrendLine(long chart_ID,string name,color trendColor,ENUM_LINE_STYLE lineStyle,int lineWidth,datetime timeStart,datetime timeEnd,double StartPrice,double StopPrice,string tooltip="")
{
   name=prefix+name;
   if(ObjectFind(0,IndicatorObjPrefix + name)<0)
   {
      ObjectCreate(chart_ID,IndicatorObjPrefix + name,OBJ_TREND,0,timeStart,StartPrice,timeEnd,StopPrice);
   }
   else
   {
      ObjectSetDouble(chart_ID,IndicatorObjPrefix + name,OBJPROP_PRICE1,StartPrice);
      ObjectSetDouble(chart_ID,IndicatorObjPrefix + name,OBJPROP_PRICE2,StopPrice);
      ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_TIME1,timeStart);
      ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_TIME2,timeEnd);
      return;
   }
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_COLOR,trendColor);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_STYLE,lineStyle);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_WIDTH,lineWidth);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_HIDDEN,true);
   ObjectSetString(chart_ID,IndicatorObjPrefix + name,OBJPROP_TOOLTIP,tooltip);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_ZORDER,0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLabel(long chart_ID,string name,string text,color labelColor,double price,datetime time,string tooltip="")
{
   name=prefix+name;
   if(ObjectFind(0,IndicatorObjPrefix + name)<0)
   {
      ObjectCreate(chart_ID,IndicatorObjPrefix + name,OBJ_TEXT,0,time,price);
   }
   else
   {
      ObjectSetDouble(chart_ID,IndicatorObjPrefix + name,OBJPROP_PRICE1,price);
      ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_TIME1,time);
   }
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetString(chart_ID,IndicatorObjPrefix + name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,IndicatorObjPrefix + name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_FONTSIZE,10);
   ObjectSetDouble(chart_ID,IndicatorObjPrefix + name,OBJPROP_ANGLE,0.0);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_COLOR,labelColor);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_HIDDEN,true);
   ObjectSetString(chart_ID,IndicatorObjPrefix + name,OBJPROP_TOOLTIP,tooltip);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_ZORDER,0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExtractCalculationType()
{
   switch(CalculationMode)
   {
      case CALC_MODE_CLASSIC1:
         CalcTypeAbb="Classic1";
         break;
      case CALC_MODE_CLASSIC2:
         CalcTypeAbb="Classic2";
         break;
      case CALC_MODE_CAMARILLA:
         CalcTypeAbb="Cam";
         break;
      case CALC_MODE_FIBONACCI:
         CalcTypeAbb="Fib";
         break;
      case CALC_MODE_FIBONACCI_RETRACEMENT:
         CalcTypeAbb="FibR";
         break;
      case CALC_MODE_FLOOR:
         CalcTypeAbb="Floor";
         break;
      case CALC_MODE_WOODIE:
         CalcTypeAbb="Woodie";
         break;
      default:
         CalcTypeAbb="";
         break;
   }
   CalcTypeAbb+=" "+FriendlyTimeframeName(InpTimeframe);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FriendlyTimeframeName(int _period)
{
   if(_period==1)  return "1Minute";
   if(_period==5)  return "5Minutes";
   if(_period==15)  return "15Minutes";
   if(_period==30)  return "30Minutes";
   if(_period==60)  return "1Hour";
   if(_period==240)  return "4Hour";
   if(_period==1440)  return "Daily";
   if(_period==10080)  return "Weekly";
   if(_period==43200)  return "Monthly";
   return "";
}
//+------------------------------------------------------------------+
void DrawPriceTag(string name,datetime time,double price,color clr,ENUM_LINE_STYLE style,int width)
{
   name=prefix+"PriceTag_"+name;
   int chart_ID=0;
   if(!ObjectCreate(chart_ID,IndicatorObjPrefix + name,OBJ_ARROW_RIGHT_PRICE,0,time,price))
   {
      ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_TIME,time);
      ObjectSetDouble(chart_ID,IndicatorObjPrefix + name,OBJPROP_PRICE,price);
   }
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chart_ID,IndicatorObjPrefix + name,OBJPROP_ZORDER,0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsChartLoaded()
{
   if(!IsChartLoaded)
   {
      double testArray[];
      if(CopyClose(_Symbol,InpTimeframe,TimeCurrent(),2,testArray)<2)
      {
         Print("Loading ",_Symbol," chart failed...");
         IsChartLoaded=false;
         return false;
      }
      else
      {
         IsChartLoaded=true;
         Print(_Symbol," chart loaded successfully!");
      }
   }
   return true;
}
//+------------------------------------------------------------------+
void UpdateCandlesIndex()
{
   int i=0;
   CurrentCandleIndex=i;
   while(TimeDayOfWeek(Time[i])==SATURDAY || (!InpIncludeSundays && TimeDayOfWeek(Time[i])==SUNDAY))
   {
      i++;
      CurrentCandleIndex=i;
   }

   i=CurrentCandleIndex+1;
   PrevCandleIndex=i;
   while(TimeDayOfWeek(Time[i])==SATURDAY || (!InpIncludeSundays && TimeDayOfWeek(Time[i])==SUNDAY))
   {
      i++;
      PrevCandleIndex=i;
   }
}
//+------------------------------------------------------------------+
