//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76392
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
 
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_label1 "PDH Raid"
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "PDL Raid"
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "PWH Raid"
#property indicator_type3 DRAW_ARROW
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "PWL Raid"
#property indicator_type4 DRAW_ARROW
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Daily Bias"
#property indicator_type5 DRAW_ARROW
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Weekly Bias"
#property indicator_type6 DRAW_ARROW
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Daily Bias"
#property indicator_type7 DRAW_NONE
#property indicator_color7 Blue
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Weekly Bias"
#property indicator_type8 DRAW_NONE
#property indicator_color8 Blue
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1

#define ColorRGB(red, green, blue, transp) (uint)(red + (green << 8) + (blue << 16) + ((uint)(transp * 2.55) << 24))
#define GetColorOnly(clr) (clr & 0xFFFFFF)
#define GetTranparency(clr) (int)MathRound(((clr & 0xFF000000) >> 24) / 2.55)
#define AddTransparency(clr, transp) (clr + ((uint)(transp * 2.55) << 24))

bool NumberToBool(double number)
{
   return number != EMPTY_VALUE && number != 0;
}

class FirstBarState
{
   bool _first;
public:
   FirstBarState()
   {
      _first = true;
   }
   void Clear()
   {
      _first = true;
   }
   bool IsFirst()
   {
      bool first = _first;
      _first = false;
      return first;
   }
};

class NewBarState
{
   datetime _last;
public:
   NewBarState()
   {
      _last = 0;
   }
   void Clear()
   {
      _last = 0;
   }
   bool IsNew(datetime date)
   {
      bool isnew = _last != date;
      _last = date;
      return isnew;
   }
};

uint FromGradient(double value, double bottomValue, double topValue, uint bottomColor, uint topColor)
{
   if (value == EMPTY_VALUE || topValue == EMPTY_VALUE)
   {
      return bottomColor;
   }
   if (bottomValue == EMPTY_VALUE)
   {
      return topColor;
   }
   return value - bottomValue < topValue - value 
      ? bottomColor
      : topColor;
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
}

datetime Timestamp(int year, int month, int day, int hour, int minute, int second)
{
   MqlDateTime time;
   time.year = year;
   time.mon = month;
   time.day = day;
   time.hour = hour;
   time.min = minute;
   time.sec = second;
   return StructToTime(time);
}

class Runtime
{
public:
   static void Error(string message)
   {
      Print(message);
      ExpertRemove();
   }
};
// PineScript timeframe.* functions
// v1.0

class Timeframe
{
public:
   static string Period()
   {
      if (_Period == PERIOD_M1) { return "1"; }
      if (_Period == PERIOD_M5) { return "5"; }
      if (_Period == PERIOD_M15) { return "15"; }
      if (_Period == PERIOD_M30) { return "30"; }
      if (_Period == PERIOD_H1) { return "60"; }
      if (_Period == PERIOD_H4) { return "240"; }
      if (_Period == PERIOD_D1) { return "D"; }
      if (_Period == PERIOD_W1) { return "W"; }
      if (_Period == PERIOD_MN1) { return "M"; }
      return "1";
   }
   
   static int InSeconds(string resolution)
   {
      return (int)GetTimeframe(resolution);
   }
   
   static bool Change(string timeframe, int pos)
   {
      int bars = iBars(_Symbol, _Period);
      if (bars <= pos + 1)
      {
         return true;
      }
      datetime currentBar = iTime(_Symbol, _Period, pos);
      datetime prevBar = iTime(_Symbol, _Period, pos + 1);
      ENUM_TIMEFRAMES tf = GetTimeframe(timeframe);
      return iBarShift(_Symbol, tf, currentBar) != iBarShift(_Symbol, tf, prevBar);
   }
   
   static bool IsDWM()
   {
      switch (_Period)
      {
         case PERIOD_D1:
         case PERIOD_W1:
         case PERIOD_MN1:
            return true;
      }
      return false;
   }
   
   static ENUM_TIMEFRAMES GetTimeframe(string resolution)
   {
      if (resolution == "1") { return PERIOD_M1; }
      if (resolution == "5") { return PERIOD_M5; }
      if (resolution == "15") { return PERIOD_M15; }
      if (resolution == "30") { return PERIOD_M30; }
      if (resolution == "60") { return PERIOD_H1; }
      if (resolution == "240") { return PERIOD_H4; }
      if (resolution == "D") { return PERIOD_D1; }
      if (resolution == "W") { return PERIOD_W1; }
      if (resolution == "M") { return PERIOD_MN1; }
      return PERIOD_CURRENT;
   }

   static bool IsIntraday()
   {
      return ~IsDWM();
   }

   static int Interval()
   {
      switch (_Period)
      {
         case PERIOD_M1:
         case PERIOD_H1:
         case PERIOD_D1:
         case PERIOD_W1:
         case PERIOD_MN1:
            return 1;
         case PERIOD_M5:
            return 5;
         case PERIOD_M15:
            return 15;
         case PERIOD_M30:
            return 30;
         case PERIOD_H4:
            return 4;
      }
      return INT_MIN;
   }
};
// Pine-script like safe operations
// v.1.2

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}
double SafePlus(int left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
int SafePlus(int left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
string SafePlus(string left, string right)
{
   if (left == NULL || right == NULL)
   {
      return NULL;
   }
   return left + right;
}

double SafeMinus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left - right;
}

double SafeDivide(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE || right == 0)
   {
      return EMPTY_VALUE;
   }
   return left / right;
}

double SafeMultiply(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left * right;
}

bool SafeGreater(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left > right;
}

bool SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left >= right;
}

bool SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left < right;
}

bool SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left <= right;
}

double SafeMathExp(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathExp(value);
}

double SafeMathMax(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(left, right);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathPow(double value, double power)
{
   if (value == EMPTY_VALUE || power == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathPow(value, power);
}

double SafeMathAbs(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathAbs(value);
}

double SafeMathRound(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathRound(value);
}

double SafeMathRound(double value, int precision)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return NormalizeDouble(value, precision);
}

double SafeMathSqrt(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSqrt(value);
}

int SafeSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   if (value == 0)
   {
      return 0;
   }
   return value > 0 ? 1 : -1;
}

double SafeLog(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog(value);
}
double SafeLog10(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog10(value);
}
double SafeCos(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathCos(value);
}
double SafeArccos(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArccos(value);
}
double SafeSin(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSin(value);
}
double SafeArcsin(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArcsin(value);
}
double SafeTan(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathTan(value);
}
double SafeArctan(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArctan(value);
}
double InvertSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return -value;
}
double SafeMathFloor(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathFloor(value);
}
int SafeMathCeil(double value)
{
   if (value == EMPTY_VALUE)
   {
      return INT_MIN;
   }
   return MathCeil(value);
}
// Collection of lines v1.3

#ifndef LinesCollection_IMPL
#define LinesCollection_IMPL

// Line object v1.7

class Line
{
   string _id;
   int _x1;
   double _y1;
   int _x2;
   double _y2;
   string _xloc;
   uint _clr;
   int _width;
   ENUM_TIMEFRAMES _timeframe;
   string _style;
   int _refs;
   string _collectionId;
   int _window;
   bool global;
   string _extend;
public:
   Line(int x1, double y1, int x2, double y2, string id, string collectionId, int window, bool global)
   {
      _extend = "none";
      _refs = 1;
      _x1 = x1;
      _x2 = x2;
      _y1 = y1;
      _y2 = y2;
      _id = id;
      _clr = Blue;
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      _window = window;
      _collectionId = collectionId;
      this.global = global;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }
   
   void CopyTo(Line* line)
   {
      line._x1 = _x1;
      line._y1 = _y1;
      line._x2 = _x2;
      line._y2 = _y2;
      line._clr = _clr;
      line._width = _width;
      line._timeframe = _timeframe;
      line._style = _style;
      line._window = _window;
      line._extend = _extend;
   }
   
   bool IsGlobal()
   {
      return global;
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   static void SetStyle(Line* line, string style)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetStyle(style);
   }
   
   Line* SetStyle(string style)
   {
      _style = style;
      return &this;
   }
   
   static void SetExtend(Line* line, string extend)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetExtend(extend);
   }
   
   Line* SetExtend(string extend)
   {
      _extend = extend;
      return &this;
   }

   void SetXY1(int x, double y)
   {
      _x1 = x;
      _y1 = y;
   }
   static void SetXY1(Line* line, int x, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXY1(x, y);
   }
   
   void SetXY2(int x, double y)
   {
      _x2 = x;
      _y2 = y;
   }
   static void SetXY2(Line* line, int x, double y)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXY2(x, y);
   }

   void SetX1(int x) { _x1 = x; }
   static void SetX1(Line* line, int x) { if (line == NULL) { return; } line.SetX1(x); }
   void SetX2(int x) { _x2 = x; }
   static void SetX2(Line* line, int x) { if (line == NULL) { return; } line.SetX2(x); }
   void SetY1(double y) { _y1 = y; }
   static void SetY1(Line* line, double y) { if (line == NULL) { return; } line.SetY1(y); }
   void SetY2(double y) { _y2 = y; }
   static void SetY2(Line* line, double y) { if (line == NULL) { return; } line.SetY2(y); }

   int GetX1() { return _x1; }
   static int GetX1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetX1(); }
   int GetX2() { return _x2; }
   static int GetX2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetX2(); }
   double GetY1() { return _y1; }
   static double GetY1(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY1(); }
   double GetY2() { return _y2; }
   static double GetY2(Line* line) { if (line == NULL) { return EMPTY_VALUE; } return line.GetY2(); }

   Line* SetColor(uint clr)
   {
      _clr = clr;
      return &this;
   }
   static void SetColor(Line* line, uint clr)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetColor(clr);
   }

   static void SetWidth(Line* line, int width)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetWidth(width);
   }

   Line* SetWidth(int width)
   {
      _width = width;
      return &this;
   }
   
   static void SetXLoc(Line* line, string xloc)
   {
      if (line == NULL)
      {
         return;
      }
      line.SetXLoc(xloc);
   }
   Line* SetXLoc(string xloc)
   {
      _xloc = xloc;
      return &this;
   }

   void Redraw()
   {
      if (_y1 == EMPTY_VALUE || _y2 == EMPTY_VALUE)
      {
         return;
      }
      datetime x1 = GetX(_x1);
      datetime x2 = GetX(_x2);
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_TREND, 0, x1, _y1, x2, _y2))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _clr);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, GetStyleMQL());
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, _width);
         if (_extend == "right")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, true);
         }
         else if (_extend == "left")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, true);
         }
         else if (_extend == "both")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, true);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, true);
         }
         else if (_extend == "none")
         {
            ObjectSetInteger(0, _id, OBJPROP_RAY, false);
            ObjectSetInteger(0, _id, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, _id, OBJPROP_RAY_LEFT, false);
         }
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _y1);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _y2);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, x1);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, x2);
   }
private:
   datetime GetX(int x)
   {
      if (_xloc == "bar_time")
      {
         return x;
      }
      int pos1 = iBars(_Symbol, _timeframe) - x - 1;
      return iTime(_Symbol, _timeframe, pos1);
   }
   int GetStyleMQL()
   {
      if (_style == "dashed")
      {
         return STYLE_DASH;
      }
      if (_style == "solid")
      {
         return STYLE_SOLID;
      }
      return STYLE_SOLID;
   }
};

class LinesCollection
{
   string _id;
   Line* _array[];
   static LinesCollection* _collections[];
   static LinesCollection* _all;
   static int _max;
public:
   static Line* Get(Line* line, int index)
   {
      if (line == NULL)
      {
         return NULL;
      }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }

   static void Clear(bool full = false)
   {
      if (_all == NULL)
      {
         if (!full)
         {
            _all = new LinesCollection("");
         }
      }
      else
      {
         _all.ClearItems();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
   }

   static void Delete(Line* line)
   {
      if (line == NULL)
      {
         return;
      }
      if (!_all.DeleteItem(line))
      {
         return;
      }
      LinesCollection* collection = FindCollection(line.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(line);
   }

   static Line* Create(string id, int x1, double y1, int x2, double y2, datetime dateId, bool global = false)
   {
      if (_all == NULL)
      {
         Clear();
      }
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x1 - 1);
      string lineId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      
      Line* line = new Line(x1, y1, x2, y2, lineId, id, WindowOnDropped(), global);
      LinesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LinesCollection(id);
         AddCollection(collection);
      }
      collection.Add(line);
      _all.Add(line);
      int allLinesCount = _all.Count();
      if (allLinesCount > _max)
      {
         for (int i = 0; i < allLinesCount; ++i)
         {
            Line* lineToDelete = _all.Get(i);
            if (!lineToDelete.IsGlobal() && lineToDelete != line)
            {
               Delete(lineToDelete);
               break;
            }
         }
      }
      line.Release();
      return line;
   }

   static void SetMaxLines(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLines();
      }
   }
