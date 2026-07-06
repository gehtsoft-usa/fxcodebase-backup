//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74522

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
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_label1 "Close Line"
#property indicator_type1 DRAW_LINE
#property indicator_color1 0x009900
#property indicator_style1 STYLE_SOLID
#property indicator_width1 10
#property indicator_label2 "Open Line"
#property indicator_type2 DRAW_LINE
#property indicator_color2 0xCC0000
#property indicator_style2 STYLE_SOLID
#property indicator_width2 10
#property indicator_type3 DRAW_LINE
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_type4 DRAW_LINE
#property indicator_color4 Blue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_type5 DRAW_LINE
#property indicator_color5 Blue
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_type6 DRAW_LINE
#property indicator_color6 Blue
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "buy label"
#property indicator_type7 DRAW_ARROW
#property indicator_color7 Blue
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "sell label"
#property indicator_type8 DRAW_ARROW
#property indicator_color8 Red
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1

// Table v1.0
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
   color _color;
   int _windowNumber;
   string _textHAlign;
   bool _withBackground;
   color _bgColor;
   int _width;
   int _height;
   int _linesHeights[];
   int _linesWidths[];
public:
   LabelCell(const string id, const string text, ENUM_BASE_CORNER corner, int fontSize, color clr, int windowNumber)
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
   
   bool SetBgColor(color clr)
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
   
   bool SetColor(color clr)
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
   static void Clear();
   static void Add(Table* table);
   static void Redraw();
};

Table* TableManager::tables[];
void TableManager::Clear()
{
   for (int i = 0; i < ArraySize(TableManager::tables); ++i)
   {
      delete tables[i];
   }
   ArrayResize(tables, 0);
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
   int _frameWidth;
   Grid* _grid;
public:
   Table(string prefix, string position, int columns, int rows)
   {
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
   
   Table* SetBorderWidth(int borderWidth)
   {
      _borderWidth = borderWidth;
      return &this;
   }
   Table* SetBGColor(color clr)
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
   static void CellTextColor(Table* table, int column, int row, color clr)
   {
      if (table == NULL)
      {
         return;
      }
      table.CellTextColor(column, row, clr);
   }
   void CellTextColor(int column, int row, color clr)
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

// Pine-script like safe operations
// v.1.0

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}

double SafePlus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
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

double SafeGreater(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left > right;
}

double SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left >= right;
}

double SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left < right;
}

double SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left <= right;
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
// Stream base v1.0

// Stream v.3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

#ifndef AStreamBase_IMP
#define AStreamBase_IMP

class AStreamBase : public IStream
{
   int _references;
public:
   AStreamBase()
   {
      _references = 1;
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
#endif
// Custom stream v2.2

class CustomStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, EMPTY_VALUE);
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[index] = value;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != EMPTY_VALUE;
   }
private:
   void EnsureStreamHasProperSize(int size)
   {
      if (ArrayRange(_stream, 0) != size) 
      {
         ArrayResize(_stream, size);
      }
   }
};



// EMA on stream v1.0

#ifndef EMAOnStream_IMP
#define EMAOnStream_IMP

class EMAOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _k;
   double _buffer[];
   int _references;
