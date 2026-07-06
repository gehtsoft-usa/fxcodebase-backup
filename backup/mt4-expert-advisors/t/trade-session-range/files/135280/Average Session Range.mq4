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

#property indicator_chart_window

input string start_1 = "08:00:00"; // Session 1 start
input string end_1 = "16:00:00"; // Session 1 end
input string name_1 = "NY"; // Session 1 name

input string start_2 = "08:00:00"; // Session 2 start
input string end_2 = "16:00:00"; // Session 2 end
input string name_2 = "NY"; // Session 2 name

input string start_3 = "08:00:00"; // Session 3 start
input string end_3 = "16:00:00"; // Session 3 end
input string name_3 = "NY"; // Session 3 name

input int N = 14; // ADR Periods
input double Multiplier = 0.5; // Multiplier
input color LevelsColor = clrRed; // Levels color
input int x_shift = 900; // X coordinate
input int y_shift = 50; // Y coordinate
input int font_size = 10; // Font Size;

// Grid cells v3.0

// Grid text cell v3.0

#ifndef GridTextCell_IMP
#define GridTextCell_IMP

class GridTextCell
{
   string _text;
   color _clr;
   uint _width;
   uint _height;
   string _id;
   int _fontSize;
   string _fontName;
   ENUM_ANCHOR_POINT _anchor;
   int _cellWidth;
public:
   GridTextCell(string id)
   {
      _id = id;
   }

   void SetData(string text, color clr, string fontName, int fontSize, ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT)
   {
      TextSetFont(fontName, fontSize * (-10));
      TextGetSize(text, _width, _height);
      _fontName = fontName;
      _fontSize = fontSize;
      _text = text;
      _clr = clr;
      _anchor = anchor;
   }

   void Draw(int __x, int __y)
   {
      ResetLastError();
      string id = _id;
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_LABEL, 0, 0, 0))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetInteger(0, id, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetString(0, id, OBJPROP_FONT, _fontName);
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, _fontSize);
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, _anchor);
      }
      if (_anchor == ANCHOR_CENTER)
      {
         ObjectSetInteger(0, id, OBJPROP_XDISTANCE, __x + _cellWidth / 2);
      }
      else
      {
         ObjectSetInteger(0, id, OBJPROP_XDISTANCE, __x);
      }
      ObjectSetInteger(0, id, OBJPROP_YDISTANCE, __y);
      ObjectSetInteger(0, id, OBJPROP_COLOR, _clr);
      ObjectSetString(0, id, OBJPROP_TEXT, _text);
   }

   void SetMinWidth(int width)
   {
      _cellWidth = width;
   }

   int GetWidth()
   {
      return (int)_width;
   }

   int GetHeight()
   {
      return (int)_height;
   }
};

#endif
// Grid row v2.0

#ifndef GridRow_IMP
#define GridRow_IMP

class GridRow
{
   GridTextCell* _cells[];
   string _id;
public:
   GridRow(string id)
   {
      _id = id;
   }

   ~GridRow()
   {
      for (int i = 0; i < ArraySize(_cells); ++i)
      {
         delete _cells[i];
      }
      ArrayResize(_cells, 0);
   }

   void EnsureEnoughtCells(int newSize)
   {
      int oldSize = ArraySize(_cells);
      if (newSize <= oldSize)
         return;
      ArrayResize(_cells, newSize);
      for (int i = oldSize; i < newSize; ++i)
      {
         _cells[i] = new GridTextCell(_id + "-" + IntegerToString(i));
      }
   }

   int Size()
   {
      return ArraySize(_cells);
   }

   GridTextCell* Get(int index)
   {
      return _cells[index];
   }
};
#endif

#ifndef GridCells_IMP
#define GridCells_IMP

class GridCells
{
   string _id;
   GridRow* _columns[];
   double _gap;
public:
   GridCells(string id, double gap)
   {
      _gap = gap;
      _id = id;
   }

   ~GridCells()
   {
      for (int i = 0; i < ArraySize(_columns); ++i)
      {
         delete _columns[i];
      }
      ArrayResize(_columns, 0);
   }

   void Clear()
   {

   }

   void Add(string text, color clr, string fontName, int fontSize, int column, int row, ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT)
   {
      EnsureEnoughtColumns(column + 1);
      _columns[column].EnsureEnoughtCells(row + 1);
      _columns[column].Get(row).SetData(text, clr, fontName, fontSize, anchor);
   }