private:
   LinesCollection(string id)
   {
      _id = id;
   }

   ~LinesCollection()
   {
      ClearItems();
   }
   
   string GetId()
   {
      return _id;
   }
   
   void ClearItems()
   {
      for (int i = 0; i < ArraySize(_array); ++i)
      {
         if (_array[i] != NULL)
         {
            _array[i].Release();
         }
      }
      ArrayResize(_array, 0);
   }
   
   int Count()
   {
      return ArraySize(_array);
   }

   Line* GetFirst()
   {
      return _array[0];
   }

   Line* Get(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[index];
   }
   Line* GetByIndex(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[size - 1 - index];
   }
   
   int FindIndex(Line* line)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == line)
         {
            return i;
         }
      }
      return -1;
   }

   bool DeleteItem(Line* line)
   {
      int index = FindIndex(line);
      if (index == -1)
      {
         return false;
      }
      if (_array[index] != NULL)
      {
         _array[index].Release();
      }
      int size = ArraySize(_array);
      for (int i = index + 1; i < size; ++i)
      {
         _array[i - 1] = _array[i];
      }
      ArrayResize(_array, size - 1);
      return true;
   }
   
   void Add(Line* line)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = line;
      if (line != NULL)
      {
         line.AddRef();
      }
   }

   void RedrawLines()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         _array[i].Redraw();
      }
   }
   
   static void AddCollection(LinesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static LinesCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
LinesCollection* LinesCollection::_collections[];
LinesCollection* LinesCollection::_all;
int LinesCollection::_max = 50;
#endif
// Array v1.7
// Array interface v1.0

// Line array interface v1.2

// Template for array interface v2.0

template <typename CLASS_TYPE>
interface ITArray
{
public:
   virtual void AddRef() = 0;
   virtual int Release() = 0;
   virtual void Unshift(CLASS_TYPE value) = 0;
   virtual int Size() = 0;
   virtual ITArray<CLASS_TYPE>* Push(CLASS_TYPE value) = 0;
   virtual CLASS_TYPE Pop() = 0;
   virtual CLASS_TYPE Get(int index) = 0;
   virtual void Set(int index, CLASS_TYPE value) = 0;
   virtual CLASS_TYPE Shift() = 0;
   virtual CLASS_TYPE Remove(int index) = 0;
   virtual int Includes(CLASS_TYPE value) = 0;
};

class ILineArray : public ITArray<Line*>
{
public:
   virtual ILineArray* Slice(int from, int to) = 0;
   virtual ILineArray* Clear() = 0;
};
// bool array interface v1.0

class IBoolArray
{
public:
   virtual void Unshift(int value) = 0;
   virtual int Size() = 0;
   virtual IBoolArray* Push(int value) = 0;
   virtual int Pop() = 0;
   virtual int Get(int index) = 0;
   virtual void Set(int index, int value) = 0;
   virtual IBoolArray* Slice(int from, int to) = 0;
   virtual IBoolArray* Clear() = 0;
   virtual int Shift() = 0;
   virtual int Remove(int index) = 0;
   virtual int Includes(int value) = 0;
};
#ifndef SimpleTypeArray_IMPL
#define SimpleTypeArray_IMPL

template <typename CLASS_TYPE>
interface ISimpleTypeArray : public ITArray<CLASS_TYPE>
{
public:
   virtual ISimpleTypeArray<CLASS_TYPE>* Clear() = 0;
};
template <typename CLASS_TYPE>
class SimpleTypeArray : public ISimpleTypeArray<CLASS_TYPE>
{
   CLASS_TYPE _array[];
   int _defaultSize;
   CLASS_TYPE _defaultValue;
   CLASS_TYPE _emptyValue;
   int _refs;
public:
   SimpleTypeArray(int size, CLASS_TYPE defaultValue, CLASS_TYPE emptyValue)
   {
      _refs = 1;
      _defaultSize = size;
      _defaultValue = defaultValue;
      _emptyValue = emptyValue;
      Clear();
   }

   ~SimpleTypeArray()
   {
      Clear();
   }

   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   
   ISimpleTypeArray<CLASS_TYPE>* Clear()
   {
      int size = ArraySize(_array);
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   ITArray<CLASS_TYPE>* Push(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
   }

   CLASS_TYPE Pop()
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   CLASS_TYPE Shift()
   {
      return Remove(0);
   }

   CLASS_TYPE Get(int index)
   {
      if (index >= Size())
      {
         return _emptyValue;
      }
      if (index < 0)
      {
         index = Size() + index;
      }
      return _array[index];
   }
   
   void Set(int index, CLASS_TYPE value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }
   
   CLASS_TYPE Remove(int index)
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
   
   int Includes(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
   
   CLASS_TYPE PercentRank(int index)
   {
      int arraySize = Size();
      if (arraySize == 0 || arraySize <= index) { return _emptyValue; }
      CLASS_TYPE target = Get(index);
      if (target == _emptyValue)
      {
         return _emptyValue;
      }
      int count = 0;
      for (int i = 0; i < arraySize; ++i)
      {
         CLASS_TYPE current = Get(i);
         if (current != _emptyValue && target >= current)
         {
            count++;
         }
      }
      return (count * 100.0) / arraySize;
   }
   
   CLASS_TYPE Max()
   {
      if (Size() == 0) { return _emptyValue; }
      CLASS_TYPE max = Get(0);
      for (int i = 1; i < Size(); ++i)
      {
         CLASS_TYPE current = Get(i);
         if (max == _emptyValue || (current != _emptyValue && max < current))
         {
            max = current;
         }
      }
      return max;
   }
   CLASS_TYPE Min()
   {
      if (Size() == 0) { return _emptyValue; }
      CLASS_TYPE min = Get(0);
      for (int i = 1; i < Size(); ++i)
      {
         CLASS_TYPE current = Get(i);
         if (min == _emptyValue || (current != _emptyValue && min > current))
         {
            min = current;
         }
      }
      return min;
   }
   
   CLASS_TYPE Sum()
   {
      CLASS_TYPE sum = 0;
      for (int i = 0; i < Size(); ++i)
      {
         sum += Get(i);
      }
      return sum;
   }
   double Stdev()
   {
      double sum = 0;
      double ssum = 0;
      int size = Size();
      if (size < 2)
      {
         return 0;
      }
      for (int i = 0; i < size; i++)
      {
         CLASS_TYPE value = Get(i);
         sum += value;
         ssum += MathPow(value, 2);
      }
      return MathSqrt((ssum * size - sum * sum) / (size * (size - 1)));
   }
};
#endif


#ifndef LineArray_IMPL
#define LineArray_IMPL
// Line array v1.3
#ifndef CustomTypeArray_IMPL
#define CustomTypeArray_IMPL

template <typename CLASS_TYPE>
interface ICustomTypeArray : public ITArray<CLASS_TYPE>
{
public:
   virtual ICustomTypeArray<CLASS_TYPE>* Clear() = 0;
};
template <typename CLASS_TYPE>
class CustomTypeArray : public ICustomTypeArray<CLASS_TYPE>
{
   CLASS_TYPE _array[];
   int _defaultSize;
   CLASS_TYPE _defaultValue;
   int _refs;
public:
   CustomTypeArray(int size, CLASS_TYPE defaultValue)
   {
      _refs = 1;
      _defaultValue = defaultValue;
      if (_defaultValue != NULL)
      {
         _defaultValue.AddRef();
      }
      _defaultSize = size;
      Clear();
   }

   ~CustomTypeArray()
   {
      Clear();
      if (_defaultValue != NULL)
      {
         _defaultValue.Release();
      }
   }

   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   
   ICustomTypeArray<CLASS_TYPE>* Clear()
   {
      int size = ArraySize(_array);
      int i;
      for (i = 0; i < size; i++)
      {
         if (_array[i] != NULL)
         {
            DeleteItem(_array[i]);
            _array[i].Release();
         }
      }
      ArrayResize(_array, _defaultSize);
      for (i = 0; i < _defaultSize; ++i)
      {
         _array[i] = Clone(_defaultValue, i);
      }
      return &this;
   }

   void Unshift(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }

   int Size()
   {
      return ArraySize(_array);
   }

   ITArray<CLASS_TYPE>* Push(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
      return &this;
   }

   CLASS_TYPE Pop()
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[size - 1];
      ArrayResize(_array, size - 1);
      if (value != NULL && value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }

   CLASS_TYPE Shift()
   {
      return Remove(0);
   }

   CLASS_TYPE Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return NULL;
      }
      return _array[index];
   }
   
   void Set(int index, CLASS_TYPE value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      if (_array[index] != NULL)
      {
         _array[index].Release();
      }
      _array[index] = value;
      if (value != NULL)
      {
         value.AddRef();
      }
   }
   
   CLASS_TYPE Remove(int index)
   {
      int size = ArraySize(_array);
      CLASS_TYPE value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      if (value == NULL || value.Release() == 0)
      {
         return NULL;
      }
      return value;
   }
   
   int Includes(CLASS_TYPE value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
protected:
   virtual CLASS_TYPE Clone(CLASS_TYPE item, int index)
   {
      return NULL;
   }
   virtual void DeleteItem(CLASS_TYPE item)
   {
   }
};
#endif


class LineArray : public CustomTypeArray<Line*>
{
public:
   LineArray(int size, Line* defaultValue)
      :CustomTypeArray(size, defaultValue)
   {
   }
protected:
   virtual Line* Clone(Line* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Line* clone = LinesCollection::Create(item.GetId() + index, item.GetX1(), item.GetY1(), item.GetX2(), item.GetY2(), 0, item.IsGlobal());
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Line* item)
   {
      LinesCollection::Delete(item);
   }
};
#endif
#ifndef LabelArray_IMPL
#define LabelArray_IMPL
// Label array v1.0

// Collection of labels v1.3

#ifndef LabelsCollection_IMPL
#define LabelsCollection_IMPL

// Label v1.6

#ifndef Label_IMPL
#define Label_IMPL

class Label
{
   uint _color;
   uint _textColor;
   string _text;
   string _labelId;
   string _collectionId;
   string _textAlign;
   int _x;
   double _y;
   string _font;
   string _style;
   string _size;
   string _yloc;
   ENUM_TIMEFRAMES _timeframe;
   int _refs;
   int _window;
   bool globalLabel;
public:
   Label(int x, double y, string labelId, string collectionId, int window, bool globalLabel)
   {
      _refs = 1;
      _window = window;
      _textColor = Yellow;
      _x = x;
      _y = y;
      _labelId = labelId;
      _collectionId = collectionId;
      _font = "Arial";
      _textAlign = "";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      this.globalLabel = globalLabel;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }
   
   void CopyTo(Label* label)
   {
      label._color = _color;
      label._textColor = _textColor;
      label._text = _text;
      label._textAlign = _textAlign;
      label._x = _x;
      label._y = _y;
      label._font = _font;
      label._style = _style;
      label._size = _size;
      label._yloc = _yloc;
      label._timeframe = _timeframe;
      label._window = _window;
   }
   
   bool IsGlobal()
   {
      return globalLabel;
   }
   
   string GetId()
   {
      return _labelId;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   int GetX()
   {
      return _x;
   }
   static int GetX(Label* label)
   {
      if (label == NULL)
      {
         return 0;
      }
      return label.GetX();
   }

   double GetY()
   {
      return _y;
   }
   static double GetY(Label* label)
   {
      if (label == NULL)
      {
         return 0;
      }
      return label.GetY();
   }
   void SetX(int x) { _x = x; }
   static void SetX(Label* label, int x) { if (label == NULL) { return; } label.SetX(x); }
   void SetY(double y) { _y = y; }
   static void SetY(Label* label, double y) { if (label == NULL) { return; } label.SetY(y); }
   static void SetXY(Label* label, int x, double y)
   {
      if (label == NULL) { return; }
      label.SetX(x);
      label.SetY(y);
  }

   Label* SetSize(string size)
   {
      _size = size;
      return &this;
   }
   static void SetSize(Label* label, string size)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetSize(size);
   }

   Label* SetYLoc(string yloc)
   {
      _yloc = yloc;
      return &this;
   }
   static void SetYLoc(Label* label, string yloc)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetYLoc(yloc);
   }
   
   static void SetColor(Label* label, uint clr)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetColor(clr);
   }
   
   Label* SetColor(uint clr)
   {
      _color = clr;
      return &this;
   }
   
   static void SetTextColor(Label* label, uint clr)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetTextColor(clr);
   }
   Label* SetTextColor(uint clr)
   {
      _textColor = clr;
      return &this;
   }
   
   static void SetStyle(Label* label, string style)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetStyle(style);
   }
   Label* SetStyle(string style)
   {
      _style = style;
      return &this;
   }
   
   static void SetText(Label* label, string text)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetText(text);
   }
   Label* SetText(string text)
   {
      _text = text;
      StringReplace(_text, "\n", " ");
      if (_text == "")
      {
         _font = "Wingdings";
      }
      else
      {
         _font = "Arial";
      }
      return &this;
   }
   
   static void SetTextAlign(Label* label, string textAlign)
   {
      if (label == NULL)
      {
         return;
      }
      label.SetTextAlign(textAlign);
   }
   Label* SetTextAlign(string textAlign)
   {
      _textAlign = textAlign;
      return &this;
   }

   void Redraw()
   {
      string usedText = _text;
      if (usedText == "")
      {
         if (_style == "up")
         {
            usedText = "\217";
         }
         else if (_style == "down")
         {
            usedText = "\218";
         }
         else if (_style == "diamond")
         {
            usedText = "\116";
         }
      }
      ResetLastError();
      int pos = iBars(_Symbol, _timeframe) - _x - 1;
      datetime x = iTime(_Symbol, _timeframe, pos);
      double y = getY(pos);
      
      if (ObjectFind(0, _labelId) == -1 
         && ObjectCreate(0, _labelId, OBJ_TEXT, _window, x, y))
      {
         ObjectSetString(0, _labelId, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, _labelId, OBJPROP_FONTSIZE, getFontSize());
         ObjectSetInteger(0, _labelId, OBJPROP_COLOR, _textColor);
         ObjectSetInteger(0, _labelId, OBJPROP_ANCHOR, GetAnchor());
      }
      ObjectSetInteger(0, _labelId, OBJPROP_TIME, x);
      ObjectSetDouble(0, _labelId, OBJPROP_PRICE1, y);
      ObjectSetString(0, _labelId, OBJPROP_TEXT, usedText);
   }
private:
   int GetAnchor()
   {
      if (_yloc == "abovebar")
      {
         return ANCHOR_LOWER;
      }
      if (_yloc == "belowbar")
      {
         return ANCHOR_UPPER;
      }
      return ANCHOR_CENTER;
   }
   int getFontSize()
   {
      if (_size == "tiny")
      {
         return 8;
      }
      if (_size == "small")
      {
         return 10;
      }
      if (_size == "large")
      {
         return 14;
      }
      if (_size == "huge")
      {
         return 16;
      }
      return 12;
   }
   double getY(int pos)
   {
      if (_yloc == "abovebar")
      {
         return iHigh(_Symbol, _timeframe, pos);
      }
      if (_yloc == "belowbar")
      {
         return iLow(_Symbol, _timeframe, pos);
      }
      return _y;
   }
};
#endif

class LabelsCollection
{
   string _id;
   Label* _labels[];
   static LabelsCollection* _collections[];
   static LabelsCollection* _all;
   static int _maxLabels;
public:
   LabelsCollection(string id)
   {
      _id = id;
   }
   
   ~LabelsCollection()
   {
      ClearLabels();
   }
   
   void ClearLabels()
   {
      for (int i = 0; i < ArraySize(_labels); ++i)
      {
         if (_labels[i] != NULL)
         {
            _labels[i].Release();
         }
      }
      ArrayResize(_labels, 0);
   }
   
   string GetId()
   {
      return _id;
   }
   
   int Count()
   {
      return ArraySize(_labels);
   }
   
   Label* GetFirst()
   {
      return _labels[0];
   }
   
   Label* Get(int index)
   {
      int size = ArraySize(_labels);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _labels[index];
   }
   Label* GetByIndex(int index)
   {
      int size = ArraySize(_labels);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _labels[size - 1 - index];
   }

   static Label* Get(Label* label, int index)
   {
      if (label == NULL)
      {
         return NULL;
      }
      LabelsCollection* collection = FindCollection(label.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }
   
   static void Clear(bool full = false)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
      if (_all == NULL && !full)
      {
         _all = new LabelsCollection("");
      }
      else
      {
         _all.ClearLabels();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
   }

   static void Delete(Label* label)
   {
      if (label == NULL)
      {
         return;
      }
      _all.RemoveLabel(label);
      LabelsCollection* collection = FindCollection(label.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteLabel(label);
   }

   static Label* Create(string id, int x, double y, datetime dateId, bool globalLabel = false)
   {
      if (_all == NULL)
      {
         Clear();
      }
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - x - 1);
      string labelId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      Label* label = new Label(x, y, labelId, id, WindowOnDropped(), globalLabel);
      LabelsCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new LabelsCollection(id);
         AddCollection(collection);
      }
      collection.Add(label);
      _all.Add(label);
      int allLabelsCount = _all.Count();
      if (allLabelsCount > _maxLabels)
      {
         for (int i = 0; i < allLabelsCount; ++i)
         {
            Label* labelToDelete = _all.Get(i);
            if (!labelToDelete.IsGlobal() && labelToDelete != label)
            {
               Delete(labelToDelete);
               break;
            }
         }
      }
      return label;
   }

   static void SetMaxLabels(int max)
   {
      _maxLabels = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawLabels();
      }
   }
