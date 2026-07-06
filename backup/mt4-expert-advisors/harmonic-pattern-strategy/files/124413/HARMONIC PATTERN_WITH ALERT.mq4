// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright � 2019, Gehtsoft USA LLC | 
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

#property copyright "Copyright � 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property strict

// Bar overlay template v.1.0.0

#property indicator_chart_window
#property indicator_buffers 28
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 Red
#property indicator_color9 Red
#property indicator_color10 Red
#property indicator_color11 Red
#property indicator_color12 Red
#property indicator_color13 Red
#property indicator_color14 Red
#property indicator_color15 Red
#property indicator_color16 Red
#property indicator_color17 Red
#property indicator_color18 Red
#property indicator_color19 Red
#property indicator_color20 Red
#property indicator_color21 Red
#property indicator_color22 Red
#property indicator_color23 Red
#property indicator_color24 Red
#property indicator_color25 Red
#property indicator_color26 Red
#property indicator_color27 Red
#property indicator_color28 Red

extern bool UseBat = true; // Bat
extern bool UseGartley = true; // Gartley
extern bool UseCrab = true; // Crab
extern bool UseButterfly = true; // Butterfly
extern bool UseABCD = true; // AB=CD
extern bool UseThreeDrives = true; // Drives

extern int Correction = 25; // Correction

extern int Depth = 12; // Depth
extern int Deviation = 5; // Deviation
extern int Backstep = 3; // Backstep

extern bool Show = false; // Show Price Targets
extern bool ShowZigZag = true; // Show Zig Zag Line
extern color Bull = Green; // Bull color
extern color Bear = Red; // Bear color

double signal[];
double out[];

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

int correction;
int lastPositions[13];
double pipSize;

int init()
{
   IndicatorName = GenerateIndicatorName("Harmonic Pattern");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   double _point = MarketInfo(_Symbol, MODE_POINT);
   double _digits = (int)MarketInfo(_Symbol, MODE_DIGITS); 
   double _mult = _digits == 3 || _digits == 5 ? 10 : 1;
   pipSize = _point * _mult;

   correction = Correction / 100;
   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, signal);
   SetIndexStyle(1, ShowZigZag ? DRAW_LINE : DRAW_NONE);
   SetIndexBuffer(1, out);
   SetIndexLabel(1, "ZigZag");
   int id = 2;
   if (UseThreeDrives)
      id = Drives.RegisterStreams(id, "Drives");
   if (UseBat)
      id = Bat.RegisterStreams(id, "Bat");
   if (UseGartley)
      id = Gartley.RegisterStreams(id, "Gartley");
   if (UseCrab)
      id = Crab.RegisterStreams(id, "Crab");
   if (UseButterfly)
      id = Butterfly.RegisterStreams(id, "Butterfly");
   if (UseABCD)
   {
      id = ABCDOneBull.RegisterStream(id, "AB=CD Bull One", Bull);
      id = ABCDTwoBull.RegisterStream(id, "AB=CD Bull Two", Bull);
      id = ABCDDownBull.RegisterStream(id, "AB=CD Bull Down", Bull);
      id = ABCDOneBear.RegisterStream(id, "AB=CD Bear One", Bear);
      id = ABCDTwoBear.RegisterStream(id, "AB=CD Bear Two", Bear);
      id = ABCDDownBear.RegisterStream(id, "AB=CD Bear Down", Bear);
   }

   double temp = iCustom(NULL, 0, "ZigZagColored", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'ZigZagColored' indicator");
      return INIT_FAILED;
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
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit = Bars - 5;
   if (ExtCountedBars > 2) 
      limit = MathMin(Bars - ExtCountedBars - 1, limit);

   int pos = limit;
   while (pos >= 0)
   {
      out[pos + 3] = iCustom(_Symbol, _Period, "ZigZagColored", Depth, Deviation, Backstep, 0, pos + 3);
      if (out[pos + 3] == EMPTY_VALUE)
         out[pos + 3] = iCustom(_Symbol, _Period, "ZigZagColored", Depth, Deviation, Backstep, 1, pos + 3);

      HighFour = 0;
      HighThree = 0;
      HighTwo = 0;
      HighOne = 0;
      LowFour = 0;
      LowThree = 0;
      LowTwo = 0;
      LowOne = 0;

      int signal_period;      
      string name;
      int id;
      double val;
      bool res;
      for (int i = limit + 1; i >= pos; --i)
      {
         if (MathAbs(out[i] - High[i]) < pipSize)
         {
            HighFour = HighThree;
            HighThree = HighTwo;
            HighTwo = HighOne;
            HighOne = i;

            if (HighFour != 0)
            {
               res = Lengt(false, name, id, val);
               if (id != 0 && lastPositions[id + 6] > i)
               {
                  signal[pos] = id;
                  lastPositions[id + 6] = i;
                  signal_period = i;
               }
            }
         }
         else if (MathAbs(out[i] - Low[i]) < pipSize)
         {
            LowFour = LowThree;
            LowThree = LowTwo;
            LowTwo = LowOne;
            LowOne = i;

            if (LowFour != 0)
            {
               res = Lengt(true, name, id, val);
               if (id != 0 && lastPositions[id + 6] > i)
               {
                  signal[pos] = id;
                  lastPositions[id + 6] = i;
                  signal_period = i;
               }
            }
         }
      }

      pos--;
   }
   return 0;
}

