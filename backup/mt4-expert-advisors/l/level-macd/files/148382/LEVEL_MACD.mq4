// More information about this indicator can be found at:
// http://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1  MediumVioletRed
#property indicator_color2  MediumVioletRed
#property indicator_color3  DeepSkyBlue
#property indicator_color4  DeepSkyBlue
#property indicator_color5  DimGray
#property indicator_color6  Gold
#property indicator_width2  2
#property indicator_width4  2
#property indicator_width5  1
#property indicator_width6  2

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern int    FastPeriod      = 12;
extern int    SlowPeriod      = 26;
extern int    SignalPeriod    =  9;
extern int    Price           = PRICE_CLOSE;
extern int    Method          = MODE_EMA;

extern bool   Interpolate       = true;
extern bool   alertsOn          = true;
extern bool   alertsOnZeroCross = true;
extern bool   alertsOnCurrent   = false;
extern bool   alertsMessage     = true;
extern bool   alertsSound       = false;
extern bool   alertsNotification = true;

extern bool   ShowLines         = false;
extern string LinesIdentifier   = "MacdLines1";
extern color  LinesColorForUp   = LimeGreen;
extern color  LinesColorForDown = Red;
extern int    LinesStyle        = STYLE_DOT;

//
//
//
//
//

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double buffer5[];
double buffer6[];
double trend[];
double trenda[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
bool   calculateMa;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorDigits(6);
   IndicatorBuffers(8);
   SetIndexBuffer(0,buffer1); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,buffer2); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,buffer3); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,buffer4); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,buffer5);
   SetIndexBuffer(5,buffer6);
   SetIndexBuffer(6,trend);
   SetIndexBuffer(7,trenda);
      FastPeriod   = MathMax(FastPeriod,1);
      SlowPeriod   = MathMax(SlowPeriod,1);
      SignalPeriod = MathMax(SignalPeriod,1);
   
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue";   if (calculateValue) { return(0); }
         calculateMa       = TimeFrame=="calculateAverage"; if (calculateMa)    { return(0); }
         returnBars        = TimeFrame=="returnBars";       if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
      
      //
      //
      //
      //
      //
               
   IndicatorShortName(timeFrameToString(timeFrame)+" MACD "+getAverageName(Method)+" ("+FastPeriod+","+SlowPeriod+","+SignalPeriod+","+")");
}

//
//
//
//
//

