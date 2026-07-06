// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69157

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 0

enum ShowType
{
   Prime,
   Square
};

input int Step = 100; // Step
input ShowType Type = Prime; // Prime / Square
input bool LOCK = true; // LOCK
input bool DEGREE0On = true; // Gann  Square 0�
input bool DEGREE45On = true; // Gann  Square 45�
input bool DEGREE90On = true; // Gann  Square 90�
input bool DEGREE135On = true; // Gann  Square 135�
input bool DEGREE180On = true; // Gann  Square 180�
input bool DEGREE230On = true; // Gann  Square 230�
input bool DEGREE270On = true; // Gann  Square 270�
input bool DEGREE315On = true; // Gann  Square 315�
input color Gann = Red; // Squere Of Nine Lines Color

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

double pipSize;

int init()
{
   IndicatorName = GenerateIndicatorName("Gann's Square Of Nine");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   pipSize = point * mult;

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}


double PRIME[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97};
double DEGREE0[] = {6, 19, 40, 69, 106, 151, 204, 265, 334};
double DEGREE90[] = {316, 249, 190, 139, 96, 61, 34, 15, 4};
double DEGREE180[] = {298, 233, 176, 127, 86, 53, 28, 11, 2};
double DEGREE270[] = {8, 23, 46, 77, 116, 163, 218, 281, 352};

double DEGREE45[] = {5, 17, 37, 65, 101, 145, 197, 256, 325};
double DEGREE135[] = {3, 13, 31, 57, 91, 133, 183, 241, 307};
double DEGREE230[] = {9, 25, 49, 81, 121, 169, 225, 289, 361};
double DEGREE315[] = {7, 21, 43, 73, 111, 157, 211, 273, 343};

void DrawLine(string id, double value)
{
   ResetLastError();
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[Bars - 1], value, Time[0], value))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, Gann);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE1, value);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, value);
}

