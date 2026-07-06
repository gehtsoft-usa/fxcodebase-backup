// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69343

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 0

enum LinesMethod
{
   Fibonacci,
   Gann,
   Custom
};
enum LevelsNumber
{
   Lines3, // 3 Lines
   Lines3Alt, // 3 Lines (alt)
   Lines5, // 5 Lines
   Lines7, // 7 Lines
   Lines9 // 9 lines
};

input int Number = 5; // Number of Fibonacci
input LinesMethod M = Fibonacci; // Lines Method
input LevelsNumber L = Lines3; // Levels number
input int E = 5; // Number of bars to show lines after the latest bar char
input bool Flip = false; // Use L-H instead H-L
input double L1 = -0.236; // 1. Level
input double L2 = 0; // 2. Level
input double L3 = 0.236; // 3. Level
input double L4 = 0.382; // 4. Level
input double L5 = 0.5; // 5. Level
input double L6 = 0.618; // 6. Level
input double L7 = 0.764; // 7. Level
input double L8 = 1; // 8. Level
input double L9 = 1.272; // 9. Level
input color clr = Red; // Color

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

double Signal[];
double levels[];

double fibonacci_levels[] = { -0.236, 0, 0.236, 0.382, 0.5, 0.618, 0.764, 1, 1.272 };
double gann_levels[] = { 0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1 };

void FillLevelsGann()
{
   switch (L)
   {
      case Lines3:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 3);
            levels[0] = fibonacci_levels[2];
            levels[1] = fibonacci_levels[4];
            levels[2] = fibonacci_levels[6];
         }
         break;
      case Lines3Alt:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 3);
            levels[0] = fibonacci_levels[0];
            levels[1] = fibonacci_levels[4];
            levels[2] = fibonacci_levels[8];
         }
         break;
      case Lines5:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 5);
            levels[0] = fibonacci_levels[0];
            levels[1] = fibonacci_levels[2];
            levels[2] = fibonacci_levels[4];
            levels[3] = fibonacci_levels[6];
            levels[4] = fibonacci_levels[8];
         }
         break;
      case Lines7:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 7);
            levels[0] = fibonacci_levels[0];
            levels[1] = fibonacci_levels[2];
            levels[2] = fibonacci_levels[3];
            levels[3] = fibonacci_levels[4];
            levels[4] = fibonacci_levels[5];
            levels[5] = fibonacci_levels[6];
            levels[6] = fibonacci_levels[8];
         }
         break;
      case Lines9:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 9);
            levels[0] = fibonacci_levels[0];
            levels[1] = fibonacci_levels[1];
            levels[2] = fibonacci_levels[2];
            levels[3] = fibonacci_levels[3];
            levels[4] = fibonacci_levels[4];
            levels[5] = fibonacci_levels[5];
            levels[6] = fibonacci_levels[6];
            levels[7] = fibonacci_levels[7];
            levels[8] = fibonacci_levels[8];
         }
         break;
   }
}

void FillLevelsCustom()
{
   switch (L)
   {
      case Lines3:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 3);
            levels[0] = L4;
            levels[1] = L5;
            levels[2] = L6;
         }
         break;
      case Lines3Alt:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 3);
            levels[0] = L2;
            levels[1] = L5;
            levels[2] = L8;
         }
         break;
      case Lines5:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 5);
            levels[0] = L2;
            levels[1] = L4;
            levels[2] = L5;
            levels[3] = L6;
            levels[4] = L8;
         }
         break;
      case Lines7:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 7);
            levels[0] = L2;
            levels[1] = L3;
            levels[2] = L4;
            levels[3] = L5;
            levels[4] = L6;
            levels[5] = L7;
            levels[6] = L8;
         }
         break;
      case Lines9:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 9);
            levels[0] = L1;
            levels[1] = L2;
            levels[2] = L3;
            levels[3] = L4;
            levels[4] = L5;
            levels[5] = L6;
            levels[6] = L7;
            levels[7] = L8;
            levels[8] = L9;
         }
         break;
   }
}

