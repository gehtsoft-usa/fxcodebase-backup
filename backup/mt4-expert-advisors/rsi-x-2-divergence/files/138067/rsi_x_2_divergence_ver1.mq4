// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70508

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrSandyBrown
#property indicator_color3  clrSandyBrown
#property indicator_color4  Green
#property indicator_color5  Red
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property strict


enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};
enum enRsiTypes
{
   rsi_rsi,  // Regular RSI
   rsi_wil,  // Slow RSI
   rsi_rap,  // Rapid RSI
   rsi_har,  // Harris RSI
   rsi_rsx,  // RSX
   rsi_cut   // Cuttlers RSI
};


extern enRsiTypes      RsiType            = rsi_rsi;       // RSI calculation method
extern int             RsiFastLength      = 14;            // Rsi fast length
extern int             RsiSlowLength      = 100;           // Rsi slow length
extern enPrices        RsiPrice           = pr_close;      // Rsi price
extern ENUM_TIMEFRAMES RsiTf              = PERIOD_CURRENT;// Rsi timeframe
extern bool            drawArrows         = true;          // Arrows usage
extern bool            alertsMessage      = false;         // Alerts message usage
extern bool            alertsSound        = false;         // Alerts sound usage
extern bool            alertsEmail        = false;         // Alerts email usage
extern bool            alertsPush         = false;         // Alerts push usage

double val[],valda[],valdb[],slope[], up_arrow[], down_arrow[];

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
   IndicatorBuffers(6);
   SetIndexBuffer(0,val);
   SetIndexBuffer(1,valda);
   SetIndexBuffer(2,valdb);   
   SetIndexBuffer(3,up_arrow);
   SetIndexStyle(3,DRAW_ARROW,0,2,Red);
   SetIndexArrow(3, 234);
   SetIndexBuffer(4,down_arrow);
   SetIndexStyle(4,DRAW_ARROW,0,2,Green);
   SetIndexArrow(4, 233);
   SetIndexBuffer(5,slope);
   return(0);
}
int deinit() { return(0); }     

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

datetime time;
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //
        
   if (slope[limit]==-1) CleanPoint(limit,valda,valdb);        
   for(int i=limit; i>=0; i--)
   {
      double open = Open[i];
      double close = Close[i];
      double high = High[i];
      double low = Low[i];
      
      if(RsiTf != PERIOD_CURRENT)
      {
         open = iOpen(NULL, RsiTf, iBarShift(NULL, RsiTf, Time[i]));
         close = iClose(NULL, RsiTf, iBarShift(NULL, RsiTf, Time[i]));
         high = iHigh(NULL, RsiTf, iBarShift(NULL, RsiTf, Time[i]));
         low = iLow(NULL, RsiTf, iBarShift(NULL, RsiTf, Time[i]));
      }        
      double price = getPrice(RsiPrice,open,close,high,low,i);
      double rsif  = iRsi(RsiType,price,RsiFastLength,i,0);
      double rsis  = iRsi(RsiType,price,RsiSlowLength,i,1);
      val[i]   = rsif-rsis;
      valda[i] = EMPTY_VALUE;
      valdb[i] = EMPTY_VALUE;
      if (i<Bars-1)
      {
         if (val[i]>val[i+1]) slope[i] =  1;
         if (val[i]<val[i+1]) slope[i] = -1;
      }         
      if (slope[i]==-1) 
      {
         PlotPoint(i,valda,valdb,val);
         
         
      }
   }
   if(time != iTime(Symbol(),0,0))
   {
       Print("val " + val[1]+" valda "+valda[1]+" valdb "+valdb[1]);
       if(IsNumeric(valda[1]) && !IsNumeric(valda[2]))
       {
          if(drawArrows)
          {                     
              up_arrow[0] = val[1]+(val[1]*0.5);
              
               Print("Arrow Up");
          }
          doAlert("Up");
       }
       if(!IsNumeric(valda[1]) && IsNumeric(valda[2]))
       {
           if(drawArrows)
           {                      
               down_arrow[0] = val[1]-(val[1]*0.5);
               
               Print("Arrow Down");
           }
           doAlert("Down");
        }            
        time = iTime(Symbol(),0,0);
   }      
	return(0);	
}

bool IsNumeric(double val)
{
   if(val >= 2147483647 || val <= -2147483647)
   return false;   
   return(true);
} 



//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//
//

string rsiMethodNames[] = {"RSI","Slow RSI","Rapid RSI","Harris RSI","RSX","Cuttler RSI"};
string getRsiName(int method)
{
   int max = ArraySize(rsiMethodNames)-1;
      method=MathMax(MathMin(method,max),0); return(rsiMethodNames[method]);
}

