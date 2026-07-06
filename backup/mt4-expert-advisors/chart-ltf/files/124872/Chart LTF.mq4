// Id: 24266
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67768


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

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  DodgerBlue
#property indicator_color2  Gold
#property indicator_color3  DodgerBlue
#property indicator_color4  LimeGreen
#property indicator_color5  Red
#property indicator_width2  2
#property indicator_width4  2
#property indicator_levelcolor DimGray


#property indicator_color6  clrNONE
#property indicator_color7  clrNONE

extern ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;
extern int    RsxPeriod                = 14;
extern int    RsxPrice                 = PRICE_CLOSE;
extern double RsxPriceLinePeriod       = 1;
extern double RsxPriceLinePhase        = 0;
extern bool   RsxPriceLineDouble       = false;
extern double RsxSignalLinePeriod      = 7;
extern double RsxSignalLinePhase       = 0;
extern bool   RsxSignalLineDouble      = false;
extern int    VolatilityBandPeriod     = 34;
extern int    VolatilityBandMAMode     = MODE_SMA;
extern double VolatilityBandMultiplier = 1.6185;
extern double LevelDown                = 32;
extern double LevelMiddle              = 50;
extern double LevelUp                  = 68;

extern bool   alertsOn                 = false;
extern bool   alertsOnCurrent          = true;
extern bool   alertsMessage            = true;
extern bool   alertsSound              = false;
extern bool   alertsEmail              = false;
extern bool   ShowArrows               = false;
extern string arrowsIdentifier         = "TDI arrows";
extern color  arrowsUpColor            = DeepSkyBlue;
extern color  arrowsDnColor            = Red;

extern bool   verticalLinesVisible     = true;
extern string verticalLinesID          = "TDI_Line";
extern color  verticalLinesUpColor     = DeepSkyBlue;
extern color  verticalLinesDownColor   = PaleVioletRed;
extern int    verticalLinesStyle       = STYLE_DOT;
extern int    verticalLinesWidth       = 0;

extern bool   StrictRules              = true;
extern int bars_limit = 1000;

double rsx[];
double rsxPriceLine[];
double rsxSignalLine[];
double bandUp[];
double bandMiddle[];
double bandDown[];
double trend[];

string indicatorFileName;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init() {
       double temp = iCustom(NULL, 0, "Chart LTF", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Chart LTF' indicator");
       return INIT_FAILED;
   }
   IndicatorBuffers(7 + 12);
   SetIndexBuffer(0,bandUp);
   SetIndexBuffer(1,bandMiddle);
   SetIndexBuffer(2,bandDown);
   SetIndexBuffer(3,rsxPriceLine);
   SetIndexBuffer(4,rsxSignalLine);
   SetIndexBuffer(5,rsx);
   SetIndexBuffer(6,trend);

   // HIDE LIVE BUFFER DATA FROM SHOWING
   SetIndexLabel(0, NULL);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   SetIndexLabel(3, "rsxPriceLine");
   SetIndexLabel(4, "rsxSignalLine");
   SetIndexLabel(5, NULL);
   SetIndexLabel(6, NULL);
   indicatorFileName = WindowExpertName();

   SetLevelValue(0,LevelUp);
   SetLevelValue(1,LevelMiddle);
   SetLevelValue(2,LevelDown);
   IndicatorName = GenerateIndicatorName(timeFrameToString(TimeFrame)+" - TDI RSX ("+RsxPeriod+")");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   int id = momStep1.RegisterStreams(7);
   id = moaStep1.RegisterStreams(id);
   id = momStep2.RegisterStreams(id);
   id = moaStep2.RegisterStreams(id);
   id = momStep3.RegisterStreams(id);
   id = moaStep3.RegisterStreams(id);

   deinit();
   return (0);
}
 