int LowFour;
int HighFour;
int LowOne;
int LowTwo;
int LowThree;
int HighOne;
int HighTwo;
int HighThree;
int D, B, X, C, A;
double XA, AB, BC, CD, XB, XD, BD, AC, AD;

bool Lengt(const bool FLAG, string &name, int &id, double &val)
{
	if (LowFour == 0 || HighFour == 0)
		return false;

	if (FLAG)
   {
		D = LowOne;
		B = LowTwo;
		X = LowThree;
		C = HighOne;
		A = HighTwo;
   }
	else
   {
		D = HighOne;
		B = HighTwo;
		X = HighThree;
		C = LowOne;
		A = LowTwo;
	}

	XA = MathAbs(out[X] - out[A]);
	AB = MathAbs(out[A] - out[B]);
	BC = MathAbs(out[B] - out[C]);
	CD = MathAbs(out[C] - out[D]);

	XB = MathAbs(out[X] - out[B]);
	XD = MathAbs(out[X] - out[D]);
	BD = MathAbs(out[B] - out[D]);
	AC = MathAbs(out[A] - out[C]);

	AD = MathAbs(out[A] - out[D]);

	if (DECODE(FLAG, name, id, val))
	{
      DRAW(name);
		return true;
   }
	return false;
}

class LineStream
{
   double _stream[];
public:
   int RegisterStream(const int id, const string name, const color clr)
   {
      SetIndexBuffer(id, _stream);
      SetIndexLabel(id, name);
      SetIndexStyle(id, DRAW_LINE, STYLE_SOLID, 1, clr);
      return id + 1;
   }

   void DrawLine(const double fromValue, const int from, const double toValue, const int to)
   {
      int count = from - to;
      if (count == 0)
         return;

      double step = (toValue - fromValue) / count;
      for (int i = from; i >= to; --i)
      {
         _stream[i] = fromValue + step * (from - i);
      }
   }
};

class UpDownBullBearStreams
{
public:
   LineStream UpBull;
   LineStream UpBear;
   LineStream DownBull;
   LineStream DownBear;

   int RegisterStreams(const int id, const string name)
   {
      int newId = UpBull.RegisterStream(id, name + " Up Bull", Bull);
      newId = DownBull.RegisterStream(newId, name + " Down Bull", Bull);
      newId = UpBear.RegisterStream(newId, name + " Up Bear", Bear);
      return DownBear.RegisterStream(newId, name + " Down Bear", Bear);
   }
};

UpDownBullBearStreams Drives;
UpDownBullBearStreams Bat;
UpDownBullBearStreams Gartley;
UpDownBullBearStreams Crab;
UpDownBullBearStreams Butterfly;
LineStream ABCDOneBull;
LineStream ABCDTwoBull;
LineStream ABCDDownBull;
LineStream ABCDOneBear;
LineStream ABCDTwoBear;
LineStream ABCDDownBear;

void DrawLabel(const datetime dt, const double value, const string label)
{
   string id = IndicatorObjPrefix + label + TimeToStr(dt);
   if (!ObjectCreate(0, id, OBJ_TEXT, 0, dt, value)) 
   { 
      return ;
   } 
   ObjectSetString(0, id, OBJPROP_TEXT, label); 
}

