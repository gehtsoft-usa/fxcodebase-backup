//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73849

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property  indicator_separate_window
#property  indicator_buffers 6
#property  indicator_color1  Green
#property  indicator_color2  Red
#property  indicator_color3  DimGray
#property  indicator_color4  Green
#property  indicator_color5  Red
#property  indicator_color6  Red
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width4  2
#property  indicator_width5  2
#property  indicator_width6  2


//
//
//
//
//

extern string TimeFrame    = "Current time frame";
extern double Oma_Period   = 32;
extern double Oma_Speed    = 3;
extern bool   Oma_Adaptive = true;
extern int    Oma_Price    = PRICE_CLOSE;
extern double AngleLevel   = 5;
extern int    AngleBars    = 6;
extern bool   alertsOn           = false;
extern bool   alertsOnCurrent    = false;
extern bool   alertsMessage      = true;
extern bool   alertsSound        = false;
extern bool   alertsEmail        = false;
extern bool   alertsNotification = false;
extern bool   arrowsVisible      = true;
extern string arrowsIdentifier   = "CorSsa Arrows1";
extern double arrowsDisplacement = 1.0;
extern color  arrowsUpColor      = Green;
extern color  arrowsDnColor      = Red;
extern int    arrowsUpCode       = 241;
extern int    arrowsDnCode       = 242;
extern bool   Interpolate        = true;

//
//
//
//
//

double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer4da[];
double Buffer4db[];
double oma[];
double slope[];

string indicatorFileName;
bool   returnBars;
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
   IndicatorBuffers(8);
   SetIndexBuffer(0,Buffer1); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Buffer2); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Buffer3); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,Buffer4);
   SetIndexBuffer(4,Buffer4da);
   SetIndexBuffer(5,Buffer4db);
   SetIndexBuffer(6,oma);
   SetIndexBuffer(7,slope);
      timeFrame         = stringToTimeFrame(TimeFrame);
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame=="returnBars");
      IndicatorShortName(timeFrameToString(timeFrame)+" Angle of OMA ("+Oma_Period+","+DoubleToStr(AngleLevel,2)+","+AngleBars+")");
      IndicatorDigits(2);
   return(0);
}
int deinit()
{  
   if (arrowsVisible) deleteArrows();  
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

#define Pi 3.141592653589793238462643

//
//
//
//
//

int start()
{
   int countedBars = IndicatorCounted();
      if(countedBars<0) return(-1);
      if(countedBars>0) countedBars--;
         int limit = MathMin(Bars-countedBars,Bars-1);
         if (returnBars) { Buffer1[0] = limit+1; return(0); }
         if (timeFrame != Period())
         {
            limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
            if (slope[limit]==-1) CleanPoint(limit,Buffer4da,Buffer4db);
            for (int i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,timeFrame,Time[i]);
                  Buffer1[i] = iCustom(NULL,timeFrame,indicatorFileName,"",Oma_Period,Oma_Speed,Oma_Adaptive,Oma_Price,AngleLevel,AngleBars,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotification,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,0,y);
                  Buffer2[i] = iCustom(NULL,timeFrame,indicatorFileName,"",Oma_Period,Oma_Speed,Oma_Adaptive,Oma_Price,AngleLevel,AngleBars,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotification,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,1,y);
                  Buffer3[i] = iCustom(NULL,timeFrame,indicatorFileName,"",Oma_Period,Oma_Speed,Oma_Adaptive,Oma_Price,AngleLevel,AngleBars,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotification,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,2,y);
                  Buffer4[i] = iCustom(NULL,timeFrame,indicatorFileName,"",Oma_Period,Oma_Speed,Oma_Adaptive,Oma_Price,AngleLevel,AngleBars,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotification,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,3,y);
                  slope[i]   = iCustom(NULL,timeFrame,indicatorFileName,"",Oma_Period,Oma_Speed,Oma_Adaptive,Oma_Price,AngleLevel,AngleBars,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotification,arrowsVisible,arrowsIdentifier,arrowsDisplacement,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,7,y);
                  if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
                  
                  datetime time = iTime(NULL,timeFrame,y);
                     for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;
                     for(int k = 1; k < n; k++)
                     {
                        Buffer4[i+k] = Buffer4[i] + (Buffer4[i+n] - Buffer4[i]) * k/n;
                        if (Buffer1[i+k] != EMPTY_VALUE) Buffer1[i+k] = Buffer4[i+k];
                        if (Buffer2[i+k] != EMPTY_VALUE) Buffer2[i+k] = Buffer4[i+k];
                        if (Buffer3[i+k] != EMPTY_VALUE) Buffer3[i+k] = Buffer4[i+k];
                     }
            }
            for(i=limit; i>=0; i--) if (slope[i] == -1) PlotPoint(i,Buffer4da,Buffer4db,Buffer4);
            return(0);
         }
         

   //
   //
   //
   //
   //
   
   if (slope[limit]==-1) CleanPoint(limit,Buffer4da,Buffer4db);
   for(i=limit; i>=0; i--)
   {
      oma[i] = iOma(iMA(NULL,0,1,0,MODE_SMA,Oma_Price,i),Oma_Period,Oma_Speed,Oma_Adaptive,i);
      double range = iATR(NULL,0,AngleBars*20,i);
      double angle = 0.00;
      double change=oma[i]-oma[i+AngleBars];
         if (range != 0) angle = MathArctan(change/(range*AngleBars))*180.0/Pi;

      //
      //
      //
      //
      //
      
         Buffer1[i] = EMPTY_VALUE;
         Buffer2[i] = EMPTY_VALUE;
         Buffer3[i] = angle;
         Buffer4[i] = angle;
         slope[i]   = slope[i+1];
            if (angle >  AngleLevel) { Buffer1[i] = angle; Buffer3[i] = EMPTY_VALUE;}
            if (angle < -AngleLevel) { Buffer2[i] = angle; Buffer3[i] = EMPTY_VALUE;}
            if (Buffer4[i]>Buffer4[i+1]) slope[i] =  1;
            if (Buffer4[i]<Buffer4[i+1]) slope[i] = -1;
            if (slope[i] == -1) PlotPoint(i,Buffer4da,Buffer4db,Buffer4);
            manageArrow(i);
   }
   manageAlerts();
   return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 

      //
      //
      //
      //
      //
            
      static datetime time1 = 0;
      static string   mess1 = "";
      if (slope[whichBar] != slope[whichBar+1])
      {
         if (slope[whichBar] ==  1) doAlert(time1,mess1,whichBar,"up");
         if (slope[whichBar] == -1) doAlert(time1,mess1,whichBar,"down");
      }
   }
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

        message = Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Slope of angle of OMA changed to "+doWhat;
          if (alertsMessage)      Alert(message);
          if (alertsEmail)        SendMail(StringConcatenate(Symbol()," Angle of OMA "),message);
          if (alertsNotification) SendNotification(message);
          if (alertsSound)        PlaySound("alert2.wav");
   }
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workOma[][7];
#define F01 0
#define F02 1
#define F03 2
#define F04 3
#define F05 4
#define F06 5
#define prc 6

