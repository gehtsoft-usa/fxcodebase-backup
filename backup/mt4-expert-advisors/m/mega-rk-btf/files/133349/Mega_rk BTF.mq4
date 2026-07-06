// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=27&t=69754
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
#property indicator_buffers 2

input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input color up_color = Lime; // Up color
input color down_color = LightGray; // Down color
input int    Period_HL = 21;
input int    Arr_otstup    = 0; 
input int    Arr_width     = 1;
input color  Arr_Up_col    = clrLime;
input color  Arr_Dn_col    = clrRed;

// Colored stream v3.0

#ifndef ColoredStream_IMP
#define ColoredStream_IMP

class ColoredStreamData
{
public:
   double Stream[];
};

// Abstract stream v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP
// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};
// Instrument info v.1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

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

   // Return < 0 when lot1 < lot2, > 0 when lot1 > lot2 and 0 owtherwise
   int CompareLots(double lot1, double lot2)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
      }
      int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
      int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
      int res = lotSteps1 - lotSteps2;
      return res;
   }
   
   static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
   double GetBid() { return GetBid(_symbol); }
   static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
   double GetAsk() { return GetAsk(_symbol); }
   static double GetPipSize(const string symbol)
   { 
      double point = MarketInfo(symbol, MODE_POINT);
      double digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      double mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPipSize() { return _pipSize; }
   double GetPointSize() { return _point; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double AddPips(const double rate, const double pips)
   {
      return RoundRate(rate + pips * _pipSize);
   }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits);
   }

   double RoundLots(const double lots)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return 0.0;
      }
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = GetMinLots();
      if (minVolume > lots)
      {
         return 0.0;
      }
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         return maxVolume;
      }
      return lots;
   }

   double NormalizeLots(const double lots)
   {
      return LimitLots(RoundLots(lots));
   }
};

#endif

class AStream : public IStream
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
   InstrumentInfo *_instrument;
   int _references;

   AStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _references = 1;
      _shift = 0.0;
      _symbol = symbol;
      _timeframe = timeframe;
      _instrument = new InstrumentInfo(_symbol);
   }

   ~AStream()
   {
      delete _instrument;
   }
public:
   void SetShift(const double shift)
   {
      _shift = shift;
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
};
#define AStream_IMP
#endif

class ColoredStream : public AStream
{
public:
   ColoredStreamData _streams[];
   double _data[];

   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data);
      SetIndexStyle(id + 0, DRAW_NONE);
      return id + 1;
   }

   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      SetIndexStyle(id + 0, lineType, lineStyle, width, clr);
      SetIndexBuffer(id + 0, _streams[size].Stream);
      if (label != "")
         SetIndexLabel(id + 0, label);
      return id + 1;
   }

   int GetColorIndex(int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].Stream[period] != EMPTY_VALUE)
            return i;
      }
      return -1;
   }

   void Set(double value, int period, int colorIndex)
   {
      _data[period] = value;
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Stream[period] = value;
            if (period + 1 < iBars(_symbol, _timeframe) && _streams[i].Stream[period + 1] == EMPTY_VALUE)
               _streams[i].Stream[period + 1] = _data[period + 1];   
         }
         else
            _streams[i].Stream[period] = EMPTY_VALUE;
      }
   }

   bool GetValue(const int period, double &val)
   {
      if (period >= iBars(_symbol, _timeframe))
      {
         return false;
      }
      val = _data[period];
      return _data[period] != EMPTY_VALUE;
   }
};

#endif

ColoredStream* line;
double G_ibuf_120[];
double G_ibuf_124[];
double Ld_36[];

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
   line = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   IndicatorName = GenerateIndicatorName("Mega_rk BTF");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(4);
   int id = 0;
   id = line.RegisterStream(id, up_color);
   id = line.RegisterStream(id, down_color);
   id = line.RegisterInternalStream(id);
   IndicatorDigits(Digits + 0);
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, Ld_36);
   return (0);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  
{
   delete line;
   line = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
} 

int start() 
{
   int minBars = 2;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      if (tf == PERIOD_CURRENT || tf == _Period)
      {
         double high_84 = High[iHighest(NULL, 0, MODE_HIGH, Period_HL, i)];
         double low_76 = Low[iLowest(NULL, 0, MODE_LOW, Period_HL, i)];
         double Ld_16 = (High[i] + Low[i]) / 2.0;
         double Ld_36_prev = Ld_36[i + 1] == EMPTY_VALUE ? 0 : Ld_36[i + 1];
         Ld_36[i] = 0.66 * ((Ld_16 - low_76) / (high_84 - low_76) - 0.5) + 0.67 * Ld_36_prev;
         double prev = line._data[i + 1] == EMPTY_VALUE ? 0 : line._data[i + 1];
         double val = MathLog((Ld_36[i] + 1.0) / (1 - Ld_36[i])) / 2.0 + prev / 2.0;
         line.Set(val, i, val > 0 ? 0 : 1);

         if (line._data[i] > 0.0 && line._data[i + 1] < 0.0)
         {
            arrows_wind(i,"Up",Arr_otstup ,233,Arr_Up_col,Arr_width,false);
         }
         else 
         {
            ObjectDelete(IndicatorObjPrefix+"Up"+TimeToStr(Time[i]));  
         }
         
         if (line._data[i + 1] < 0.0 && line._data[i + 2] > 0.0) 
         {
            arrows_wind(i,"Dn",Arr_otstup ,234,Arr_Dn_col,Arr_width,true);
         }
         else 
         {
            ObjectDelete(IndicatorObjPrefix + "Dn" + TimeToStr(Time[i]));  
         }
      }
      else
      {
         int index = iBarShift(_Symbol, tf, Time[i]);
         if (index < 0)
         {
            continue;
         }
         double val = iCustom(_Symbol, tf, "Mega_rk BTF", tf, Period_HL, 2, index);
         line.Set(val, i, val > 0 ? 0 : 1);

         if (line._data[i] > 0.0 && line._data[i + 1] < 0.0)
         {
            arrows_wind(i,"Up",Arr_otstup ,233,Arr_Up_col,Arr_width,false);
         }
         else 
         {
            ObjectDelete(IndicatorObjPrefix+"Up"+TimeToStr(Time[i]));  
         }
         
         if (line._data[i + 1] < 0.0 && line._data[i + 2] > 0.0) 
         {
            arrows_wind(i,"Dn",Arr_otstup ,234,Arr_Dn_col,Arr_width,true);
         }
         else 
         {
            ObjectDelete(IndicatorObjPrefix + "Dn" + TimeToStr(Time[i]));  
         }
      }
   }
   return (0);
}
//+------------------------------------------------------------------+ 
void arrows_wind(int k, string N,int ots,int Code,color clr, int ArrowSize,bool up)                 
{           
   string objName = IndicatorObjPrefix+N+TimeToStr(Time[k]);
   double gap = ots*Point;
   
   ObjectCreate(objName, OBJ_ARROW,0,Time[k],0);
   ObjectSet   (objName, OBJPROP_COLOR, clr);  
   ObjectSet   (objName, OBJPROP_ARROWCODE,Code);
   ObjectSet   (objName, OBJPROP_WIDTH,ArrowSize);  
  if (up)
    {
      ObjectSet(objName, OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      ObjectSet(objName,OBJPROP_PRICE1,High[k]+gap);
    }else{  
      ObjectSet(objName, OBJPROP_ANCHOR,ANCHOR_TOP);
      ObjectSet(objName,OBJPROP_PRICE1,Low[k]-gap);
    }
}