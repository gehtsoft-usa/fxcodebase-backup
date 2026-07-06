//+------------------------------------------------------------------+
//|                                                   CCI stochastic |
//+------------------------------------------------------------------+


#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DimGray
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2

//
//
//
//
//

extern string TimeFrame             = "current time frame";
extern int    CCIPeriod             = 14;
extern int    StochPeriod           = 14;
extern int    StochSmooth           =  3;
extern double OverSold              = 20;
extern double OverBought            = 80;
extern color  OverSoldColor         = Red; 
extern color  OverBoughtColor       = DeepSkyBlue; 
extern bool   ShowArrows            = false;
extern bool   ShowArrowsOnZoneEnter = true;
extern bool   ShowArrowsOnZoneExit  = true;
extern string ArrowsIdentifier      = "CCIStochasticArrows";
extern color  ArrowsDnColor         = Red; 
extern color  ArrowsUpColor         = DeepSkyBlue; 
extern bool   Interpolate           = true;
extern bool   IgnoreLastPeriod           = true;


//
//
//
//
//

double cci[];
double stoch[];
double rawStoch[];
double stochUpa[];
double stochUpb[];
double stochDna[];
double stochDnb[];
double prices[];
double trend[];

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
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
      SetIndexBuffer(0,stoch);
      SetIndexBuffer(1,stochUpa); SetIndexStyle(1,DRAW_LINE,EMPTY,EMPTY,OverSoldColor);
      SetIndexBuffer(2,stochUpb); SetIndexStyle(2,DRAW_LINE,EMPTY,EMPTY,OverSoldColor);
      SetIndexBuffer(3,stochDna); SetIndexStyle(3,DRAW_LINE,EMPTY,EMPTY,OverBoughtColor);
      SetIndexBuffer(4,stochDnb); SetIndexStyle(4,DRAW_LINE,EMPTY,EMPTY,OverBoughtColor);
      SetIndexBuffer(5,cci);
      SetIndexBuffer(6,rawStoch);
      SetIndexBuffer(7,trend);
         SetLevelValue(0,OverBought);
         SetLevelValue(1,OverSold);

         //
         //
         //
         //
         //
                  
         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);
         
         //
         //
         //
         //
         //
         
   IndicatorShortName("CCI Stochastic");
   return(0);
}

//
//
//
//
//

int deinit()
{
   if (!calculateValue && ShowArrows)
   {
      string lookFor       = ArrowsIdentifier+":";
      int    lookForLength = StringLen(lookFor);
      for (int i=ObjectsTotal()-1; i>=0; i--)
      {
         string objectName = ObjectName(i);
            if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
      }
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

int start()
{
   int counted_bars=IndicatorCounted();
   int i,k,n,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { cci[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {
      if (trend[limit]== 1) CleanPoint(limit,stochUpa,stochUpb);
      if (trend[limit]==-1) CleanPoint(limit,stochDna,stochDnb);
      if (ArraySize(prices)!=Bars) ArrayResize(prices,Bars);
      for(i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         prices[r]  = iMA(NULL,0,1,0,MODE_SMA,PRICE_TYPICAL,i);
         double avg = 0; for(k=0; k<CCIPeriod; k++) avg +=         prices[r-k];      avg /= CCIPeriod;
         double dev = 0; for(k=0; k<CCIPeriod; k++) dev += MathAbs(prices[r-k]-avg); dev /= CCIPeriod;
            if (dev!=0)
                  cci[i] = (prices[r]-avg)/(0.015*dev);
            else  cci[i] = 0;
         
            //
            //
            //
            //
            //
         
            double hh = cci[ArrayMaximum(cci,StochPeriod,i)];
            double ll = cci[ArrayMinimum(cci,StochPeriod,i)];
               if (hh!=ll)
                     rawStoch[i] = 100*(cci[i]-ll)/(hh-ll);
               else  rawStoch[i] = 0;
            stoch[i] = 0; for(k=0; k<StochSmooth; k++) stoch[i] += rawStoch[i+k];  stoch[i] /= StochSmooth;
            
            //
            //
            //
            //
            //
         
            stochUpa[i] = EMPTY_VALUE;
            stochUpb[i] = EMPTY_VALUE;
            stochDna[i] = EMPTY_VALUE;
            stochDnb[i] = EMPTY_VALUE;
            trend[i] = trend[i+1];
               if (stoch[i]>OverBought)                      trend[i] =  1;
               if (stoch[i]<OverSold)                        trend[i] = -1;
               if (stoch[i]>OverSold && stoch[i]<OverBought) trend[i] =  0;
               if (trend[i] ==  1) PlotPoint(i,stochUpa,stochUpb,stoch);
               if (trend[i] == -1) PlotPoint(i,stochDna,stochDnb,stoch);
            manageArrow(i);
      }
      return(0);
   }      
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (trend[limit]== 1) CleanPoint(limit,stochUpa,stochUpb);
   if (trend[limit]==-1) CleanPoint(limit,stochDna,stochDnb);
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         stoch[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",CCIPeriod,StochPeriod,StochSmooth,OverSold,OverBought,0,y);
         trend[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",CCIPeriod,StochPeriod,StochSmooth,OverSold,OverBought,7,y);
         stochUpa[i] = EMPTY_VALUE;
         stochUpb[i] = EMPTY_VALUE;
         stochDna[i] = EMPTY_VALUE;
         stochDnb[i] = EMPTY_VALUE;
         manageArrow(i);

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
            for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(k = 1; k < n; k++)
               stoch[i+k] = stoch[i] + (stoch[i+n]-stoch[i])*k/n;
   }
   for (i=limit;i>=0;i--)
   {
      if (trend[i]== 1) PlotPoint(i,stochUpa,stochUpb,stoch);
      if (trend[i]==-1) PlotPoint(i,stochDna,stochDnb,stoch);
   }

   //
   //
   //
   //
   //
   
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

int manageArrow(int i)
{

	if (i == 0 && IgnoreLastPeriod)
	{
	return(0);   
	}
	
   if (!calculateValue && ShowArrows)
   {
      deleteArrow(Time[i]);
      if (trend[i]!=trend[i+1])
      {
         if (ShowArrowsOnZoneEnter && trend[i]   == 1) drawArrow(i,ArrowsUpColor,241,false);
         if (ShowArrowsOnZoneEnter && trend[i]   ==-1) drawArrow(i,ArrowsDnColor,242,true);
         if (ShowArrowsOnZoneExit  && trend[i+1] ==-1) drawArrow(i,ArrowsUpColor,241,false);
         if (ShowArrowsOnZoneExit  && trend[i+1] == 1) drawArrow(i,ArrowsDnColor,242,true);
      }
   }
   
   return(0);   
}               

//
//
//
//
//

int drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = ArrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = ArrowsIdentifier+":"+time; ObjectDelete(lookFor);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
      int Char = StringGetChar(s, length);
         if((Char > 96 && Char < 123) || (Char > 223 && Char < 256))
                     s = StringSetChar(s, length, Char - 32);
         else if(Char > -33 && Char < 0)
                     s = StringSetChar(s, length, Char + 224);
   }
   return(s);
}