//
//
//
//
//

#define rsiInstances 2
double workRsi[][rsiInstances*13];
#define _price  0
#define _change 1
#define _changa 2
#define _rsival 1
#define _rsval  1

double iRsi(int rsiMode, double price, double period, int i, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int z = instanceNo*13; 
      int r = Bars-i-1;
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
   switch (rsiMode)
   {
      case rsi_rsi:
         {
         double alpha = 1.0/MathMax(period,1); 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
                  workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
            }
         if (workRsi[r][z+_changa] != 0)
               return(50.0*(workRsi[r][z+_change]/workRsi[r][z+_changa]+1));
         else  return(50.0);
         }
         
      //
      //
      //
      //
      //
      
      case rsi_wil :
         {         
            double up = 0;
            double dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if (r<1)
                  workRsi[r][z+_rsival] = 50;
            else               
               if(up + dn == 0)
                     workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/MathMax(period,1))*(50            -workRsi[r-1][z+_rsival]);
               else  workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/MathMax(period,1))*(100*up/(up+dn)-workRsi[r-1][z+_rsival]);
            return(workRsi[r][z+_rsival]);      
         }
      
      //
      //
      //
      //
      //

      case rsi_rap :
         {
            double up = 0;
            double dn = 0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if(up + dn == 0)
                  return(50);
            else  return(100 * up / (up + dn));      
         }            

      //
      //
      //
      //
      //

      
      case rsi_har :
         {
            double avgUp=0,avgDn=0; double up=0; double dn=0;
            for(int k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][instanceNo+_price]- workRsi[r-k-1][instanceNo+_price];
               if(diff>0)
                     { avgUp += diff; up++; }
               else  { avgDn -= diff; dn++; }
            }
            if (up!=0) avgUp /= up;
            if (dn!=0) avgDn /= dn;
            double rs = 1;
               if (avgDn!=0) rs = avgUp/avgDn;
               return(100-100/(1.0+rs));
         }               

      //
      //
      //
      //
      //
      
      case rsi_rsx :  
         {   
            double Kg = (3.0)/(2.0+period), Hg = 1.0-Kg;
            if (r<period) { for (int k=1; k<13; k++) workRsi[r][k+z] = 0; return(50); }  

            //
            //
            //
            //
            //
      
            double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
            double moa = MathAbs(mom);
            for (int k=0; k<3; k++)
            {
               int kk = k*2;
               workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
               workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
               workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
               workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
            }
            if (moa != 0)
                 return(MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00)); 
            else return(50);
         }            
            
      //
      //
      //
      //
      //
      
      case rsi_cut :
         {
            double sump = 0;
            double sumn = 0;
            for (int k=0; k<(int)period && r-k-1>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
                  if (diff > 0) sump += diff;
                  if (diff < 0) sumn -= diff;
            }
            if (sumn > 0)
                  return(100.0-100.0/(1.0+sump/sumn));
            else  return(50);
         }            
   } 
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
//

double workHa[][4];
double getPrice(int price, double open, double& close, double& high, double& low, int i)
{
  if (price>=pr_haclose && price<=pr_hatbiased)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); 
         int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][2] + workHa[r-1][3])/2.0;
         else   haOpen  = (open+close)/2;
         double haClose = (open + high + low + close) / 4.0;
         double haHigh  = MathMax(high, MathMax(haOpen,haClose));
         double haLow   = MathMin(low , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][0] = haLow;  workHa[r][1] = haHigh; } 
         else                 { workHa[r][0] = haHigh; workHa[r][1] = haLow;  } 
                                workHa[r][2] = haOpen;
                                workHa[r][3] = haClose;
         //
         //
         //
         //
         //
         
         switch (price)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (price)
   {
      case pr_close:     return(close);
      case pr_open:      return(open);
      case pr_high:      return(high);
      case pr_low:       return(low);
      case pr_median:    return((high+low)/2.0);
      case pr_medianb:   return((open+close)/2.0);
      case pr_typical:   return((high+low+close)/3.0);
      case pr_weighted:  return((high+low+close+close)/4.0);
      case pr_average:   return((high+low+close+open)/4.0);
      case pr_tbiased:   
               if (close>open)
                     return((high+close)/2.0);
               else  return((low+close)/2.0);        
   }
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

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}


void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message =  StringConcatenate(timeFrameToString(Period())+" "+Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," MACD predictor crossed price ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(Symbol()+" MACD predictor",message);
          if (alertsPush)    SendNotification(message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}