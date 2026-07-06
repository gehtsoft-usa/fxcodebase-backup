// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71061

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict
//----
#property indicator_separate_window

input color TColor = SteelBlue;
input color TxtColor = White;

//----The parameters of the indicators
input string p1 = "Parabolic SAR Parameter";
input double SAR_Step = 0.02;
input double SAR_Max = 0.2;
input string p2 = "MACD Parameter";
input int Fast_EMA = 12;
input int Slow_EMA = 26;
input int MACD_SMA = 9;
input string p3 = "Moving Average Parameter";
input int Fast_MA = 5;
input int Slow_MA = 10;
input string p4 = "ADX Parameter";
input int ADX_Period = 14;
input string p5 = "CCI Parameter";
input int Period_CCI = 14;
input int x = 10;
input int y = 50;
int t1, t2, t11, t12, t13, t14, t15, a, b;
int textT[7], textC[8], tt[10];
ENUM_TIMEFRAMES per[] = {PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4};
string nameS[] = {"INDICATOR", "M5", "M15", "M30", "H1", "H4"};
string name[] = {"Parabolic SAR", "MACD", "SMA Cross", "ADX", "CCI",
                 "", ""};

// Grid cells v1.0

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
   int _window;
public:
   GridTextCell(string id, int window)
   {
      _window = window;
      _id = id;
   }

   void SetData(string text, color clr, string fontName, int fontSize, ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT)
   {
      TextSetFont(fontName, fontSize * (-10));
      TextGetSize(text, _width, _height);
      if (_width > 130)
      {
         Print(_width);
      }
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
         if (!ObjectCreate(0, id, OBJ_LABEL, _window, 0, 0))
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
      if (width > 130)
      {
         Print(width);
      }
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
// Grid row v1.0

#ifndef GridRow_IMP
#define GridRow_IMP

class GridRow
{
   GridTextCell* _cells[];
   string _id;
   int _window;
public:
   GridRow(string id, int window)
   {
      _window = window;
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
         _cells[i] = new GridTextCell(_id + "-" + IntegerToString(i), _window);
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
   int _window;
public:
   GridCells(string id, double gap, int window)
   {
      _window = window;
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
      ArrayInitialize(maxHeight, 0);
      ArrayInitialize(maxWidth, 0);

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
            _columns[i] = new GridRow(_id + "-" + IntegerToString(i), _window);
         }
      }
   }
};

#endif

GridCells* cells0;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
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
class PeriodIndicators
{
   int _sar;
   int _macd;
   int _cma1;
   int _cma2;
   int _adx;
   int _cci;
   ENUM_TIMEFRAMES _tf;
public:
   PeriodIndicators(ENUM_TIMEFRAMES tf)
   {
      _tf = tf;
      _sar = iSAR(_Symbol, tf, SAR_Step, SAR_Max);
      _macd = iMACD(_Symbol, tf, Fast_EMA, Slow_EMA, MACD_SMA, PRICE_MEDIAN);
      _cma1 = iMA(_Symbol, tf, Fast_MA, 0, MODE_SMA, PRICE_MEDIAN);
      _cma2 = iMA(_Symbol, tf, Slow_MA, 0, MODE_SMA, PRICE_MEDIAN);
      _adx = iADX(_Symbol, tf, ADX_Period);
      _cci = iCCI(_Symbol, tf, Period_CCI, PRICE_MEDIAN);
   }
   ~PeriodIndicators()
   {
      IndicatorRelease(_sar);
      IndicatorRelease(_macd);
      IndicatorRelease(_cma1);
      IndicatorRelease(_cma2);
      IndicatorRelease(_adx);
      IndicatorRelease(_cci);
   }
   string SAR()
   {
      int ii = 1;
      double buffer[1];
      if (CopyBuffer(_sar, 0, 0, 1, buffer) != 1)
      {
         return "";
      }
      if (buffer[0] > iClose(NULL, _tf, ii))
      {
         if (CopyBuffer(_sar, 0, ii, 1, buffer) != 1)
         {
            return "";
         }
         while (buffer[0] > iClose(NULL, _tf, ii))
         {
            ii++;
            if (CopyBuffer(_sar, 0, ii, 1, buffer) != 1)
            {
               return "";
            }
         }
         return ("Sell(" + DoubleToString(ii, 0) + ")");
      }
      else
      {
         if (CopyBuffer(_sar, 0, ii, 1, buffer) != 1)
         {
            return "";
         }
         while (buffer[0] < iClose(NULL, _tf, ii))
         {
            ii++;
            if (CopyBuffer(_sar, 0, ii, 1, buffer) != 1)
            {
               return "";
            }
         }
         return ("Buy(" + DoubleToString(ii, 0) + ")");
      }
   }

