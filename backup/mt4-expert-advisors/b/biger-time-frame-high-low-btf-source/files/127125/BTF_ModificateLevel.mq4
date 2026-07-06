// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=63985


//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 20
#property strict
enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8, Quoter=9, Year=10 };
enum e_method{ Current=1, Previous = 2 };

enum DayOfWeek
{
   DayOfWeekSunday = 0, // Sunday
   DayOfWeekMonday = 1, // Monday
   DayOfWeekTuesday = 2, // Tuesday
   DayOfWeekWednesday = 3, // Wednesday
   DayOfWeekThursday = 4, // Thursday
   DayOfWeekFriday = 5, // Friday
   DayOfWeekSaturday = 6 // Saturday
};

input  int        magicID               = 1;
input  e_cycles   BTF                   = Daily;
input  e_method   Method                = Previous;
input int start_hour = 17; // D1/W1 start hour
input DayOfWeek week_start = DayOfWeekSunday; // W1 day start
extern float      Val_X                 = 0.25;  
extern int        Number_Of_BTF_Candles = 50;
extern bool       Show_Labels           = true;
extern bool       Draw_Cycles_Separator = true;
extern color      Open_Color            = clrDarkGray;
extern color      High_Color            = clrAqua;
extern color      Low_Color             = clrAqua;
extern color      Close_Color           = clrBlue;
extern color      KK_Color              = clrYellow;

extern color H2Color=clrChartreuse;
extern color H1Color=clrMagenta;

extern color OPColor=clrMagenta;
extern color L50Color=clrBlue;

extern color D1Color=clrMagenta;
extern color D2Color=clrRed;

///////////////////////////////////////////////////////////////////

extern int   Lines_Style           = 0;
extern int   Lines_Width           = 2;
extern color BTF_Separator         = clrDimGray;

int Periodo,Minutes;

double b_H10[], b_H9[], b_H8[], b_H7[], b_H6[], b_H5[], b_H4[], b_H3[], b_H2[], b_H1[],
       b_D10[], b_D9[], b_D8[], b_D7[], b_D6[], b_D5[], b_D4[], b_D3[], b_D2[], b_D1[];
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

class BarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _referenceCount;
public:
   BarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _referenceCount = 1;
      _symbol = symbol;
      _timeframe = timeframe;
   }
   virtual void AddRef()
   {
      ++_referenceCount;
   }
   virtual void Release()
   {
      --_referenceCount;
      if (_referenceCount == 0)
         delete &this;
   }

   virtual bool GetValue(const int period, double &val)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      val = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      dt = iTime(_symbol, _timeframe, period);
      return true;
   }

   virtual double GetOpen(const int period, double &open)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      return true;
   }

   virtual double GetHigh(const int period, double &high)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      return true;
   }

   virtual double GetLow(const int period, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual double GetClose(const int period, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      open = iOpen(_symbol, _timeframe, period);
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      close = iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      high = iHigh(_symbol, _timeframe, period);
      low = iLow(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      res = iOpen(_symbol, _timeframe, period) < iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      res = iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual void Refresh() { }
};

class ACustomBarStream : public IBarStream
{
protected:
   int _references;

   datetime _dates[];
   double _open[];
   double _close[];
   double _high[];
   double _low[];
   int _size;

   ACustomBarStream()
   {
      _size = 0;
      _references = 1;
   }
public:
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
};

class D1CustomHourBarStream : public ACustomBarStream
{
   string _symbol;
   int _hour;
public:
   D1CustomHourBarStream(const string symbol, int hour)
   {
      _symbol = symbol;
      _hour = hour;
   }

   virtual void Refresh()
   {
      int start = iBars(_symbol, PERIOD_H1) - 1;
      if (_size > 0)
         start = iBarShift(_symbol, PERIOD_H1, _dates[_size - 1]);

      int periodLength = (int)PERIOD_H1 * 24 * 60;
      for (int i = start; i >= 0; --i)
      {
         datetime barStart = (iTime(_symbol, PERIOD_H1, i) / periodLength) * periodLength + _hour * 3600;
         if (_size == 0 || barStart != _dates[_size - 1])
         {
            ++_size;
            ArrayResize(_dates, _size);
            ArrayResize(_open, _size);
            ArrayResize(_high, _size);
            ArrayResize(_low, _size);
            ArrayResize(_close, _size);
            _dates[_size - 1] = barStart;
            _open[_size - 1] = iOpen(_symbol, PERIOD_H1, i);
            _high[_size - 1] = iHigh(_symbol, PERIOD_H1, i);
            _low[_size - 1] = iLow(_symbol, PERIOD_H1, i);
         }
         else
         {
            _high[_size - 1] = MathMax(iHigh(_symbol, PERIOD_H1, i), _high[_size - 1]);
            _low[_size - 1] = MathMin(iLow(_symbol, PERIOD_H1, i), _low[_size - 1]);
         }
         _close[_size - 1] = iClose(_symbol, PERIOD_H1, i);
      }
   }
};

class W1CustomHourAndDayBarStream : public ACustomBarStream
{
   string _symbol;
   int _hour;
   int _day;
public:
   W1CustomHourAndDayBarStream(const string symbol, int hour, int day)
   {
      _symbol = symbol;
      _hour = hour;
      _day = day;
   }

   virtual void Refresh()
   {
      int start = iBars(_symbol, PERIOD_H1) - 1;
      if (_size > 0)
         start = iBarShift(_symbol, PERIOD_H1, _dates[_size - 1]);

      for (int i = start; i >= 0; --i)
      {
         datetime barStart = iTime(_symbol, PERIOD_H1, i);
         if (!RoundDate(barStart))
            continue;
         
         if (_size == 0 || barStart != _dates[_size - 1])
         {
            ++_size;
            ArrayResize(_dates, _size);
            ArrayResize(_open, _size);
            ArrayResize(_high, _size);
            ArrayResize(_low, _size);
            ArrayResize(_close, _size);
            _dates[_size - 1] = barStart;
            _open[_size - 1] = iOpen(_symbol, PERIOD_H1, i);
            _high[_size - 1] = iHigh(_symbol, PERIOD_H1, i);
            _low[_size - 1] = iLow(_symbol, PERIOD_H1, i);
         }
         else
         {
            _high[_size - 1] = MathMax(iHigh(_symbol, PERIOD_H1, i), _high[_size - 1]);
            _low[_size - 1] = MathMin(iLow(_symbol, PERIOD_H1, i), _low[_size - 1]);
         }
         _close[_size - 1] = iClose(_symbol, PERIOD_H1, i);
      }
   }
private:
   bool RoundDate(datetime& date)
   {
      int periodLength = (int)PERIOD_H1 * 24 * 60;
      date = (date / periodLength) * periodLength + _hour * 3600;
      MqlDateTime current_time;
      if (!TimeToStruct(date, current_time))
         return false;

      int daysPass = current_time.day_of_week - _day;
      if (daysPass < 0)
         daysPass += 7;
      date -= periodLength * daysPass;
      return true;
   }
};

class CustomTimeframeBarStream : public ACustomBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _timeframeMult;
public:
   CustomTimeframeBarStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int timeframeMult)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _timeframeMult = timeframeMult;
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
      }
   }
};
        