public:
   EMAOnStream(IStream *source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _references = 1;
      _k = 2.0 / (_length + 1.0);
   }

   ~EMAOnStream()
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
      {
         delete &this;
      }
   }
   
   virtual int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      int currentBufferSize = ArrayRange(_buffer, 0);
      if (currentBufferSize != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
         for (int i = currentBufferSize; i < totalBars; ++i)
         {
            _buffer[i] = EMPTY_VALUE;
         }
      }
      
      if (period > totalBars - _length)
      {
         return false;
      }

      int bufferIndex = totalBars - 1 - period;
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current;
      _buffer[bufferIndex] = (1 - _k) * last + _k * current;
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif
input int param1 = 55; // EMA LENGTH?
input string param2 = "https://www.tradingview.com/script/0qBCefI3/"; //  You  can use advanced version Heikin Ashi Smoothed Master Buy Sell,to get Advanced version copy link ---> 
input int bars_limit = 100000; // Bars limit
int EMAlength;
string i_text;
Table* table1;
Table* table2;
Table* table3;
double haOpen[];
CustomStream* ema1Source;
EMAOnStream* ema1;
CustomStream* ema2Source;
EMAOnStream* ema2;
CustomStream* ema3Source;
EMAOnStream* ema3;
CustomStream* ema4Source;
EMAOnStream* ema4;
CustomStream* ema5Source;
EMAOnStream* ema5;
CustomStream* ema6Source;
EMAOnStream* ema6;
CustomStream* ema7Source;
EMAOnStream* ema7;
CustomStream* ema8Source;
EMAOnStream* ema8;
CustomStream* ema9Source;
EMAOnStream* ema9;
CustomStream* ema10Source;
EMAOnStream* ema10;
CustomStream* ema11Source;
EMAOnStream* ema11;
CustomStream* ema12Source;
EMAOnStream* ema12;
double mavi[];
double kirmizi[];
double plot1[];
double plot2[];
double plot3[];
double plot4[];
double plot5[];
double plot6[];
double last_signal[];
//Signaler v2.1
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