void DRAW(const string label)
{
	if (X == A || A == B || B == C || C == D)
		return;

	if (label == "Bull Three Drives" || label == "Bear Three Drives")
   {
      if (!UseThreeDrives)
         return;
      if (out[X] < out[A])
      {
         drawline(D, out[D] + AD * 1.272, D + (D - A), out[D] + AD * 1.272, Bull);
         drawline(D, out[D] + XA, D + (A - X), out[D] + XA, Bull);

         Drives.UpBull.DrawLine(out[X], X, out[B], B);
         Drives.UpBull.DrawLine(out[B], B, out[D], D);
         
         DrawLabel(Time[X], MathMax(out[X], out[A]), label);

         Drives.DownBull.DrawLine(out[X], X, out[A], A);
         Drives.DownBull.DrawLine(out[A], A, out[B], B);
         Drives.DownBull.DrawLine(out[B], B, out[C], C);
         Drives.DownBull.DrawLine(out[C], C, out[D], D);
      }
      else
      {
         drawline(D, out[D] + AD * 1.272, D - (D - A), out[D] + AD * 1.272, Bear);
         drawline(D, out[D] + XA, D - (A - X), out[D] + XA, Bear);

         Drives.UpBear.DrawLine(out[X], X, out[B], B);
         Drives.UpBear.DrawLine(out[B], B, out[D], D);

         DrawLabel(Time[X], MathMax(out[X], out[A]), label);

         Drives.DownBear.DrawLine(out[X], X, out[A], A);
         Drives.DownBear.DrawLine(out[A], A, out[B], B);
         Drives.DownBear.DrawLine(out[B], B, out[C], C);
         Drives.DownBear.DrawLine(out[C], C, out[D], D);
      }
   }
	else if (label == "Bull Bat" || label == "Bear Bat")
   {
      if (!UseBat)
         return;

      if (out[X] < out[A])
      {
         drawline(D, out[D] + AD * 1.272, D - (D - A), out[D] + AD * 1.272, Bull);
         drawline(D, out[D] + XA, D - (A - X), out[D] + XA, Bull);
         Bat.UpBull.DrawLine(out[X], X, out[D], D);

         DrawLabel(Time[X], MathMax(out[B], out[A]), label);
         Bat.DownBull.DrawLine(out[X], X, out[A], A);
         Bat.DownBull.DrawLine(out[A], A, out[B], B);
         Bat.DownBull.DrawLine(out[B], B, out[C], C);
         Bat.DownBull.DrawLine(out[C], C, out[D], D);
      }
      else
      {
         drawline(D, out[D] - AD * 1.272, D - (D - A), out[D] - AD * 1.272, Bear);
         drawline(D, out[D] - XA, D - (A - X), out[D] - XA, Bear);
         Bat.UpBear.DrawLine(out[X], X, out[D], D);

         DrawLabel(Time[X], MathMax(out[B], out[A]), label);
         Bat.DownBear.DrawLine(out[X], X, out[A], A);
         Bat.DownBear.DrawLine(out[A], A, out[B], B);
         Bat.DownBear.DrawLine(out[B], B, out[C], C);
         Bat.DownBear.DrawLine(out[C], C, out[D], D);
      }
   }
	else if (label == "Bull Gartley" || label == "Bear Gartley")
   {
		if (!UseGartley)
         return;
      
      if (out[X] < out[A])
      {
         drawline(D, out[D] + AD * 1.272, D - (D - A), out[D] + AD * 1.272, Bull);
         drawline(D, out[D] + XA, D - (A - X), out[D] + XA, Bull);
         Gartley.UpBull.DrawLine(out[X], X, out[D], D);

         DrawLabel(Time[X], MathMax(out[B], out[A]), label);
         Gartley.DownBull.DrawLine(out[X], X, out[A], A);
         Gartley.DownBull.DrawLine(out[A], A, out[B], B);
         Gartley.DownBull.DrawLine(out[B], B, out[C], C);
         Gartley.DownBull.DrawLine(out[C], C, out[D], D);
      }
      else
      {
         drawline(D, out[D] - AD * 1.272, D - (D - A), out[D] - AD * 1.272, Bear);
         drawline(D, out[D] - XA, D - (A - X), out[D] - XA, Bear);
         Gartley.UpBear.DrawLine(out[X], X, out[D], D);

         DrawLabel(Time[X], MathMax(out[B], out[A]), label);
         Gartley.DownBear.DrawLine(out[X], X, out[A], A);
         Gartley.DownBear.DrawLine(out[A], A, out[B], B);
         Gartley.DownBear.DrawLine(out[B], B, out[C], C);
         Gartley.DownBear.DrawLine(out[C], C, out[D], D);
      }
   }
	else if (label == "Bull Crab" || label == "Bear Crab")
   {
		if (!UseCrab)
         return;
      
      if (out[X] < out[A])
      {
         drawline(D, out[D] + AD * 1.272, D - (D - A), out[D] + AD * 1.272, Bull);
         drawline(D, out[D] + XA, D - (A - X), out[D] + XA, Bull);

         Gartley.UpBull.DrawLine(out[X], X, out[D], D);

         DrawLabel(Time[X], MathMax(out[B], out[A]), label);
         Gartley.DownBull.DrawLine(out[X], X, out[A], A);
         Gartley.DownBull.DrawLine(out[A], A, out[B], B);
         Gartley.DownBull.DrawLine(out[B], B, out[C], C);
         Gartley.DownBull.DrawLine(out[C], C, out[D], D);
      }
      else
      {
         drawline(D, out[D] - AD * 1.272, D - (D - A), out[D] - AD * 1.272, Bear);
         drawline(D, out[D] - XA, D - (A - X), out[D] - XA, Bear);

         Gartley.UpBear.DrawLine(out[X], X, out[D], D);

         DrawLabel(Time[X], MathMax(out[B], out[A]), label);
         Gartley.DownBear.DrawLine(out[X], X, out[A], A);
         Gartley.DownBear.DrawLine(out[A], A, out[B], B);
         Gartley.DownBear.DrawLine(out[B], B, out[C], C);
         Gartley.DownBear.DrawLine(out[C], C, out[D], D);
      }
   }
	else if (label == "Bull Butterfly" || label == "Bear Butterfly")
   {
		if (!UseButterfly)
         return;
      
      if (out[X] < out[A])
      {
         drawline(D, out[D] + AD * 1.272, D - (D - A), out[D] + AD * 1.272, Bull);
         drawline(D, out[D] + XA, D - (A - X), out[D] + XA, Bull);
         
         Butterfly.UpBull.DrawLine(out[X], X, out[D], D);
         DrawLabel(Time[X], MathMax(out[B], out[A]), label);
         Butterfly.DownBull.DrawLine(out[X], X, out[A], A);
         Butterfly.DownBull.DrawLine(out[A], A, out[B], B);
         Butterfly.DownBull.DrawLine(out[B], B, out[C], C);
         Butterfly.DownBull.DrawLine(out[C], C, out[D], D);
      }
      else
      {
         drawline(D, out[D] - AD * 1.272, D - (D - A), out[D] - AD * 1.272, Bear);
         drawline(D, out[D] - XA, D - (A - X), out[D] - XA, Bear);
         
         Butterfly.UpBear.DrawLine(out[X], X, out[D], D);
         DrawLabel(Time[X], MathMax(out[B], out[A]), label);
         Butterfly.DownBear.DrawLine(out[X], X, out[A], A);
         Butterfly.DownBear.DrawLine(out[A], A, out[B], B);
         Butterfly.DownBear.DrawLine(out[B], B, out[C], C);
         Butterfly.DownBear.DrawLine(out[C], C, out[D], D);
      }
   }
	else if (label != "Bull AB=CD" || label != "Bear AB=CD")
   {
		if (!UseABCD)
         return;
      
      if (out[A] > out[B])
      {
         drawline(D, out[D] + AB * 1.272, D - (B - A), out[D] + AB * 1.272, Bull);
         drawline(D, out[D] + AD, D - (D - A), out[D] + AD, Bull);
         ABCDOneBull.DrawLine(out[A], A, out[C], C);
         ABCDTwoBull.DrawLine(out[B], B, out[D], D);
         DrawLabel(Time[X], MathMax(out[X], out[A]), label);
         ABCDDownBull.DrawLine(out[X], X, out[A], A);
         ABCDDownBull.DrawLine(out[A], A, out[B], B);
         ABCDDownBull.DrawLine(out[B], B, out[C], C);
         ABCDDownBull.DrawLine(out[C], C, out[D], D);
      }
      else
      {
         drawline(D, out[D] - AB * 1.272, D - (B - A), out[D] - AB * 1.272, Bear);
         drawline(D, out[D] - AD, D - (D - A), out[D] - AD, Bear);
         ABCDOneBear.DrawLine(out[A], A, out[C], C);
         ABCDTwoBear.DrawLine(out[B], B, out[D], D);
         DrawLabel(Time[X], MathMax(out[X], out[A]), label);
         ABCDDownBear.DrawLine(out[X], X, out[A], A);
         ABCDDownBear.DrawLine(out[A], A, out[B], B);
         ABCDDownBear.DrawLine(out[B], B, out[C], C);
         ABCDDownBear.DrawLine(out[C], C, out[D], D);
      }
	}
}

