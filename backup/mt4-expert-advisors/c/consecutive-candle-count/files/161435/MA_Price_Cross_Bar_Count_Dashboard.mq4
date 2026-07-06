/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        MA_Price_Cross_Bar_Count_Dashboard
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=60775&start=20
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"

#property indicator_separate_window
#property strict
enum DisplayMode
  {
   Vertical,
   Horizontal
  };
input ENUM_MA_METHOD ma1_type = MODE_SMA; // MA #1 Smoothing method
input int ma1_period = 14; // MA #1 period
input ENUM_APPLIED_PRICE ma1_price = PRICE_CLOSE; // MA #1 Price type
input string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
input string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD";
input bool     Include_M1               = false;
input bool     Include_M5               = false;
input bool     Include_M15              = false;
input bool     Include_M30              = false;
input bool     Include_H1               = true;
input bool     Include_H4               = false;
input bool     Include_D1               = true;
input bool     Include_W1               = true;
input bool     Include_MN1              = false;
input color    ma1_above_ma2_color             = Green; // MA 1 above MA 2 color
input color    ma1_below_ma2_color             = Red; // MA 1 below MA 2 color
input color    Labels_Color             = White; // Labels color
input bool auto_mode = true; // Auto Mode (auto position and size)
input int x_shift = 900; // X coordinate (manual mode)
input int y_shift = 50; // Y coordinate (manual mode)
input ENUM_BASE_CORNER corner           = CORNER_LEFT_UPPER; // Corner (manual mode)
input DisplayMode display_mode = Horizontal; // Display mode
input int font_size = 10; // Font Size;
input int cell_width = 80; // Cell width max (auto mode) / fixed (manual mode)
input int min_cell_width = 30; // Min cell width (auto mode)
input int cell_height = 30; // Cell height (manual mode)
#define MAX_LOOPBACK 500
string   WindowName;
int      WindowNumber;
int calculated_x_shift;
int calculated_y_shift;
int calculated_cell_width;
int calculated_cell_height;
ENUM_BASE_CORNER calculated_corner;
class Iterator
  {
   int               _initialValue;
   int               _shift;
   int               _current;
public:

                     Iterator(int initialValue, int shift) { _initialValue = initialValue; _shift = shift; _current = _initialValue - _shift; }

   int               GetNext() { _current += _shift; return _current; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ICell
  {
public:

   virtual void      Draw() = 0;

   virtual void      HandleButtonClicks() = 0;
protected:

   void              ObjectMakeLabel(string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner = 1, int Window = 0, string Font = "Arial", int FSize = 8)
     {
      ObjectDelete(nm);
      ObjectCreate(nm, OBJ_LABEL, Window, 0, 0);
      ObjectSet(nm, OBJPROP_CORNER, LabelCorner);
      ObjectSet(nm, OBJPROP_XDISTANCE, xoff);
      ObjectSet(nm, OBJPROP_YDISTANCE, yoff);
      ObjectSet(nm, OBJPROP_BACK, false);
      ObjectSetText(nm, LabelTexto, FSize, Font, LabelColor);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EmptyCell : public ICell
  {
public:

   virtual void      Draw() { }

   virtual void      HandleButtonClicks() {}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class LabelCell : public ICell
  {
   string            _id;
   string            _text;
   int               _x;
   int               _y;
   ENUM_BASE_CORNER  _corner;
public:

                     LabelCell(const string id, const string text, const int x, const int y, ENUM_BASE_CORNER cornerParam)
     {
      _corner = cornerParam;
      _id = id;
      _text = text;
      _x = x;
      _y = y;
     }

   virtual void      Draw()
     {
      ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, _corner, WindowNumber, "Arial", font_size);
     }

   virtual void      HandleButtonClicks()
     {
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Row
  {
   ICell             *_cells[];
public:

                    ~Row()
     {
      int count = ArraySize(_cells);
      for(int i = 0; i < count; ++i)
        {
         delete _cells[i];
        }
     }

   void              Draw()
     {
      int count = ArraySize(_cells);
      for(int i = 0; i < count; ++i)
        {
         _cells[i].Draw();
        }
     }

   void              HandleButtonClicks()
     {
      int count = ArraySize(_cells);
      for(int i = 0; i < count; ++i)
        {
         _cells[i].HandleButtonClicks();
        }
     }

   void              Add(ICell *cell)
     {
      int count = ArraySize(_cells);
      ArrayResize(_cells, count + 1);
      _cells[count] = cell;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Grid
  {
   Row               *_rows[];
public:

                    ~Grid()
     {
      int count = ArraySize(_rows);
      for(int i = 0; i < count; ++i)
        {
         delete _rows[i];
        }
     }

   Row               *AddRow()
     {
      int count = ArraySize(_rows);
      ArrayResize(_rows, count + 1);
      _rows[count] = new Row();
      return _rows[count];
     }

   Row               *GetRow(const int index)
     {
      return _rows[index];
     }

   void              Draw()
     {
      int count = ArraySize(_rows);
      for(int i = 0; i < count; ++i)
        {
         _rows[i].Draw();
        }
     }

   void              HandleButtonClicks()
     {
      int count = ArraySize(_rows);
      for(int i = 0; i < count; ++i)
        {
         _rows[i].HandleButtonClicks();
        }
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TextValueCell : public ICell
  {
   string            _id;
   int               _x;
   int               _y;
   string            _symbol;
   ENUM_TIMEFRAMES   _timeframe;
   datetime          _lastDatetime;
   ENUM_BASE_CORNER  _corner;
   bool              _showHistorical;
public:

                     TextValueCell(const string id, const int x, const int y, ENUM_BASE_CORNER cornerParam, const string symbol, const ENUM_TIMEFRAMES timeframe, bool showHistorical)
     {
      _showHistorical = showHistorical;
      _corner = cornerParam;
      _id = id;
      _x = x;
      _y = y;
      _symbol = symbol;
      _timeframe = timeframe;
     }

                    ~TextValueCell()
     {
     }

   bool              isAbove(int period)
     {
      double ma1 = iMA(_symbol, _timeframe, ma1_period, 0, ma1_type, ma1_price, period);
      double ma2 = iClose(_symbol, _timeframe, period);
      return ma1 > ma2;
     }

   virtual void      Draw()
     {
      int i = 1;
      bool lastAbove = isAbove(0);
      bool currentAbove = isAbove(i);
      while(lastAbove == currentAbove)
        {
         ++i;
         currentAbove = isAbove(i);
        }
      --i;
      string label = IntegerToString(i);
      ObjectMakeLabel(_id, _x, _y, label, lastAbove ? ma1_above_ma2_color : ma1_below_ma2_color, _corner, WindowNumber, "Arial", font_size);
     }

   virtual void      HandleButtonClicks()
     {
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ICellFactory
  {
public:

   virtual ICell*    Create(const string id, const int x, const int y, ENUM_BASE_CORNER cornerParam, const string symbol, const ENUM_TIMEFRAMES timeframe, bool showHistorical) = 0;

   virtual string    GetHeader() = 0;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TextValueCellFactory : public ICellFactory
  {
public:

   virtual string    GetHeader()
     {
      return "Value";
     }

   virtual ICell*    Create(const string id, const int x, const int y, ENUM_BASE_CORNER cornerParam, const string symbol, const ENUM_TIMEFRAMES timeframe, bool showHistorical)
     {
      return new TextValueCell(id, x, y, cornerParam, symbol, timeframe, showHistorical);
     }
  };
string IndicatorObjPrefix;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NamesCollision(const string name)
  {
   for(int k = ObjectsTotal(); k >= 0; k--)
     {
      if(StringFind(ObjectName(0, k), name) == 0)
        {
         return true;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorPrefix(const string target)
  {
   for(int i = 0; i < 1000; ++i)
     {
      string prefix = target + "_" + IntegerToString(i);
      if(!NamesCollision(prefix))
        {
         return prefix;
        }
     }
   return target;
  }
Grid *grid;
class GridBuilder
  {
   string            _symbols[];
   int               _symbolsCount;
   Grid              *grid;
   int               _originalX;
   int               _originalY;
   Iterator          _xIterator;
   Iterator          _yIterator;
   bool              _verticalMode;
   int               _cellHeight;
   int               _headerHeight;
   ICellFactory*     _cellFactory[];
   ENUM_BASE_CORNER  _corner;
   bool              _showHistorical;
public:

                     GridBuilder(int x, int y, int headerHeight, int cellHeight, bool verticalMode, ENUM_BASE_CORNER __corner, bool showHistorical)

      :              _xIterator(x, -calculated_cell_width), _yIterator(y, cellHeight)
     {
      _showHistorical = showHistorical;
      _corner = __corner;
      _cellHeight = cellHeight;
      _headerHeight = headerHeight;
      _verticalMode = verticalMode;
      _originalY = y;
      _originalX = x;
      grid = new Grid();
     }

                    ~GridBuilder()
     {
      for(int i = 0; i < ArraySize(_cellFactory); ++i)
        {
         delete _cellFactory[i];
        }
      ArrayResize(_cellFactory, 0);
     }

   void              AddCell(ICellFactory* cellFactory)
     {
      int size = ArraySize(_cellFactory);
      ArrayResize(_cellFactory, size + 1);
      _cellFactory[size] = cellFactory;
     }

   void              SetSymbols(const string symbols)
     {
      StringSplit(symbols, ',', _symbols);
      _symbolsCount = ArraySize(_symbols);
      int cellFactorySize = ArraySize(_cellFactory);
      if(_verticalMode)
        {
         Iterator yIterator(_originalY, _cellHeight);
         if(cellFactorySize > 1)
           {
            yIterator.GetNext();
           }
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for(int i = 0; i < _symbolsCount; i++)
           {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _originalX + calculated_cell_width, yIterator.GetNext(), _corner));
           }
        }
      else
        {
         Iterator xIterator(_originalX - calculated_cell_width, -calculated_cell_width);
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for(int i = 0; i < _symbolsCount; i++)
           {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], xIterator.GetNext(), _originalY - _headerHeight, _corner));
           }
        }
     }

   void              AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
     {
      int cellFactorySize = ArraySize(_cellFactory);
      if(_verticalMode)
        {
         int x[];
         ArrayResize(x, cellFactorySize);
         for(int ii = 0; ii < cellFactorySize; ++ii)
           {
            x[ii] = _xIterator.GetNext();
           }
         Row* column[];
         ArrayResize(column, cellFactorySize);
         for(int ii = 0; ii < cellFactorySize; ++ii)
           {
            column[ii] = grid.AddRow();
            if(ii > 0)
              {
               column[ii].Add(new EmptyCell());
              }
            else
              {
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_h", label, x[0], _headerHeight, _corner));
              }
           }
         Iterator yIterator(_originalY, _cellHeight);
         if(cellFactorySize > 1)
           {
            int y = yIterator.GetNext();
            for(int ii = 0; ii < cellFactorySize; ++ii)
              {
               string index = IntegerToString(ii + 1);
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_sh" + index, _cellFactory[ii].GetHeader(), x[ii], y, _corner));
              }
           }
         for(int i = 0; i < _symbolsCount; i++)
           {
            int y = yIterator.GetNext();
            for(int ii = 0; ii < cellFactorySize; ++ii)
              {
               string id = IndicatorObjPrefix + _symbols[i] + "_" + label + IntegerToString(ii);
               column[ii].Add(_cellFactory[ii].Create(id, x[ii], y, _corner, _symbols[i], timeframe, _showHistorical));
              }
           }
        }
      else
        {
         int y[];
         ArrayResize(y, cellFactorySize);
         for(int ii = 0; ii < cellFactorySize; ++ii)
           {
            y[ii] = _yIterator.GetNext();
           }
         Row* row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _originalX, y[0], _corner));
         Iterator xIterator(_originalX - calculated_cell_width, -calculated_cell_width);
         for(int i = 0; i < _symbolsCount; i++)
           {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            int x = xIterator.GetNext();
            for(int ii = 0; ii < cellFactorySize; ++ii)
              {
               row.Add(_cellFactory[ii].Create(id, x, y[ii], _corner, _symbols[i], timeframe, _showHistorical));
              }
           }
        }
     }

   Grid*             Build()
     {
      return grid;
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateAutoModeParameters()
  {
   if(auto_mode)
     {
      int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
      calculated_corner = CORNER_RIGHT_UPPER;
      string pairs_array[];
      StringSplit(Pairs, ',', pairs_array);
      int pair_count = ArraySize(pairs_array);
      int timeframe_count = 0;
      if(Include_M1)
         timeframe_count++;
      if(Include_M5)
         timeframe_count++;
      if(Include_M15)
         timeframe_count++;
      if(Include_M30)
         timeframe_count++;
      if(Include_H1)
         timeframe_count++;
      if(Include_H4)
         timeframe_count++;
      if(Include_D1)
         timeframe_count++;
      if(Include_W1)
         timeframe_count++;
      if(Include_MN1)
         timeframe_count++;
      int column_count = 0;
      if(display_mode == Horizontal)
        {
         column_count = pair_count + 1;
        }
      else
        {
         column_count = timeframe_count + 1;
        }
      int available_width = chart_width - 20;
      int optimal_cell_width = available_width / column_count;
      calculated_cell_width = MathMax(min_cell_width, MathMin(cell_width, optimal_cell_width));
      calculated_cell_height = 30;
      int dashboard_width = column_count * calculated_cell_width;
      calculated_x_shift = 10 + dashboard_width;
      calculated_y_shift = 10;
     }
   else
     {
      calculated_x_shift = x_shift;
      calculated_y_shift = y_shift;
      calculated_cell_width = cell_width;
      calculated_cell_height = cell_height;
      calculated_corner = corner;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorObjPrefix = GenerateIndicatorPrefix("MACBCD");
   IndicatorShortName("MA Cross Bar Count");
   CalculateAutoModeParameters();
   GridBuilder builder(calculated_x_shift, calculated_y_shift, calculated_cell_height, calculated_cell_height, display_mode == Vertical, calculated_corner, false);
   builder.AddCell(new TextValueCellFactory());
   builder.SetSymbols(Pairs);
   if(Include_M1)
      builder.AddTimeframe("M1", PERIOD_M1);
   if(Include_M5)
      builder.AddTimeframe("M5", PERIOD_M5);
   if(Include_M15)
      builder.AddTimeframe("M15", PERIOD_M15);
   if(Include_M30)
      builder.AddTimeframe("M30", PERIOD_M30);
   if(Include_H1)
      builder.AddTimeframe("H1", PERIOD_H1);
   if(Include_H4)
      builder.AddTimeframe("H4", PERIOD_H4);
   if(Include_D1)
      builder.AddTimeframe("D1", PERIOD_D1);
   if(Include_W1)
      builder.AddTimeframe("W1", PERIOD_W1);
   if(Include_MN1)
      builder.AddTimeframe("MN1", PERIOD_MN1);
   grid = builder.Build();
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete grid;
   grid = NULL;
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   WindowNumber = MathMax(0, WindowFind("MA Cross Bar Count"));
   static int last_chart_width = 0;
   int current_chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   if(auto_mode && last_chart_width != current_chart_width)
     {
      last_chart_width = current_chart_width;
      deinit();
      init();
     }
   grid.Draw();
   return 0;
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        MA_Price_Cross_Bar_Count_Dashboard
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=60775&start=20
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
