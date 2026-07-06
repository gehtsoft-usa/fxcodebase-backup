// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67334

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
#property version   "1.4"
#property strict

#property indicator_chart_window

enum ShowMode
{
   ShowInPips, // In pips
   ShowInPoints // In points
};

extern int ADRPeriod = 7; // ADR length
extern int ADMPeriod = 7; // ADM length
extern ShowMode show_mode = ShowInPoints; // Values unit
extern ENUM_BASE_CORNER DisplayLocation = CORNER_RIGHT_UPPER; //Display location
extern int x_shift = 0; // X shift
extern int y_shift = 0; // Y shift
extern color labelColor = Red; // Label color
input ENUM_TIMEFRAMES adm_period = PERIOD_CURRENT; // ADM period

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

interface IStream
{
public:
   virtual bool GetValue(const int period, double &val) = 0;
};

class RangeStream : public IStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   RangeStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   virtual bool GetValue(const int period, double &val)
   {
      val = iHigh(_symbol, _timeframe, period) - iLow(_symbol, _timeframe, period);
      return true;
   }
};

class SmaOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _buffer[];
public:
   SmaOnStream(IStream *source, const int length)
   {
      _source = source;
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
      if (period > totalBars - _length)
         return false;

      int bufferIndex = totalBars - 1 - period;
      if (period > totalBars - _length && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         double current;
         double last;
         if (!_source.GetValue(period, current) || !_source.GetValue(period + _length, last))
            return false;
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + (current - last) / _length;
      }
      else 
      {
         _buffer[bufferIndex] = EMPTY_VALUE; 
         double summ = 0;
         for(int i = 0; i < _length; i++) 
         {
            double current;
            if (!_source.GetValue(period + i, current))
               return false;

           summ += current;
         }
         _buffer[bufferIndex] = summ / _length;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};

// Instrument info v.1.2
class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digits;
   double _tickSize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = MarketInfo(symbol, MODE_POINT);
      _digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      _mult = _digits == 3 || _digits == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
   }
   
   static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
   double GetBid() { return GetBid(_symbol); }
   static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
   double GetAsk() { return GetAsk(_symbol); }
   double GetPipSize() { return _pipSize; }
   double GetPointSize() { return _point; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathCeil(rate / _tickSize + 0.5) * _tickSize, _digits);
   }
};

class MoveStream : public IStream
{
   string _symbol;
   ENUM_TIMEFRAMES _baseTimeframe;
   ENUM_TIMEFRAMES _moveTimeframe;
public:
   MoveStream(const string symbol, const ENUM_TIMEFRAMES baseTimeframe, const ENUM_TIMEFRAMES moveTimeframe)
   {
      _symbol = symbol;
      _baseTimeframe = baseTimeframe;
      _moveTimeframe = moveTimeframe;
   }

   virtual bool GetValue(const int period, double &val)
   {
      int startIndex = iBarShift(_symbol, _moveTimeframe, iTime(_symbol, _baseTimeframe, period));
      int endIndex = period == 0 ? 0 : iBarShift(_symbol, _moveTimeframe, iTime(_symbol, _baseTimeframe, period - 1));
      val = 0;
      for (int i = startIndex; i >= endIndex; --i)
      {
         val += MathAbs(iClose(_symbol, _moveTimeframe, i) - iOpen(_symbol, _moveTimeframe, i));
      }

      return true;
   }
};

IStream *dr;
IStream *adr;
IStream *dm;
IStream *adm;
InstrumentInfo *instr;

int init()
{
   IndicatorName = GenerateIndicatorName("DailyRangeMovementSummary");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   dr = new RangeStream(_Symbol, PERIOD_D1);
   adr = new SmaOnStream(dr, ADRPeriod);
   instr = new InstrumentInfo(_Symbol);
   dm = new MoveStream(_Symbol, adm_period, PERIOD_D1);
   adm = new SmaOnStream(dm, ADMPeriod);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete dr;
   delete adr;
   delete dm;
   delete adm;
   delete instr;
   return(0);
}

int start()
{
   double adrValue;
   if (!adr.GetValue(1, adrValue))
      return 0;
   double drValue;
   if (!dr.GetValue(0, drValue))
      return 0;

   double admValue;
   if (!adm.GetValue(1, admValue))
      return 0;
   double dmValue;
   if (!dm.GetValue(0, dmValue))
      return 0;

   double divider;
   int numbers;
   if (show_mode == ShowInPips)
   {
      divider = instr.GetPipSize();
      numbers = 1;
   }
   else
   {
      divider = instr.GetPointSize();
      numbers = 0;
   }

   string adrLabel = IndicatorObjPrefix + "adr";
   double adrPr = (drValue / adrValue) * 100;
   string adrText = "ADR: " + DoubleToStr(adrValue / divider, numbers) + " (" + IntegerToString((int)adrPr) + "%)";
   ObjectCreate(0, adrLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, adrLabel, OBJPROP_CORNER, DisplayLocation); 
   ObjectSetString(0, adrLabel, OBJPROP_TEXT, adrText); 
   ObjectSetString(0, adrLabel, OBJPROP_FONT, "Arial"); 
   ObjectSetInteger(0, adrLabel, OBJPROP_FONTSIZE, 8); 
   ObjectSetInteger(0, adrLabel, OBJPROP_COLOR, labelColor);

   string admLabel = IndicatorObjPrefix + "adm";
   double admPr = (dmValue / admValue) * 100;
   string admText = "ADM: " + DoubleToStr(admValue / divider, numbers) + " (" + IntegerToString((int)admPr) + "%)";
   ObjectCreate(0, admLabel, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, admLabel, OBJPROP_CORNER, DisplayLocation); 
   ObjectSetString(0, admLabel, OBJPROP_TEXT, admText); 
   ObjectSetString(0, admLabel, OBJPROP_FONT, "Arial"); 
   ObjectSetInteger(0, admLabel, OBJPROP_FONTSIZE, 8); 
   ObjectSetInteger(0, admLabel, OBJPROP_COLOR, labelColor);

   ObjectSetInteger(0, adrLabel, OBJPROP_XDISTANCE, x_shift);
   ObjectSetInteger(0, adrLabel, OBJPROP_YDISTANCE, y_shift);
   ObjectSetInteger(0, admLabel, OBJPROP_XDISTANCE, x_shift);
   ObjectSetInteger(0, admLabel, OBJPROP_YDISTANCE, y_shift + 20);

   switch (DisplayLocation)
   {
      case CORNER_LEFT_LOWER:
         ObjectSetInteger(0, adrLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER); 
         ObjectSetInteger(0, admLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER); 
         break;
      case CORNER_LEFT_UPPER:
         ObjectSetInteger(0, adrLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER); 
         ObjectSetInteger(0, admLabel, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER); 
         break;
      case CORNER_RIGHT_LOWER:
         ObjectSetInteger(0, adrLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER); 
         ObjectSetInteger(0, admLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER); 
         break;
      case CORNER_RIGHT_UPPER:
         ObjectSetInteger(0, adrLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER); 
         ObjectSetInteger(0, admLabel, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER); 
         break;
   }
   return 0;
}