//
//
//
//
//

double iOma(double price, double averagePeriod, double constant, bool adaptive, int r, int s=0)
{
   if (averagePeriod <=1) return(price);
   if (ArrayRange(workOma,0) != Bars) ArrayResize(workOma,Bars); r=Bars-r-1; s *=7;
   if (r<=1) 
   {
      for (int i=0; i<6; i++) workOma[r][i  +s] = 0;
                              workOma[r][prc+s] = price;
                              return(price);
   }      
   double f01=workOma[r-1][F01+s];  double f02=workOma[r-1][F02+s];
   double f03=workOma[r-1][F03+s];  double f04=workOma[r-1][F04+s];
   double f05=workOma[r-1][F05+s];  double f06=workOma[r-1][F06+s];

   //
   //
   //
   //
   //

      if (adaptive && (averagePeriod > 1))
      {
         double minPeriod = MathMin(averagePeriod,r)/2.0;
         double maxPeriod = MathMin(minPeriod*5.0,r);
         int    endPeriod = (int)MathCeil(maxPeriod);
         double signal    = MathAbs((price-workOma[r-endPeriod][prc+s]));
         double noise     = 0.00000000001;

            for(i=1; i<endPeriod; i++) noise=noise+MathAbs(price-workOma[r-i][prc+s]);

         averagePeriod = ((signal/noise)*(maxPeriod-minPeriod))+minPeriod;
      }
      
      //
      //
      //
      //
      //
      
      double Kg = (2.0+constant)/(1.0+constant+averagePeriod);
      double Hg = 1.0-Kg;

      f01 = Kg * price + Hg * f01; f02 = Kg * f01 + Hg * f02; double v01 = 1.5 * f01 - 0.5 * f02;
      f03 = Kg * v01   + Hg * f03; f04 = Kg * f03 + Hg * f04; double v02 = 1.5 * f03 - 0.5 * f04;
      f05 = Kg * v02   + Hg * f05; f06 = Kg * f05 + Hg * f06; double v03 = 1.5 * f05 - 0.5 * f06;

   //
   //
   //
   //
   //

   workOma[r][F01+s] = f01;  workOma[r][F02+s] = f02;
   workOma[r][F03+s] = f03;  workOma[r][F04+s] = f04;
   workOma[r][F05+s] = f05;  workOma[r][F06+s] = f06;
   workOma[r][prc+s] = price;
   return(v03);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
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

void manageArrow(int i)
{
   if (arrowsVisible)
   {
      deleteArrow(Time[i]);
      if (slope[i] != slope[i+1])
      {
         if (slope[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
         if (slope[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,true);
      }
   }
}               
void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsDisplacement * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsDisplacement * gap);
}
void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}
void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

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

string StringUpperCase(string str)
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