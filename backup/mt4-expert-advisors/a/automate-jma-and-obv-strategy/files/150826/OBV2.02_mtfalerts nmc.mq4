// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=73717

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
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_label1  "Obv"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_label2  "Obv"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_width2  2
#property indicator_label3  "Obv"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrCornflowerBlue
#property indicator_width3  2
#property indicator_color4  clrCornflowerBlue

extern string         TimeFrame       = "Current time frame";
extern int            SignalPeriod    = 13;
extern ENUM_MA_METHOD SignalMaMode    = MODE_SMMA;
input bool            ShowMa          = true;

extern bool           alertsOn        = false;
extern bool           alertsOnCurrent = true;
extern bool           alertsMessage   = true;
extern bool           alertsSound     = false;
extern bool           alertsEmail     = false;

double gadblOBV[],valda[],valdb[],ma[],trend[];

string indicatorFileName;
bool   returnBars,calculateValue;
int    timeFrame;

int init()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,gadblOBV);
   SetIndexBuffer(1,valda);
   SetIndexBuffer(2,valdb);
   SetIndexBuffer(3,ma);      SetIndexStyle(3,ShowMa ? DRAW_LINE : DRAW_NONE);
   SetIndexBuffer(4,trend);
   IndicatorDigits(0);     
   
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
      
      //
      //
      //
      //
      //

   IndicatorShortName( timeFrameToString(timeFrame)+" OBV2" );
   SetIndexLabel( 0, "OBV2" );
   return( 0 );
}

int start()
{
   int counted_bars = IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { gadblOBV[0] = MathMin(limit+1,Bars-1); return(0); }
   
   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      if (trend[limit]==-1) iCleanPoint(limit,valda,valdb);
      for( int inx = limit; inx >=0; inx-- )
      {
         if ( inx == ( Bars - 1 ) )
         {
            gadblOBV[inx] = Volume[inx];
         }
         else 
         {
            if ( ( High[inx] == Low[inx] ) || ( Open[inx] == Close[inx] ) || ( Close[inx] == Close[inx+1] ) )
            {
               gadblOBV[inx] = gadblOBV[inx+1];
            }
            else
            {            
               if ( Close[inx] > Open[inx] )   gadblOBV[inx] = gadblOBV[inx+1] + ( Volume[inx] * ( Close[inx] - Open[inx] ) / ( High[inx] - Low[inx] ) );
               else                            gadblOBV[inx] = gadblOBV[inx+1] - ( Volume[inx] * ( Open[inx] - Close[inx] ) / ( High[inx] - Low[inx] ) );
            }
         }     
      }
      for(inx=limit; inx>=0; inx--)
      {
         ma[inx]  = iMAOnArray(gadblOBV,0,SignalPeriod,0,SignalMaMode,inx);
         if (inx<Bars-1) trend[inx] = (gadblOBV[inx]>ma[inx]) ? 1 : (gadblOBV[inx]<ma[inx]) ? -1 : trend[inx+1]; 
         valda[inx] = valdb[inx] = EMPTY_VALUE; if (trend[inx] == -1) iPlotPoint(inx,valda,valdb,gadblOBV);      
      } 
      manageAlerts();            
      return( 0 );
   }      
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (trend[limit]==-1) iCleanPoint(limit,valda,valdb);
   for (int i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         gadblOBV[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SignalPeriod,SignalMaMode,ShowMa,0,y);
         valda[inx]  = valdb[inx] = EMPTY_VALUE;
         ma[i]       = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SignalPeriod,SignalMaMode,ShowMa,3,y);
         trend[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SignalPeriod,SignalMaMode,ShowMa,4,y);
   }
   for (i=limit;i>=0 && !_StopFlag; i--)  if (trend[i] == -1) iPlotPoint(i,valda,valdb,gadblOBV); 
   manageAlerts();
   return(0);
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void iCleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}
void iPlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}


//+------------------------------------------------------------------
//|                                                                 
//+------------------------------------------------------------------
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
         if (trend[whichBar]   == 1) doAlert(whichBar," buy ");
         if (trend[whichBar]   ==-1) doAlert(whichBar," sell ");
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

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," ",timeFrameToString(timeFrame)," OBV2 ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," OBV2 "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
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