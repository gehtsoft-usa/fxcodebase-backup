// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71747
 
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

//Your donations will allow the service to continue onward.
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




#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  Blue
#property indicator_color2  Red
#property indicator_color3  Red
#property indicator_color4  DodgerBlue
#property indicator_color5  Magenta
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

//
//
//
//
//

extern string TimeFrame        = "Current time frame";
extern int    HMAPeriod        = 34;
extern int    HMAPrice         = PRICE_CLOSE;
extern double HMASpeed         = 2.0;
extern bool   LinesVisible     = true;
extern int    LinesNumber      = 5;
extern color  ColorUp          = Blue;
extern color  ColorDown        = Red;
extern string UniqueID         = "HullLines1";
extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = false;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;

extern bool   ShowArrows       = true;
extern int    arrowSize        = 2;
extern int    uparrowCode      = 233;
extern int    dnarrowCode      = 234;
extern bool   ArrowsOnFirstBar = true;

//
//
//
//
//

double hma[];
double hmada[];
double hmadb[];
double arrowUp[];
double arrowDn[];
double work[];
double trend[];

int    HalfPeriod;
int    HullPeriod;

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(7);
      SetIndexBuffer(0,hma);
      SetIndexBuffer(1,hmada);
      SetIndexBuffer(2,hmadb);
      SetIndexBuffer(3,arrowUp);   
      SetIndexBuffer(4,arrowDn); 
      SetIndexBuffer(5,trend);
      SetIndexBuffer(6,work);
      if (ShowArrows)
      {
        SetIndexStyle(3,DRAW_ARROW,0,arrowSize); SetIndexArrow(3,uparrowCode);
        SetIndexStyle(4,DRAW_ARROW,0,arrowSize); SetIndexArrow(4,dnarrowCode);   
      }
      else
      {
        SetIndexStyle(3,DRAW_NONE);
        SetIndexStyle(4,DRAW_NONE);
      }       
      
   //
   //
   //
   //
   //
         
      HMAPeriod  = MathMax(2,HMAPeriod);
      HalfPeriod = MathFloor(HMAPeriod/HMASpeed);
      HullPeriod = MathFloor(MathSqrt(HMAPeriod));

         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);

   //
   //
   //
   //
   //
   
   IndicatorShortName(timeFrameToString(timeFrame)+" HMA ("+HMAPeriod+")");
   return(0);
}
void deinit()
{
   deleteLines();
}
void deleteLines()
{
   int lookForLength = StringLen(UniqueID);
   for (int i= ObjectsTotal()-1; i>=0; i--)
   {
      string name = ObjectName(i);
      if (StringSubstr(name,0,lookForLength)==UniqueID) ObjectDelete(name);
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

int start()
{
   int i,counted_bars = IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;   
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { hma[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      if (trend[limit] == -1) CleanPoint(limit,hmada,hmadb);
      for(i=limit; i>=0; i--) work[i] = 2.0*iMA(NULL,0,HalfPeriod,0,MODE_LWMA,HMAPrice,i)-iMA(NULL,0,HMAPeriod,0,MODE_LWMA,HMAPrice,i);
      for(i=limit; i>=0; i--)
      {
         hma[i]   = iMAOnArray(work,0,HullPeriod,0,MODE_LWMA,i);
         hmada[i] = EMPTY_VALUE;
         hmadb[i] = EMPTY_VALUE;
         trend[i] = trend[i+1];
            if (hma[i] > hma[i+1]) trend[i] =  1;
            if (hma[i] < hma[i+1]) trend[i] = -1;
            if (trend[i] == -1) PlotPoint(i,hmada,hmadb,hma);
            
            //
            //
            //
            //
            //
            
            arrowUp[i] = EMPTY_VALUE;
            arrowDn[i] = EMPTY_VALUE;
            if (trend[i]!= trend[i+1])
            if (trend[i] == 1)
                  arrowUp[i] = hma[i] - iATR(NULL,0,20,i)/2.0;
            else  arrowDn[i] = hma[i] + iATR(NULL,0,20,i)/2.0;
      }  
      
      //
      //
      //
      //
      //
          
      deleteLines();
         if (LinesVisible)
         {
            int k = 0;
            for (i=0; i<Bars && k<LinesNumber; i++)
            if (trend[i]!=trend[i+1])
            {
               string name = UniqueID+(string)Time[i];
               ObjectCreate(name,OBJ_TREND,0,Time[i],hma[i],Time[i]+Period()*60,hma[i]);
                  if (trend[i]==1)
                        ObjectSet(name,OBJPROP_COLOR,ColorUp);
                  else  ObjectSet(name,OBJPROP_COLOR,ColorDown);                   
                  k++;
            }
         }               
   manageAlerts();
   return(0);
   }

   //
   //
   //
   //
   //
   
   int shift = -1; if (ArrowsOnFirstBar) shift=1;
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (trend[limit]==-1) CleanPoint(limit,hmada,hmadb);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
      int x = iBarShift(NULL,timeFrame,Time[i+shift]);
         trend[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HMAPeriod,HMAPrice,HMASpeed,LinesVisible,LinesNumber,ColorUp,ColorDown,UniqueID,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,5,y);
         hma[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",HMAPeriod,HMAPrice,HMASpeed,LinesVisible,LinesNumber,ColorUp,ColorDown,UniqueID,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,0,y);
         hmada[i]  = EMPTY_VALUE;
         hmadb[i]  = EMPTY_VALUE;
         
      if(x!=y)
      {
        arrowUp[i] = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",HMAPeriod,HMAPrice,HMASpeed,LinesVisible,LinesNumber,ColorUp,ColorDown,UniqueID,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,3,y);
        arrowDn[i] = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",HMAPeriod,HMAPrice,HMASpeed,LinesVisible,LinesNumber,ColorUp,ColorDown,UniqueID,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,4,y);
      }
      else
      {
        arrowUp[i] = EMPTY_VALUE;
        arrowDn[i] = EMPTY_VALUE;
      }
   }
   for (i=limit;i>=0;i--) if (trend[i]==-1) PlotPoint(i,hmada,hmadb,hma);
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
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
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

       message =  Symbol()+" "+timeFrameToString(Period())+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" HMA trend changed to "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(Symbol()+" HMA ",message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
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

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
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