int deinit() {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

interface IStream
{
public:
   virtual bool GetValue(const int period, double &val) = 0;
};

class Algo
{
   double _stream1[];
   double _stream2[];
public:
   int RegisterStreams(const int id)
   {
      SetIndexBuffer(id, _stream1);
      SetIndexBuffer(id + 1, _stream2);
      return id + 2;
   }

   double calcValue(const int period, double val)
   {
      double Kg = 3.0 / (2.0 + RsxPeriod); 
      double Hg = 1.0 - Kg;
      _stream1[period] = Kg * val + Hg * _stream1[period + 1];
      _stream2[period] = Kg * _stream1[period] + Hg * _stream2[period + 1];
      return 1.5 * _stream1[period] - 0.5 * _stream2[period];
   }
};

Algo momStep1;
Algo moaStep1;
Algo momStep2;
Algo moaStep2;
Algo momStep3;
Algo moaStep3;

double GetValue(const int period, const int stream)
{
   return iCustom(_Symbol, TimeFrame, "Chart LTF", TimeFrame, RsxPeriod, RsxPrice, RsxPriceLinePeriod,
      RsxPriceLinePhase, RsxPriceLineDouble, RsxSignalLinePeriod, RsxSignalLinePhase,
      RsxSignalLineDouble, VolatilityBandPeriod, VolatilityBandMAMode, VolatilityBandMultiplier, stream, period);
}

int start()
{
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) 
      return(-1);
   if (counted_bars>0) 
      counted_bars--;
   int limit = MathMin(bars_limit, MathMin(Bars - counted_bars, Bars - 2));
   for (int i=limit; i>=0; i--)
   {
      if (TimeFrame == _Period || TimeFrame == PERIOD_CURRENT)
      {
         double mom = iMA(NULL,0,1,0,MODE_SMA,RsxPrice,i) - iMA(NULL,0,1,0,MODE_SMA,RsxPrice,i + 1);
         double moa = MathAbs(mom);
         mom = momStep3.calcValue(i, momStep2.calcValue(i, momStep1.calcValue(i, mom)));
         moa = moaStep3.calcValue(i, moaStep2.calcValue(i, moaStep1.calcValue(i, moa)));
         if (moa != 0)
            rsx[i] = MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00); 
         else 
            rsx[i] = 50.0;

         rsxPriceLine[i]  = iDSmooth(rsx[i],RsxPriceLinePeriod ,RsxPriceLinePhase ,RsxPriceLineDouble ,i, 0);
         rsxSignalLine[i] = iDSmooth(rsx[i],RsxSignalLinePeriod,RsxSignalLinePhase,RsxSignalLineDouble,i,20);
         double deviation = iStdDevOnArray(rsx,0,VolatilityBandPeriod,0,VolatilityBandMAMode,i);
         double average   = iMAOnArray(rsx,0,VolatilityBandPeriod,0,VolatilityBandMAMode,i);
         bandUp[i]     = average + VolatilityBandMultiplier * deviation;
         bandDown[i]   = average - VolatilityBandMultiplier * deviation;
         bandMiddle[i] = average;
         trend[i] = trend[i+1];
         if (rsxPriceLine[i]>rsxSignalLine[i]) 
            trend[i] =  1;
         else if (rsxPriceLine[i]<rsxSignalLine[i]) 
            trend[i] = -1;
         manageLines(i);
         manageArrow(i);
      }
      else
      {
         int periodFrom = iBarShift(_Symbol, TimeFrame, Time[i]);
         if (periodFrom < 0)
            continue;
         int periodTo = i == 0 ? 0 : iBarShift(_Symbol, TimeFrame, Time[i - 1]);
         if (periodTo < 0)
            continue;
         
         int trendPrevious = trend[i + 1];
         for (int period = periodFrom; period >= periodTo; --period)
         {
            bandUp[i] = GetValue(period, 0);
            bandMiddle[i] = GetValue(period, 1);
            bandDown[i] = GetValue(period, 2);
            rsxPriceLine[i] = GetValue(period, 3);
            rsxSignalLine[i] = GetValue(period, 4);
            rsx[i] = GetValue(period, 5);
            trend[i] = GetValue(period, 6);
            if (ShowArrows) {
               deleteArrow(Time[i]);
               if (trend[i] != trendPrevious) {
                  if (trend[i] == 1) 
                     drawArrow(i,arrowsUpColor,241,false);
                  if (trend[i] ==-1) 
                     drawArrow(i,arrowsDnColor,242,true);
               }
            }
            trendPrevious = trend[i];
         }
      }
   }
   manageAlerts();
   return (0);
}