   void Draw(int __x, int __y)
   {
      int maxHeight[];
      int maxWidth[];
      ArrayResize(maxWidth, ArraySize(_columns));

      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentRows = ArraySize(maxHeight);
         if (rows > currentRows)
         {
            ArrayResize(maxHeight, rows);
         }

         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            maxHeight[rowIndex] = MathMax(maxHeight[rowIndex], _columns[columnIndex].Get(rowIndex).GetHeight());
            maxWidth[columnIndex] = MathMax(maxWidth[columnIndex], _columns[columnIndex].Get(rowIndex).GetWidth());
         }
      }

      int currentX = __x;
      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentY = __y;
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            _columns[columnIndex].Get(rowIndex).Draw(currentX, currentY);
            currentY += (int)(maxHeight[rowIndex] * _gap);
         }
         currentX += (int)(maxWidth[columnIndex] * _gap);
      }
   }

   void SetMinWidth(int width)
   {
      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            _columns[columnIndex].Get(rowIndex).SetMinWidth(width);
         }
      }
   }

   int GetTotalWidth()
   {
      int maxHeight[];
      int maxWidth[];
      ArrayResize(maxWidth, ArraySize(_columns));

      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentRows = ArraySize(maxHeight);
         if (rows > currentRows)
         {
            ArrayResize(maxHeight, rows);
         }
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            maxHeight[rowIndex] = MathMax(maxHeight[rowIndex], _columns[columnIndex].Get(rowIndex).GetHeight());
            maxWidth[columnIndex] = MathMax(maxWidth[columnIndex], _columns[columnIndex].Get(rowIndex).GetWidth());
         }
      }
      int total = 0;
      int count = ArraySize(maxWidth);
      for (int i = 0; i < count; ++i)
      {
         total += (int)((i < count - 1) ? maxWidth[i] * _gap : maxWidth[i]);
      }
      return total;
   }
   int GetTotalHeight()
   {
      int maxHeight[];
      int maxWidth[];
      ArrayResize(maxWidth, ArraySize(_columns));

      for (int columnIndex = 0; columnIndex < ArraySize(_columns); ++columnIndex)
      {
         int rows = _columns[columnIndex].Size();
         int currentRows = ArraySize(maxHeight);
         if (rows > currentRows)
         {
            ArrayResize(maxHeight, rows);
         }
         for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
         {
            maxHeight[rowIndex] = MathMax(maxHeight[rowIndex], _columns[columnIndex].Get(rowIndex).GetHeight());
            maxWidth[columnIndex] = MathMax(maxWidth[columnIndex], _columns[columnIndex].Get(rowIndex).GetWidth());
         }
      }
      int total = 0;
      int count = ArraySize(maxHeight);
      for (int i = 0; i < count; ++i)
      {
         total += (int)((i < count - 1) ? maxHeight[i] * _gap : maxHeight[i]);
      }
      return total;
   }
private:
   void EnsureEnoughtColumns(int newSize)
   {
      int oldSize = ArraySize(_columns);
      if (oldSize <= newSize)
      {
         ArrayResize(_columns, newSize);
         for (int i = oldSize; i < newSize; ++i)
         {
            _columns[i] = new GridRow(_id + "-" + IntegerToString(i));
         }
      }
   }
};

#endif
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

double _pipSize;
GridCells* cells;

int init()
{
   IndicatorName = GenerateIndicatorName("Average Session Range");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);

   double _point = MarketInfo(_Symbol, MODE_POINT);
   double _digits = (int)MarketInfo(_Symbol, MODE_DIGITS); 
   double _mult = _digits == 3 || _digits == 5 ? 10 : 1;
   _pipSize = _point * _mult;

   cells = new GridCells(IndicatorObjPrefix + "0", 1.2);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

double CalcADR(string start, string end)
{
   double summ = 0;
   int pos = 0;
   int limit = iBars(_Symbol, PERIOD_H1) - 1;
   for (int i = 0; i < N; ++i)
   {
      double value = iCustom(_Symbol, PERIOD_H1, "Trade Session Range", start, end, 0, pos);
      summ += value;
      while (limit > pos && iCustom(_Symbol, PERIOD_H1, "Trade Session Range", start, end, 1, pos) != 1)
      {
         ++pos;
      }
      ++pos;
      if (pos >= limit)
      {
         break;
      }
   }

   return summ / N;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 1;
   if(ExtCountedBars > 1) 
      limit = Bars - ExtCountedBars - 1;

   datetime startDate = iTime(NULL, 0, 0);
   
   cells.Add(name_1 + ": " + DoubleToStr(CalcADR(start_1, end_1), 1), LevelsColor, "Arial", font_size, 0, 0, ANCHOR_LEFT_LOWER);
   cells.Add(name_2 + ": " + DoubleToStr(CalcADR(start_2, end_2), 1), LevelsColor, "Arial", font_size, 0, 1, ANCHOR_LEFT_LOWER);
   cells.Add(name_3 + ": " + DoubleToStr(CalcADR(start_3, end_3), 1), LevelsColor, "Arial", font_size, 0, 2, ANCHOR_LEFT_LOWER);
   cells.Draw(x_shift, y_shift);
   
   return 0;
}