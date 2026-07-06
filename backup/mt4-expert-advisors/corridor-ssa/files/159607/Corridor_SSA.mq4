//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76035

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Yellow
#property indicator_color2 LimeGreen
#property indicator_color3 Orange
#property indicator_width2 2
#property indicator_width3 2
#property indicator_level1 0.0

#import "libSSA.dll"
   void fastSingular(double& sourceArray[],int arraySize, int lag, int numberOfComputationLoops, double& destinationArray[]);
#import

//
//
//
//
//

extern string TimeFrame               = "Current time frame";
extern int    SSAPrice                =  PRICE_CLOSE;
extern int    SSALag                  = 25;
extern int    SSANumberOfComputations =  2;
extern int    SSAPeriodNormalization  = 25;
extern int    SSANumberOfBars         = 300;
extern int    FirstBar                = 400; 
extern double HighLowStep             = 0.005;
extern int    Shift                   = 0;
extern bool showdivergences           = true; // Divergences

//
//
//
//
//

double in[];
double no[];
double ssaIn[];
double ssaOut[];
double max[];
double min[];
double indiMax[];
double indiMin[];

int    timeFrame;
string indicatorFileName;
bool   returnBars;
bool   calculateValue;
// 
// 
// 
// 
// 
double bullDiv[]; // Divergencia alcista
double bearDiv[]; // Divergencia bajista



//+--------------------------------------------------------------------------------------+
//|                                                                                      |
//+--------------------------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(8);
      SetIndexBuffer(0,in);
      SetIndexBuffer(1,max);
      SetIndexBuffer(2,min);
      SetIndexBuffer(3,no);
      SetIndexStyle(3, DRAW_NONE);
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
      SetIndexShift(0,Shift*timeFrame/Period());
      SetIndexShift(1,Shift*timeFrame/Period());
      SetIndexShift(2,Shift*timeFrame/Period());
      // --------
      SetIndexBuffer(4, bullDiv);
      SetIndexStyle(4, DRAW_ARROW, 0, 2, clrLime); // Divergencia alcista
      SetIndexArrow(4, 233); // Código de flecha hacia arriba
      SetIndexLabel(4, "Bullish Divergence");
      
      SetIndexBuffer(5, bearDiv);
      SetIndexStyle(5, DRAW_ARROW, 0, 2, clrRed); // Divergencia bajista
      SetIndexArrow(5, 234); // Código de flecha hacia abajo
      SetIndexLabel(5, "Bearish Divergence");
    
     SetIndexBuffer(6, indiMin);
      SetIndexStyle(6, DRAW_NONE, 0, 2, clrGreen); 
      SetIndexArrow(6, 200); // Código de flecha hacia arriba
      SetIndexLabel(6, "Min");

     SetIndexBuffer(7, indiMax);
      SetIndexStyle(7, DRAW_NONE, 0, 2, clrCrimson); 
      SetIndexArrow(7, 200); // Código de flecha hacia abajo
      SetIndexLabel(7, "Max");


      // --------
   IndicatorShortName(timeFrameToString(timeFrame)+" Corridor SSA normalized end-pointed");
   return(0);
}
int deinit(){return(0);}