void DRAW(int i, double low, datetime p, int k)
{
	if (Type == Prime)
   {
      DrawLine(IndicatorObjPrefix + "_" + IntegerToString(i) + "idValue", low + PRIME[i] * Step * pipSize);
		// core.host:execute("drawLabel", k * 1000 + 2 * 100 + i, source:date(p) + 2 * size,
		// 	low + PRIME[i] * Step * source:pipSize(), "(" .. tostring(PRIME[i]) .. ")")
   }
	else if (k == 1)
   {
      DrawLine(IndicatorObjPrefix + "_" + IntegerToString(i) + "idValue", low + DEGREE0[i] * Step * pipSize);
		// core.host:execute(
		// 	"drawLabel",
		// 	k * 1000 + 2 * 100 + i,
		// 	source:date(p) + 2 * size,
		// 	low + DEGREE0[i] * Step * source:pipSize(),
		// 	"(" .. tostring(DEGREE0[i]) .. ", 0�" .. ")"
		// )
   }
	else if (k == 2)
   {
      DrawLine(IndicatorObjPrefix + "_" + IntegerToString(i) + "idValue", low + DEGREE90[i] * Step * pipSize);
		//	core.host:execute(
		// 	"drawLabel",
		// 	k * 1000 + 2 * 100 + i,
		// 	source:date(p) + 2 * size,
		// 	low + DEGREE90[i] * Step * source:pipSize(),
		// 	"(" .. tostring(DEGREE90[i]) .. ", 90�" .. ")"
		// )
   }
	else if (k == 3)
   {
      DrawLine(IndicatorObjPrefix + "_" + IntegerToString(i) + "idValue", low + DEGREE180[i] * Step * pipSize);
		// core.host:execute(
		// 	"drawLabel",
		// 	k * 1000 + 2 * 100 + i,
		// 	source:date(p) + 2 * size,
		// 	low + DEGREE180[i] * Step * source:pipSize(),
		// 	"(" .. tostring(DEGREE180[i]) .. ", 180�" .. ")"
		// )
   }
	else if (k == 4)
   {
      DrawLine(IndicatorObjPrefix + "_" + IntegerToString(i) + "idValue", low + DEGREE270[i] * Step * pipSize);
		// core.host:execute(
		// 	"drawLabel",
		// 	k * 1000 + 2 * 100 + i,
		// 	source:date(p) + 2 * size,
		// 	low + DEGREE270[i] * Step * source:pipSize(),
		// 	"(" .. tostring(DEGREE270[i]) .. ", 270�" .. ")"
		// )
   }
	else if (k == 5)
   {
      DrawLine(IndicatorObjPrefix + "_" + IntegerToString(i) + "idValue", low + DEGREE45[i] * Step * pipSize);
		// core.host:execute(
		// 	"drawLabel",
		// 	k * 1000 + 2 * 100 + i,
		// 	source:date(p) + 2 * size,
		// 	low + DEGREE45[i] * Step * source:pipSize(),
		// 	"(" .. tostring(DEGREE45[i]) .. ", 45�" .. ")"
		// )
   }
	else if (k == 6)
   {
      DrawLine(IndicatorObjPrefix + "_" + IntegerToString(i) + "idValue", low + DEGREE135[i] * Step * pipSize);
		// core.host:execute(
		// 	"drawLabel",
		// 	k * 1000 + 2 * 100 + i,
		// 	source:date(p) + 2 * size,
		// 	low + DEGREE135[i] * Step * source:pipSize(),
		// 	"(" .. tostring(DEGREE135[i]) .. ", 135�" .. ")"
		// )
   }
	else if (k == 7)
   {
      DrawLine(IndicatorObjPrefix + "_" + IntegerToString(i) + "idValue", low + DEGREE230[i] * Step * pipSize);
		// core.host:execute(
		// 	"drawLabel",
		// 	k * 1000 + 2 * 100 + i,
		// 	source:date(p) + 2 * size,
		// 	low + DEGREE230[i] * Step * source:pipSize(),
		// 	"(" .. tostring(DEGREE230[i]) .. ", 230�" .. ")"
		// )
   }
	else if (k == 8)
   {
      DrawLine(IndicatorObjPrefix + "_" + IntegerToString(i) + "idValue", low + DEGREE315[i] * Step * pipSize);
		// core.host:execute(
		// 	"drawLabel",
		// 	k * 1000 + 2 * 100 + i,
		// 	source:date(p) + 2 * size,
		// 	low + DEGREE315[i] * Step * source:pipSize(),
		// 	"(" .. tostring(DEGREE315[i]) .. ", 315�" .. ")"
		// )
	}
}

bool SET = true;

int start()
{
   double LOW;
   if (!LOCK || SET)
   {
		SET = false;
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, Bars - 1, 0);
      LOW = iLow(_Symbol, _Period, lowestIndex);
   }

   DrawLine("main_line", LOW);
	//core.host:execute("drawLabel", 2, source:date(source:size() - 1) + 2 * size, LOW, "( 0. Line )")

	for (int i = 0; i < 25; ++i)
   {
		if (Type == Prime)
      {
			DRAW(i, LOW, Time[0], 0);
      }
		else if (i < 10)
      {
			if (DEGREE0On)
				DRAW(i, LOW, Time[0], 1);
			if (DEGREE90On)
				DRAW(i, LOW, Time[0], 2);
			if (DEGREE180On)
				DRAW(i, LOW, Time[0], 3);
			if (DEGREE270On)
				DRAW(i, LOW, Time[0], 4);
			if (DEGREE45On)
				DRAW(i, LOW, Time[0], 5);
			if (DEGREE135On)
				DRAW(i, LOW, Time[0], 6);
			if (DEGREE230On)
				DRAW(i, LOW, Time[0], 7);
			if (DEGREE315On)
				DRAW(i, LOW, Time[0], 8);
		}
	}
   return 0;
}
