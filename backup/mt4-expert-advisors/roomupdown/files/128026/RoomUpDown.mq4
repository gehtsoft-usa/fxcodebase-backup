// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68809

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

extern string     UpLevels                   = "75,100,125";
extern string     DownLevels                 = ".";
extern int        StartCandle                = 10;
extern int        LineLength                 = 5;
extern int        ADRdays                    = 30;
extern bool       FixFromOpen                = false;
extern color LineColor = Green; // Line color

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


int        nup,ndn;
double     uparr[10],dnarr[10];

//+------------------------------------------------------------------+
string StringRight(string str, int n=1)
//+------------------------------------------------------------------+
// Returns the rightmost N characters of STR, if N is positive
// Usage:    string x=StringRight("ABCDEFG",2)  returns x = "FG"
//
// Returns all but the leftmost N characters of STR, if N is negative
// Usage:    string x=StringRight("ABCDEFG",-2)  returns x = "CDEFG"
{
  if (n > 0)  return(StringSubstr(str,StringLen(str)-n,n));
  if (n < 0)  return(StringSubstr(str,-n,StringLen(str)-n));
  return("");
}

double StrToNumber(string str)  {
//+------------------------------------------------------------------+
// Usage: strips all non-numeric characters out of a string, to return a numeric (double) value
//  valid numeric characters are digits 0,1,2,3,4,5,6,7,8,9, decimal point (.) and minus sign (-)
// Example: StrToNumber("the balance is $-34,567.98") returns the numeric value -34567.98
  int    dp   = -1;
  int    sgn  = 1;
  double num  = 0.0;
  for (int i=0; i<StringLen(str); i++)  {
    string s = StringSubstr(str,i,1);
    if (s == "-")  sgn = -sgn;   else
    if (s == ".")  dp = 0;       else
    if (s >= "0" && s <= "9")  {
      if (dp >= 0)  dp++;
      if (dp > 0)
        num = num + StrToInteger(s) / MathPow(10,dp);
      else
        num = num * 10 + StrToInteger(s);
    }
  }
  return(num*sgn);
}

int StringFindCount(string str, string str2)
//+------------------------------------------------------------------+
// Returns the number of occurrences of STR2 in STR
// Usage:   int x = StringFindCount("ABCDEFGHIJKABACABB","AB")   returns x = 3
{
  int c = 0;
  for (int i=0; i<StringLen(str); i++)
    if (StringSubstr(str,i,StringLen(str2)) == str2)  c++;
  return(c);
}


int StrToDoubleArray(string str, double &a[], string delim=",", int init=0)  {
//+------------------------------------------------------------------+
// Breaks down a single string into double array 'a' (elements delimited by 'delim')
//  e.g. string is "1,2,3,4,5";  if delim is "," then the result will be
//  a[0]=1.0   a[1]=2.0   a[2]=3.0   a[3]=4.0   a[4]=5.0
//  Unused array elements are initialized by value in 'init' (default is 0)
  for (int i=0; i<ArraySize(a); i++)
    a[i] = init;
  if (str == "")  return(0);  
  int z1=-1, z2=0;
  if (StringRight(str,1) != delim)  str = str + delim;
  for (int i=0; i<ArraySize(a); i++)  {
    z2 = StringFind(str,delim,z1+1);
    if (z2>z1+1)  a[i] = StrToNumber(StringSubstr(str,z1+1,z2-z1-1));
    if (z2 >= StringLen(str)-1)   break;
    z1 = z2;
  }
  return(StringFindCount(str,delim));
}

string StringTrim(string str, string _char=" ")
//+------------------------------------------------------------------+
// Removes all spaces (leading, traing embedded) from a string
// Usage:    string x=StringTrim("The Quick Brown Fox")  returns x = "TheQuickBrownFox"
// char defaults to space(s), but may contain a list of characters to be stripped
{
  string outstr = "";
  for(int i=0; i<StringLen(str); i++)  {
    if (StringFind(_char,StringSubstr(str,i,1)) < 0)
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}

string StringUpper(string str)
//+------------------------------------------------------------------+
// Converts any lowercase characters in a string to uppercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "THE QUICK BROWN FOX"
{
  string outstr = "";
  string lower  = "abcdefghijklmnopqrstuvwxyz";
  string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  for(int i=0; i<StringLen(str); i++)  {
    int t1 = StringFind(lower,StringSubstr(str,i,1),0);
    if (t1 >=0)  
      outstr = outstr + StringSubstr(upper,t1,1);
    else
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}  

int init()
{
   IndicatorName = GenerateIndicatorName("Room Up/Down");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   if (DownLevels == ".")
      DownLevels = UpLevels;
   nup = StrToDoubleArray(UpLevels, uparr);
   ndn = StrToDoubleArray(DownLevels, dnarr);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;

   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      double sum = 0;
      double cnt = 0;
      for (int k = 1; k <= ADRdays; ++k)
      {
         double range = iHigh(_Symbol, PERIOD_D1, k) - iLow(_Symbol, PERIOD_D1, k);
         sum = sum + range / pipSize;
         cnt = cnt + 1;
      }
      double adr = 0;
      if (cnt != 0)
         adr = (sum / cnt) * pipSize;

      for (int i = 0; i < nup; ++i)
      {
         double lvl = uparr[i];
         double level = 0;
         if (FixFromOpen)
            level = iOpen(_Symbol, PERIOD_D1, 0) + adr * lvl / 100;
         else
            level = iLow(_Symbol, PERIOD_D1, 0) + adr * lvl / 100;
         ResetLastError();
         string id = IndicatorObjPrefix + "up" + IntegerToString(i);
         ObjectCreate(0, id, OBJ_TREND, 0, iTime(_Symbol, _Period, StartCandle), level, iTime(_Symbol, _Period, StartCandle + LineLength), level);
         ObjectSetInteger(0, id, OBJPROP_COLOR, LineColor);
         ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
      }

      for (int i = 0; i < ndn; ++i)
      {
         double lvl = dnarr[i];
         double level = 0;
         if (FixFromOpen)
            level = iOpen(_Symbol, PERIOD_D1, 0) - adr * lvl / 100;
         else
            level = iLow(_Symbol, PERIOD_D1, 0) - adr * lvl / 100;
         ResetLastError();
         string id = IndicatorObjPrefix + "dn" + IntegerToString(i);
         ObjectCreate(0, id, OBJ_TREND, 0, iTime(_Symbol, _Period, StartCandle), level, iTime(_Symbol, _Period, StartCandle + LineLength), level);
         ObjectSetInteger(0, id, OBJPROP_COLOR, LineColor);
         ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
      }
   } 
   return 0;
}