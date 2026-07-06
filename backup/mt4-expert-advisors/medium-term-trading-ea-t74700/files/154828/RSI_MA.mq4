// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=74700

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers    4
#property indicator_color1     LimeGreen
#property indicator_color2     Red
#property indicator_color3     Red
#property indicator_color4     White
#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
#property indicator_width4     2
#property indicator_levelcolor MediumOrchid

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern int    RsiOma_Period   = 14;
extern int    RsiOma_Price    = 0;
extern int    RsiOma_Mode     = MODE_LWMA;
extern int    MaPeriod        = 10;
extern int    MaType          = MODE_LWMA;
extern double levelOb         = 70;
extern double levelOs         = 30;

extern string note            = "turn on Alert = true; turn off = false";
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;
extern string soundfile       = "alert2.wav";

//
//
//
//
//

double rsi[];
double rsida[];
double rsidb[];
double ma[];
double mab[];
double trend[];
double slope[];

//
//
//
//
//

string indicatorFileName;
int    timeFrame;
bool   returnBars;
bool   calculateValue;

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
  IndicatorBuffers(7);
    SetIndexBuffer(0,rsi);
    SetIndexBuffer(1,rsida);
    SetIndexBuffer(2,rsidb);
    SetIndexBuffer(3,ma);
    SetIndexBuffer(4,mab);
    SetIndexBuffer(5,trend);
    SetIndexBuffer(6,slope);
    SetLevelValue(0,levelOs);
    SetLevelValue(1,levelOb);
    
       //
       //
       //
       //
       //
     
        indicatorFileName = WindowExpertName();
        calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
        returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
        timeFrame         = stringToTimeFrame(TimeFrame);
 
   IndicatorShortName(timeFrameToString(timeFrame)+"  Rsi Ma ("+RsiOma_Period+","+MaPeriod+")");
   SetIndexLabel(0,"");
   SetIndexLabel(1,"");
   SetIndexLabel(2,"");
   SetIndexLabel(3,"");
return(0);
}

int deinit() { return(0); }

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
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { rsi[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame==Period())
   {

     if  (slope[limit] == -1) ClearPoint(limit,rsida,rsidb);
     for (i=limit; i >= 0; i--) mab[i] = iMA(NULL,0,RsiOma_Period,0,RsiOma_Mode,RsiOma_Price,i);
     for (i=limit; i >= 0; i--) rsi[i] = iRSIOnArray(mab,0,RsiOma_Period,i);
     for (i=limit; i >= 0; i--)
     {
        ma[i] = iMAOnArray(rsi,0,MaPeriod,0,MaType,i);
        rsida[i] = EMPTY_VALUE;
        rsidb[i] = EMPTY_VALUE;
        slope[i] = slope[i+1];
        trend[i] = trend[i+1]; 
         
	     if (rsi[i] > rsi[i+1]) slope[i]= 1; 
	     if (rsi[i] < rsi[i+1]) slope[i]=-1;
	     if (rsi[i] > ma[i])    trend[i]= 1; 
	     if (rsi[i] < ma[i])    trend[i]=-1;
	     if (slope[i] == -1) PlotPoint(i,rsida,rsidb,rsi);
	       
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
    if (slope[limit]==-1) ClearPoint(limit,rsida,rsidb);
    for (i=limit;i>=0; i--)
    {
       int y = iBarShift(NULL,timeFrame,Time[i]);
            rsi[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiOma_Period,RsiOma_Price,RsiOma_Mode,MaPeriod,MaType,0,y);
            rsida[i] = EMPTY_VALUE;
            rsidb[i] = EMPTY_VALUE;
            ma[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiOma_Period,RsiOma_Price,RsiOma_Mode,MaPeriod,MaType,3,y);
            trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiOma_Period,RsiOma_Price,RsiOma_Mode,MaPeriod,MaType,5,y);
            slope[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiOma_Period,RsiOma_Price,RsiOma_Mode,MaPeriod,MaType,6,y);  
    }
      
    for (i=limit;i>=0;i--) if (slope[i]==-1) PlotPoint(i,rsida,rsidb,rsi);
    manageAlerts();
return(0);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
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

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int _char = StringGetChar(s, length);
         if((_char > 96 && _char < 123) || (_char > 223 && _char < 256))
                     s = StringSetChar(s, length, _char - 32);
         else if(_char > -33 && _char < 0)
                     s = StringSetChar(s, length, _char + 224);
   }
return(s);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void ClearPoint(int i,double& first[],double& second[])
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
      if (first[i+2] == EMPTY_VALUE) 
      {
          first[i]    = from[i];
          first[i+1]  = from[i+1];
          second[i]   = EMPTY_VALUE;
      }
      else
      {
          second[i]   = from[i];
          second[i+1] = from[i+1];
          first[i]    = EMPTY_VALUE;
      }
   }
   else
   {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}

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
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"trend");
         if (trend[whichBar] ==-1) doAlert(whichBar,"no trend");
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

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," - ",timeFrameToString(timeFrame)+" rsioma ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," rsioma "),message);
          if (alertsSound)   PlaySound(soundfile);
   }
}





//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+