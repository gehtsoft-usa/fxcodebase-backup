// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67157

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

// Dashboard overlay template v.1.0

#property indicator_chart_window
#property strict

extern int vwma_period = 14; // VWMA period
extern int sma_period = 14; // SMA period

extern string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern bool     Include_M1               = true;
extern bool     Include_M5               = true;
extern bool     Include_M15              = true;
extern bool     Include_M30              = true;
extern bool     Include_H1               = true;
extern bool     Include_H4               = true;
extern bool     Include_D1               = true;
extern bool     Include_W1               = true;
extern bool     Include_MN1              = true;
extern color    Labels_Color             = clrWhite; // Labels color
extern color    Up_Color                 = clrLime; // Up signal color
extern color    Dn_Color                 = clrRed; // Down signal color
extern color    Neutral_Color            = clrDarkGray; // No signal color
extern color    Background_Color            = clrBlack; // Background color

string   WindowName;
int      WindowNumber;

// Dashboard v.1.2
class Iterator
{
   int _initialValue; int _shift; int _current;
public:
   Iterator(int initialValue, int shift) { _initialValue = initialValue; _shift = shift; _current = _initialValue - _shift; }
   int GetNext() { _current += _shift; return _current; }
};

class ICell
{
public:
   virtual void Draw() = 0;

   virtual int GetX2() = 0;

   virtual int GetY2() = 0;
protected:
   void ObjectMakeLabel(string nm, int xoff, int yoff, string LabelTexto, 
      color LabelColor, int LabelCorner = CORNER_LEFT_UPPER, int Window = 0, 
      string Font = "Arial", int FSize = 8 )
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

class Row
{
   ICell *_cells[];
public:
   ~Row()
   {
      int count = GetCellsCount();
      for (int i = 0; i < count; ++i)
      {
         delete _cells[i];
      }
   }
   void Draw()
   {
      int count = GetCellsCount();
      for (int i = 0; i < count; ++i)
      {
         _cells[i].Draw();
      }
   }
   void Add(ICell *cell)
   {
      int count = GetCellsCount();
      ArrayResize(_cells, count + 1);
      _cells[count] = cell;
   } 

   int GetCellsCount()
   {
      return ArraySize(_cells);
   }

   ICell *GetCell(const int index)
   {
      return _cells[index];
   }
};

//draws nothing
class EmptyCell : public ICell
{
public:
   virtual void Draw() { }
   virtual int GetX2() { return 0; }
   virtual int GetY2() { return 0; }
};

//draws a label
class LabelCell : public ICell
{
   string _id;
   string _text;
   int _x;
   int _y;
   int _fontSize;
public:
   LabelCell(const string id, const string text, const int x, const int y, const int fontSize = 12)
   {
      _fontSize = fontSize;
      _id = id;
      _text = text;
      _x = x;
      _y = y;
   } 

   virtual void Draw()
   {
      ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, CORNER_LEFT_UPPER, WindowNumber, "Arial", _fontSize);
   }
   virtual int GetX2()
   {
      return _x;
   }
   virtual int GetY2()
   {
      return _y;
   }
};

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1

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

class ValueIndicator : public ICell
{
   string _id;
   int _x;
   int _y;
   int _xEnd;
   int _yEnd;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   ValueIndicator(const string id, const int x, const int y, const int xEnd, const int yEnd, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _id = id;
      _x = x;
      _y = y;
      _xEnd = xEnd;
      _yEnd = yEnd;
   }

   virtual void Draw()
   {
      int direction = GetDirection();
      ObjectCreate(_id, OBJ_RECTANGLE_LABEL, 0, 0, 0); 
      ObjectSetInteger(0, _id, OBJPROP_XDISTANCE, _x); 
      ObjectSetInteger(0, _id, OBJPROP_YDISTANCE, _y); 
      ObjectSetInteger(0, _id, OBJPROP_XSIZE, _xEnd - _x); 
      ObjectSetInteger(0, _id, OBJPROP_YSIZE, _yEnd - _y); 
      ObjectSetInteger(0, _id, OBJPROP_BGCOLOR, GetDirectionColor(direction));
   }
   virtual int GetX2()
   {
      return _xEnd;
   }
   virtual int GetY2()
   {
      return _yEnd;
   }
private:
   double VWMA(int per, int bar)
   {
      double Sum = 0;
      long weight = 0;
      for(int i = 0; i < per; i++)
      { 
         long volume = iVolume(_symbol, _timeframe, bar + i);
         weight += volume;
         Sum += iClose(_symbol, _timeframe, bar + i) * volume;
      }
      if (weight > 0)
         return Sum / weight;
      return 0;
   } 