private:
   int FindIndex(Label* label)
   {
      int size = ArraySize(_labels);
      for (int i = 0; i < size; ++i)
      {
         if (_labels[i] == label)
         {
            return i;
         }
      }
      return -1;
   }
   void RemoveLabel(Label* label)
   {
      int index = FindIndex(label);
      if (index == -1)
      {
         return;
      }
      int size = ArraySize(_labels);
      for (int i = index + 1; i < size; ++i)
      {
         _labels[i - 1] = _labels[i];
      }
      ArrayResize(_labels, size - 1);
      label.Release();
   }
   void DeleteLabel(Label* label)
   {
      RemoveLabel(label);
      label.Release();
   }
   void Add(Label* label)
   {
      int index = FindIndex(label);
      
      int size = ArraySize(_labels);
      ArrayResize(_labels, size + 1);
      _labels[size] = label;
      if (label != NULL)
      {
         label.AddRef();
      }
   }

   void RedrawLabels()
   {
      int size = ArraySize(_labels);
      for (int i = 0; i < size; ++i)
      {
         _labels[i].Redraw();
      }
   }

   static void AddCollection(LabelsCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static LabelsCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
LabelsCollection* LabelsCollection::_collections[];
LabelsCollection* LabelsCollection::_all;
int LabelsCollection::_maxLabels = 50;
#endif

class LabelArray : public CustomTypeArray<Label*>
{
public:
   LabelArray(int size, Label* defaultValue) : CustomTypeArray(size, defaultValue)
   {
   }

protected:
   virtual Label* Clone(Label* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Label* clone = LabelsCollection::Create(item.GetId() + index, item.GetX(), item.GetY(), 0, item.IsGlobal());
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Label* item)
   {
      LabelsCollection::Delete(item);
   }
};
#endif
// Int array v2.0


class IntArray : public SimpleTypeArray<int>
{
public:
   IntArray(int size, double defaultValue)
      :SimpleTypeArray(size, defaultValue, INT_MIN)
   {
   }
};
// Bool array v1.0


class BoolArray : public IBoolArray
{
   int _array[];
   int _defaultSize;
   int _defaultValue;
public:
   BoolArray(int size, int defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   IBoolArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   IBoolArray* Push(int value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
   }

   int Pop()
   {
      int size = ArraySize(_array);
      int value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   int Shift()
   {
      return Remove(0);
   }

   int Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return EMPTY_VALUE;
      }
      return _array[index];
   }
   
   void Set(int index, int value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }
   
   IBoolArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   int Remove(int index)
   {
      int size = ArraySize(_array);
      int value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
   
   int Includes(int value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
};
// Float array v1.3


class FloatArray : public SimpleTypeArray<double>
{
public:
   FloatArray(int size, double defaultValue)
      :SimpleTypeArray(size, defaultValue, EMPTY_VALUE)
   {
   }
};
#ifndef BoxArray_IMPL
#define BoxArray_IMPL
// Box array v2.0

// Collection of boxes v1.3

#ifndef BoxesCollection_IMPL
#define BoxesCollection_IMPL

#ifndef Box_IMPL
#define Box_IMPL

// Box object v1.6

class Box
{
   string _id;
   string _collectionId;
   int _left;
   double _top;
   int _right;
   double _bottom;
   int _window;
   color _bgcolor;
   color _borderColor;
   ENUM_TIMEFRAMES _timeframe;
   string _extend;

   string _text;
   string _textHAlign;
   string _textVAlign;
   string _textSize;
   color _textColor;
   bool global;

   int _refs;
public:
   Box(int left, double top, int right, double bottom, string id, string collectionId, int window, bool global = false)
   {
      _refs = 1;
      _textColor = White;
      _left = left;
      _right = right;
      _top = top;
      _bottom = bottom;
      _id = id;
      _collectionId = collectionId;
      _window = window;
      _extend = "none";
      _timeframe = (ENUM_TIMEFRAMES)_Period;
      this.global = global;
   }
   void AddRef()
   {
      _refs++;
   }
   int Release()
   {
      int refs = --_refs;
      if (refs == 0)
      {
         delete &this;
      }
      return refs;
   }
   void CopyTo(Box* target)
   {
      target.SetLeft(_left);
      target.SetTop(_top);
      target.SetRight(_right);
      target.SetBottom(_bottom);
      target.SetBgColor(_bgcolor);
      target.SetBorderColor(_borderColor);
      target.SetExtend(_extend);
      target.SetText(_text);
      target.SetTextHAlign(_textHAlign);
      target.SetTextVAlign(_textVAlign);
      target.SetTextSize(_textSize);
      target.SetTextColor(_textColor);
   }
   bool IsGlobal()
   {
      return global;
   }

   string GetId()
   {
      return _id;
   }
   string GetCollectionId()
   {
      return _collectionId;
   }

   static Box* Copy(Box* box) { if (box == NULL) { return NULL; } return box.Copy(); }
   Box* Copy()
   {
      Box* copy = new Box(_left, _top, _right, _bottom, _id, _collectionId, _window);
      copy.SetBgColor(_bgcolor);
      copy.SetBorderColor(_borderColor);
      copy.SetExtend(_extend);
      copy.SetText(_text);
      copy.SetTextHAlign(_textHAlign);
      copy.SetTextVAlign(_textVAlign);
      copy.SetTextSize(_textSize);
      copy.SetTextColor(_textColor);
      return copy;
   }

   static double GetTop(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetTop(); }
   double GetTop() { return _top; }
   static double GetBottom(Box* box) { if (box == NULL) { return EMPTY_VALUE; } return box.GetBottom(); }
   double GetBottom() { return _bottom; }
   static int GetLeft(Box* box) { if (box == NULL) { return INT_MIN; } return box.GetLeft(); }
   int GetLeft() { return _left; }
   static int GetRight(Box* box) { if (box == NULL) { return INT_MIN; } return box.GetRight(); }
   int GetRight() { return _right; }

   static void SetTop(Box* box, double value) { if (box == NULL) { return; } box.SetTop(value); }
   void SetTop(double value) { _top = value; }
   static void SetBottom(Box* box, double value) { if (box == NULL) { return; } box.SetBottom(value); }
   void SetBottom(double value) { _bottom = value; }
   static void SetLeft(Box* box, int value) { if (box == NULL) { return; } box.SetLeft(value); }
   void SetLeft(int value) { _left = value; }
   static void SetRight(Box* box, int value) { if (box == NULL) { return; } box.SetRight(value); }
   void SetRight(int value) { _right = value; }
   static void SetLeftTop(Box* box, double top, int left) { if (box == NULL) { return; } box.SetTop(top); box.SetLeft(left); }
   static void SetRightBottom(Box* box, double bottom, int right) { if (box == NULL) { return; } box.SetRight(right); box.SetBottom(bottom); }

   static void SetBgColor(Box* box, color clr) { if (box == NULL) { return; } box.SetBgColor(clr); }
   Box* SetBgColor(color clr) { _bgcolor = clr; return &this; }
   static void SetBorderColor(Box* box, color clr) { if (box == NULL) { return; } box.SetBorderColor(clr); }
   Box* SetBorderColor(color clr) { _borderColor = clr; return &this; }
   static void SetExtend(Box* box, string extend) { if (box == NULL) { return; } box.SetExtend(extend); }
   Box* SetExtend(string extend) { _extend = extend; return &this; }

   static void SetText(Box* box, string text) { if (box == NULL) { return; } box.SetText(text); }
   Box* SetText(string text) { _text = text; return &this; }
   static void SetTextHAlign(Box* box, string halign) { if (box == NULL) { return; } box.SetTextHAlign(halign); }
   Box* SetTextHAlign(string halign) { _textHAlign = halign; return &this; }
   static void SetTextVAlign(Box* box, string valign) { if (box == NULL) { return; } box.SetTextVAlign(valign); }
   Box* SetTextVAlign(string valign) { _textVAlign = valign; return &this; }
   static void SetTextSize(Box* box, string size) { if (box == NULL) { return; } box.SetTextSize(size); }
   Box* SetTextSize(string size) { _textSize = size; return &this; }
   static void SetTextColor(Box* box, color clr) { if (box == NULL) { return; } box.SetTextColor(clr); }
   Box* SetTextColor(color clr) { _textColor = clr; return &this; }

   void Redraw()
   {
      int pos1 = 0;
      if (_extend == "left" || _extend == "both")
      {
         pos1 = iBars(_Symbol, _timeframe) - 1;
      }
      else
      {
         pos1 = iBars(_Symbol, _timeframe) - _left - 1;
      }
      datetime left = iTime(_Symbol, _timeframe, MathMax(0, pos1));
      int pos2 = 0;
      if (_extend == "right" || _extend == "both")
      {
         pos2 = 0;
      }
      else
      {
         pos2 = iBars(_Symbol, _timeframe) - _right - 1;
      }
      datetime right = iTime(_Symbol, _timeframe, MathMax(0, pos2));
      if (ObjectFind(0, _id) == -1 && ObjectCreate(0, _id, OBJ_RECTANGLE, _window, left, _top, right, _bottom))
      {
         ObjectSetInteger(0, _id, OBJPROP_COLOR, _bgcolor);
         ObjectSetInteger(0, _id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, _id, OBJPROP_WIDTH, 1);
      }
      ObjectSetDouble(0, _id, OBJPROP_PRICE1, _top);
      ObjectSetDouble(0, _id, OBJPROP_PRICE2, _bottom);
      ObjectSetInteger(0, _id, OBJPROP_TIME1, left);
      ObjectSetInteger(0, _id, OBJPROP_TIME2, right);
   }
};

#endif

class BoxesCollection
{
   string _id;
   Box* _array[];
   static BoxesCollection* _collections[];
   static BoxesCollection* _all;
   static int _max;
public:
   BoxesCollection(string id)
   {
      _id = id;
   }

   ~BoxesCollection()
   {
      ClearItems();
   }
   
   void ClearItems()
   {
      for (int i = 0; i < ArraySize(_array); ++i)
      {
         if (_array[i] != NULL)
         {
            _array[i].Release();
         }
      }
      ArrayResize(_array, 0);
   }
   
   string GetId()
   {
      return _id;
   }

   int Count()
   {
      return ArraySize(_array);
   }

   Box* GetFirst()
   {
      return _array[0];
   }

   Box* Get(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[index];
   }
   Box* GetByIndex(int index)
   {
      int size = ArraySize(_array);
      if (index < 0 || index >= size)
      {
         return NULL;
      }
      return _array[size - 1 - index];
   }

   static Box* Get(Box* box, int index)
   {
      if (box == NULL)
      {
         return NULL;
      }
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if (collection == NULL)
      {
         return NULL;
      }
      return collection.GetByIndex(index);
   }

   static void Clear(bool full = false)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         delete _collections[i];
      }
      ArrayResize(_collections, 0);
      if (_all == NULL && !full)
      {
         _all = new BoxesCollection("");
      }
      else
      {
         _all.ClearItems();
         if (full)
         {
            delete _all;
            _all = NULL;
         }
      }
   }

   static void Delete(Box* box)
   {
      if (box == NULL)
      {
         return;
      }
      _all.DeleteItem(box);
      BoxesCollection* collection = FindCollection(box.GetCollectionId());
      if (collection == NULL)
      {
         return;
      }
      collection.DeleteItem(box);
   }

   static Box* Create(string id, int left, double top, int right, double bottom, datetime dateId, bool global = false)
   {
      ResetLastError();
      dateId = iTime(_Symbol, _Period, iBars(_Symbol, _Period) - left - 1);
      string boxId = id + "_" 
         + IntegerToString(TimeDay(dateId)) + "_"
         + IntegerToString(TimeMonth(dateId)) + "_"
         + IntegerToString(TimeYear(dateId)) + "_"
         + IntegerToString(TimeHour(dateId)) + "_"
         + IntegerToString(TimeMinute(dateId)) + "_"
         + IntegerToString(TimeSeconds(dateId));
      
      Box* box = new Box(left, top, right, bottom, boxId, id, WindowOnDropped(), global);
      BoxesCollection* collection = FindCollection(id);
      if (collection == NULL)
      {
         collection = new BoxesCollection(id);
         AddCollection(collection);
      }
      collection.Add(box);
      _all.Add(box);
      box.Release();
      int allCount = _all.Count();
      if (allCount > _max)
      {
         for (int i = 0; i < allCount; ++i)
         {
            Box* toDelete = _all.Get(i);
            if (!toDelete.IsGlobal() && toDelete != box)
            {
               Delete(toDelete);
               break;
            }
         }
      }
      return box;
   }
   
   static void SetMaxBoxes(int max)
   {
      _max = max;
   }

   static void Redraw()
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         _collections[i].RedrawBoxs();
      }
   }
private:
   int FindIndex(Box* box)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == box)
         {
            return i;
         }
      }
      return -1;
   }

   void DeleteItem(Box* box)
   {
      int index = FindIndex(box);
      if (index == -1)
      {
         return;
      }
      int size = ArraySize(_array);
      for (int i = index + 1; i < size; ++i)
      {
         _array[i - 1] = _array[i];
      }
      ArrayResize(_array, size - 1);
      box.Release();
   }
   
   void Add(Box* box)
   {
      int index = FindIndex(box);
      
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = box;
      box.AddRef();
   }

   void RedrawBoxs()
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         _array[i].Redraw();
      }
   }
   
   static void AddCollection(BoxesCollection* collection)
   {
      int size = ArraySize(_collections);
      ArrayResize(_collections, size + 1);
      _collections[size] = collection;
   }
   
   static BoxesCollection* FindCollection(string id)
   {
      for (int i = 0; i < ArraySize(_collections); ++i)
      {
         if (_collections[i].GetId() == id)
         {
            return _collections[i];
         }
      }
      return NULL;
   }
};
BoxesCollection* BoxesCollection::_collections[];
BoxesCollection* BoxesCollection::_all;
int BoxesCollection::_max = 50;
#endif

class BoxArray : public CustomTypeArray<Box*>
{
public:
   BoxArray(int size, Box* defaultValue) : CustomTypeArray(size, defaultValue)
   {
   }

protected:
   virtual Box* Clone(Box* item, int index)
   {
      if (item == NULL)
      {
         return NULL;
      }
      Box* clone = BoxesCollection::Create(item.GetId() + index, item.GetLeft(), item.GetTop(), item.GetRight(), item.GetBottom(), 0, item.IsGlobal());
      item.CopyTo(clone);
      return clone;
   }
   virtual void DeleteItem(Box* item)
   {
      BoxesCollection::Delete(item);
   }
};
#endif
// String array v1.0
// string array interface v1.0

class IStringArray
{
public:
   virtual void Unshift(string value) = 0;
   virtual int Size() = 0;
   virtual IStringArray* Push(string value) = 0;
   virtual string Pop() = 0;
   virtual string Get(int index) = 0;
   virtual void Set(int index, string value) = 0;
   virtual IStringArray* Slice(int from, int to) = 0;
   virtual IStringArray* Clear() = 0;
   virtual string Shift() = 0;
   virtual string Remove(int index) = 0;
   virtual int Includes(string value) = 0;
};

