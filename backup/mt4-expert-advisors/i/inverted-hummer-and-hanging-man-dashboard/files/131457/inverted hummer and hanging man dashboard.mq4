// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69444

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

enum DisplayMode
{
   Vertical,
   Horizontal
};

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
input color    Labels_Color             = clrWhite;
input color    ih_Color             = Green; // Inverted hummer color
input color    hm_Color             = Red; // Handging man color
input int x_shift = 900; // X coordinate
input int y_shift = 50; // X coordinate
input DisplayMode display_mode = Horizontal; // Display mode
input int font_size = 10; // Font Size;
input int cell_width = 80; // Cell width
input int cell_height = 30; // Cell height

#define MAX_LOOPBACK 500

string   WindowName;
int      WindowNumber;

class Iterator
{
   int _initialValue; int _shift; int _current;
public:
   Iterator(int initialValue, int shift) { _initialValue = initialValue; _shift = shift; _current = _initialValue - _shift; }
   int GetNext() { _current += _shift; return _current; }
};

// Empty cell v1.0

// Interface for a cell v1.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw() = 0;
protected:
   void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 )
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

#endif

#ifndef EmptyCell_IMP
#define EmptyCell_IMP

class EmptyCell : public ICell
{
public:
   virtual void Draw() { }
};

#endif
// Label cell v1.0



#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ICell
{
   string _id;
   string _text; 
   int _x; 
   int _y;
public:
   LabelCell(const string id, const string text, const int x, const int y) 
   { 
      _id = id; 
      _text = text; 
      _x = x; 
      _y = y; 
   } 
   virtual void Draw() 
   { 
      ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, 1, WindowNumber, "Arial", font_size); 
   }
};

#endif
// Grid v1.0

// Row v1.0

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
   void Draw() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].Draw(); 
      } 
   }
   void Add(ICell *cell) 
   {
      int count = ArraySize(_cells); 
      ArrayResize(_cells, count + 1); 
      _cells[count] = cell; 
   } 
};

#endif

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
   
   void Draw()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].Draw();
      }
   }
};

#endif

class TextValueCell : public ICell
{
   string _id; 
   int _x; 
   int _y; 
   string _symbol; 
   ENUM_TIMEFRAMES _timeframe; 
   datetime _lastDatetime;
public:
   TextValueCell(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe)
   { 
      _id = id; 
      _x = x; 
      _y = y; 
      _symbol = symbol; 
      _timeframe = timeframe; 
   }

   ~TextValueCell()
   {
   }

   virtual void Draw()
   {
      double close = iClose(_symbol, _timeframe, 0);
      double open = iOpen(_symbol, _timeframe, 0);
      double high = iHigh(_symbol, _timeframe, 0);
      double low = iLow(_symbol, _timeframe, 0);
      double body = MathAbs(close - open);
      double upWick = high - MathMax(close, open);
      double downWick = MathMin(close, open) - low;
      if (body * 2 < upWick)
      {
         string label = "IH";
         ObjectMakeLabel(_id, _x, _y, label, ih_Color, 1, WindowNumber, "Arial", font_size); 
      }
      else if (body * 2 < downWick)
      {
         string label = "HM";
         ObjectMakeLabel(_id, _x, _y, label, hm_Color, 1, WindowNumber, "Arial", font_size); 
      }
      else
      {
         string label = "-";
         ObjectMakeLabel(_id, _x, _y, label, Labels_Color, 1, WindowNumber, "Arial", font_size); 
      }
   }
};

// Text value cell factory v1.0

// Interface for a cell factory v1.0



#ifndef ICellFactory_IMP
#define ICellFactory_IMP

class ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
};

#endif

#ifndef TextValueCellFactory_IMP
#define TextValueCellFactory_IMP

class TextValueCellFactory : public ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      return new TextValueCell(id, x, y, symbol, timeframe);
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

Grid *grid;

// Grid builder v2.0