//+--------------------------------------------------------------------------------------+
//|                                                                                      |
//+--------------------------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { in[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
      
   if (calculateValue || timeFrame==Period())
   {
      for(int i=limit; i>=0; i--)
      {
         double ma    = iMA(NULL,0,SSAPeriodNormalization,0,MODE_SMA,SSAPrice,i);
         double dev   = 3.0*iStdDev(NULL,0,SSAPeriodNormalization,0,MODE_SMA,SSAPrice,i);
         double price = iMA(NULL,0,1,0,MODE_SMA,SSAPrice,i);
         if (dev == 0) dev = 0.000001;
         no[i] = (price-ma)/dev;
         in[i] = 0;
         min[i] = 0;
         max[i] = 0;
         
            //
            //
            //
            //
            //
            
            if (i<=FirstBar)
            {
               int ssaBars = MathMin(Bars-i,SSANumberOfBars);
               if (ssaBars<SSALag) continue;
               if (ArraySize(ssaIn) != ssaBars)
               {
                  ArrayResize(ssaIn ,ssaBars);
                  ArrayResize(ssaOut,ssaBars);
               }
               ArrayCopy(ssaIn,no,0,i,ssaBars);
               
               fastSingular(ssaIn,ssaBars,SSALag,SSANumberOfComputations,ssaOut);
               in[i]  = ssaOut[0];
               max[i] = MathMax(in[i],max[i+1]-HighLowStep);
               min[i] = MathMin(in[i],min[i+1]+HighLowStep);
            }                   

         // Marca los máximos y mínimos del indicador
         if (in[i+1] < in[i+2] && in[i+1] < in[i])
         {
            indiMin[i] = in[i+1];
         }
         if (in[i+1] > in[i+2] && in[i+1] > in[i])
         {
            indiMax[i] = in[i+1];
         }
            

      }                  
      SetIndexDrawBegin(0,Bars-FirstBar);
      SetIndexDrawBegin(1,Bars-FirstBar);
      SetIndexDrawBegin(2,Bars-FirstBar);
   
   
   
   if (showdivergences)
   {
      double priceLow1, priceLow2, priceHigh1, priceHigh2;

      for (int m = i; m < i+50; m++)
      {
         if (indiMin[m] != 0 && indiMin[m] != EMPTY_VALUE)
         {
            priceLow1 = iLow(NULL, 0, m);
            for (int n = m+1; n < m+50 && n < Bars; n++)
            {
               if (indiMin[m] != 0 &&indiMin[n] != EMPTY_VALUE)
               {
                  priceLow2 = iLow(NULL, 0, n);
                  if (priceLow1 < priceLow2 && indiMin[m] >= indiMin[n])
                  {
                     bullDiv[m] = indiMin[m]; // Marca la divergencia
                  }
                  break;
               }
            }
            break;
         }
      }
      
      for (m = i; m < i+50; m++)
      {
         if (indiMax[m] != 0 && indiMax[m] != EMPTY_VALUE)
         {
            priceHigh1 = iHigh(NULL, 0, m);
            for (n = m+1; n < m+50 && n < Bars; n++)
            {
               if (indiMax[m] != 0 && indiMax[n] != EMPTY_VALUE)
               {
                  priceHigh2 = iHigh(NULL, 0, n);
                  if (priceHigh1 > priceHigh2 && indiMax[m] <= indiMax[n])
                  {
                     bearDiv[m] = indiMax[m]; // Marca la divergencia
                  }
                  break;
               }
            }
            break;
         }
      }
   }
   
      return(0); 
   
   }

   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for(i=limit; i>=0; i--) 
   {
         int y = iBarShift(NULL,timeFrame,Time[i]);
         in[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SSAPrice,SSALag,SSANumberOfComputations,SSAPeriodNormalization,SSANumberOfBars,FirstBar,HighLowStep,0,y);
         max[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SSAPrice,SSALag,SSANumberOfComputations,SSAPeriodNormalization,SSANumberOfBars,FirstBar,HighLowStep,1,y);
         min[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",SSAPrice,SSALag,SSANumberOfComputations,SSAPeriodNormalization,SSANumberOfBars,FirstBar,HighLowStep,2,y);
   }
   
   SetIndexDrawBegin(0,Bars-FirstBar*timeFrame/Period());
   SetIndexDrawBegin(1,Bars-FirstBar*timeFrame/Period());
   SetIndexDrawBegin(2,Bars-FirstBar*timeFrame/Period());
   
   
   
   // Divergences
   // Inicializa buffers de divergencia
    ArrayInitialize(bullDiv, 0);
    ArrayInitialize(bearDiv, 0);
    ArrayInitialize(indiMin, 0);
    ArrayInitialize(indiMax, 0);


 // Detección de divergencias
   //  recorrer el buffer indiMin, desde la vela actual hacia atras, cuando encontremos un valor > 0 y distinto de vacío parar:



      //   // Divergencia alcista: el precio hace un mínimo menor y el indicador un mínimo mayor
      //   //   if (Low[n+1] < Low[n+2] && Low[n+1] < Low[n] && in[n] > in[n+1] && in[n] > in[n+2])
      //      if (in[n+1] < in[n+2] && in[n+1] < in[n])
      //   {
      //       // Busca el mínimo anterior
      //       for(int j=n+5; j<n+30 && j<Bars-2; j++)
      //       {
      //           if (in[j+1] < in[j+2] && in[j+1] < in[j])
      //           {
      //               if (Low[n+1] < Low[j+1] && in[n+1] >= in[j+1])
      //               {
      //                   bullDiv[n] =  in[n]; // Marca la divergencia
      //                   break;
      //               }
      //           }
      //       }
      //   }









   /*  
    
    // Detección de divergencias
    for(int i=limit-30; i>=2; i--) // Busca en las últimas 30 velas
    {
        // Divergencia alcista: el precio hace un mínimo menor y el indicador un mínimo mayor
         //   if (Low[i+1] < Low[i+2] && Low[i+1] < Low[i] && in[i] > in[i+1] && in[i] > in[i+2])
        if (in[i+1] < in[i+2] && in[i+1] < in[i])
        {
            // Busca el mínimo anterior
            for(int j=i+5; j<i+30 && j<Bars-2; j++)
            {
                if (in[j+1] < in[j+2] && in[j+1] < in[j])
                {
                    if (Low[i+1] < Low[j+1] && in[i+1] >= in[j+1])
                    {
                        bullDiv[i] =  in[i]; // Marca la divergencia
                        break;
                    }
                }
            }
        }

        // Divergencia bajista: el precio hace un máximo mayor y el indicador un máximo menor
        if (in[i+1] > in[i+2] && in[i+1] > in[i])
        {
            // Busca el máximo anterior
            for(j=i+5; j<i+30 && j<Bars-2; j++)
            {
                if (in[j+1] > in[j+2] && in[j+1] > in[j])
                {
                    if (High[i+1] > High[j+1] && in[i+1] < in[j+1])
                    {
                        bearDiv[i] =  in[i]; // Marca la divergencia
                        break;
                    }
                }
            }
        }
    }

   */
   
   
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
      int char3 = StringGetChar(s, length);
         if((char3 > 96 && char3 < 123) || (char3 > 223 && char3 < 256))
                     s = StringSetChar(s, length, char3 - 32);
         else if(char3 > -33 && char3 < 0)
                     s = StringSetChar(s, length, char3 + 224);
   }
   return(s);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76035

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 