class StringArray : public IStringArray
{
   string _array[];
   int _defaultSize;
   string _defaultValue;
public:
   StringArray(int size, string defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   IStringArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(string value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   IStringArray* Push(string value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
   }

   string Pop()
   {
      int size = ArraySize(_array);
      string value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   string Shift()
   {
      return Remove(0);
   }

   string Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return NULL;
      }
      return _array[index];
   }
   
   void Set(int index, string value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }
   
   IStringArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   string Remove(int index)
   {
      int size = ArraySize(_array);
      string value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
   
   int Includes(string value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
};
// Color array v1.0
// Color array interface v1.0

class IColorArray
{
public:
   virtual void Unshift(uint value) = 0;
   virtual int Size() = 0;
   virtual IColorArray* Push(uint value) = 0;
   virtual uint Pop() = 0;
   virtual uint Get(int index) = 0;
   virtual void Set(int index, uint value) = 0;
   virtual IColorArray* Slice(int from, int to) = 0;
   virtual IColorArray* Clear() = 0;
   virtual uint Shift() = 0;
   virtual uint Remove(int index) = 0;
   virtual int Includes(uint value) = 0;
};

class ColorArray : public IColorArray
{
   uint _array[];
   int _defaultSize;
   uint _defaultValue;
public:
   ColorArray(int size, uint defaultValue)
   {
      _defaultSize = size;
      Clear();
   }

   IColorArray* Clear()
   {
      ArrayResize(_array, _defaultSize);
      for (int i = 0; i < _defaultSize; ++i)
      {
         _array[i] = _defaultValue;
      }
      return &this;
   }

   void Unshift(uint value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      for (int i = size - 1; i >= 0; --i)
      {
         _array[i + 1] = _array[i];
      }
      _array[0] = value;
   }

   int Size()
   {
      return ArraySize(_array);
   }

   IColorArray* Push(uint value)
   {
      int size = ArraySize(_array);
      ArrayResize(_array, size + 1);
      _array[size] = value;
      return &this;
   }

   uint Pop()
   {
      int size = ArraySize(_array);
      uint value = _array[size - 1];
      ArrayResize(_array, size - 1);
      return value;
   }

   uint Shift()
   {
      return Remove(0);
   }

   uint Get(int index)
   {
      if (index < 0 || index >= Size())
      {
         return EMPTY_VALUE;
      }
      return _array[index];
   }
   
   void Set(int index, uint value)
   {
      if (index < 0 || index >= Size())
      {
         return;
      }
      _array[index] = value;
   }
   
   IColorArray* Slice(int from, int to)
   {
      return NULL; //TODO;
   }

   uint Remove(int index)
   {
      int size = ArraySize(_array);
      uint value = _array[index];
      for (int i = index; i < size - 1; ++i)
      {
         _array[i] = _array[i + 1];
      }
      ArrayResize(_array, size - 1);
      return value;
   }
   
   int Includes(uint value)
   {
      int size = ArraySize(_array);
      for (int i = 0; i < size; ++i)
      {
         if (_array[i] == value)
         {
            return true;
         }
      }
      return false;
   }
};



class Array
{
public:
   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void Unshift(ARRAY_TYPE array, VALUE_TYPE value) { if (array == NULL) { return; } array.Unshift(value); }
   
   static double Avg(ISimpleTypeArray<double>* array)
   {
      if (array == NULL || array.Size() == 0)
      {
         return EMPTY_VALUE;
      }
      return Sum(array) / array.Size();
   }
   static double Avg(ISimpleTypeArray<int>* array)
   {
      if (array == NULL || array.Size() == 0)
      {
         return EMPTY_VALUE;
      }
      return Sum(array) / array.Size();
   }
   static double Sum(ISimpleTypeArray<double>* array)
   {
      if (array == NULL || array.Size() == 0)
      {
         return EMPTY_VALUE;
      }
      double sum = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   static int Sum(ISimpleTypeArray<int>* array)
   {
      if (array == NULL || array.Size() == 0)
      {
         return INT_MIN;
      }
      int sum = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         sum += array.Get(i);
      }
      return sum;
   }
   
   static double Min(ISimpleTypeArray<double>* array, int nth)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return EMPTY_VALUE;
      }
      double minVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double val = array.Get(i);
         if (minVal > val)
         {
            minVal = val;
         }
      }
      return minVal;
   }
   static int Min(ISimpleTypeArray<int>* array, int nth)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return INT_MIN;
      }
      int minVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int val = array.Get(i);
         if (minVal > val)
         {
            minVal = val;
         }
      }
      return minVal;
   }
   static double Max(ISimpleTypeArray<double>* array, int nth)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return EMPTY_VALUE;
      }
      double maxVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         double val = array.Get(i);
         if (maxVal < val)
         {
            maxVal = val;
         }
      }
      return maxVal;
   }
   static int Max(ISimpleTypeArray<int>* array, int nth)
   {
      if (array == NULL || array.Size() == 0 || nth != 0)
      {
         return INT_MIN;
      }
      int maxVal = array.Get(0);
      for (int i = 1; i < array.Size(); ++i)
      {
         int val = array.Get(i);
         if (maxVal < val)
         {
            maxVal = val;
         }
      }
      return maxVal;
   }
   template <typename DUMMY_TYPE, typename ARRAY_TYPE>
   static int Size(ARRAY_TYPE array, int defaultValue) { if (array == NULL) { return INT_MIN;} return array.Size(); }

   template <typename ARRAY_TYPE>
   static void Clear(ARRAY_TYPE array) { if (array == NULL) { return;} array.Clear(); }

   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Shift(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Shift(); }

   template <typename ARRAY_TYPE, typename VALUE_TYPE>
   static void Push(ARRAY_TYPE array, VALUE_TYPE value) { if (array == NULL) { return; } array.Push(value); }
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE First(ARRAY_TYPE array, VALUE_TYPE defaultValue)
   {
      if (array == NULL || array.Size() == 0) { return defaultValue; } 
      return array.Get(0);
   }
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Last(ARRAY_TYPE array, VALUE_TYPE defaultValue)
   {
      if (array == NULL || array.Size() == 0) { return defaultValue; } 
      return array.Get(array.Size() - 1);
   }
   
   template <typename VALUE_TYPE, typename ARRAY_TYPE>
   static VALUE_TYPE Pop(ARRAY_TYPE array, VALUE_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Pop(); }

   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static RETURN_TYPE Get(ARRAY_TYPE array, int index, RETURN_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Get(index); }
   
   template <typename ARRAY_TYPE, typename DUMMY_TYPE, typename VALUE_TYPE>
   static void Set(ARRAY_TYPE array, int index, VALUE_TYPE value) { if (array == NULL) { return; } array.Set(index, value); }

   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static RETURN_TYPE Remove(ARRAY_TYPE array, int index, RETURN_TYPE emptyValue) { if (array == NULL) { return emptyValue; } return array.Remove(index); }
   
   static int Includes(ITArray<int>* array, int value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(ILineArray* array, Line* value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(ITArray<Box*>* array, Box* value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(IStringArray* array, string value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(IBoolArray* array, int value) { if (array == NULL) { return -1; } return array.Includes(value); }
   static int Includes(IColorArray* array, uint value) { if (array == NULL) { return -1; } return array.Includes(value); }

   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static ARRAY_TYPE PercentRank(ISimpleTypeArray<ARRAY_TYPE>* array) { if (array == NULL) { return -1; } return array.PercentRank(index); }

   template <typename RETURN_TYPE, typename ARRAY_TYPE, typename DUMMY_TYPE>
   static ARRAY_TYPE Stdev(ISimpleTypeArray<ARRAY_TYPE>* array) { if (array == NULL) { return -1; } return array.Stdev(); }
   
   static string Join(IStringArray* array, string concat)
   {
      string res = "";
      for (int i = 0; i < array.Size(); ++i)
      {
         string val = array.Get(i);
         if (val == NULL)
         {
            continue;
         }
         if (i > 0)
         {
            res += concat;
         }
         res += array.Get(i);
      }
      return res;
   }
};




//Signaler v3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start external program
input string   program_path             = ""; // Path to the external program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   advanced_server          = "https://profitrobots.com"; // Advanced alert server url
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

enum SignalerFrequency
{
   SignalsAll,
   SignalsOncePerBarClose,
   SignalsOncePerBar
};

class Signaler
{
   string _prefix;
   SignalerFrequency _frequency;
   datetime _lastSignal;
public:
   Signaler(string frequency)
   {
      if (frequency == "all")
      {
         _frequency = SignalsAll;
      }
      else if (frequency == "once_per_bar_close")
      {
         _frequency = SignalsOncePerBarClose;
      }
      else if (frequency == "once_per_bar")
      {
         _frequency = SignalsOncePerBar;
      }
      _lastSignal = 0;
   }
   Signaler()
   {
      _lastSignal = 0;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void ShowAlert(string message, int position, datetime time)
   {
      if (position != 0)
      {
         return;
      }
      if (_frequency != SignalsAll)
      {
         if (_lastSignal == time)
         {
            return;
         }
      }
      _lastSignal = time;
      SendNotifications("", message);
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
   }
};

// PlotShape v1.3
#ifndef PlotShape_IMPL
#define PlotShape_IMPL

class PlotShape
{
private:
   static void SetNA(double& plot[], int period)
   {
      plot[period] = EMPTY_VALUE;
   }
   
   static void SetValue(double& plot[], int period, string location, double seriesValue, const double& high[], const double& low[], int shift)
   {
      if (location == "abovebar" || location == "top")
      {
         plot[period] = high[period + shift];
         return;
      }
      if (location == "belowbar" || location == "bottom")
      {
         plot[period] = low[period + shift];
         return;
      }
      plot[period] = seriesValue;
   }
public:
   static void Set(double& plot[], int period, string location, double seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == EMPTY_VALUE || clr == INT_MAX)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void Set(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == INT_MIN || clr == INT_MAX)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void SetBool(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == -1 || seriesValue == 0 || clr == INT_MAX)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
};

#endif
// Table v1.1
// Interface for a cell v2.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw(int x, int y) = 0;
   virtual void HandleButtonClicks() = 0;
   virtual void Measure(int& width, int& height) = 0;
};

#endif
//Row size v1.0

class RowSize
{
   int _widths[];
   int _maxHeight;
public:
   void Add(int index, int width, int height)
   {
      int size = ArraySize(_widths);
      if (size <= index)
      {
         ArrayResize(_widths, index + 1);
      }
      _maxHeight = MathMax(_maxHeight, height);
      _widths[index] = MathMax(_widths[index], width);
   }

   int GetWidth(int index)
   {
      return _widths[index];
   }

   int GetMaxHeight()
   {
      return _maxHeight;
   }
};

// Row v2.2

#ifndef Row_IMP
#define Row_IMP

class Row
{
   ICell *_cells[];
public:
   ~Row() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         delete _cells[i]; 
      } 
   }

   void Measure(RowSize* rowSizes)
   {
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         int w, h;
         _cells[i].Measure(w, h);
         rowSizes.Add(i, w + 5, h + 5);
      } 
   }
   
   int GetColumnsCount()
   {
      return ArraySize(_cells);
   }

   void Draw(int x, int y, RowSize* rowSizes) 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].Draw(x, y);
         x += rowSizes.GetWidth(i);
      } 
   }

   void HandleButtonClicks() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].HandleButtonClicks(); 
      } 
   }
   
   ICell* GetCell(int index)
   {
      if (index < 0)
      {
         return NULL;
      }
      int count = ArraySize(_cells);
      if (index >= count)
      {
         return NULL;
      }
      return _cells[index];
   }

   void Add(ICell *cell) 
   {
      int count = ArraySize(_cells); 
      ArrayResize(_cells, count + 1); 
      _cells[count] = cell; 
   } 
};


#endif


// Grid v2.1

#ifndef Grid_IMP
#define Grid_IMP

class Grid
{
   Row *_rows[];
public:
   ~Grid()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         delete _rows[i];
      }
   }

   Row *AddRow()
   {
      int count = ArraySize(_rows);
      ArrayResize(_rows, count + 1);
      _rows[count] = new Row();
      return _rows[count];
   }
   
   Row *GetRow(const int index)
   {
      return _rows[index];
   }
   
   int GetRowsCount()
   {
      return ArraySize(_rows);
   }
   
   void Draw(int x, int y)
   {
      RowSize* widths = MeasureColumns();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         int w, h;
         _rows[i].Draw(x, y, widths);
         y += widths.GetMaxHeight();
      }
      delete widths;
   }

   void HandleButtonClicks()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].HandleButtonClicks();
      }
   }
private:
   RowSize* MeasureColumns()
   {
      RowSize* widths = new RowSize();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].Measure(widths);
      }
      return widths;
   }
};

#endif


// ACell v1.1

class ACell : public ICell
{
protected:
   void Measure(string text, string font, int fontSize, int& width, int& height)
   {
      TextSetFont(font, -fontSize * 10);
      TextGetSize(text, width, height);
   }
   void ObjectMakeLabel(string nm, int xoff, int yoff, string text, color LabelColor, int LabelCorner, int Window, string Font, int FSize)
   { 
      ObjectDelete(nm); 
      ObjectCreate(nm, OBJ_LABEL, Window, 0, 0); 
      ObjectSet(nm, OBJPROP_CORNER, LabelCorner); 
      ObjectSet(nm, OBJPROP_XDISTANCE, xoff); 
      ObjectSet(nm, OBJPROP_YDISTANCE, yoff); 
      ObjectSet(nm, OBJPROP_BACK, false); 
      ObjectSetText(nm, text, FSize, Font, LabelColor);
   }
};

// Label cell v4.0

#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ACell
{
   string _id;
   string _text; 
   ENUM_BASE_CORNER _corner;
   int _fontSize;
   uint _color;
   int _windowNumber;
   string _textHAlign;
   bool _withBackground;
   uint _bgColor;
   int _width;
   int _height;
   int _linesHeights[];
   int _linesWidths[];
public:
   LabelCell(const string id, const string text, ENUM_BASE_CORNER corner, int fontSize, uint clr, int windowNumber)
   { 
      _withBackground = false;
      _textHAlign = "cental";
      _corner = corner;
      _id = id; 
      _text = text;
      _fontSize = fontSize;
      _color = clr;
      _windowNumber = windowNumber;
   }

   virtual void Measure(int& width, int& height)
   {
      _width = 0;
      _height = 0;
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      ArrayResize(_linesHeights, linesCount);
      ArrayResize(_linesWidths, linesCount);
      for (int i = 0; i < linesCount; ++i)
      {
         int w, h;
         Measure(lines[i], "Arial", _fontSize, w, h);
         _height += h;
         _width = MathMax(_width, w);
         _linesHeights[i] = h;
         _linesWidths[i] = w;
      }
      width = _width;
      height = _height;
   }

   virtual void Draw(int x, int y) 
   {
      if (_withBackground)
      {
         ObjectCreate(_id + "rect", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, _id + "rect", OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YDISTANCE, y);
         ObjectSetInteger(0, _id + "rect", OBJPROP_BGCOLOR, _bgColor); 
         ObjectSetInteger(0, _id + "rect", OBJPROP_XSIZE, _width);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YSIZE, _height);
         ObjectSetInteger(0, _id + "rect", OBJPROP_COLOR, _color);
         ObjectSetInteger(0, _id + "rect", OBJPROP_CORNER, _corner);
      }
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      for (int i = 0; i < linesCount; ++i)
      {
         int lineX = x;
         if (_textHAlign == "center")
         {
            lineX += (_width - _linesWidths[i]) / 2;
         }
         else if (_textHAlign == "right")
         {
            lineX += _width - _linesWidths[i];
         }
         ObjectMakeLabel(_id + "line" + i, lineX, y, lines[i], _color, _corner, _windowNumber, "Arial", _fontSize); 
         y += _linesHeights[i];
      }
   }
   
   bool SetBgColor(uint clr)
   {
      if (_bgColor == clr)
      {
         return false;
      }
      _bgColor = clr;
      _withBackground = true;
      return true;
   }

   virtual void HandleButtonClicks()
   {
      
   }
   
   bool SetColor(uint clr)
   {
      if (_color == clr)
      {
         return false;
      }
      _color = clr;
      return true;
   }
   
   bool SetText(string text)
   {
      if (_text == text)
      {
         return false;
      }
      _text = text;
      return true;
   }
   
   bool SetFontSize(int fontSize)
   {
      if (_fontSize == fontSize)
      {
         return false;
      }
      _fontSize = fontSize;
      return true;
   }
   
   bool SetTextHAlign(string textHAlign)
   {
      if (_textHAlign == textHAlign)
      {
         return false;
      }
      _textHAlign = textHAlign;
      return true;
   }
};

