// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70220

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

#property indicator_chart_window
#property strict

input int values_count = 2; // Values to summ

enum DisplayMode
{
   Vertical,
   Horizontal
};

input string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
input string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD";
input bool     Include_M1               = false;
input int corrPeriod_m1 = 20;
input bool     Include_M5               = false;
input int corrPeriod_m5 = 20;
input bool     Include_M15              = false;
input int corrPeriod_m15 = 20;
input bool     Include_M30              = false;
input int corrPeriod_m30 = 20;
input bool     Include_H1               = true;
input int corrPeriod_h1 = 20;
input bool     Include_H4               = false;
input int corrPeriod_h4 = 20;
input bool     Include_D1               = true;
input int corrPeriod_d1 = 20;
input bool     Include_W1               = true;
input int corrPeriod_w1 = 20;
input bool     Include_MN1              = false;
input int corrPeriod_mn1 = 20;
input color    Labels_Color             = clrWhite; // Label color
input color    up_Color             = Green; // Positive color
input color    down_Color             = Red; // Negative color
input int x_shift = 900; // X coordinate
input int y_shift = 50; // Y coordinate
input DisplayMode display_mode = Horizontal; // Display mode
input int font_size = 10; // Font Size;
input int cell_width = 80; // Cell width
input int cell_height = 30; // Cell height
//input int lookbakc_limit = 0; // Lookback limit

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

// Empty cell v1.1

// Interface for a cell v1.1

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw() = 0;
   virtual void HandleButtonClicks() = 0;
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
   virtual void HandleButtonClicks() {}
};

#endif
// Label cell v1.1



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

   virtual void HandleButtonClicks()
   {
      
   }
};

#endif
// Grid v1.1

// Row v1.1

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

   void HandleButtonClicks() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].HandleButtonClicks(); 
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

   void HandleButtonClicks()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].HandleButtonClicks();
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
   int _corrPeriod;
public:
   TextValueCell(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe, int corrPeriod)
   { 
      _corrPeriod = corrPeriod;
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
      int sum = 0;
      for (int i = 0; i < values_count; ++i)
      {
         sum += iCustom(_symbol, _timeframe, "CumulativeDelta 2", true, 0, 0, true, _corrPeriod, 0, i);
      }
      string label = DoubleToString(sum, 0);
      ObjectMakeLabel(_id, _x, _y, label, sum >= 0 ? up_Color : down_Color, 1, WindowNumber, "Arial", font_size); 
   }

   virtual void HandleButtonClicks()
   {
      
   }
};


// Interface for a cell factory v1.0



#ifndef ICellFactory_IMP
#define ICellFactory_IMP

class ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe, int corrPeriod) = 0;
   virtual string GetHeader() = 0;
};

#endif

// Text value cell factory v1.0

#ifndef TextValueCellFactory_IMP
#define TextValueCellFactory_IMP

class TextValueCellFactory : public ICellFactory
{
public:

   virtual string GetHeader()
   {
      return "Value";
   }
   
   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe, int corrPeriod)
   {
      return new TextValueCell(id, x, y, symbol, timeframe, corrPeriod);
   }
};
#endif

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

Grid *grid;

// Grid builder v2.1



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
   ICellFactory* _cellFactory[];