class Signaler
{
   string _prefix;
public:
   Signaler()
   {
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
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

Signaler* _signaler;
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
   IndicatorBuffers(12);
   int id = 0;
   SetIndexBuffer(id++, plot1);
   SetIndexBuffer(id++, plot2);
   SetIndexBuffer(id++, plot3);
   SetIndexBuffer(id++, plot4);
   SetIndexBuffer(id++, plot5);
   SetIndexBuffer(id++, plot6);
   SetIndexBuffer(id, plot7);
   SetIndexArrow(id++, 241);
   SetIndexBuffer(id, plot8);
   SetIndexArrow(id++, 242);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Heikin Ashi Smoothed Buy Sell v4 ");
   EMAlength = param1;
   i_text = param2;
   SetIndexBuffer(id++, haOpen);
   ema1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema1 = new EMAOnStream(ema1Source, EMAlength);
   ema2Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema2 = new EMAOnStream(ema2Source, EMAlength);
   ema3Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema3 = new EMAOnStream(ema3Source, EMAlength);
   ema4Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema4 = new EMAOnStream(ema4Source, EMAlength);
   ema5Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema5 = new EMAOnStream(ema5Source, EMAlength);
   ema6Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema6 = new EMAOnStream(ema6Source, EMAlength);
   ema7Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema7 = new EMAOnStream(ema7Source, EMAlength);
   ema8Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema8 = new EMAOnStream(ema8Source, EMAlength);
   ema9Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema9 = new EMAOnStream(ema9Source, EMAlength);
   ema10Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema10 = new EMAOnStream(ema10Source, EMAlength);
   ema11Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema11 = new EMAOnStream(ema11Source, EMAlength);
   ema12Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ema12 = new EMAOnStream(ema12Source, EMAlength);
   SetIndexBuffer(id++, mavi);
   SetIndexBuffer(id++, kirmizi);
   SetIndexBuffer(id++, last_signal);
   _signaler = new Signaler();
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   TableManager::Clear();
   ema1Source.Release();
   ema1.Release();
   ema2Source.Release();
   ema2.Release();
   ema3Source.Release();
   ema3.Release();
   ema4Source.Release();
   ema4.Release();
   ema5Source.Release();
   ema5.Release();
   ema6Source.Release();
   ema6.Release();
   ema7Source.Release();
   ema7.Release();
   ema8Source.Release();
   ema8.Release();
   ema9Source.Release();
   ema9.Release();
   ema10Source.Release();
   ema10.Release();
   ema11Source.Release();
   ema11.Release();
   ema12Source.Release();
   ema12.Release();
   delete _signaler;
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
      table1 = NULL;
      TableManager::Clear();
      table2 = new Table(IndicatorObjPrefix, "top_left", EMPTY_VALUE, EMPTY_VALUE).SetBorderWidth(0).SetFrameWidth(0);
      table3 = new Table(IndicatorObjPrefix, "top_right", 1, 1).SetBorderWidth(10).SetBGColor(Yellow).SetFrameWidth(0);
      ArrayInitialize(haOpen, EMPTY_VALUE);
      ArrayInitialize(mavi, EMPTY_VALUE);
      ArrayInitialize(kirmizi, EMPTY_VALUE);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
      ArrayInitialize(plot3, EMPTY_VALUE);
      ArrayInitialize(plot4, EMPTY_VALUE);
      ArrayInitialize(plot5, EMPTY_VALUE);
      ArrayInitialize(plot6, EMPTY_VALUE);
      ArrayInitialize(last_signal, EMPTY_VALUE);
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
      if ((pos == 1))
      {
         Table::CellText(table3, 0, 0, "You  can use advanced version Heikin Ashi Smoothed Master Buy Sell  \n \n https://www.tradingview.com/script/0qBCefI3/ ");
         Table::CellTextColor(table3, 0, 0, Black);
         Table::CellTextSize(table3, 0, 0, "normal");
         Table::CellTextHAlign(table3, 0, 0, "center");
      }
      double src = (open[pos] + high[pos] + low[pos] + close[pos]) / 4;
      haOpen[pos] = 0.0;
      if (pos + 1 > rates_total - 1) { continue; }
      haOpen[pos] = SafeDivide((SafePlus(src, Nz(haOpen[pos + 1]))), 2);
      double haC = SafeDivide((SafePlus(SafePlus(SafePlus((open[pos] + high[pos] + low[pos] + close[pos]) / 4, Nz(haOpen[pos])), SafeMathMax(high[pos], Nz(haOpen[pos]))), SafeMathMin(low[pos], Nz(haOpen[pos])))), 4);
      ema1Source.SetValue(pos, haC);
      double ema1Value;
      if (!ema1.GetValue(pos, ema1Value)) { continue; }
      double EMA1 = ema1Value;
      ema2Source.SetValue(pos, EMA1);
      double ema2Value;
      if (!ema2.GetValue(pos, ema2Value)) { continue; }
      double EMA2 = ema2Value;
      ema3Source.SetValue(pos, EMA2);
      double ema3Value;
      if (!ema3.GetValue(pos, ema3Value)) { continue; }
      double EMA3 = ema3Value;
      double TMA1 = SafePlus(SafeMinus(SafeMultiply(3, EMA1), SafeMultiply(3, EMA2)), EMA3);
      ema4Source.SetValue(pos, TMA1);
      double ema4Value;
      if (!ema4.GetValue(pos, ema4Value)) { continue; }
      double EMA4 = ema4Value;
      ema5Source.SetValue(pos, EMA4);
      double ema5Value;
      if (!ema5.GetValue(pos, ema5Value)) { continue; }
      double EMA5 = ema5Value;
      ema6Source.SetValue(pos, EMA5);
      double ema6Value;
      if (!ema6.GetValue(pos, ema6Value)) { continue; }
      double EMA6 = ema6Value;
      double TMA2 = SafePlus(SafeMinus(SafeMultiply(3, EMA4), SafeMultiply(3, EMA5)), EMA6);
      double IPEK = SafeMinus(TMA1, TMA2);
      double YASIN = SafePlus(TMA1, IPEK);
      ema7Source.SetValue(pos, (high[pos] + low[pos] + close[pos]) / 3);
      double ema7Value;
      if (!ema7.GetValue(pos, ema7Value)) { continue; }
      double EMA7 = ema7Value;
      ema8Source.SetValue(pos, EMA7);
      double ema8Value;
      if (!ema8.GetValue(pos, ema8Value)) { continue; }
      double EMA8 = ema8Value;
      ema9Source.SetValue(pos, EMA8);
      double ema9Value;
      if (!ema9.GetValue(pos, ema9Value)) { continue; }
      double EMA9 = ema9Value;
      double TMA3 = SafePlus(SafeMinus(SafeMultiply(3, EMA7), SafeMultiply(3, EMA8)), EMA9);
      ema10Source.SetValue(pos, TMA3);
      double ema10Value;
      if (!ema10.GetValue(pos, ema10Value)) { continue; }
      double EMA10 = ema10Value;
      ema11Source.SetValue(pos, EMA10);
      double ema11Value;
      if (!ema11.GetValue(pos, ema11Value)) { continue; }
      double EMA11 = ema11Value;
      ema12Source.SetValue(pos, EMA11);
      double ema12Value;
      if (!ema12.GetValue(pos, ema12Value)) { continue; }
      double EMA12 = ema12Value;
      double TMA4 = SafePlus(SafeMinus(SafeMultiply(3, EMA10), SafeMultiply(3, EMA11)), EMA12);
      double IPEK1 = SafeMinus(TMA3, TMA4);
      double YASIN1 = SafePlus(TMA3, IPEK1);
      mavi[pos] = YASIN1;
      kirmizi[pos] = YASIN;
      if (pos + 1 > rates_total - 1) { continue; }
      if (pos + 1 > rates_total - 1) { continue; }
      bool longCond = SafeGreater(mavi[pos], kirmizi[pos]) && SafeLE(mavi[pos + 1], kirmizi[pos + 1]);
      if (pos + 1 > rates_total - 1) { continue; }
      if (pos + 1 > rates_total - 1) { continue; }
      bool shortCond = SafeLess(mavi[pos], kirmizi[pos]) && SafeGE(mavi[pos + 1], kirmizi[pos + 1]);
      bool trendState = (SafeLess(kirmizi[pos], mavi[pos]) ? true : (SafeGreater(kirmizi[pos], mavi[pos]) ? false : EMPTY_VALUE));
      plot1[pos] = kirmizi[pos];
      double closePlot = plot1[pos];
      plot2[pos] = mavi[pos];
      double openPlot = plot2[pos];
      plot3[pos] = (trendState ? kirmizi[pos] : EMPTY_VALUE);
      double closePlotU = plot3[pos];
      plot4[pos] = (trendState ? mavi[pos] : EMPTY_VALUE);
      double openPlotU = plot4[pos];
      plot5[pos] = (trendState ? EMPTY_VALUE : kirmizi[pos]);
      double closePlotD = plot5[pos];
      plot6[pos] = (trendState ? EMPTY_VALUE : mavi[pos]);
      double openPlotD = plot6[pos];
      last_signal[pos] = 0;
      if (pos + 1 > rates_total - 1) { continue; }
      if (pos + 1 > rates_total - 1) { continue; }
      bool long_final = longCond && (((Nz(last_signal[pos + 1]) == 0) || (Nz(last_signal[pos + 1]) == (-1))));
      if (pos + 1 > rates_total - 1) { continue; }
      if (pos + 1 > rates_total - 1) { continue; }
      bool short_final = shortCond && (((Nz(last_signal[pos + 1]) == 0) || (Nz(last_signal[pos + 1]) == 1)));
      if (long_final) { _signaler.SendNotifications("buy alarm", "buy signal!!!"); }
      if (short_final) { _signaler.SendNotifications("sell alarm", "sell signal!!!"); }
      if (pos + 1 > rates_total - 1) { continue; }
      last_signal[pos] = (long_final ? 1 : (short_final ? (-1) : last_signal[pos + 1]));
      if (long_final) { plot7[pos] = low[pos]; }
      if (short_final) { plot8[pos] = high[pos]; }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   TableManager::Redraw();
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