   string Format(int indi1, int stream1, int indi2, int stream2)
   {
      int ii = 1;
      double val1[1];
      if (CopyBuffer(indi1, stream1, 0, 1, val1) != 1)
      {
         return "";
      }
      double val2[1];
      if (CopyBuffer(indi2, stream2, 0, 1, val2) != 1)
      {
         return "";
      }
      if (val1[0] < val2[0])
      {
         if (CopyBuffer(indi1, stream1, ii, 1, val1) != 1)
         {
            return "";
         }
         if (CopyBuffer(indi2, stream2, ii, 1, val2) != 1)
         {
            return "";
         }
         while (val1[0] < val2[0])
         {
            ii++;
            if (CopyBuffer(indi1, stream1, ii, 1, val1) != 1)
            {
               return "";
            }
            if (CopyBuffer(indi2, stream2, ii, 1, val2) != 1)
            {
               return "";
            }
         }
         return ("Sell(" + DoubleToString(ii, 0) + ")");
      }
      if (CopyBuffer(indi1, stream1, ii, 1, val1) != 1)
      {
         return "";
      }
      if (CopyBuffer(indi2, stream2, ii, 1, val2) != 1)
      {
         return "";
      }
      while (val1[0] > val2[0])
      {
         ii++;
         if (CopyBuffer(indi1, stream1, ii, 1, val1) != 1)
         {
            return "";
         }
         if (CopyBuffer(indi2, stream2, ii, 1, val2) != 1)
         {
            return "";
         }
      }
      return ("Buy(" + DoubleToString(ii, 0) + ")");
   }

   string MACD()
   {
      return Format(_macd, 0, _macd, 1);
   }
   string CMA()
   {
      return Format(_cma1, 0, _cma2, 0);
   }
   string ADX()
   {
      return Format(_adx, 1, _adx, 2);
   }
   string CCI()
   {
      int ii = 1;
      double val1[1];
      if (CopyBuffer(_cci, 0, 0, 1, val1) != 1)
      {
         return "";
      }
      if (val1[0] < 0)
      {
         if (CopyBuffer(_cci, 0, ii, 1, val1) != 1)
         {
            return "";
         }
         while (val1[0] < 0)
         {
            ii++;
            if (CopyBuffer(_cci, 0, ii, 1, val1) != 1)
            {
               return "";
            }
         }
         return ("Sell(" + DoubleToString(ii, 0) + ")");
      }
      if (CopyBuffer(_cci, 0, ii, 1, val1) != 1)
      {
         return "";
      }
      while (val1[0] > 0)
      {
         ii++;
         if (CopyBuffer(_cci, 0, ii, 1, val1) != 1)
         {
            return "";
         }
      }
      return ("Buy(" + DoubleToString(ii, 0) + ")");
   }
};
PeriodIndicators* tfs[];

int OnInit(void)
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("rtmi");
   IndicatorSetString(INDICATOR_SHORTNAME, "Realtime Multiindicator");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   name[0] = name[0] + "(" + DoubleToString(SAR_Step, 2) + ", " +
             DoubleToString(SAR_Max, 2) + ")";
   name[1] = name[1] + "(" + DoubleToString(Fast_EMA, 0) + ", " +
             DoubleToString(Slow_EMA, 0) + ", " +
             DoubleToString(MACD_SMA, 0) + ")";
   name[2] = name[2] + "(" + DoubleToString(Fast_MA, 0) + ", " +
             DoubleToString(Slow_MA, 0) + ")";
   name[3] = name[3] + "(" + DoubleToString(ADX_Period, 0) + ")";
   name[4] = name[4] + "(" + DoubleToString(Period_CCI, 0) + ")";
   int size = ArraySize(tfs);
   ArrayResize(tfs, size + ArraySize(per));
   for (int i = 0; i < ArraySize(per); ++i)
   {
      tfs[i] = new PeriodIndicators(per[i]);
   }

   return 0;
}

void OnDeinit(const int reason)
{
   for (int i = 0; i < ArraySize(tfs); ++i)
   {
      delete tfs[i];
   }
   ArrayResize(tfs, 0);
   delete cells0;
   cells0 = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
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
   if (cells0 == NULL)
   {
      int windowNumber = ChartWindowFind();
      cells0 = new GridCells(IndicatorObjPrefix, 1.2, windowNumber);
   }
   for (int i = 1; i <= ArraySize(name); i++)
   {
      cells0.Add(name[i - 1], TxtColor, "Tahoma", 8, 0, i);
   }
   for (int i = 1; i <= ArraySize(tfs); i++)
   {
      cells0.Add(tfs[i - 1].SAR(), TxtColor, "Tahoma", 8, 1, i);
      cells0.Add(tfs[i - 1].MACD(), TxtColor, "Tahoma", 8, 2, i);
      cells0.Add(tfs[i - 1].CMA(), TxtColor, "Tahoma", 8, 3, i);
      cells0.Add(tfs[i - 1].ADX(), TxtColor, "Tahoma", 8, 4, i);
      cells0.Add(tfs[i - 1].CCI(), TxtColor, "Tahoma", 8, 5, i);
   }
   for (int i = 1; i <= ArraySize(nameS); i++)
   {
      cells0.Add(nameS[i - 1], TxtColor, "Tahoma", 10, i - 1, 0);
   }
      
   cells0.Draw(x, y);
   return 0;
}