public:
   GridBuilder(int x, int y, int headerHeight, int cellHeight, bool verticalMode)
      :_xIterator(x, -cell_width), _yIterator(y, cellHeight)
   {
      _cellHeight = cellHeight;
      _headerHeight = headerHeight;
      _verticalMode = verticalMode;
      _originalY = y;
      _originalX = x;
      grid = new Grid();
   }

   ~GridBuilder()
   {
      for (int i = 0; i < ArraySize(_cellFactory); ++i)
      {
         delete _cellFactory[i];
      }
      ArrayResize(_cellFactory, 0);
   }

   void AddCell(ICellFactory* cellFactory)
   {
      int size = ArraySize(_cellFactory);
      ArrayResize(_cellFactory, size + 1);
      _cellFactory[size] = cellFactory;
   }

   void SetSymbols(const string symbols)
   {
      StringSplit(symbols, ',', _symbols);
      _symbolsCount = ArraySize(_symbols);

      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         Iterator yIterator(_originalY, _cellHeight);
         if (cellFactorySize > 1)
         {
            yIterator.GetNext();
         }
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _originalX + cell_width, yIterator.GetNext()));
         }
      }
      else
      {
         //TODO: add support of multiple values
         Iterator xIterator(_originalX - cell_width, -cell_width);
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], xIterator.GetNext(), _originalY - _headerHeight));
         }
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe, int corrPeriod)
   {
      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         int x[];
         ArrayResize(x, cellFactorySize);
         for (int ii = 0; ii < cellFactorySize; ++ii)
         {
            x[ii] = _xIterator.GetNext();
         }

         Row* column[];
         ArrayResize(column, cellFactorySize);
         for (int ii = 0; ii < cellFactorySize; ++ii)
         {
            column[ii] = grid.AddRow();
            if (ii > 0)
            {
               column[ii].Add(new EmptyCell());
            }
            else
            {
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_h", label, x[0], _headerHeight));
            }
         }
         
         Iterator yIterator(_originalY, _cellHeight);
         if (cellFactorySize > 1)
         {
            int y = yIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string index = IntegerToString(ii + 1);
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_sh" + index, _cellFactory[ii].GetHeader(), x[ii], y));
            }
         }

         for (int i = 0; i < _symbolsCount; i++)
         {
            int y = yIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string id = IndicatorObjPrefix + _symbols[i] + "_" + label + IntegerToString(ii);
               column[ii].Add(_cellFactory[ii].Create(id, x[ii], y, _symbols[i], timeframe, corrPeriod));
            }
         }
      }
      else
      {
         //TODO: add support of multiple values
         int y[];
         ArrayResize(y, cellFactorySize);
         for (int ii = 0; ii < cellFactorySize; ++ii)
         {
            y[ii] = _yIterator.GetNext();
         }
         Row* row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _originalX, y[0]));
         Iterator xIterator(_originalX - cell_width, -cell_width);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            int x = xIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               row.Add(_cellFactory[ii].Create(id, x, y[ii], _symbols[i], timeframe, corrPeriod));
            }
         }
      }
   }

   Grid* Build()
   {
      return grid;
   }
};
#endif

string IndicatorName;
int init()
{
   double temp = iCustom(NULL, 0, "CumulativeDelta 2", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'CumulativeDelta 2' indicator");
      return INIT_FAILED;
   }

   IndicatorName = "Cumulative Delta";
   IndicatorObjPrefix = GenerateIndicatorPrefix("cd");
   IndicatorShortName(IndicatorName);

   GridBuilder builder(x_shift, y_shift, cell_height, cell_height, display_mode == Vertical);
   builder.AddCell(new TextValueCellFactory());
   builder.SetSymbols(Pairs);

   if (Include_M1)
      builder.AddTimeframe("M1", PERIOD_M1, corrPeriod_m1);
   if (Include_M5)
      builder.AddTimeframe("M5", PERIOD_M5, corrPeriod_m5);
   if (Include_M15)
      builder.AddTimeframe("M15", PERIOD_M15, corrPeriod_m15);
   if (Include_M30)
      builder.AddTimeframe("M30", PERIOD_M30, corrPeriod_m30);
   if (Include_H1)
      builder.AddTimeframe("H1", PERIOD_H1, corrPeriod_h1);
   if (Include_H4)
      builder.AddTimeframe("H4", PERIOD_H4, corrPeriod_h4);
   if (Include_D1)
      builder.AddTimeframe("D1", PERIOD_D1, corrPeriod_d1);
   if (Include_W1)
      builder.AddTimeframe("W1", PERIOD_W1, corrPeriod_w1);
   if (Include_MN1)
      builder.AddTimeframe("MN1", PERIOD_MN1, corrPeriod_mn1);

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