   int GetDirection()
   {
      double vwma = VWMA(vwma_period, 0);
      double sma = iMA(_symbol, _timeframe, sma_period, 0, MODE_SMA, PRICE_CLOSE, 0);
      return vwma > sma ? 1 : -1;
   }

   color GetDirectionColor(const int direction)
   {
      if (direction >= 1)
      {
         return Up_Color;
      }
      else if (direction <= -1)
      {
         return Dn_Color;
      }
      return Neutral_Color;
   }
};

class Grid
{
   Row *_rows[];
   bool _drawBackgound;
public:
   Grid()
   {
      _drawBackgound = false;
   }

   ~Grid()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         delete _rows[i];
      }
   }

   void AddBackground(const int xStart, const int yStart, const int xEnd, const int yEnd)
   {
      string id = IndicatorObjPrefix + "BG";
      ObjectCreate(id, OBJ_RECTANGLE_LABEL, 0, 0, 0); 
      ObjectSetInteger(0, id, OBJPROP_XDISTANCE, xStart); 
      ObjectSetInteger(0, id, OBJPROP_YDISTANCE, yStart); 
      ObjectSetInteger(0, id, OBJPROP_XSIZE, xEnd - xStart); 
      ObjectSetInteger(0, id, OBJPROP_YSIZE, yEnd - yStart); 
      ObjectSetInteger(0, id, OBJPROP_BGCOLOR, Background_Color);
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
   
   void Draw()
   {
      int count = GetRowsCount();
      for (int i = 0; i < count; ++i)
      {
         _rows[i].Draw();
      }
   }
};

Grid *grid;

class GridBuilder
{
   string sym_arr[];
   int sym_count;
   Grid *grid;
   int Original_x;
   Iterator xIterator;
   int _yStep;
   int _yStart;
public:
   GridBuilder(const string symbols, const string title)
      :xIterator(80, 40)
   {
      _yStep = 15;
      _yStart = 20;
      grid = new Grid();
      split(sym_arr, symbols, ",");
      sym_count = ArraySize(sym_arr);

      Iterator yIterator(_yStart, _yStep);
      Row *titleRow = grid.AddRow();
      titleRow.Add(new LabelCell(IndicatorObjPrefix + "_title", title, 10, yIterator.GetNext(), 10));
      int ignore = yIterator.GetNext();

      int x = 10;
      Row *row = grid.AddRow();
      row.Add(new EmptyCell());
      for (int i = 0; i < sym_count; i++)
      {
         row.Add(new LabelCell(IndicatorObjPrefix + sym_arr[i] + "_Name", sym_arr[i], x, yIterator.GetNext(), 10));
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
   {
      Iterator yIterator(_yStart + _yStep, _yStep);
      int x = xIterator.GetNext();
      Row *row = grid.AddRow();
      row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, x, yIterator.GetNext(), 10));
      int y = yIterator.GetNext();
      for (int i = 0; i < sym_count; i++)
      {
         int yNext = yIterator.GetNext();
         row.Add(new ValueIndicator(IndicatorObjPrefix + sym_arr[i] + "_" + label, x, y, x + 40, yNext, sym_arr[i], timeframe));
         y = yNext;
      }
   }

   Grid *Build()
   {
      int maxX = 0;
      int maxY = 0;
      int rows = grid.GetRowsCount();
      for (int rowIndex = 0; rowIndex < rows; ++rowIndex)
      {
         Row *row = grid.GetRow(rowIndex);
         int cellsCount = row.GetCellsCount();
         for (int cellIndex = 0; cellIndex < cellsCount; cellIndex++)
         {
            ICell *cell = row.GetCell(cellIndex);
            int x2 = cell.GetX2();
            if (x2 > maxX)
               maxX = x2;
            int y2 = cell.GetY2();
            if (y2 > maxY)
               maxY = y2;
         }
      }
      grid.AddBackground(0, _yStart - 10, maxX + 10, maxY + 10);
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

int init()
{
   IndicatorName = GenerateIndicatorName("MTF Multipair VWMA Crossover Dashboard");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   GridBuilder builder(Pairs, IndicatorName);
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
   return 0;
}

int start()
{
   WindowNumber = 0;
   grid.Draw();
   
   return 0;
}