#endif

class Table;
class TableManager
{
   static Table* tables[];
public:
   static void Clear(bool forced = false);
   static void Add(Table* table);
   static void Redraw();
   static Table* Create(string prefix, string tableIndex, string position, int columns, int rows);
};

Table* TableManager::Create(string prefix, string tableIndex, string position, int columns, int rows)
{
   string id = prefix + "_" + tableIndex;
   int tablesCount = ArraySize(tables);
   for (int i = 0; i < tablesCount; ++i)
   {
      if (tables[i].GetId() == id)
      {
         return tables[i];
      }
   }
   return new Table(id, position, columns, rows);
}

Table* TableManager::tables[];
void TableManager::Clear(bool forced = false)
{
   int movedIndex = 0;
   for (int i = 0; i < ArraySize(TableManager::tables); ++i)
   {
      if (!tables[i].IsLocked())
      {
         delete tables[i];
      }
      else
      {
         tables[movedIndex] = tables[i];
         ++movedIndex;
      }
   }
   ArrayResize(tables, movedIndex);
}

void TableManager::Add(Table* table)
{
   int size = ArraySize(tables);
   ArrayResize(tables, size + 1);
   tables[size] = table;
}

void TableManager::Redraw()
{
   for (int i = 0; i < ArraySize(tables); ++i)
   {
      tables[i].Redraw();
   }
}

enum TablePosition
{
   TablePositionTopLeft,
   TablePositionTopCenter,
   TablePositionTopRight,
   TablePositionMiddleLeft,
   TablePositionMiddleCenter,
   TablePositionMiddleRight,
   TablePositionBottomLeft,
   TablePositionBottomCenter,
   TablePositionBottomRight
};

TablePosition TablePositionFromString(string value)
{
   if (value == "top_left") return TablePositionTopLeft;
   if (value == "top_center") return TablePositionTopCenter;
   if (value == "top_right") return TablePositionTopRight;
   if (value == "middle_left") return TablePositionMiddleLeft;
   if (value == "middle_center") return TablePositionMiddleCenter;
   if (value == "middle_right") return TablePositionMiddleRight;
   if (value == "bottom_left") return TablePositionBottomLeft;
   if (value == "bottom_center") return TablePositionBottomCenter;
   if (value == "bottom_right") return TablePositionBottomRight;
   return TablePositionMiddleCenter;
}

class Table
{
   string _prefix;
   TablePosition _position;
   int _columns;
   int _rows;

   int _borderWidth;
   uint _borderColor;
   
   int _frameWidth;
   uint _frameColor;
   Grid* _grid;
   bool locked;
public:
   Table(string prefix, string position, int columns, int rows)
   {
      locked = false;
      if (columns == EMPTY_VALUE)
      {
         columns = 0;
      }
      if (rows == EMPTY_VALUE)
      {
         rows = 0;
      }
      _prefix = prefix;
      _position = TablePositionFromString(position);
      _columns = columns;
      _rows = rows;
      _borderWidth = 0;
      _frameWidth = 0;
      _grid = new Grid();
      for (int i = 0; i < rows; ++i)
      {
         Row* row = _grid.AddRow();
         for (int j = 0; j < columns; ++j)
         {
            string id = _prefix + "_cell_" + IntegerToString(i) + "_" + IntegerToString(j);
            row.Add(new LabelCell(id, "", CORNER_LEFT_UPPER, 10, Red, 0));
         }
      }
      Redraw();
      TableManager::Add(&this);
   }
   ~Table()
   {
      delete _grid;
   }
   
   void Lock()
   {
      locked = true;
   }
   void Unlock()
   {
      locked = false;
   }
   bool IsLocked()
   {
      return locked;
   }
   
   string GetId()
   {
      return _prefix;
   }

   Table* SetBorderColor(uint clr)
   {
      _borderColor = clr;
      return &this;
   }
   Table* SetBorderWidth(int borderWidth)
   {
      _borderWidth = borderWidth;
      return &this;
   }
   Table* SetBGColor(uint clr)
   {
      for (int row = 0; row < _grid.GetRowsCount(); ++row)
      {
         Row* gridRow = _grid.GetRow(row);
         for (int column = 0; column < gridRow.GetColumnsCount(); ++column)
         {
            LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
            cell.SetBgColor(clr);
         }
      }
      return &this;
   }
   
   Table* SetFrameColor(uint clr)
   {
      _frameColor = clr;
      return &this;
   }
   Table* SetFrameWidth(int frameWidth)
   {
      _frameWidth = frameWidth;
      return &this;
   }
   static void CellText(Table* table, int column, int row, string text)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellText(column, row, text);
   }
   void CellText(int column, int row, string text)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetText(text))
      {
         Redraw();
      }
   }
   static void CellTextColor(Table* table, int column, int row, uint clr)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextColor(column, row, clr);
   }
   void CellTextColor(int column, int row, uint clr)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetColor(clr))
      {
      }
   }
   static void CellTextSize(Table* table, int column, int row, string size)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextSize(column, row, size);
   }
   void CellTextSize(int column, int row, string size)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetFontSize(GetFontSize(size)))
      {
      }
   }
   
   static void CellBGColor(Table* table, int column, int row, uint clr)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellBGColor(column, row, clr);
   }
   void CellBGColor(int column, int row, uint clr)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      cell.SetBgColor(clr);
   }
   
   static void CellTextHAlign(Table* table, int column, int row, string halign)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextHAlign(column, row, halign);
   }
   void CellTextHAlign(int column, int row, string halign)
   {
      Row* gridRow = _grid.GetRow(row);
      LabelCell* cell = (LabelCell*)gridRow.GetCell(column);
      if (cell.SetTextHAlign(halign))
      {
      }
   }
   
   void Redraw()
   {
      int x = 0;
      int y = 0;
      switch (_position)
      {
         case TablePositionTopLeft:
            break;
         case TablePositionTopCenter:
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionTopRight:
            x = GetScreenWidth() - GetGridWidth();
            break;
         case TablePositionMiddleLeft:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            break;
         case TablePositionMiddleCenter:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionMiddleRight:
            y = (GetScreenHeight() - GetGridHeight()) / 2;
            x = GetScreenWidth() - GetGridWidth();
            break;
         case TablePositionBottomLeft:
            y = GetScreenHeight() - GetGridHeight();
            break;
         case TablePositionBottomCenter:
            y = GetScreenHeight() - GetGridHeight();
            x = (GetScreenWidth() - GetGridWidth()) / 2;
            break;
         case TablePositionBottomRight:
            y = GetScreenHeight() - GetGridHeight();
            x = GetScreenWidth() - GetGridWidth();
            break;
      }
      _grid.Draw(x, y);
   }
private:
   int GetFontSize(string size)
   {
      if (size == "auto" || size == "normal")
      {
         return 10;
      }
      if (size == "tiny")
      {
         return 6;
      }
      if (size == "small")
      {
         return 8;
      }
      if (size == "large")
      {
         return 12;
      }
      if (size == "huge")
      {
         return 14;
      }
      return 10;
   }
   int GetScreenWidth()
   {
      return ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   }
   int GetGridWidth()
   {
      int width = 0;
      for (int i = 0; i < _rows; ++i)
      {
         RowSize* rowSizes = new RowSize();
         _grid.GetRow(i).Measure(rowSizes);
         int rowWidth = 0;
         for (int ii = 0; ii < _columns; ++ii)
         {
            rowWidth += rowSizes.GetWidth(ii);
         }
         delete rowSizes;
         width = MathMax(width, rowWidth);
      }
      return width;
   }
   int GetScreenHeight()
   {
      return ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
   }
   int GetGridHeight()
   {
      int height = 0;
      for (int i = 0; i < _rows; ++i)
      {
         RowSize* rowSizes = new RowSize();
         _grid.GetRow(i).Measure(rowSizes);
         height = MathMax(height, rowSizes.GetMaxHeight());
         delete rowSizes;
      }
      return height;
   }
};

// str.* functions from Pine Script
// v1.1

class Str
{
public:
   static string ToString(int value, string format)
   {
      if (format == "percent")
      {
         return IntegerToString(value, 2) + "%";
      }
      return IntegerToString(value);
   }
   static string ToString(double value, string format)
   {
      if (format == "percent")
      {
         return DoubleToString(value, 2) + "%";
      }
      return DoubleToString(value);
   }
   static string ToString(double value)
   {
      return DoubleToString(value);
   }
   static string ToString(int value)
   {
      return IntegerToString(value);
   }
   static string ToString(string value)
   {
      return value;
   }
   static string ReplaceAll(string source, string target, string replaceWith)
   {
      StringReplace(source, target, replaceWith);
      return source;
   }
   static bool Contains(string source, string str)
   {
      return StringFind(source, str) >= 0;
   }
   static int Length(string str)
   {
      return StringLen(str);
   }
};

enum StrFormatValueType
{
   String,
   Integer,
   Float
};
interface IStrFormatValue
{
public:
   virtual StrFormatValueType GetType() = 0;
};
class StrFormatStringValue : public IStrFormatValue
{
   string value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::String;
   }
   
   void SetValue(string val)
   {
      value = val;
   }
   string GetValue()
   {
      return value;
   }
};
class StrFormatIntValue : public IStrFormatValue
{
   int value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::Integer;
   }
   
   void SetValue(int val)
   {
      value = val;
   }
   int GetValue()
   {
      return value;
   }
};
class StrFormatDoubleValue : public IStrFormatValue
{
   double value;
public:
   StrFormatValueType GetType() 
   {
      return StrFormatValueType::Float;
   }
   
   void SetValue(double val)
   {
      value = val;
   }
   double GetValue()
   {
      return value;
   }
};
class StrFormat
{
   string format;
   IStrFormatValue* values[];
   int nextValueIndex;
public:
   StrFormat(string format)
   {
      this.format = format;
      nextValueIndex = 0;
   }
   ~StrFormat()
   {
      int size = ArraySize(values);
      for (int i = 0; i < size; ++i)
      {
         delete values[i];
      }
   }
   