#define BullThreeDrives 1
#define BullABCD 2
#define BullBat 3
#define BullGartley 4
#define BullCrab 5
#define BullButterfly 6
#define BearThreeDrives -1
#define BearABCD -2
#define BearBat -3
#define BearGartley -4
#define BearCrab -5
#define BearButterfly -6

bool DECODE(const bool FLAG, string &name, int &id, double &val)
{
	if (FLAG)
   {
		if ((out[X] - (1.27 - correction / 3) * XA) >= out[B] 
         && (out[X] - (1.618 + correction / 3) * XA) <= out[B] 
         && (out[B] - (1.27 - correction / 3) * XA) >= out[D]
         && (out[B] - (1.618 + correction / 3) * XA) <= out[D])
      {
         name = "Bull Three Drives";
         id = BullThreeDrives;
         val = MathMax(MathMax(X, B), D);
         return true;
      }
		if ((out[A] - (0.618 - correction / 3) * AB) >= out[C] 
         && (out[A] - (0.786 + correction / 3) * AB) <= out[C]
         && (out[A] - (1.27 - correction / 3) * AB) >= out[D]
         && (out[A] - (1.618 + correction / 3) * AB) <= out[D])
      {
         name = "Bull AB=CD";
         id = BullABCD;
         val = MathMax(MathMax(A, C), D);
         return true;
		}

		if ((out[A] - (0.382 - correction) * XA) >= out[B] 
         && (out[A] - (0.5 + correction) * XA) <= out[B]
         && (out[A] - (0.382 - correction) * AB) >= out[C]
         && (out[A] - (0.886 + correction) * AB) <= out[C]
         && (out[A] + (1.618 - correction) * AB) >= out[D]
         && (out[A] + (2.618 + correction) * AB) <= out[D]
         && (out[A] - (0.886 - correction) * XA) >= out[D]
         && (out[A] - (0.886 + correction) * XA) >= out[D])
		{
         name = "Bull Bat";
         id = BullBat;
         val = MathMax(MathMax(MathMax(A, B), C), D);
         return true;
		}

		if ((out[A] - (0.618 - correction) * XA) >= out[B] 
         && (out[A] - (0.618 + correction) * XA) <= out[B]
         && (out[A] - (0.382 - correction) * AB) >= out[C]
         && (out[A] - (0.886 + correction) * AB) <= out[C]
         && (out[A] + (1.27 - correction) * AB) >= out[D]
         && (out[A] + (1.618 + correction) * AB) <= out[D]
         && (out[A] - (0.786 - correction) * XA) >= out[D]
         && (out[A] - (0.786 + correction) * XA) <= out[D])
		{
         name = "Bull Gartley";
         id = BullGartley;
         val = MathMax(MathMax(MathMax(A, B), C), D);
         return true;
      }

		if ((out[A] - (0.382 - correction) * XA) >= out[B] 
         && (out[A] - (0.618 + correction) * XA) <= out[B] 
         && (out[A] - (0.382 - correction) * AB) >= out[C]
         && (out[A] - (0.886 + correction) * AB) <= out[C]
         && (out[A] - (2.24 - correction) * AB) >= out[D]
         && (out[A] - (3.618 + correction) * AB) <= out[D]
         && (out[A] - (1.618 - correction) * XA) >= out[D]
         && (out[A] - (1.618 + correction) * XA) <= out[D])
		{
         name = "Bull Crab";
         id = BullCrab;
         val = MathMax(MathMax(MathMax(A, B), C), D);
         return true;
		}

		if ((out[A] - (0.786 - correction) * XA) >= out[B] 
         && (out[A] - (0.786 + correction) * XA) <= out[B] 
         && (out[A] - (0.382 - correction) * AB) >= out[C] 
         && (out[A] - (0.886 + correction) * AB) <= out[C] 
         && (out[A] - (1.618 - correction) * AB) >= out[D] 
         && (out[A] - (2.618 + correction) * AB) <= out[D] 
         && (out[A] - (1.27 - correction) * XA) >= out[D] 
         && (out[A] - (1.618 + correction) * XA) <= out[D])
      {
         name = "Bull Butterfly";
         id = BullButterfly;
         val = MathMax(MathMax(MathMax(A, B), C), D);
         return true;
      }
      return false;
   }

   if ((out[X] + (1.27 - correction / 3) * XA) <= out[B] 
      && (out[X] + (1.618 + correction / 3) * XA) >= out[B] 
      && (out[B] + (1.27 - correction / 3) * XA) <= out[D] 
      && (out[B] + (1.618 + correction / 3) * XA) >= out[D])
   {
      name = "Bear Three Drives";
      id = BearThreeDrives;
      val = MathMax(MathMax(X, B), D);
      return true;
   }

   if ((out[A] + (0.618 - correction / 3) * AB) <= out[C] 
      && (out[A] + (0.786 + correction / 3) * AB) >= out[C]
      && (out[A] + (1.27 - correction / 3) * AB) <= out[D]
      && (out[A] + (1.618 + correction / 3) * AB) >= out[D])
   {
      name = "Bear AB=CD";
      id = BearABCD;
      val = MathMax(MathMax(A, C), D);
      return true;
   }

   if ((out[A] + (0.382 - correction) * XA) <= out[B] 
      && (out[A] + (0.5 + correction) * XA) >= out[B]
      && (out[A] + (0.382 - correction) * AB) <= out[C]
      && (out[A] + (0.886 + correction) * AB) >= out[C]
      && (out[A] - (1.618 - correction) * AB) <= out[D]
      && (out[A] - (2.618 + correction) * AB) >= out[D]
      && (out[A] + (0.886 - correction) * XA) <= out[D]
      && (out[A] + (0.886 + correction) * XA) >= out[D])
   {
      name = "Bear Bat";
      id = BearBat;
      val = MathMax(MathMax(MathMax(A, B), C), D);
      return true;
   }

   if ((out[A] + (0.618 - correction) * XA) <= out[B] 
      && (out[A] + (0.618 + correction) * XA) >= out[B] 
      && (out[A] + (0.382 - correction) * AB) <= out[C] 
      && (out[A] + (0.886 + correction) * AB) >= out[C] 
      && (out[A] - (1.27 - correction) * AB) <= out[D] 
      && (out[A] - (1.618 + correction) * AB) >= out[D] 
      && (out[A] + (0.786 - correction) * XA) <= out[D] 
      && (out[A] + (0.786 + correction) * XA) >= out[D])
   {
      name = "Bear Gartley";
      id = BearGartley;
      val = MathMax(MathMax(MathMax(A, B), C), D);
      return true;
   }

   if ((out[A] + (0.382 - correction) * XA) <= out[B] 
      && (out[A] + (0.618 + correction) * XA) >= out[B] 
      && (out[A] + (0.382 - correction) * AB) <= out[C] 
      && (out[A] + (0.886 + correction) * AB) >= out[C] 
      && (out[A] + (2.24 - correction) * AB) <= out[D] 
      && (out[A] + (3.618 + correction) * AB) >= out[D] 
      && (out[A] + (1.618 - correction) * XA) <= out[D] 
      && (out[A] + (1.618 + correction) * XA) >= out[D])
   {
      name = "Bear Crab";
      id = BearCrab;
      val = MathMax(MathMax(MathMax(A, B), C), D);
      return true;
   }

   if ((out[A] + (0.786 - correction) * XA) <= out[B] 
      && (out[A] + (0.786 + correction) * XA) >= out[B] 
      && (out[A] + (0.382 - correction) * AB) <= out[C] 
      && (out[A] + (0.886 + correction) * AB) >= out[C] 
      && (out[A] + (1.618 - correction) * AB) <= out[D] 
      && (out[A] + (2.618 + correction) * AB) >= out[D] 
      && (out[A] + (1.27 - correction) * XA) <= out[D] 
      && (out[A] + (1.618 + correction) * XA) >= out[D])
   {
      name = "Bear Butterfly";
      id = BearButterfly;
      val = MathMax(MathMax(MathMax(A, B), C), D);
      return true;
   }
   return false;
}

void drawline(const int x1, const double y1, const int x2, const double y2, const color clr)
{
	if (x1 <= 0 || x2 <= 0 || !Show)
		return;

   string id = IndicatorObjPrefix + TimeToStr(Time[x1]);
   if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[x1], y1, Time[x2], y1))
   {
      Print(__FUNCTION__, ": failed to create a trend line! Error code = ",GetLastError());
      return;
   }
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, id, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
}

double Distance(const int x1, const int y1, const int x2, const int y2)
{
   return MathSqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
}
