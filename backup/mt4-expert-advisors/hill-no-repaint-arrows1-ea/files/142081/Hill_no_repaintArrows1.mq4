// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=71079

// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70919


//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.1"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Orange
#property indicator_color2 DarkGray
#property indicator_color3 Orange
#property indicator_color4 LimeGreen
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT

input int RsiLength = 14;
input int RsiPrice = PRICE_CLOSE;
input int HalfLength = 12;
input int DevPeriod = 100;
input double Deviations = 1.5;
input bool UseAlert = true;
input bool DrawArrows = true;
input int bars_limit = 1000; // Bars limit

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];

int init()
{
   SetIndexBuffer(0, buffer1);
   SetIndexBuffer(1, buffer2);
   SetIndexBuffer(2, buffer3);
   SetIndexBuffer(3, buffer4);
   return (0);
}

int deinit()
{
   DellObj(PrefixArrow);

   return (0);
}

int start()
{
   int j, k, counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;

   static datetime timeLastAlert = NULL;

   int toSkip = MathMax(RsiLength, HalfLength);
   for (int i = MathMin(bars_limit, Bars - 1 - MathMax(IndicatorCounted() - 1, toSkip)); i >= 0 && !IsStopped(); --i)
   {
      buffer1[i] = iRSI(NULL, 0, RsiLength, RsiPrice, i);
   }
   for (i = MathMin(bars_limit, Bars - 1 - MathMax(IndicatorCounted() - 1, toSkip)); i >= 0 && !IsStopped(); --i)
   {
      if (buffer1[i + DevPeriod + 1] == EMPTY_VALUE)
      {
         continue;
      }
      double dev = iStdDevOnArray(buffer1, 0, DevPeriod, 0, MODE_SMA, i);
      double sum = (HalfLength + 1) * buffer1[i];
      double sumw = (HalfLength + 1);
      for (j = 1, k = HalfLength; j <= HalfLength; j++, k--)
      {
         sum += k * buffer1[i + j];
         sumw += k;
         if (j <= i)
         {
            sum += k * buffer1[i - j];
            sumw += k;
         }
      }
      buffer2[i] = sum / sumw;
      buffer3[i] = buffer2[i] + dev * Deviations;
      buffer4[i] = buffer2[i] - dev * Deviations;

      if (buffer1[i] >= buffer3[i])
      {
         if (DrawArrows)
            ArrowDn(Time[i], High[i]);

         if (UseAlert && i == 0 && Time[0] != timeLastAlert)
         {
            Alert("Signal DOWN!");
            timeLastAlert = Time[0];
         }
      }

      if (buffer1[i] <= buffer4[i])
      {
         if (DrawArrows)
            ArrowUp(Time[i], Low[i]);

         if (UseAlert && i == 0 && Time[0] != timeLastAlert)
         {
            Alert("Signal UP!");
            timeLastAlert = Time[0];
         }
      }
   }
   return (0);
}

color ColorDn = Crimson;
color ColorUp = DodgerBlue;
int CodDn = 226;
int CodUp = 225;
input int Sise = 11;
string Font = "Verdana";

string PrefixArrow = "ArrowsHill";
//+==================================================================+
//+==================================================================+
void ArrowUp(datetime tim, double pr)
{
   if (ObjectFind(PrefixArrow + "TextUp" + tim) == -1)
   {
      if (ObjectCreate(PrefixArrow + "TextUp" + tim, OBJ_TEXT, 0, tim, pr - GetDistSdvig()))
         ObjectSetText(PrefixArrow + "TextUp" + tim, CharToStr(CodUp), Sise, "WingDings", ColorUp);
   }
}

//+==================================================================+
//+==================================================================+
void ArrowDn(datetime tim, double pr)
{
   if (ObjectFind(PrefixArrow + "TextDn" + tim) == -1)
   {
      if (ObjectCreate(PrefixArrow + "TextDn" + tim, OBJ_TEXT, 0, tim, pr + GetDistSdvig()))
         ObjectSetText(PrefixArrow + "TextDn" + tim, CharToStr(CodDn), Sise, "WingDings", ColorDn);
   }
}
input double TextSdvigMnoj = 2;
double GetDistSdvig() { return (iATR(NULL, 0, 100, 1) * TextSdvigMnoj); }
//+------------------------------------------------------------------+
//
void DellObj(string dell)
{
   string name;
   for (int i = ObjectsTotal() - 1; i >= 0; i--)
   {
      name = ObjectName(i);
      if (StringFind(name, dell) != EMPTY)
         ObjectDelete(name);
   }
}