   StrFormat* Add(string value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatStringValue();
      }
      ((StrFormatStringValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   StrFormat* Add(int value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatIntValue();
      }
      ((StrFormatIntValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   StrFormat* Add(double value)
   {
      int size = ArraySize(values);
      if (size <= nextValueIndex)
      {
         ArrayResize(values, nextValueIndex + 1);
         values[nextValueIndex] = new StrFormatDoubleValue();
      }
      ((StrFormatDoubleValue*)values[nextValueIndex]).SetValue(value);
      nextValueIndex = nextValueIndex + 1;
      return &this;
   }
   
   string Format()
   {
      int size = ArraySize(values);
      string res = format;
      for (int i = 0; i < size; ++i)
      {
         int pos = StringFind(res, "{" + IntegerToString(i));
         if (pos < 0)
         {
            continue;
         }
         int end = StringFind(res, "}", pos + 1);
         if (end < 0)
         {
            continue;
         }
         switch (values[i].GetType())
         {
         case StrFormatValueType::String:
            {
               string strValue = ((StrFormatStringValue*)values[i]).GetValue();
               res = StringSubstr(res, 0, pos) + strValue + StringSubstr(res, end + 1);
            }
            break;
         case StrFormatValueType::Integer:
            {
               int intValue = ((StrFormatIntValue*)values[i]).GetValue();
               string numberFormat = StringSubstr(res, pos + 1, end - pos - 1);
               
               res = StringSubstr(res, 0, pos) + FormatIntValue(intValue, numberFormat) + StringSubstr(res, end + 1);
            }
            break;
         case StrFormatValueType::Float:
            {
               double doubleValue = ((StrFormatDoubleValue*)values[i]).GetValue();
               res = StringSubstr(res, 0, pos) + DoubleToString(doubleValue) + StringSubstr(res, end + 1);
            }
            break;
         }
      }
      nextValueIndex = 0;
      return res;
   }
private:
   string FormatIntValue(int intValue, string numberFormat)
   {
      string tokens[];
      int count = StringSplit(numberFormat, ',', tokens);
      if (count == 1 || tokens[1] != "number")
      {
          return IntegerToString(intValue);
      }
      int precision = GetPrecision(tokens[2]);
      if (precision == 0)
      {
         return IntegerToString(intValue);
      }
      return DoubleToString(intValue, precision);
   }
   
   int GetPrecision(string format)
   {
      int pointPos = StringFind(format, ".");
      if (pointPos < 0)
      {
         return -1;
      }
      return StringLen(format) - pointPos;
   }
};
input bool param1 = true; // Daily Bias
input bool param2 = false; // Weekly Bias
input bool param3 = true; // Show Bias Reasoning
input color param4 = Teal; // Bull / Bear Bias Colors
input color param5 = Red; // 
input bool param6 = true; // Plot Daily Bias
input bool param7 = true; // Plot Weekly Bias
enum param8_enum
{
   param8_value_1, // Top
   param8_value_2 // Bottom
};
input param8_enum param8_e = param8_value_1; // 
string Get_param8()
{
   switch (param8_e)
   {
      case param8_value_1: return "Top";
      case param8_value_2: return "Bottom";
   }
   return NULL;
}
enum param9_enum
{
   param9_value_1, // Top
   param9_value_2 // Bottom
};
input param9_enum param9_e = param9_value_2; // 
string Get_param9()
{
   switch (param9_e)
   {
      case param9_value_1: return "Top";
      case param9_value_2: return "Bottom";
   }
   return NULL;
}
input color param10 = Blue; // Before / After Hit Colors
input color param11 = Red; // 
input bool param12 = false; // Stop Extending Lines After Hit
input bool param13 = true; // Day Separator
input bool param14 = true; // Week Separator
input color param15 = AddTransparency(Black, 80); // 
input color param16 = AddTransparency(Black, 30); // 
input int param17 = 1; // Line Width
input bool param18 = true; // Show Statistics
enum param19_enum
{
   param19_value_1, // Bottom Center
   param19_value_2, // Bottom Left
   param19_value_3, // Bottom Right
   param19_value_4, // Middle Center
   param19_value_5, // Middle Left
   param19_value_6, // Middle Right
   param19_value_7, // Top Center
   param19_value_8, // Top Left
   param19_value_9 // Top Right
};
input param19_enum param19_e = param19_value_9; // Position
string Get_param19()
{
   switch (param19_e)
   {
      case param19_value_1: return "Bottom Center";
      case param19_value_2: return "Bottom Left";
      case param19_value_3: return "Bottom Right";
      case param19_value_4: return "Middle Center";
      case param19_value_5: return "Middle Left";
      case param19_value_6: return "Middle Right";
      case param19_value_7: return "Top Center";
      case param19_value_8: return "Top Left";
      case param19_value_9: return "Top Right";
   }
   return NULL;
}
enum param20_enum
{
   param20_value_1, // Auto
   param20_value_2, // Tiny
   param20_value_3, // Small
   param20_value_4, // Normal
   param20_value_5, // Large
   param20_value_6 // Huge
};
input param20_enum param20_e = param20_value_4; // Size
string Get_param20()
{
   switch (param20_e)
   {
      case param20_value_1: return "Auto";
      case param20_value_2: return "Tiny";
      case param20_value_3: return "Small";
      case param20_value_4: return "Normal";
      case param20_value_5: return "Large";
      case param20_value_6: return "Huge";
   }
   return NULL;
}
enum param21_enum
{
   param21_value_1, // Bottom Center
   param21_value_2, // Bottom Left
   param21_value_3, // Bottom Right
   param21_value_4, // Middle Center
   param21_value_5, // Middle Left
   param21_value_6, // Middle Right
   param21_value_7, // Top Center
   param21_value_8, // Top Left
   param21_value_9 // Top Right
};
input param21_enum param21_e = param21_value_9; // Position
string Get_param21()
{
   switch (param21_e)
   {
      case param21_value_1: return "Bottom Center";
      case param21_value_2: return "Bottom Left";
      case param21_value_3: return "Bottom Right";
      case param21_value_4: return "Middle Center";
      case param21_value_5: return "Middle Left";
      case param21_value_6: return "Middle Right";
      case param21_value_7: return "Top Center";
      case param21_value_8: return "Top Left";
      case param21_value_9: return "Top Right";
   }
   return NULL;
}
enum param22_enum
{
   param22_value_1, // Auto
   param22_value_2, // Tiny
   param22_value_3, // Small
   param22_value_4, // Normal
   param22_value_5, // Large
   param22_value_6 // Huge
};
input param22_enum param22_e = param22_value_4; // Size
string Get_param22()
{
   switch (param22_e)
   {
      case param22_value_1: return "Auto";
      case param22_value_2: return "Tiny";
      case param22_value_3: return "Small";
      case param22_value_4: return "Normal";
      case param22_value_5: return "Large";
      case param22_value_6: return "Huge";
   }
   return NULL;
}
input int bars_limit = 100000; // Bars limit
string g_VIS;
int d_stats;
int w_stats;
int bias_reason;
string g_PLT;
uint bull_color;
uint bear_color;
int d_bias_plot;
int w_bias_plot;
string d_bias_loc;
string w_bias_loc;
string g_STY;
uint before_raid_color;
uint after_raid_color;
int stop_ext;
int use_d_sep;
int use_w_sep;
uint d_sep;
uint w_sep;
int line_width;
string g_TBL;
int tbl_show_stats;
string tbl_loc;
string tbl_size;
int new_day;
int new_week;
int can_plot_d;
int can_plot_w;
class _lines
{
   int _refs;
public:
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   _lines(_lines* src)
   {
      _refs = 1;
      this.ph_line = src.ph_line;
      this.pl_line = src.pl_line;
      this.hit_ph_line = src.hit_ph_line;
      this.hit_pl_line = src.hit_pl_line;
   }
   _lines(Line* ph_line = NULL, Line* pl_line = NULL, int hit_ph_line = false, int hit_pl_line = false)
   {
      _refs = 1;
      this.ph_line = ph_line;
      this.pl_line = pl_line;
      this.hit_ph_line = hit_ph_line;
      this.hit_pl_line = hit_pl_line;
   }
   ~_lines()
   {
   }
   Line* ph_line;
   static Line* Getph_line(_lines* self) { return self == NULL ? NULL : self.ph_line; }
   static void Setph_line(_lines* self, Line* val) { if (self == NULL) return; self.Setph_line(val); } 
   _lines* Setph_line(Line* val) { this.ph_line = val; return &this; }
   Line* pl_line;
   static Line* Getpl_line(_lines* self) { return self == NULL ? NULL : self.pl_line; }
   static void Setpl_line(_lines* self, Line* val) { if (self == NULL) return; self.Setpl_line(val); } 
   _lines* Setpl_line(Line* val) { this.pl_line = val; return &this; }
   int hit_ph_line;
   static int Gethit_ph_line(_lines* self) { return self == NULL ? (-1) : self.hit_ph_line; }
   static void Sethit_ph_line(_lines* self, int val) { if (self == NULL) return; self.Sethit_ph_line(val); } 
   _lines* Sethit_ph_line(int val) { this.hit_ph_line = val; return &this; }
   int hit_pl_line;
   static int Gethit_pl_line(_lines* self) { return self == NULL ? (-1) : self.hit_pl_line; }
   static void Sethit_pl_line(_lines* self, int val) { if (self == NULL) return; self.Sethit_pl_line(val); } 
   _lines* Sethit_pl_line(int val) { this.hit_pl_line = val; return &this; }
};
class info
{
   int _refs;
public:
   void AddRef() { _refs++; }
   int Release() { int refs = --_refs; if (refs == 0) { delete &this; } return refs; }
   info(info* src)
   {
      _refs = 1;
      this.ph = src.ph;
      this.pl = src.pl;
      this.ch = src.ch;
      this.cl = src.cl;
      this.co = src.co;
      this.p_up = src.p_up;
      this.bias = src.bias;
      this.bias_ph = src.bias_ph;
      this.bias_pl = src.bias_pl;
      this.hit_ph = src.hit_ph;
      this.hit_pl = src.hit_pl;
      this.close_ph = src.close_ph;
      this.close_pl = src.close_pl;
   }
   info(double ph = EMPTY_VALUE, double pl = EMPTY_VALUE, double ch = EMPTY_VALUE, double cl = EMPTY_VALUE, double co = EMPTY_VALUE, int p_up = (-1), int bias = 0, int bias_ph = 0, int bias_pl = 0, int hit_ph = 0, int hit_pl = 0, int close_ph = 0, int close_pl = 0)
   {
      _refs = 1;
      this.ph = ph;
      this.pl = pl;
      this.ch = ch;
      this.cl = cl;
      this.co = co;
      this.p_up = p_up;
      this.bias = bias;
      this.bias_ph = bias_ph;
      this.bias_pl = bias_pl;
      this.hit_ph = hit_ph;
      this.hit_pl = hit_pl;
      this.close_ph = close_ph;
      this.close_pl = close_pl;
   }
   ~info()
   {
   }
   double ph;
   static double Getph(info* self) { return self == NULL ? EMPTY_VALUE : self.ph; }
   static void Setph(info* self, double val) { if (self == NULL) return; self.Setph(val); } 
   info* Setph(double val) { this.ph = val; return &this; }
   double pl;
   static double Getpl(info* self) { return self == NULL ? EMPTY_VALUE : self.pl; }
   static void Setpl(info* self, double val) { if (self == NULL) return; self.Setpl(val); } 
   info* Setpl(double val) { this.pl = val; return &this; }
   double ch;
   static double Getch(info* self) { return self == NULL ? EMPTY_VALUE : self.ch; }
   static void Setch(info* self, double val) { if (self == NULL) return; self.Setch(val); } 
   info* Setch(double val) { this.ch = val; return &this; }
   double cl;
   static double Getcl(info* self) { return self == NULL ? EMPTY_VALUE : self.cl; }
   static void Setcl(info* self, double val) { if (self == NULL) return; self.Setcl(val); } 
   info* Setcl(double val) { this.cl = val; return &this; }
   double co;
   static double Getco(info* self) { return self == NULL ? EMPTY_VALUE : self.co; }
   static void Setco(info* self, double val) { if (self == NULL) return; self.Setco(val); } 
   info* Setco(double val) { this.co = val; return &this; }
   int p_up;
   static int Getp_up(info* self) { return self == NULL ? (-1) : self.p_up; }
   static void Setp_up(info* self, int val) { if (self == NULL) return; self.Setp_up(val); } 
   info* Setp_up(int val) { this.p_up = val; return &this; }
   int bias;
   static int Getbias(info* self) { return self == NULL ? INT_MIN : self.bias; }
   static void Setbias(info* self, int val) { if (self == NULL) return; self.Setbias(val); } 
   info* Setbias(int val) { this.bias = val; return &this; }
   int bias_ph;
   static int Getbias_ph(info* self) { return self == NULL ? INT_MIN : self.bias_ph; }
   static void Setbias_ph(info* self, int val) { if (self == NULL) return; self.Setbias_ph(val); } 
   info* Setbias_ph(int val) { this.bias_ph = val; return &this; }
   int bias_pl;
   static int Getbias_pl(info* self) { return self == NULL ? INT_MIN : self.bias_pl; }
   static void Setbias_pl(info* self, int val) { if (self == NULL) return; self.Setbias_pl(val); } 
   info* Setbias_pl(int val) { this.bias_pl = val; return &this; }
   int hit_ph;
   static int Gethit_ph(info* self) { return self == NULL ? INT_MIN : self.hit_ph; }
   static void Sethit_ph(info* self, int val) { if (self == NULL) return; self.Sethit_ph(val); } 
   info* Sethit_ph(int val) { this.hit_ph = val; return &this; }
   int hit_pl;
   static int Gethit_pl(info* self) { return self == NULL ? INT_MIN : self.hit_pl; }
   static void Sethit_pl(info* self, int val) { if (self == NULL) return; self.Sethit_pl(val); } 
   info* Sethit_pl(int val) { this.hit_pl = val; return &this; }
   int close_ph;
   static int Getclose_ph(info* self) { return self == NULL ? INT_MIN : self.close_ph; }
   static void Setclose_ph(info* self, int val) { if (self == NULL) return; self.Setclose_ph(val); } 
   info* Setclose_ph(int val) { this.close_ph = val; return &this; }
   int close_pl;
   static int Getclose_pl(info* self) { return self == NULL ? INT_MIN : self.close_pl; }
   static void Setclose_pl(info* self, int val) { if (self == NULL) return; self.Setclose_pl(val); } 
   info* Setclose_pl(int val) { this.close_pl = val; return &this; }
};
info* d_info;
info* w_info;
ICustomTypeArray<_lines*>* d_lines;
ICustomTypeArray<_lines*>* w_lines;
class handle_bias_1Stream
{
   string tf;
   Signaler* _signaler1;
   Signaler* _signaler2;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   handle_bias_1Stream(string tf, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.tf = tf;
   }
   ~handle_bias_1Stream()
   {
      delete _signaler1;
      delete _signaler2;
   }
   int Init(int id)
   {
      _signaler1 = new Signaler("once_per_bar");
      _signaler2 = new Signaler("once_per_bar");
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, info* __n)
   {
      info* n = __n;
      string _yloc = "price";
      string _style = ((tf == "D") ? "up" : "down");
      double _y = ((tf == "D") ? info::Getcl(n) : info::Getch(n));
      int can_plot = ((tf == "D") ? can_plot_d : can_plot_w);
      if (SafeGreater(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1), info::Getph(n)))
      {
         if ((info::Getbias(n) == 1))
         {
            info::Setclose_ph(n, info::Getclose_ph(n) + 1);
         }
         info::Setbias(n, 1);
         if (bias_reason && can_plot)
         {
            string txt = "Close Above P" + tf + "H\nBias P" + tf + "H";
            LabelsCollection::Create(IndicatorObjPrefix + "label_1_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), _y, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(ChartGetInteger(0, CHART_COLOR_BACKGROUND)).SetText(txt).SetTextColor(ChartGetInteger(0, CHART_COLOR_FOREGROUND)).SetStyle(_style).SetSize("normal").SetYLoc(_yloc).SetTextAlign("center");
         }
      }
      else if ((iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) < info::Getpl(n)))
      {
         if ((info::Getbias(n) == (-1)))
         {
            info::Setclose_pl(n, info::Getclose_pl(n) + 1);
         }
         info::Setbias(n, (-1));
         if (bias_reason && can_plot)
         {
            string txt = "Close Below P" + tf + "L\nBias P" + tf + "L";
            LabelsCollection::Create(IndicatorObjPrefix + "label_2_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), _y, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(ChartGetInteger(0, CHART_COLOR_BACKGROUND)).SetText(txt).SetTextColor(ChartGetInteger(0, CHART_COLOR_FOREGROUND)).SetStyle(_style).SetSize("normal").SetYLoc(_yloc).SetTextAlign("center");
         }
      }
      else if ((iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) < info::Getph(n)) && SafeGreater(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1), info::Getpl(n)) && (info::Getch(n) > info::Getph(n)) && (info::Getcl(n) > info::Getpl(n)))
      {
         info::Setbias(n, (-1));
         if (bias_reason && can_plot)
         {
            string txt = "Failed to Close Above P" + tf + "H\nBias P" + tf + "L";
            LabelsCollection::Create(IndicatorObjPrefix + "label_3_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), _y, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(ChartGetInteger(0, CHART_COLOR_BACKGROUND)).SetText(txt).SetTextColor(ChartGetInteger(0, CHART_COLOR_FOREGROUND)).SetStyle(_style).SetSize("normal").SetYLoc(_yloc).SetTextAlign("center");
         }
      }
      else if (SafeGreater(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1), info::Getpl(n)) && (iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos) < info::Getph(n)) && (info::Getch(n) < info::Getph(n)) && (info::Getcl(n) < info::Getpl(n)))
      {
         info::Setbias(n, 1);
         if (bias_reason && can_plot)
         {
            string txt = "Failed to Close Below P" + tf + "L\nBias P" + tf + "H";
            LabelsCollection::Create(IndicatorObjPrefix + "label_4_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), _y, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(ChartGetInteger(0, CHART_COLOR_BACKGROUND)).SetText(txt).SetTextColor(ChartGetInteger(0, CHART_COLOR_FOREGROUND)).SetStyle(_style).SetSize("normal").SetYLoc(_yloc).SetTextAlign("center");
         }
      }
      else if ((info::Getch(n) <= info::Getph(n)) && (info::Getcl(n) >= info::Getpl(n)))
      {
         if (info::Getp_up(n))
         {
            info::Setbias(n, 1);
         }
         if (bias_reason && can_plot)
         {
            string txt = "Close Inside\nBias P" + tf + ((info::Getp_up(n) ? "H" : "L"));
            LabelsCollection::Create(IndicatorObjPrefix + "label_5_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), _y, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(ChartGetInteger(0, CHART_COLOR_BACKGROUND)).SetText(txt).SetTextColor(ChartGetInteger(0, CHART_COLOR_FOREGROUND)).SetStyle(_style).SetSize("normal").SetYLoc(_yloc).SetTextAlign("center");
         }
      }
      else
      {
         info::Setbias(n, 0);
         if (bias_reason && can_plot)
         {
            string txt = "Outside Bar but Closed Inside\nNo Bias";
            LabelsCollection::Create(IndicatorObjPrefix + "label_6_id", ((iBars(_Symbol, (ENUM_TIMEFRAMES)_Period) - 1) - pos), _y, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor(ChartGetInteger(0, CHART_COLOR_BACKGROUND)).SetText(txt).SetTextColor(ChartGetInteger(0, CHART_COLOR_FOREGROUND)).SetStyle(_style).SetSize("normal").SetYLoc(_yloc).SetTextAlign("center");
         }
      }
      if ((info::Getbias(n) == 1))
      {
         info::Setbias_ph(n, info::Getbias_ph(n) + 1);
         _signaler1.ShowAlert("Bias P" + tf + "H", pos, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
      }
      else if ((info::Getbias(n) == (-1)))
      {
         info::Setbias_pl(n, info::Getbias_pl(n) + 1);
         _signaler2.ShowAlert("Bias P" + tf + "L", pos, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
      }
      return true;
   }
};
class update_info_1Stream
{
   string tf;
   handle_bias_1Stream* handle_bias_11;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   update_info_1Stream(string tf, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.tf = tf;
   }
   ~update_info_1Stream()
   {
      delete handle_bias_11;
   }
   int Init(int id)
   {
      handle_bias_11 = new handle_bias_1Stream(tf, IndicatorObjPrefix + "_1");
      id = handle_bias_11.Init(id);
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, info* __n, double &__out1)
   {
      if (!_initialized)
      {
         handle_bias_11.Clear();
         _initialized = true;
      }
      info* n = __n;
      if ((((tf == "D") ? new_day : new_week)))
      {
         if (!((info::Getch(n)) == EMPTY_VALUE))
         {
            if (!handle_bias_11.GetValue(pos, n)) { }
            if (SafeGE(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, pos + 1), info::Getco(n)))
            {
               info::Setp_up(n, true);
            }
            else
            {
               info::Setp_up(n, false);
            }
            info::Setph(n, info::Getch(n));
            info::Setpl(n, info::Getcl(n));
            info::Setch(n, iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
            info::Setcl(n, iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
            info::Setco(n, iOpen(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
         }
      }
      if (((info::Getch(n)) == EMPTY_VALUE))
      {
         info::Setch(n, iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
         info::Setch(n, iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
         __out1 = info::Getch(n);
      }
      else
      {
         info::Setch(n, MathMax(iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), info::Getch(n)));
         info::Setcl(n, MathMin(iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), info::Getcl(n)));
         __out1 = info::Getcl(n);
      }
      return true;
   }
};
update_info_1Stream* update_info_12;
class update_lines_1Stream
{
   string tf;
   Signaler* _signaler3;
   Signaler* _signaler4;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   update_lines_1Stream(string tf, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.tf = tf;
   }
   ~update_lines_1Stream()
   {
      delete _signaler3;
      delete _signaler4;
   }
   int Init(int id)
   {
      _signaler3 = new Signaler("once_per_bar");
      _signaler4 = new Signaler("once_per_bar");
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, ICustomTypeArray<_lines*>* __L, info* __n, int &__out1, int &__out2)
   {
      ICustomTypeArray<_lines*>* L = __L;
      info* n = __n;
      int hit_high = false;
      int hit_low = false;
      int can_plot = ((tf == "D") ? can_plot_d : can_plot_w);
      if ((((tf == "D") ? new_day : new_week)))
      {
         Array::Pop<_lines*, ICustomTypeArray<_lines*>*>(L, NULL);
         int _right = SafePlus(iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), SafeMultiply(Timeframe::InSeconds(tf), 1000));
         string _style = ((tf == "D") ? "solid" : "dashed");
         Array::Unshift<ICustomTypeArray<_lines*>*, _lines*>(L, new _lines(LinesCollection::Create(IndicatorObjPrefix + "line_3_id", iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), info::Getph(n), _right, info::Getph(n), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor((can_plot ? before_raid_color : INT_MAX)).SetWidth(line_width).SetStyle(_style).SetExtend("none").SetXLoc("bar_time"), LinesCollection::Create(IndicatorObjPrefix + "line_4_id", iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), info::Getpl(n), _right, info::Getpl(n), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos)).SetColor((can_plot ? before_raid_color : INT_MAX)).SetWidth(line_width).SetStyle(_style).SetExtend("none").SetXLoc("bar_time"), false, false));
      }
      int for1_from = 0;
      int for1_to = SafeMinus(Array::Size<int, ICustomTypeArray<_lines*>*>(L, INT_MIN), 1);
      bool for1_forward = for1_from <= for1_to;
      int for1_step = 1 * (for1_forward ? 1 : -1);
      if (for1_from == INT_MIN || for1_to == INT_MIN) { return false; }
      for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
      {
         _lines* x = Array::Get<_lines*, ICustomTypeArray<_lines*>*, int>(L, i, NULL);
         if (!((_lines::Getph_line(x)) == NULL))
         {
            if (SafeGE(iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), Line::GetY1(_lines::Getph_line(x))) && !_lines::Gethit_ph_line(x))
            {
               if (stop_ext)
               {
                  Line::SetX2(_lines::Getph_line(x), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
               }
               if ((info::Getbias(n) == 1))
               {
                  info::Sethit_ph(n, info::Gethit_ph(n) + 1);
               }
               _lines::Sethit_ph_line(x, true);
               if (can_plot)
               {
                  Line::SetColor(_lines::Getph_line(x), after_raid_color);
               }
               hit_high = true;
               _signaler3.ShowAlert("Hit P" + tf + "H", pos, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
            }
            if (SafeLE(iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, pos), Line::GetY1(_lines::Getpl_line(x))) && !_lines::Gethit_pl_line(x))
            {
               if (stop_ext)
               {
                  Line::SetX2(_lines::Getpl_line(x), iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
               }
               if ((info::Getbias(n) == (-1)))
               {
                  info::Sethit_pl(n, info::Gethit_pl(n) + 1);
               }
               _lines::Sethit_pl_line(x, true);
               if (can_plot)
               {
                  Line::SetColor(_lines::Getpl_line(x), after_raid_color);
               }
               hit_low = true;
               _signaler4.ShowAlert("Hit P" + tf + "L", pos, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, pos));
            }
         }
      }
      __out1 = hit_high;
      __out2 = hit_low;
      return true;
   }
};
update_lines_1Stream* update_lines_13;
update_info_1Stream* update_info_14;
update_lines_1Stream* update_lines_15;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
Signaler* _signaler;
class get_table_pos_1Stream
{
   string _pos;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   get_table_pos_1Stream(string _pos, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this._pos = _pos;
   }
   ~get_table_pos_1Stream()
   {
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, string &__out1)
   {
      string switch1Value1 = NULL;
      if ((_pos == "Bottom Center"))
      {
         switch1Value1 = "bottom_center";
      }
      else if ((_pos == "Bottom Left"))
      {
         switch1Value1 = "bottom_left";
      }
      else if ((_pos == "Bottom Right"))
      {
         switch1Value1 = "bottom_right";
      }
      else if ((_pos == "Middle Center"))
      {
         switch1Value1 = "middle_center";
      }
      else if ((_pos == "Middle Left"))
      {
         switch1Value1 = "middle_left";
      }
      else if ((_pos == "Middle Right"))
      {
         switch1Value1 = "middle_right";
      }
      else if ((_pos == "Top Center"))
      {
         switch1Value1 = "top_center";
      }
      else if ((_pos == "Top Left"))
      {
         switch1Value1 = "top_left";
      }
      else if ((_pos == "Top Right"))
      {
         switch1Value1 = "top_right";
      }
      __out1 = switch1Value1;
      return true;
   }
};
get_table_pos_1Stream* get_table_pos_16;
Table* stats;
class get_table_size_1Stream
{
   string size;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   get_table_size_1Stream(string size, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.size = size;
   }
   ~get_table_size_1Stream()
   {
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, string &__out1)
   {
      string switch2Value1 = NULL;
      if ((size == "Tiny"))
      {
         switch2Value1 = "tiny";
      }
      else if ((size == "Small"))
      {
         switch2Value1 = "small";
      }
      else if ((size == "Normal"))
      {
         switch2Value1 = "normal";
      }
      else if ((size == "Large"))
      {
         switch2Value1 = "large";
      }
      else if ((size == "Huge"))
      {
         switch2Value1 = "huge";
      }
      else if ((size == "Auto"))
      {
         switch2Value1 = "auto";
      }
      __out1 = switch2Value1;
      return true;
   }
};
get_table_size_1Stream* get_table_size_17;
string text_size;
class format_color_1Stream
{
   int bull;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   format_color_1Stream(int bull, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.bull = bull;
   }
   ~format_color_1Stream()
   {
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, info* __n, ICustomTypeArray<_lines*>* __L, uint &__out1)
   {
      info* n = __n;
      ICustomTypeArray<_lines*>* L = __L;
      uint result = INT_MAX;
      if ((bull ? ((info::Getbias(n) == 1)) : ((info::Getbias(n) == (-1)))))
      {
         if ((bull ? (_lines::Gethit_ph_line(Array::Get<_lines*, ICustomTypeArray<_lines*>*, int>(L, 0, NULL))) : (_lines::Gethit_pl_line(Array::Get<_lines*, ICustomTypeArray<_lines*>*, int>(L, 0, NULL)))))
         {
            result = AddTransparency(after_raid_color, 50);
            __out1 = result;
         }
         else
         {
            result = AddTransparency(before_raid_color, 50);
            __out1 = result;
         }
      }
      return true;
   }
};
format_color_1Stream* format_color_18;
format_color_1Stream* format_color_19;
class format_result_1Stream
{
   bool _initialized;
   string IndicatorObjPrefix;
public:
   format_result_1Stream(string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
   }
   ~format_result_1Stream()
   {
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, int __hit, int __bias, string &__out1)
   {
      int hit = __hit;
      int bias = __bias;
      string result = "";
      if ((bias > 0))
      {
         result = Str::ToString(SafeDivide(SafeMathFloor(SafeMultiply(SafeDivide(hit, bias), 1000)), 10));
      }
      else
      {
         result = "0";
      }
      __out1 = result = SafePlus(result, "%");
;
      return true;
   }
};
format_result_1Stream* format_result_110;
format_result_1Stream* format_result_111;
format_result_1Stream* format_result_112;
format_result_1Stream* format_result_113;
format_color_1Stream* format_color_114;
format_color_1Stream* format_color_115;
format_result_1Stream* format_result_116;
format_result_1Stream* format_result_117;
format_result_1Stream* format_result_118;
format_result_1Stream* format_result_119;
double plot7[];
double plot8[];

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(string target)
{
   if (StringLen(target) > 20)
   {
      target = StringSubstr(target, 0, 20);
   }
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

int init()
{
   IndicatorBuffers(8);
   d_stats = param1;
   w_stats = param2;
   bias_reason = param3;
   bull_color = param4;
   bear_color = param5;
   d_bias_plot = param6;
   w_bias_plot = param7;
   d_bias_loc = Get_param8();
   w_bias_loc = Get_param9();
   before_raid_color = param10;
   after_raid_color = param11;
   stop_ext = param12;
   use_d_sep = param13;
   use_w_sep = param14;
   d_sep = param15;
   w_sep = param16;
   line_width = param17;
   tbl_show_stats = param18;
   tbl_loc = Get_param19();
   tbl_size = Get_param20();
   int id = 0;
   SetIndexBuffer(id, plot1);
   SetIndexArrow(id, 217);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, GetColorOnly(after_raid_color));
   SetIndexBuffer(id, plot2);
   SetIndexArrow(id, 218);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, GetColorOnly(after_raid_color));
   SetIndexBuffer(id, plot3);
   SetIndexArrow(id, 217);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, GetColorOnly(after_raid_color));
   SetIndexBuffer(id, plot4);
   SetIndexArrow(id, 218);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, GetColorOnly(after_raid_color));
   SetIndexBuffer(id, plot5);
   SetIndexArrow(id, 111);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, GetColorOnly(bull_color));
   SetIndexBuffer(id, plot6);
   SetIndexArrow(id, 111);
   SetIndexStyle(id++, DRAW_ARROW, STYLE_SOLID, 1, GetColorOnly(bull_color));
   tbl_loc = Get_param21();
   tbl_size = Get_param22();
   SetIndexBuffer(id++, plot7);
   SetIndexBuffer(id++, plot8);
   LinesCollection::SetMaxLines(500);
   LabelsCollection::SetMaxLabels(500);
   IndicatorObjPrefix = GenerateIndicatorPrefix("TTrades Daily Bias [TFO]");
   IndicatorShortName("TTrades Daily Bias [TFO]");
      d_info = new info();
      w_info = new info();
   update_info_12 = new update_info_1Stream("D", IndicatorObjPrefix + "_2");
   id = update_info_12.Init(id);
   update_lines_13 = new update_lines_1Stream("D", IndicatorObjPrefix + "_3");
   id = update_lines_13.Init(id);
   update_info_14 = new update_info_1Stream("W", IndicatorObjPrefix + "_4");
   id = update_info_14.Init(id);
   update_lines_15 = new update_lines_1Stream("W", IndicatorObjPrefix + "_5");
   id = update_lines_15.Init(id);
   _signaler = new Signaler();
   get_table_pos_16 = new get_table_pos_1Stream(tbl_loc, IndicatorObjPrefix + "_6");
   id = get_table_pos_16.Init(id);
   get_table_size_17 = new get_table_size_1Stream(tbl_size, IndicatorObjPrefix + "_7");
   id = get_table_size_17.Init(id);
   format_color_18 = new format_color_1Stream(true, IndicatorObjPrefix + "_8");
   id = format_color_18.Init(id);
   format_color_19 = new format_color_1Stream(false, IndicatorObjPrefix + "_9");
   id = format_color_19.Init(id);
   format_result_110 = new format_result_1Stream(IndicatorObjPrefix + "_10");
   id = format_result_110.Init(id);
   format_result_111 = new format_result_1Stream(IndicatorObjPrefix + "_11");
   id = format_result_111.Init(id);
   format_result_112 = new format_result_1Stream(IndicatorObjPrefix + "_12");
   id = format_result_112.Init(id);
   format_result_113 = new format_result_1Stream(IndicatorObjPrefix + "_13");
   id = format_result_113.Init(id);
   format_color_114 = new format_color_1Stream(true, IndicatorObjPrefix + "_14");
   id = format_color_114.Init(id);
   format_color_115 = new format_color_1Stream(false, IndicatorObjPrefix + "_15");
   id = format_color_115.Init(id);
   format_result_116 = new format_result_1Stream(IndicatorObjPrefix + "_16");
   id = format_result_116.Init(id);
   format_result_117 = new format_result_1Stream(IndicatorObjPrefix + "_17");
   id = format_result_117.Init(id);
   format_result_118 = new format_result_1Stream(IndicatorObjPrefix + "_18");
   id = format_result_118.Init(id);
   format_result_119 = new format_result_1Stream(IndicatorObjPrefix + "_19");
   id = format_result_119.Init(id);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   d_info.Release();
   w_info.Release();
   if (d_lines != NULL) d_lines.Release();
   if (w_lines != NULL) w_lines.Release();
   delete update_info_12;
   delete update_lines_13;
   delete update_info_14;
   delete update_lines_15;
   delete _signaler;
   delete get_table_pos_16;
   delete get_table_size_17;
   delete format_color_18;
   delete format_color_19;
   delete format_result_110;
   delete format_result_111;
   delete format_result_112;
   delete format_result_113;
   delete format_color_114;
   delete format_color_115;
   delete format_result_116;
   delete format_result_117;
   delete format_result_118;
   delete format_result_119;
   LinesCollection::Clear(true);
   LabelsCollection::Clear(true);
   TableManager::Clear(true);
   return 0;
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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      LinesCollection::Clear();
      LabelsCollection::Clear();
      TableManager::Clear();
      g_VIS = NULL;
      g_PLT = NULL;
      g_STY = NULL;
      g_TBL = NULL;
      if (d_lines != NULL) d_lines.Release();
      d_lines = NULL;
      if (w_lines != NULL) w_lines.Release();
      w_lines = NULL;
      update_info_12.Clear();
      update_lines_13.Clear();
      update_info_14.Clear();
      update_lines_15.Clear();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      get_table_pos_16.Clear();
      stats = NULL;
      get_table_size_17.Clear();
      text_size = NULL;
      format_color_18.Clear();
      format_color_19.Clear();
      format_result_110.Clear();
      format_result_111.Clear();
      format_result_112.Clear();
      format_result_113.Clear();
      format_color_114.Clear();
      format_color_115.Clear();
      format_result_116.Clear();
      format_result_117.Clear();
      format_result_118.Clear();
      format_result_119.Clear();
      ArrayInitialize(plot7, EMPTY_VALUE);
      ArrayInitialize(plot8, EMPTY_VALUE);
   }
   bool timeSeries = ArrayGetAsSeries(time);
   bool openSeries = ArrayGetAsSeries(open);
   bool highSeries = ArrayGetAsSeries(high);
   bool lowSeries = ArrayGetAsSeries(low);
   bool closeSeries = ArrayGetAsSeries(close);
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = 0;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      if (g_VIS == NULL)
      {
      g_VIS = "Bias";
      }
      if (g_PLT == NULL)
      {
      g_PLT = "Plotting";
      }
      if (g_STY == NULL)
      {
      g_STY = "Style";
      }
      if (g_TBL == NULL)
      {
      g_TBL = "Table";
      }
      new_day = Timeframe::Change("D", pos);
      new_week = Timeframe::Change("W", pos);
      can_plot_d = SafeLess(Timeframe::InSeconds(Timeframe::Period()), Timeframe::InSeconds("D"));
      can_plot_w = SafeLess(Timeframe::InSeconds(Timeframe::Period()), Timeframe::InSeconds("W"));
      if (use_d_sep && new_day && can_plot_d)
      {
         LinesCollection::Create(IndicatorObjPrefix + "line_1_id", ((rates_total - 1) - pos), high[pos] * 1.000001, ((rates_total - 1) - pos), low[pos], time[pos]).SetColor(d_sep).SetWidth(line_width).SetStyle("solid").SetExtend("both").SetXLoc("bar_index");
      }
      if (use_w_sep && new_week && can_plot_w)
      {
         LinesCollection::Create(IndicatorObjPrefix + "line_2_id", ((rates_total - 1) - pos), high[pos] * 1.000001, ((rates_total - 1) - pos), low[pos], time[pos]).SetColor(w_sep).SetWidth(line_width).SetStyle("solid").SetExtend("both").SetXLoc("bar_index");
      }
      if (d_lines == NULL)
      {
      ICustomTypeArray<_lines*>* __array1 = new CustomTypeArray<_lines*>(1, new _lines());
      d_lines = __array1;
      d_lines.AddRef();
      __array1.Release();
      }
      if (w_lines == NULL)
      {
      ICustomTypeArray<_lines*>* __array2 = new CustomTypeArray<_lines*>(1, new _lines());
      w_lines = __array2;
      w_lines.AddRef();
      __array2.Release();
      }
      int d_hit_high = false;
      int d_hit_low = false;
      int w_hit_high = false;
      int w_hit_low = false;
      if (d_stats && SafeLE(Timeframe::InSeconds(Timeframe::Period()), Timeframe::InSeconds("D")))
      {
         double update_info_12Value;
         if (!update_info_12.GetValue(pos, d_info, update_info_12Value)) { update_info_12Value = EMPTY_VALUE; }
         update_info_12Value;
         int update_lines_13Value1;
         int update_lines_13Value2;
         if (!update_lines_13.GetValue(pos, d_lines, d_info, update_lines_13Value1, update_lines_13Value2)) { update_lines_13Value1 = (-1); update_lines_13Value2 = (-1); }
         int hr = update_lines_13Value1;
         int lr = update_lines_13Value2;
         d_hit_high = hr;
         d_hit_low = lr;
      }
      if (w_stats && SafeLE(Timeframe::InSeconds(Timeframe::Period()), Timeframe::InSeconds("W")))
      {
         double update_info_14Value;
         if (!update_info_14.GetValue(pos, w_info, update_info_14Value)) { update_info_14Value = EMPTY_VALUE; }
         update_info_14Value;
         int update_lines_15Value1;
         int update_lines_15Value2;
         if (!update_lines_15.GetValue(pos, w_lines, w_info, update_lines_15Value1, update_lines_15Value2)) { update_lines_15Value1 = (-1); update_lines_15Value2 = (-1); }
         int hr = update_lines_15Value1;
         int lr = update_lines_15Value2;
         w_hit_high = hr;
         w_hit_low = lr;
      }
      PlotShape::SetBool(plot1, pos, "abovebar", can_plot_d && d_hit_high, high, low, 0, after_raid_color);
      PlotShape::SetBool(plot2, pos, "belowbar", can_plot_d && d_hit_low, high, low, 0, after_raid_color);
      PlotShape::SetBool(plot3, pos, "abovebar", can_plot_w && w_hit_high, high, low, 0, after_raid_color);
      PlotShape::SetBool(plot4, pos, "belowbar", can_plot_w && w_hit_low, high, low, 0, after_raid_color);
      PlotShape::SetBool(plot5, pos, ((d_bias_loc == "Top") ? "top" : "bottom"), d_bias_plot, high, low, 0, ((info::Getbias(d_info) == 1) ? bull_color : ((info::Getbias(d_info) == (-1)) ? bear_color : INT_MAX)));
      PlotShape::SetBool(plot6, pos, ((w_bias_loc == "Top") ? "top" : "bottom"), w_bias_plot, high, low, 0, ((info::Getbias(w_info) == 1) ? bull_color : ((info::Getbias(w_info) == (-1)) ? bear_color : INT_MAX)));
      if (new_day && (info::Getbias(d_info) == 1)) { _signaler.SendNotifications("Bias PDH", "Bias PDH"); }
      if (new_day && (info::Getbias(d_info) == (-1))) { _signaler.SendNotifications("Bias PDL", "Bias PDL"); }
      if (new_day && (info::Getbias(d_info) == 0)) { _signaler.SendNotifications("No Daily Bias", "No Daily Bias"); }
      if (new_week && (info::Getbias(w_info) == 1)) { _signaler.SendNotifications("Bias PWH", "Bias PWH"); }
      if (new_week && (info::Getbias(w_info) == (-1))) { _signaler.SendNotifications("Bias PWL", "Bias PWL"); }
      if (new_week && (info::Getbias(w_info) == 0)) { _signaler.SendNotifications("No Weekly Bias", "No Weekly Bias"); }
      if (d_hit_high) { _signaler.SendNotifications("Hit PDH", "Hit PDH"); }
      if (d_hit_low) { _signaler.SendNotifications("Hit PDL", "Hit PDL"); }
      if (w_hit_high) { _signaler.SendNotifications("Hit PWH", "Hit PWH"); }
      if (w_hit_low) { _signaler.SendNotifications("Hit PWL", "Hit PWL"); }
      if (stats == NULL)
      {
      string get_table_pos_16Value;
      if (!get_table_pos_16.GetValue(pos, get_table_pos_16Value)) { get_table_pos_16Value = NULL; }
      stats = TableManager::Create(IndicatorObjPrefix, "1", get_table_pos_16Value, 20, 20).SetBorderWidth(1).SetBGColor(ChartGetInteger(0, CHART_COLOR_BACKGROUND)).SetBorderColor(ChartGetInteger(0, CHART_COLOR_FOREGROUND)).SetFrameColor(ChartGetInteger(0, CHART_COLOR_FOREGROUND)).SetFrameWidth(2);
      }
      if (text_size == NULL)
      {
      string get_table_size_17Value;
      if (!get_table_size_17.GetValue(pos, get_table_size_17Value)) { get_table_size_17Value = NULL; }
      text_size = get_table_size_17Value;
      }
      if ((pos == 0))
      {
         Table::CellText(stats, 0, 0, "Bias");
         Table::CellTextColor(stats, 0, 0, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
         Table::CellTextSize(stats, 0, 0, text_size);
         Table::CellTextHAlign(stats, 0, 0, "center");
         if (tbl_show_stats)
         {
            Table::CellText(stats, 1, 0, "Success\nRate");
            Table::CellTextColor(stats, 1, 0, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
            Table::CellTextSize(stats, 1, 0, text_size);
            Table::CellTextHAlign(stats, 1, 0, "center");
            Table::CellText(stats, 2, 0, "Close Thru\nRate");
            Table::CellTextColor(stats, 2, 0, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
            Table::CellTextSize(stats, 2, 0, text_size);
            Table::CellTextHAlign(stats, 2, 0, "center");
            Table::CellText(stats, 3, 0, "Sample\nSize");
            Table::CellTextColor(stats, 3, 0, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
            Table::CellTextSize(stats, 3, 0, text_size);
            Table::CellTextHAlign(stats, 3, 0, "center");
         }
         if (d_stats)
         {
            uint format_color_18Value;
            if (!format_color_18.GetValue(pos, d_info, d_lines, format_color_18Value)) { format_color_18Value = INT_MAX; }
            Table::CellText(stats, 0, 1, "PDH");
            Table::CellTextColor(stats, 0, 1, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
            Table::CellTextSize(stats, 0, 1, text_size);
            Table::CellTextHAlign(stats, 0, 1, "center");
            Table::CellBGColor(stats, 0, 1, format_color_18Value);
            uint format_color_19Value;
            if (!format_color_19.GetValue(pos, d_info, d_lines, format_color_19Value)) { format_color_19Value = INT_MAX; }
            Table::CellText(stats, 0, 2, "PDL");
            Table::CellTextColor(stats, 0, 2, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
            Table::CellTextSize(stats, 0, 2, text_size);
            Table::CellTextHAlign(stats, 0, 2, "center");
            Table::CellBGColor(stats, 0, 2, format_color_19Value);
            if (tbl_show_stats)
            {
               string format_result_110Value;
               if (!format_result_110.GetValue(pos, info::Gethit_ph(d_info), info::Getbias_ph(d_info), format_result_110Value)) { format_result_110Value = NULL; }
               Table::CellText(stats, 1, 1, format_result_110Value);
               Table::CellTextColor(stats, 1, 1, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 1, 1, text_size);
               Table::CellTextHAlign(stats, 1, 1, "center");
               string format_result_111Value;
               if (!format_result_111.GetValue(pos, info::Gethit_pl(d_info), info::Getbias_pl(d_info), format_result_111Value)) { format_result_111Value = NULL; }
               Table::CellText(stats, 1, 2, format_result_111Value);
               Table::CellTextColor(stats, 1, 2, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 1, 2, text_size);
               Table::CellTextHAlign(stats, 1, 2, "center");
               string format_result_112Value;
               if (!format_result_112.GetValue(pos, info::Getclose_ph(d_info), info::Gethit_ph(d_info), format_result_112Value)) { format_result_112Value = NULL; }
               Table::CellText(stats, 2, 1, format_result_112Value);
               Table::CellTextColor(stats, 2, 1, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 2, 1, text_size);
               Table::CellTextHAlign(stats, 2, 1, "center");
               string format_result_113Value;
               if (!format_result_113.GetValue(pos, info::Getclose_pl(d_info), info::Gethit_pl(d_info), format_result_113Value)) { format_result_113Value = NULL; }
               Table::CellText(stats, 2, 2, format_result_113Value);
               Table::CellTextColor(stats, 2, 2, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 2, 2, text_size);
               Table::CellTextHAlign(stats, 2, 2, "center");
               Table::CellText(stats, 3, 1, Str::ToString(info::Getbias_ph(d_info)));
               Table::CellTextColor(stats, 3, 1, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 3, 1, text_size);
               Table::CellTextHAlign(stats, 3, 1, "center");
               Table::CellText(stats, 3, 2, Str::ToString(info::Getbias_pl(d_info)));
               Table::CellTextColor(stats, 3, 2, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 3, 2, text_size);
               Table::CellTextHAlign(stats, 3, 2, "center");
            }
         }
         if (w_stats)
         {
            uint format_color_114Value;
            if (!format_color_114.GetValue(pos, w_info, w_lines, format_color_114Value)) { format_color_114Value = INT_MAX; }
            Table::CellText(stats, 0, 3, "PWH");
            Table::CellTextColor(stats, 0, 3, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
            Table::CellTextSize(stats, 0, 3, text_size);
            Table::CellTextHAlign(stats, 0, 3, "center");
            Table::CellBGColor(stats, 0, 3, format_color_114Value);
            uint format_color_115Value;
            if (!format_color_115.GetValue(pos, w_info, w_lines, format_color_115Value)) { format_color_115Value = INT_MAX; }
            Table::CellText(stats, 0, 4, "PWL");
            Table::CellTextColor(stats, 0, 4, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
            Table::CellTextSize(stats, 0, 4, text_size);
            Table::CellTextHAlign(stats, 0, 4, "center");
            Table::CellBGColor(stats, 0, 4, format_color_115Value);
            if (tbl_show_stats)
            {
               string format_result_116Value;
               if (!format_result_116.GetValue(pos, info::Gethit_ph(w_info), info::Getbias_ph(w_info), format_result_116Value)) { format_result_116Value = NULL; }
               Table::CellText(stats, 1, 3, format_result_116Value);
               Table::CellTextColor(stats, 1, 3, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 1, 3, text_size);
               Table::CellTextHAlign(stats, 1, 3, "center");
               string format_result_117Value;
               if (!format_result_117.GetValue(pos, info::Gethit_pl(w_info), info::Getbias_pl(w_info), format_result_117Value)) { format_result_117Value = NULL; }
               Table::CellText(stats, 1, 4, format_result_117Value);
               Table::CellTextColor(stats, 1, 4, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 1, 4, text_size);
               Table::CellTextHAlign(stats, 1, 4, "center");
               string format_result_118Value;
               if (!format_result_118.GetValue(pos, info::Getclose_ph(w_info), info::Gethit_ph(w_info), format_result_118Value)) { format_result_118Value = NULL; }
               Table::CellText(stats, 2, 3, format_result_118Value);
               Table::CellTextColor(stats, 2, 3, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 2, 3, text_size);
               Table::CellTextHAlign(stats, 2, 3, "center");
               string format_result_119Value;
               if (!format_result_119.GetValue(pos, info::Getclose_pl(w_info), info::Gethit_pl(w_info), format_result_119Value)) { format_result_119Value = NULL; }
               Table::CellText(stats, 2, 4, format_result_119Value);
               Table::CellTextColor(stats, 2, 4, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 2, 4, text_size);
               Table::CellTextHAlign(stats, 2, 4, "center");
               Table::CellText(stats, 3, 3, Str::ToString(info::Getbias_ph(w_info)));
               Table::CellTextColor(stats, 3, 3, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 3, 3, text_size);
               Table::CellTextHAlign(stats, 3, 3, "center");
               Table::CellText(stats, 3, 4, Str::ToString(info::Getbias_pl(w_info)));
               Table::CellTextColor(stats, 3, 4, ChartGetInteger(0, CHART_COLOR_FOREGROUND));
               Table::CellTextSize(stats, 3, 4, text_size);
               Table::CellTextHAlign(stats, 3, 4, "center");
            }
         }
      }
      plot7[pos] = info::Getbias(d_info);
      plot8[pos] = info::Getbias(w_info);
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   LinesCollection::Redraw();
   LabelsCollection::Redraw();
   TableManager::Redraw();
   return rates_total;
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76392
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/