int deinit()
{
   int lookForLength = StringLen(LinesIdentifier);
   for (int i=ObjectsTotal(); i>=0; i--)
      {
         string name = ObjectName(i);
         if (StringSubstr(name,0,lookForLength)==LinesIdentifier) ObjectDelete(name);
      }
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { buffer1[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (calculateMa)
   {
      for(i=limit; i>=0; i--) buffer1[i] = iCustomMA(iMA(NULL,0,1,0,MODE_SMA,Price,i),FastPeriod,Method,i);  return(0);
   }
   
   //
   //
   //
   //
   //
         
   if (calculateValue || timeFrame == Period())
   {
      for(i=limit; i>=0; i--)
      {
         buffer5[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateAverage",FastPeriod,0,0,Price,Method,0,i)-iCustom(NULL,timeFrame,indicatorFileName,"calculateAverage",SlowPeriod,0,0,Price,Method,0,i);
         buffer6[i] = iCustomMA(buffer5[i],SignalPeriod,Method,i);
         buffer1[i] = EMPTY_VALUE;
         buffer2[i] = EMPTY_VALUE;
         buffer3[i] = EMPTY_VALUE;
         buffer4[i] = EMPTY_VALUE;
         trend[i]   = trend[i+1];
         trenda[i]  = trenda[i+1];
         
            //
            //
            //
            //
            //
            
            if (buffer5[i]>0) trend[i] =  1;
            if (buffer5[i]<0) trend[i] = -1;
            if (trend[i] == 1)
            {
               if (buffer5[i] >  buffer5[i+1]) { buffer4[i] = buffer5[i]; }
               if (buffer5[i] <  buffer5[i+1]) { buffer3[i] = buffer5[i]; }
               if (buffer5[i] == buffer5[i+1])
               { 
                  if (buffer3[i+1] != EMPTY_VALUE) buffer3[i] = buffer5[i];
                  if (buffer4[i+1] != EMPTY_VALUE) buffer4[i] = buffer5[i];
               }
            }
            if (trend[i] == -1)
            {
               if (buffer5[i] >  buffer5[i+1]) { buffer1[i] = buffer5[i]; }
               if (buffer5[i] <  buffer5[i+1]) { buffer2[i] = buffer5[i]; }
               if (buffer5[i] == buffer5[i+1])
               { 
                  if (buffer1[i+1] != EMPTY_VALUE) buffer1[i] = buffer5[i];
                  if (buffer2[i+1] != EMPTY_VALUE) buffer2[i] = buffer5[i];
               }
            }
      
            if (alertsOnZeroCross)
            {
               if (buffer5[i]>0) trenda[i] =  1;
               if (buffer5[i]<0) trenda[i] = -1;
            }
            else
            {
               if (buffer5[i]>buffer6[i]) trenda[i] =  1;
               if (buffer5[i]<buffer6[i]) trenda[i] = -1;
            }               

            //
            //
            //
            //
            //
            
            if (calculateValue || !ShowLines) continue;
               deleteLine(i);
               if (trend[i]!=trend[i+1])
               if (trend[i]==1)
                     drawLine(i,LinesColorForUp);
               else  drawLine(i,LinesColorForDown);
      }            
      manageAlerts();
      return(0);
   }      

   //
   //
   //
   //
   //

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         buffer1[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastPeriod,SlowPeriod,SignalPeriod,Price,Method,0,y);
         buffer2[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastPeriod,SlowPeriod,SignalPeriod,Price,Method,1,y);
         buffer3[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastPeriod,SlowPeriod,SignalPeriod,Price,Method,2,y);
         buffer4[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastPeriod,SlowPeriod,SignalPeriod,Price,Method,3,y);
         buffer5[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastPeriod,SlowPeriod,SignalPeriod,Price,Method,4,y);
         buffer6[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastPeriod,SlowPeriod,SignalPeriod,Price,Method,5,y);
         trend[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastPeriod,SlowPeriod,SignalPeriod,Price,Method,6,y);
         trenda[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastPeriod,SlowPeriod,SignalPeriod,Price,Method,7,y);

         //
         //
         //
         //
         //
         
            if (ShowLines)
            {
               deleteLine(i);
                  if (trend[i]!=trend[i+1])
                  if (trend[i]==1)
                        drawLine(i,LinesColorForUp);
                  else  drawLine(i,LinesColorForDown);
            }                  

         //
         //
         //
         //
         //
      
         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

            datetime time = iTime(NULL,timeFrame,y);
               for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
               for(int k = 1; k < n; k++)
               {
                  buffer5[i+k] = buffer5[i] + (buffer5[i+n] - buffer5[i])*k/n;
                  buffer6[i+k] = buffer6[i] + (buffer6[i+n] - buffer6[i])*k/n;
                  if (buffer1[i+k] != EMPTY_VALUE) buffer1[i+k] = buffer5[i+k];
                  if (buffer2[i+k] != EMPTY_VALUE) buffer2[i+k] = buffer5[i+k];
                  if (buffer3[i+k] != EMPTY_VALUE) buffer3[i+k] = buffer5[i+k];
                  if (buffer4[i+k] != EMPTY_VALUE) buffer4[i+k] = buffer5[i+k];
               }                  
   }
   manageAlerts();
   
   //
   //
   //
   //
   //

   return(0);
}



//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trenda[whichBar] != trenda[whichBar+1])
      {
         if (trenda[whichBar] ==  1) doAlert(whichBar,"BUY");
         if (trenda[whichBar] == -1) doAlert(whichBar,"SELL");
      }
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," MACD ",getAverageName(Method)," TREND ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotification)   SendNotification(message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void deleteLine(int i)
{
   ObjectDelete(LinesIdentifier+":"+Time[i]);
}
void drawLine(int i, color theColor)
{
   string name = LinesIdentifier+":"+Time[i];
   if (ObjectFind(name)<0)
       ObjectCreate(name,OBJ_VLINE,0,Time[i],0);
       ObjectSet(name,OBJPROP_COLOR,theColor);
       ObjectSet(name,OBJPROP_BACK,true);
       ObjectSet(name,OBJPROP_STYLE,LinesStyle);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double workPrices[];
double workResult[];
int    r;

double iCustomMA(double price, int period, int method, int i)
{
   if (ArraySize(workPrices)!= Bars) ArrayResize(workPrices,Bars);
            r = Bars-i-1;
   workPrices[r] = price;

   //
   //
   //
   //
   //
   
      switch(method)
      {
         case  0: return(iSma(price,period,i));
         case  1: return(iEma(price,period,i));
         case  2: return(iSmma(price,period,i));
         case  3: return(iLwma(price,period,i));
         case  4: return(iLsma(price,period,i));
         case  5: return(iTma(price,period,i));
         case  6: return(iSineWMA(price,period,i));
         case  7: return(iVolumeWMA(price,period,i));
         case  8: return(iHma(price,period,i));
         case  9: return(iNonLagMa(price,period,i));
      }
   return(EMPTY_VALUE);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double iSma(double price, double period, int i)
{
   double sum = 0;
   for(int k=0; k<period && (r-k)>=0; k++) sum += workPrices[r-k];  
   if (k!=0)
         return(sum/k);
   else  return(EMPTY_VALUE);
}

//
//
//
//
//

double iEma(double price, double period, int i)
{
   if (ArraySize(workResult)!= Bars) ArrayResize(workResult,Bars);
   double alpha = 2.0 / (1.0+period);
          workResult[r] = workResult[r-1]+alpha*(price-workResult[r-1]);
   return(workResult[r]);
}
//
//
//
//
//

double iSmma(double price, double period, int i)
{
   if (ArraySize(workResult)!= Bars) ArrayResize(workResult,Bars);
   if (i>=(Bars-period))
   {
      double sum = 0; 
         for(int k=0; k<period && (r-k)>=0; k++) sum += workPrices[r-k];  
         if (k!=0)
               workResult[i] = sum/k;
         else  workResult[i] = EMPTY_VALUE;
   }      
   else   workResult[r] = (workResult[r-1]*(period-1)+price)/period;
   return(workResult[r]);
}

//
//
//
//
//

double iLwma_prices[][3];
double iLwma(double price, double period, int i,int forValue=0)
{
   if (ArrayRange(iLwma_prices,0)!= Bars) ArrayResize(iLwma_prices,Bars);
   
   //
   //
   //
   //
   //
   
   iLwma_prices[r][forValue] = price;
      double sum  = 0;
      double sumw = 0;

      for(int k=0; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*iLwma_prices[r-k][forValue];  
      }             
   if (sumw!=0)
         return(sum/sumw);
   else  return(EMPTY_VALUE);
}

//
//
//
//
//

double iLsma(double price, double period, int i)
{
   return(3.0*iLwma(price,period,i)-2.0*iSma(price,period,i));
}

//
//
//
//
//

double iHma(double price, double period, int i)
{
   int HalfPeriod = MathFloor(period/2);
   int HullPeriod = MathFloor(MathSqrt(period));
            double price1 = 2.0*iLwma(price,HalfPeriod,i,0)-iLwma(price,period,i,1);
   return (iLwma(price1,HullPeriod,i,2));
}

//
//
//
//
//

double iTma(double price, double period, int i)
{
   double half = (period+1.0)/2.0;
   double sum  = 0;
   double sumw = 0;

   for(int k=0; k<period && (r-k)>=0; k++)
   {
      double weight = k+1; if (weight > half) weight = period-k;
             sumw  += weight;
             sum   += weight*workPrices[r-k];  
   }             
   if (sumw!=0)
         return(sum/sumw);
   else  return(EMPTY_VALUE);
}

//
//
//
//
//

#define Pi 3.14159265358979323846
double iSineWMA(double price, int period, int i)
{
   double sum  = 0;
   double sumw = 0;
  
   for(int k=0; k<period && (r-k)>=0; k++)
   { 
      double weight = MathSin(Pi*(k+1)/(period+1));
             sumw  += weight;
             sum   += weight*workPrices[r-k]; 
   }
   if (sumw!=0)
         return(sum/sumw);
   else  return(EMPTY_VALUE);
}

//
//
//
//
//

double iVolumeWMA(double price, int period, int i)
{
   double sum  = 0;
   double sumw = 0;
  
   for(int k=0; k<period && (r-k)>=0; k++)
   { 
      double weight = Volume[i+k];
             sumw  += weight;
             sum   += weight*workPrices[r-k]; 
   }
   if (sumw!=0)
         return(sum/sumw);
   else  return(EMPTY_VALUE);
}


//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

#define Pi       3.14159265358979323846264338327950288
#define _length  0
#define _len     1
#define _weight  2

#define numOfSeparateCalculations 1
double  nlm_values[3][numOfSeparateCalculations];
double  nlm_prices[ ][numOfSeparateCalculations];
double  nlm_alphas[ ][numOfSeparateCalculations];

//
//
//
//
//

double iNonLagMa(double price, int length, int i, int forValue=0)
{
   if (ArrayRange(nlm_prices,0) != Bars) ArrayResize(nlm_prices,Bars);
            int r = Bars-i-1;  nlm_prices[r][forValue]=price;
   if (length<3 || r<3) return(nlm_prices[r][forValue]);
   
   //
   //
   //
   //
   //
   
   if (nlm_values[_length][forValue] != length)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*Pi;
      int    Phase = length-1;
      
         nlm_values[_length][forValue] = length;
         nlm_values[_len   ][forValue] = length*4 + Phase;  
         nlm_values[_weight][forValue] = 0;

         if (ArrayRange(nlm_alphas,0) < nlm_values[_len][forValue]) ArrayResize(nlm_alphas,nlm_values[_len][forValue]);
         for (int k=0; k<nlm_values[_len][forValue]; k++)
         {
            if (k<=Phase-1) 
                 double t = 1.0 * k/(Phase-1);
            else        t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(Pi*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlm_alphas[k][forValue]        = g * beta;
            nlm_values[_weight][forValue] += nlm_alphas[k][forValue];
         }
   }
   
   //
   //
   //
   //
   //
   
   if (nlm_values[_weight][forValue]>0)
   {
      double sum = 0;
           for (k=0; k < nlm_values[_len][forValue]; k++) sum += nlm_alphas[k][forValue]*nlm_prices[r-k][forValue];
           return( sum / nlm_values[_weight][forValue]);
   }
   else return(0);           
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

string methodNames[] = {"SMA","EMA","SMMA","LWMA","LSMA","TriMA","SWMA","VWMA","HullMA","NonLagMA"};
string getAverageName(int& method)
{
   method=MathMax(MathMin(method,9),0); return(methodNames[method]);
}


//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+