#ifndef GridBuilder_IMP
#define GridBuilder_IMP

class GridBuilder
{
   string _symbols[];
   int _symbolsCount;
   Grid *grid;
   int _originalX;
   int _originalY;
   Iterator _xIterator;
   Iterator _yIterator;
   bool _verticalMode;
   int _cellHeight;
   int _headerHeight;
   ICellFactory* _cellFactory;
public:
   GridBuilder(int x, int y, int headerHeight, int cellHeight, bool verticalMode, ICellFactory* cellFactory)
      :_xIterator(x, -cell_width), _yIterator(y, cellHeight)
   {
      _cellHeight = cellHeight;
      _headerHeight = headerHeight;
      _cellFactory = cellFactory;
      _verticalMode = verticalMode;
      _originalY = y;
      _originalX = x;
      grid = new Grid();
   }

   ~GridBuilder()
   {
      delete _cellFactory;
   }

   void SetSymbols(const string symbols)
   {
      split(_symbols, symbols, ",");
      _symbolsCount = ArraySize(_symbols);

      if (_verticalMode)
      {
         Iterator yIterator(_originalY, _cellHeight);
         Row *row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _originalX + cell_width, yIterator.GetNext()));
         }
      }
      else
      {
         Iterator xIterator(_originalX - cell_width, -cell_width);
         Row *row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], xIterator.GetNext(), _originalY - _headerHeight));
         }
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
   {
      if (_verticalMode)
      {
         int x = _xIterator.GetNext();
         Row *row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, x, _headerHeight));
         Iterator yIterator(_originalY, _cellHeight);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            row.Add(_cellFactory.Create(id, x, yIterator.GetNext(), _symbols[i], timeframe));
         }
      }
      else
      {
         int y = _yIterator.GetNext();
         Row *row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _originalX, y));
         Iterator xIterator(_originalX - cell_width, -cell_width);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            row.Add(_cellFactory.Create(id, xIterator.GetNext(), y, _symbols[i], timeframe));
         }
      }
   }

   Grid* Build()
   {
      return grid;
   }

private:
   void split(string& arr[], string str, string sym) 
   {
      ArrayResize(arr, 0);
      int len = StringLen(str);
      for (int i=0; i < len;)
      {
         int pos = StringFind(str, sym, i);
         if (pos == -1)
            pos = len;
   
         string item = StringSubstr(str, i, pos-i);
         item = StringTrimLeft(item);
         item = StringTrimRight(item);
   
         int size = ArraySize(arr);
         ArrayResize(arr, size+1);
         arr[size] = item;
   
         i = pos+1;
      }
   }
};
#endif

int init()
{
   IndicatorName = GenerateIndicatorName("Inverted Hummer/Handging Man");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   GridBuilder builder(x_shift, y_shift, cell_height, cell_height, display_mode == Vertical, new TextValueCellFactory());
   builder.SetSymbols(Pairs);

   if (Include_M1)
      builder.AddTimeframe("M1", PERIOD_M1);
   if (Include_M5)
      builder.AddTimeframe("M5", PERIOD_M5);
   if (Include_M15)
      builder.AddTimeframe("M15", PERIOD_M15);
   if (Include_M30)
      builder.AddTimeframe("M30", PERIOD_M30);
   if (Include_H1)
      builder.AddTimeframe("H1", PERIOD_H1);
   if (Include_H4)
      builder.AddTimeframe("H4", PERIOD_H4);
   if (Include_D1)
      builder.AddTimeframe("D1", PERIOD_D1);
   if (Include_W1)
      builder.AddTimeframe("W1", PERIOD_W1);
   if (Include_MN1)
      builder.AddTimeframe("MN1", PERIOD_MN1);

   grid = builder.Build();

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete grid;
   grid = NULL;
   return 0;
}

int start()
{
   WindowNumber = MathMax(0, WindowFind(IndicatorName));
   grid.Draw();
   
   return 0;
}