void manageAlerts() {
   if (alertsOn) {
      int whichBar = iBarShift(NULL,0,iTime(NULL,TimeFrame,alertsOnCurrent ? 0 : 1));
      if (trend[whichBar] != trend[whichBar+1]) {
         if (trend[whichBar] ==  1) 
            doAlert(whichBar,"up");
         if (trend[whichBar] == -1) 
            doAlert(whichBar,"down");
      }
   }
}

void doAlert(int forBar, string doWhat) {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       message =  StringConcatenate(Symbol()," ",timeFrameToString(TimeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," TDI trend changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"TDI"),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

void manageArrow(int i) {
   if (ShowArrows) {
      deleteArrow(Time[i]);
      if (trend[i] != trend[i+1]) {
         if (trend[i] == 1) drawArrow(i,arrowsUpColor,241,false);
         if (trend[i] ==-1) drawArrow(i,arrowsDnColor,242,true);
      }
   }
}               

void drawArrow(int i,color theColor,int theCode,bool up) {
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
   ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
   ObjectSet(name,OBJPROP_ARROWCODE,theCode);
   ObjectSet(name,OBJPROP_COLOR,theColor);
   if (up)
         ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
   else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
}

void deleteArrow(datetime time) {
   string lookFor = arrowsIdentifier+":"+time;
   ObjectDelete(lookFor);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int stringToTimeFrame(string tfs) {
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf) {
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

string stringUpperCase(string str) {
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--) {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double wrk[][40];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

double iDSmooth(double price, double length, double phase, bool isDouble, int i, int s=0) {
   if (isDouble)
      return (iSmooth(iSmooth(price,MathSqrt(length),phase,i,s),MathSqrt(length),phase,i,s+10));
   else  
      return (iSmooth(price,length,phase,i,s));
}

double iSmooth(double price, double length, double phase, int i, int s=0) {
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   int r = Bars-i-1; 
   if (r==0) 
   { 
      int k;
      for(k=0; k<7; k++) 
         wrk[r][k+s]=price; 
      for(; k<10; k++) 
         wrk[r][k+s]=0; 
      return(price); 
   }

   double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
   double pow1   = MathMax(len1-2.0,0.5);
   double del1   = price - wrk[r-1][bsmax+s];
   double del2   = price - wrk[r-1][bsmin+s];
   double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
   int    forBar = MathMin(r,10);

   wrk[r][volty+s] = 0;
   if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
   if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
   wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
   
   wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
   double dVolty = wrk[r][avolty+s] > 0 ? wrk[r][volty+s]/wrk[r][avolty+s] : 0;   
   if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
   if (dVolty < 1)                      dVolty = 1.0;

   double pow2 = MathPow(dVolty, pow1);
   double len2 = MathSqrt(0.5*(length-1))*len1;
   double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

   if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
   if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;

   double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
   double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
   double alpha = MathPow(beta,pow2);

   wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
   wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
   wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
   wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
   wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   return(wrk[r][4+s]);
}

void manageLines(int i) {
   if (verticalLinesVisible) {
         deleteLine(Time[i]);
         if (trend[i]!=trend[i+1]) {
            if (StrictRules) {
               if (trend[i] == 1 && rsxPriceLine[i] < 50) drawLine(i,verticalLinesUpColor);
               if (trend[i] ==-1 && rsxPriceLine[i] > 50) drawLine(i,verticalLinesDownColor);
            } else {
               if (trend[i] == 1 ) drawLine(i,verticalLinesUpColor);
               if (trend[i] ==-1 ) drawLine(i,verticalLinesDownColor);
            }
         }
   }
}               

void drawLine(int i,color theColor) {
   string name = verticalLinesID+":"+Time[i];
   
      ObjectCreate(name,OBJ_VLINE,0,Time[i],0);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_STYLE,verticalLinesStyle);
         ObjectSet(name,OBJPROP_WIDTH,verticalLinesWidth);
         ObjectSet(name,OBJPROP_BACK,true);
}

void deleteLine(datetime time) {
   string lookFor = verticalLinesID+":"+time; ObjectDelete(lookFor);
}