IBarStream* data;

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
   IndicatorBuffers(20);
   IndicatorDigits(Digits);
   IndicatorName = GenerateIndicatorName("Bigger TF Source");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   if (IsInvalidTimeframe()) 
      Alert("The Bigger TF Source selected for this Time Frame cannot be calculated");
   
   SetIndexLabel(0, "H10"); 
   SetIndexLabel(1, "H9"); 
   SetIndexLabel(2, "H8"); 
   SetIndexLabel(3, "H7"); 
   SetIndexLabel(4, "H6"); 
   SetIndexLabel(5, "H5"); 
   SetIndexLabel(6, "H4"); 
   SetIndexLabel(7, "H3"); 
   SetIndexLabel(8, "H2"); 
   SetIndexLabel(9, "H1"); 
   SetIndexLabel(10, "D1"); 
   SetIndexLabel(11, "D2"); 
   SetIndexLabel(12, "D3"); 
   SetIndexLabel(13, "D4"); 
   SetIndexLabel(14, "D5"); 
   SetIndexLabel(15, "D6"); 
   SetIndexLabel(16, "D7"); 
   SetIndexLabel(17, "D8"); 
   SetIndexLabel(18, "D9"); 
   SetIndexLabel(19, "D10"); 
   SetIndexBuffer(0, b_H10);
   SetIndexBuffer(1, b_H9);
   SetIndexBuffer(2, b_H8);
   SetIndexBuffer(3, b_H7);
   SetIndexBuffer(4, b_H6);
   SetIndexBuffer(5, b_H5);
   SetIndexBuffer(6, b_H4);
   SetIndexBuffer(7, b_H3);
   SetIndexBuffer(8, b_H2);
   SetIndexBuffer(9, b_H1);
   SetIndexBuffer(10, b_D1);
   SetIndexBuffer(11, b_D2);
   SetIndexBuffer(12, b_D3);
   SetIndexBuffer(13, b_D4);
   SetIndexBuffer(14, b_D5);
   SetIndexBuffer(15, b_D6);
   SetIndexBuffer(16, b_D7);
   SetIndexBuffer(17, b_D8);
   SetIndexBuffer(18, b_D9);
   SetIndexBuffer(19, b_D10);

   switch(BTF)
   {
      case Min_5:
         data = new BarStream(_Symbol, PERIOD_M5);
         break;
      case Min_15:
         data = new BarStream(_Symbol, PERIOD_M15);
         break;
      case Min_30:
         data = new BarStream(_Symbol, PERIOD_M30);
         break;
      case Min_60:
         data = new BarStream(_Symbol, PERIOD_H1);
         break;
      case Min_240:
         data = new BarStream(_Symbol, PERIOD_H4);
         break;
      case Daily:
         data = new D1CustomHourBarStream(_Symbol, start_hour);
         break;
      case Weekly:
         data = new W1CustomHourAndDayBarStream(_Symbol, start_hour, week_start);
         break;
      case Monthly:
         data = new BarStream(_Symbol, PERIOD_MN1);
         break;
      case Quoter:
         data = new CustomTimeframeBarStream(_Symbol, PERIOD_MN1, 3);
         break;
      case Year:
         data = new CustomTimeframeBarStream(_Symbol, PERIOD_MN1, 12);
         break;
   }
   
   return(0);
}

