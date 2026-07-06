// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70807

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

input int adx_period = 14; // ADX Period
input color color_text = White; // General text color
input color background_color = DarkBlue; // Background color
input int x = 50; // Dashboard X coordinate
input int y = 50; // Dashboard Y coordinate
input int _fontSize = 10; // Font size
input string _fontName = "Cambria";

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
// Grid row v3.0

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

// Account statistics v1.5

class AccountStatistics
{
   GridCells* cells0;
public:
   AccountStatistics()
   {
      cells0 = new GridCells(IndicatorObjPrefix + "0", 1.2);
   }

   ~AccountStatistics()
   {
      delete cells0;
   }

   void Update()
   {
      int row = 0;
      cells0.Add("ADX", color_text, _fontName, _fontSize, 0, row);
      cells0.Add("DMI+", color_text, _fontName, _fontSize, 1, row);
      cells0.Add("DMI-", color_text, _fontName, _fontSize, 2, row++);
      double adxValue = iADX(_Symbol, _Period, adx_period, PRICE_CLOSE, MODE_MAIN, 0);
      double dmip = iADX(_Symbol, _Period, adx_period, PRICE_CLOSE, MODE_PLUSDI, 0);
      double dmim = iADX(_Symbol, _Period, adx_period, PRICE_CLOSE, MODE_MINUSDI, 0);
      cells0.Add(DoubleToString(adxValue, 2), color_text, _fontName, _fontSize, 0, row);
      cells0.Add(DoubleToString(dmip, 2), color_text, _fontName, _fontSize, 1, row);
      cells0.Add(DoubleToString(dmim, 2), color_text, _fontName, _fontSize, 2, row);
      
      int height0 = cells0.GetTotalHeight();
      int width0 = cells0.GetTotalWidth();
      ResetLastError();
      string id = IndicatorObjPrefix + "idValue2";
      ObjectCreate(0, id, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, id, OBJPROP_BGCOLOR, background_color);
      ObjectSetInteger(0, id, OBJPROP_FILL, true);
      ObjectSetInteger(0, id, OBJPROP_XDISTANCE, x - 10); 
      ObjectSetInteger(0, id, OBJPROP_YDISTANCE, y - 10); 
      ObjectSetInteger(0, id, OBJPROP_XSIZE, width0 + 20); 
      ObjectSetInteger(0, id, OBJPROP_YSIZE, height0 + 20);
      
      cells0.Draw(x, y);
   }
};
AccountStatistics stats;

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

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("adxd");
   IndicatorShortName("ADX Display");

   IndicatorBuffers(1);

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
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
   stats.Update();
   return rates_total;
}