void FillLevelsFib()
{
   switch (L)
   {
      case Lines3:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 3);
            levels[0] = fibonacci_levels[3];
            levels[1] = fibonacci_levels[4];
            levels[2] = fibonacci_levels[5];
         }
         break;
      case Lines3Alt:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 3);
            levels[0] = fibonacci_levels[1];
            levels[1] = fibonacci_levels[4];
            levels[2] = fibonacci_levels[7];
         }
         break;
      case Lines5:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 5);
            levels[0] = fibonacci_levels[1];
            levels[1] = fibonacci_levels[3];
            levels[2] = fibonacci_levels[4];
            levels[3] = fibonacci_levels[5];
            levels[4] = fibonacci_levels[7];
         }
         break;
      case Lines7:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 7);
            levels[0] = fibonacci_levels[1];
            levels[1] = fibonacci_levels[2];
            levels[2] = fibonacci_levels[3];
            levels[3] = fibonacci_levels[4];
            levels[4] = fibonacci_levels[5];
            levels[5] = fibonacci_levels[6];
            levels[6] = fibonacci_levels[7];
         }
         break;
      case Lines9:
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 9);
            levels[0] = fibonacci_levels[0];
            levels[1] = fibonacci_levels[1];
            levels[2] = fibonacci_levels[2];
            levels[3] = fibonacci_levels[3];
            levels[4] = fibonacci_levels[4];
            levels[5] = fibonacci_levels[5];
            levels[6] = fibonacci_levels[6];
            levels[7] = fibonacci_levels[7];
            levels[8] = fibonacci_levels[8];
         }
         break;
   }
}

int init()
{
   IndicatorName = GenerateIndicatorName("Dynamic Fibonacci");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, Signal);
   if (M == Fibonacci)
   {
      FillLevelsFib();
   }
   else if (M == Gann)
   {
      FillLevelsGann();
   }
   else if (M == Custom)
   {
      FillLevelsCustom();
   }

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = MathMin(Bars - 1 - 4, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      Signal[i + 2] = EMPTY_VALUE;
      double curr = High[i + 2];
      if (curr >= High[i + 4] && curr >= High[i + 3] && curr >= High[i + 1] && curr >= High[i])
      {
         Signal[i + 2] = 1;
      }

      curr = Low[i + 2];
      if (curr <= Low[i + 4] && curr <= Low[i + 3] && curr <= Low[i + 1] && curr <= Low[i])
      {
         Signal[i + 2] = -1;
      }
      double curr1 = High[i + 2];
      double curr2 = Low[i + 2];
      if ((curr1 >= High[i + 4] && curr1 >= High[i + 3] && curr1 >= High[i + 1] && curr1 >= High[i]) 
         && (curr2 <= Low[i + 4] && curr2 <= Low[i + 3] && curr2 <= Low[i + 1] && curr2 <= Low[i]))
      {
         Signal[i + 2] = -2;
      }
   }
   int Count = 0;
   for (int i = 2; i < Bars; ++i)
   {
      if (Signal[i] == 1 || Signal[i] == -2)
      {
         int i1 = 0;
         int i2 = 0;
         double Price1 = 0;
         double Price2 = 0;
         if (Signal[i] == 1)
         {
            Price1 = High[i];
            i1 = i;
            Second(i, Price2, i2);
         }

         if (Signal[i] == -2)
         {
            Price1 = High[i];
            i1 = i;
            Price2 = Low[i];
            i2 = i;
         }

         if (Price1 == 0 || i2 == 0)
         {
            continue;
         }

         int p1 = MathMax(i1, i2);
         int p2 = MathMin(i1, i2);

         double min = MathMin(Price1, Price2);
         double max = MathMax(Price1, Price2);
         double d = max - min;

         int size = ArraySize(levels);
         for (int v = 0; v < size; ++v)
         {
            double price;
            if (Flip)
               price = max - d * levels[v];
            else
               price = min + d * levels[v];

            ResetLastError();
            string id = IndicatorObjPrefix + TimeToString(Time[i1]) + "_" + IntegerToString(v) + "idValue";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[i1], price, Time[i2], price))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
                  continue;
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
               ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, price);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[i1]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[i2]);
         }
         Count++;
      }

      if (Count > Number)
      {
         break;
      }
   }
   return 0;
}

void Second(int Index, double& p2, int& i2)
{
   for (int i = Index; i >= 0; ++i)
   {
      if (Signal[i] == -1 || Signal[i] == -2)
      {
         p2 = Low[i];
         i2 = i;
         return;
      }
   }
}