int deinit()
{
   delete data;
   data = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   int shift = Method == Previous ? 1 : 0;
   data.Refresh();
   for (int i = Number_Of_BTF_Candles; i >= 0; --i)
   {
      double OPEN, CLOSE, HIGH, LOW;
      datetime Line_Start, Line_End;
      if (!data.GetValues(i + shift, OPEN, HIGH, LOW, CLOSE) || !data.GetDate(i + shift, Line_Start) || !data.GetDate(i + 1 + shift, Line_End))
         continue;
      double range1 = HIGH - LOW;
      double H10 = OPEN+range1*(Val_X*10);                                                  
      double H9  = OPEN+range1*(Val_X*9);
      double H8  = OPEN+range1*(Val_X*8);
      double H7  = OPEN+range1*(Val_X*7);                                                  
      double H6  = OPEN+range1*(Val_X*6);
      double H5  = OPEN+range1*(Val_X*5);
      double H4  = OPEN+range1*(Val_X*4);  
      double H3  = OPEN+range1*(Val_X*3);
      double H2  = OPEN+range1*(Val_X*2);
      double H1  = OPEN+range1*(Val_X*1);    
  
      double OP = OPEN ;//////////////////////////// CENTRALE FUCSIA                        
      double KK = HIGH-range1*0.5;
         
      double D1  = OPEN-range1*(Val_X*1);                                                   
      double D2  = OPEN-range1*(Val_X*2);
      double D3  = OPEN-range1*(Val_X*3);                                                   
      double D4  = OPEN-range1*(Val_X*4);
      double D5  = OPEN-range1*(Val_X*5);                                                   
      double D6  = OPEN-range1*(Val_X*6);
      double D7  = OPEN-range1*(Val_X*7);                                                   
      double D8  = OPEN-range1*(Val_X*8);
      double D9  = OPEN-range1*(Val_X*9);                                                   
      double D10 = OPEN-range1*(Val_X*10);

      if( i==0 ) 
      {
         b_H10[i] = H10;
         b_H9[i]  = H9;
         b_H8[i]  = H8;
         b_H7[i]  = H7;
         b_H6[i]  = H6;
         b_H5[i]  = H5;
         b_H4[i]  = H4;
         b_H3[i]  = H3;
         b_H2[i]  = H2;
         b_H1[i]  = H1;
         b_D1[i]  = D1;
         b_D2[i]  = D2;
         b_D3[i]  = D3;
         b_D4[i]  = D4;
         b_D5[i]  = D5;
         b_D6[i]  = D6;
         b_D7[i]  = D7;
         b_D8[i]  = D8;
         b_D9[i]  = D9;
         b_D10[i] = D10;
      }

      bool Draw_Label = true;

      Pivot(" - HIGH"+IntegerToString(i),Line_Start,HIGH,Line_End,High_Color,2,STYLE_SOLID,Draw_Label);
      Pivot(" - LOW"+IntegerToString(i),Line_Start,LOW,Line_End,Low_Color,2,STYLE_SOLID,Draw_Label);
      Pivot(" - H10 "+IntegerToString(i),Line_Start,H10,Line_End,H2Color,1,STYLE_DOT,Draw_Label); 
      Pivot(" - H9 "+IntegerToString(i),Line_Start,H9,Line_End,H2Color,1,STYLE_DOT,Draw_Label); 
      Pivot(" - H8 "+IntegerToString(i),Line_Start,H8,Line_End,H2Color,1,STYLE_DOT,Draw_Label); 
      Pivot(" - H7 "+IntegerToString(i),Line_Start,H7,Line_End,H2Color,1,STYLE_DOT,Draw_Label); 
      Pivot(" - H6 "+IntegerToString(i),Line_Start,H6,Line_End,H2Color,1,STYLE_DOT,Draw_Label); 
      Pivot(" - H5 "+IntegerToString(i),Line_Start,H5,Line_End,H2Color,1,STYLE_DOT,Draw_Label); 
      Pivot(" - H4 "+IntegerToString(i),Line_Start,H4,Line_End,H2Color,1,STYLE_DOT,Draw_Label); 
      Pivot(" - H3 "+IntegerToString(i),Line_Start,H3,Line_End,H2Color,1,STYLE_DOT,Draw_Label); 
      Pivot(" - H2 "+IntegerToString(i),Line_Start,H2,Line_End,H2Color,1,STYLE_DOT,Draw_Label); 
      Pivot(" - H1 "+IntegerToString(i),Line_Start,H1,Line_End,H1Color,1,STYLE_DOT,Draw_Label); 
      Pivot(" - OP "+IntegerToString(i),Line_Start,OP,Line_End,OPColor,2,STYLE_SOLID,Draw_Label);        //FUCSIA CENTRALE CONTINUA
      Pivot(" - KK "+IntegerToString(i),Line_Start,KK,Line_End,KK_Color,2,STYLE_SOLID,Draw_Label);       //50%max low                                               
      Pivot(" - D1 "+IntegerToString(i),Line_Start,D1,Line_End,D1Color,1,STYLE_DOT,Draw_Label); 
      Pivot(" - D2 "+IntegerToString(i),Line_Start,D2,Line_End,D2Color,1,STYLE_DOT,Draw_Label);
      Pivot(" - D3 "+IntegerToString(i),Line_Start,D3,Line_End,D2Color,1,STYLE_DOT,Draw_Label);
      Pivot(" - D4 "+IntegerToString(i),Line_Start,D4,Line_End,D2Color,1,STYLE_DOT,Draw_Label);
      Pivot(" - D5 "+IntegerToString(i),Line_Start,D5,Line_End,D2Color,1,STYLE_DOT,Draw_Label);
      Pivot(" - D6 "+IntegerToString(i),Line_Start,D6,Line_End,D2Color,1,STYLE_DOT,Draw_Label);
      Pivot(" - D7 "+IntegerToString(i),Line_Start,D7,Line_End,D2Color,1,STYLE_DOT,Draw_Label);
      Pivot(" - D8 "+IntegerToString(i),Line_Start,D8,Line_End,D2Color,1,STYLE_DOT,Draw_Label);
      Pivot(" - D9 "+IntegerToString(i),Line_Start,D9,Line_End,D2Color,1,STYLE_DOT,Draw_Label);
      Pivot(" - D10 "+IntegerToString(i),Line_Start,D10,Line_End,D2Color,1,STYLE_DOT,Draw_Label);

      if (Draw_Cycles_Separator)
         Separator(IndicatorObjPrefix + " - Sep "+IntegerToString(i),Line_Start,BTF_Separator,0,STYLE_DOT);
   }
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Pivot(string Nombre,datetime tiempo1,double precio1,datetime tiempo2,color bpcolor,int ancho,int style,bool draw_text)
{
   string id = IndicatorObjPrefix + Nombre;
   string text = IntegerToString(magicID) + Nombre;
   ObjectDelete(id);
   ObjectCreate(id,OBJ_TREND,0,tiempo1,precio1,tiempo2,precio1);
   ObjectSet(id,OBJPROP_COLOR,bpcolor);
   ObjectSet(id,OBJPROP_STYLE,style);
   ObjectSet(id,OBJPROP_WIDTH,ancho);
   ObjectSet(id,OBJPROP_RAY,False);
   ObjectSet(id,OBJPROP_BACK,true);
   if (Show_Labels && draw_text)
   {
      ObjectDelete("T"+id);
      ObjectCreate("T"+id,OBJ_TEXT,0,tiempo2+(2*Period()*60),precio1);
      ObjectSetText("T"+id,StringSubstr(text,0,StringLen(text)-1),7,"Arial",bpcolor);
      ObjectSet("T"+id,OBJPROP_TIME1,tiempo2+(2*Period()*60));
      ObjectSet("T"+id,OBJPROP_PRICE1,precio1);
   }
}
// Draw Separator
void Separator(string Nombre,datetime tiempo1,color sesscolor,int ancho,int style)
{
   ObjectDelete(Nombre);
   ObjectCreate(Nombre,OBJ_VLINE,0,tiempo1,WindowPriceMax());
   ObjectSet(Nombre,OBJPROP_COLOR,sesscolor);
   ObjectSet(Nombre,OBJPROP_STYLE,style);
   ObjectSet(Nombre,OBJPROP_WIDTH,ancho);
   ObjectSet(Nombre,OBJPROP_BACK,True);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsInvalidTimeframe()
{
   bool wrong_tf=false;

   if(Period()==5     && BTF<2) wrong_tf = true;
   if(Period()==15    && BTF<3) wrong_tf = true;
   if(Period()==30    && BTF<4) wrong_tf = true;
   if(Period()==60    && BTF<5) wrong_tf = true;
   if(Period()==240   && BTF<6) wrong_tf = true;
   if(Period()==1440  && BTF<7) wrong_tf = true;
   if(Period()==10080 && BTF<8) wrong_tf = true;
   if(Period()==43200)          wrong_tf = true;

   return(wrong_tf);
}
//+------------------------------------------------------------------+
