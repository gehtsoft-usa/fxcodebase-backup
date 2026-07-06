//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75700

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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


//---- indicator version number
#property version   "1.01"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 5
//---- only one plot is used
#property indicator_plots   4

//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrMagenta
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label1 "FullSSA"

//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
#property indicator_label2 "MA"

#property indicator_label3 "Arrow Up"
#property  indicator_type3  DRAW_ARROW
#property indicator_color3 clrBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Arrow Down"
#property  indicator_type4  DRAW_ARROW
#property indicator_color4 clrRed
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];
double MaBuffer[];

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // The constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Averaging algorithms description            |
//+----------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define MaxCompCol 20
#define MaxCatLag  10  // 200
#define MaxLen     300 // 5000
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Equal(double &x1[][MaxCatLag],double &x2[][MaxCatLag],int t)
  {
//----
   int N=ArrayRange(x1,0);
   int M=ArrayRange(x1,1);

   for(int i=0; i<N; i++) for(int j=0; j<M; j++)
     {
      if(t) x1[i][j]=x2[j][i];
      else  x1[i][j]=x2[i][j];
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*Calculation of the Sn function, is needed for calculation of the eigen values
There the negative determinants are calculated*/
double gaussSn(double &A[][MaxCatLag],double l,int n)
  {
//----
   int count,cp,i1,i,j,k;
   double B[MaxCatLag][MaxCatLag]={0};
   double c;
   double w[];
   ArrayResize(w,n);
   double s1,s2;
//------
   Equal(B,A,0);
//------
   for(i=0; i<n; i++)
     {
      B[i][i]=B[i][i]-l;
     }
   cp=0;
   for(k=0;k<=n-2;k++)
     {
      for(i=k+1;i<=n-1;i++)
        {
         if(B[k][k]==0)
           {
            for(i1=0;i1<=n-1;i1++)
              {
               w[i1]=B[i1][k];
               B[i1][k]=B[i1][k+1];
               B[i1][k+1]=w[i1];
              }
            cp=cp+1;
           }
         c=B[i][k]/B[k][k];
         for(j=0;j<=n-1;j++)
           {
            B[i][j]=B[i][j]-B[k][j]*c;
           }
        }
     }
   count=0;
   s1=1;
   for(i=0;i<=n-1;i++)
     {
      s2=B[i][i];
      if(s2<0) count=count+1;
     }
//----
   ArrayFree(w);
   return(1.0*count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*Calculation of eigen values by bisection method}
  It is good as it will calculate as much eigen numbers, as needed,  
  greatly saves the resource */
double gaussbisectionl(double &A[][MaxCatLag],int k,int n)
  {
//----
   double e1,maxnorm,cn,a1,b1,c;
   int i,j;
   maxnorm=0;
   for(i=0;i<=n-1;i++)
     {
      cn=0;
      for(j=0;j<=n-1;j++) cn+=A[i][j];
      if(maxnorm<cn) maxnorm=cn;
     }
     
   a1=0;
   b1=10*maxnorm;
   e1=1.0*maxnorm/10000000;
   while(MathAbs(b1-a1)>e1)
     {
      c=1.0*(a1+b1)/2;
      if(gaussSn(A,c,n)<k)
         a1=c;
      else
         b1=c;
     }
//----
   return((a1+b1)/2.0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*It calculates eigen vectors for already calculated eigen numbersl*/
void svector(double &A[][MaxCatLag],double l,int n,double &V[])
  {
//----
   int cp,i1,i,j,k;
   double B[MaxCatLag][MaxCatLag]={0};
   double c;
   double w[];
   ArrayResize(w,n);
   Equal(B,A,0);
   for(i=0;i<=n-1;i++) B[i][i]-=l;
   cp=0;
   for(k=0;k<=n-2;k++)for(i=k+1;i<=n-1;i++)
     {
      if(!B[k][k])
        {
         for(i1=0;i<=n-1;i++)
           {
            w[i1]=B[i1][k];
            B[i1][k]=B[i1][k+1];
            B[i1][k+1]=w[i1];
           }
         cp++;
        }
        
      c=1.0*B[i][k]/B[k][k];
      for(j=0;j<=n-1;j++) B[i][j]-=B[k][j]*c;
     }
     
   V[n-1]=1;
   c=1;
   for(i=n-2;i>=0;i--)
     {
      V[i]=0;
      for(j=i;j<=n-1;j++) V[i]-=B[i][j]*V[j];
      V[i]/=B[i][i];
      c+=V[i]*V[i];
     }
   for(i=0;i<=n-1;i++) V[i]/=MathSqrt(c);
//----
   ArrayFree(w);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*And here is the caterpillar itself}
{Õ-vector of the source series
n-its length
l-lag length
s-number of the eigen components
(there the source series is divided into components and then restored, then you set how many components you will need)
Y - restored series (smoothed by the caterpillar) there I also added a comment where the separate
components of the series are located
*/
//---------------------------------------------------------------------------
void fastsingular(double &X[],int n,int l,int s,double &Y[])
  {
//----
   if(l>MaxCatLag) l=MaxCatLag;
   if(s>MaxCompCol) s=MaxCompCol;
   if(s>l) s=l;
   if(n>MaxLen) n=MaxLen;
   double A[MaxCatLag][MaxCatLag]={0};
   double B[MaxLen][MaxCatLag]={0};
   double Bn[MaxCatLag][MaxLen]={0};

   int kb,lb,m,k,i,j,i1;
   double V[MaxCatLag][MaxLen]={0};
   double Yn[MaxCatLag][MaxLen]={0};
   double ls[MaxCatLag]={0};
//---
   double Vtemp[MaxCatLag]={0};
//---
   j=0;
   k=n-l+1;
/*Form the A matrix (in the method that I downloaded from the developers web site it is the S matrix) */
   for(i=0;i<=l-1;i++)
     {
      for(j=0;j<=l-1;j++)
        {
         A[i][j]=0;
         for(m=0;m<=k-1;m++)
           {
            A[i][j]+=X[i+m]*X[m+j];
            B[m][j]=X[m+j];
           }
        }
     }
/*Find the eigen numbers and the À matrix vectors*/
   for(i=0;i<=s-1;i++)
     {
      ls[i]=gaussbisectionl(A,l-i,l);
      svector(A,ls[i],l,Vtemp);
      for(j=0;j<=l-1; j++) V[i][j]=Vtemp[j];
     }
//------
/*The restored matrix is formed*/
   for(i1=0;i1<=s-1;i1++)
     {
      //------
      for(i=0;i<=k-1;i++)
        {
         Yn[i1][i]=0;
         for(j=0;j<=l-1;j++) Yn[i1][i]+=B[i][j]*V[i1][j];
        }
      //------
      for(i=0;i<=l-1;i++)for(j=0;j<=k-1;j++) Bn[i][j]=V[i1][i]*Yn[i1][j];
      //-------
      //Diagonal averaging (recovery series)
      kb=k;
      lb=l;
      for(i=0;i<=n-1;i++)
        {
         Yn[i1][i]=0;
         if(i<lb-1)
           {
            for(j=0;j<=i;j++)
              {
               if(l<=k) Yn[i1][i]+=Bn[j][i-j];
               else Yn[i1][i]+=Bn[i-j][j];
              }
            Yn[i1][i]/=(1.0*(i+1));
           }
         if((lb-1<=i) && (i<kb-1))
           {
            for(j=0;j<=lb-1;j++)
              {
               if(l<=k) Yn[i1][i]+=Bn[j][i-j];
               else Yn[i1][i]+=Bn[i-j][j];
              }
            Yn[i1][i]=Yn[i1][i]/(1.0*lb);
           }
         if(kb-1<=i)
           {
            for(j=i-kb+1;j<=n-kb;j++)
              {
               if(l<=k) Yn[i1][i]+=Bn[j][i-j];
               else Yn[i1][i]+=Bn[i-j][j];
              }
            Yn[i1][i]/=(1.0*(n-i));
           }
        }
     }
/* If you do not sum up here, then there will be separate components of dissection
	of the process by eigen functions */
   for(i=0;i<=n-1;i++)
     {
      Y[i]=0;
      for(i1=0;i1<=s-1;i1++) Y[i]+=Yn[i1][i];
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*{Õ-vector of the source series
n-its length
l-lag length
s-number of the eigen components
(there the source series is divided into components and then restored, then you set how many components you will need)
Y - restored series (smoothed by the caterpillar) there I also added a comment where the separate
components of the series are located
*/
//---------------------------------------------------------------------------
void singularPCA(double &X[],int n,int l,int s,double &Y[])
  {
//----
   if(l>MaxCatLag) l=MaxCatLag;
   if(s>MaxCompCol) s=MaxCompCol;
   if(s>l) s=l;
   if(n>MaxLen) n=MaxLen;
   double A[MaxCatLag][MaxCatLag]={0};
   double B[MaxLen][MaxCatLag]={0};
   double Bn[MaxCatLag][MaxLen]={0};

   int kb,lb,m,k,i,j,i1;
   double V[MaxCatLag][MaxLen]={0};
   double Yn[MaxCatLag][MaxLen]={0};
   double ls[MaxCatLag]={0};
//---
   double Vtemp[MaxCatLag]={0};
//---
   j=0;
   k=n-l+1;
/*Form the A matrix (in the method that I downloaded from the developers web site it is the S matrix) */
   for(i=0;i<=l-1;i++)
     {
      for(j=0;j<=l-1;j++)
        {
         A[i][j]=0;
         for(m=0;m<=k-1;m++)
           {
            A[i][j]+=X[i+m]*X[m+j];
            B[m][j]=X[m+j];
           }
        }
     }
/*Find the eigen numbers and the À matrix vectors*/
//for (i=0;i<=s-1;i++)
// {
   ls[s]=gaussbisectionl(A,l-s,l);
   svector(A,ls[s],l,Vtemp);
   for(j=0;j<=l-1; j++) V[s][j]=Vtemp[j];
// }
//------
/*The restored matrix is formed*/
   i1=s;
//------
   for(i=0;i<=k-1;i++)
     {
      Yn[i1][i]=0;
      for(j=0;j<=l-1;j++) Yn[i1][i]+=B[i][j]*V[i1][j];
     }
//------
   for(i=0;i<=l-1;i++)
     {
      for(j=0;j<=k-1;j++) Bn[i][j]=V[i1][i]*Yn[i1][j];
     }
//-------
//Diagonal averaging (recovery series)
   kb=k;
   lb=l;
   for(i=0;i<=n-1;i++)
     {
      Yn[i1][i]=0;
      if(i<lb-1)
        {
         for(j=0;j<=i;j++)
           {
            if(l<=k) Yn[i1][i]+=Bn[j][i-j];
            if(l>k) Yn[i1][i]+=Bn[i-j][j];
           }
         Yn[i1][i]=Yn[i1][i]/(1.0*(i+1));
        }
      if((lb-1<=i) && (i<kb-1))
        {
         for(j=0;j<=lb-1;j++)
           {
            if(l<=k) Yn[i1][i]+=Bn[j][i-j];
            if(l>k) Yn[i1][i]+=Bn[i-j][j];
           }
         Yn[i1][i]=Yn[i1][i]/(1.0*lb);
        }
      if(kb-1<=i)
        {
         for(j=i-kb+1;j<=n-kb;j++)
           {
            if(l<=k) Yn[i1][i]+=Bn[j][i-j];
            if(l>k) Yn[i1][i]+=Bn[i-j][j];
           }
         Yn[i1][i]/=(1.0*(n-i));
        }
     }
/* If you do not sum up here, then there will be separate components of dissection
	of the process by eigen functions */
   for(i=0;i<=n-1;i++)
     {
      Y[i]=0;
      Y[i]=Yn[s][i];
     }
//----
  }
//-----------------------------------------------------------------------------+

//+----------------------------------------------+
//|  INDICATOR INPUT PARAMETERS                  |
//+----------------------------------------------+
input uint Lag=10;
input uint NumComps=2;
input uint PeriodNorm=10;
input uint iN=100;

input double ma_periods=20;
//+----------------------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer[],TimeSeriesBuffer[];
//---- Declaration of integer variables for the indicator handles
int MA_Handle,STD_Handle;
//+------------------------------------------------------------------+    
//| FullSSA indicator initialization function                        | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=int(MathMax(Lag,PeriodNorm));

//---- getting the iMA indicator handle
   MA_Handle=iMA(NULL,0,PeriodNorm,0,MODE_SMA,PRICE_CLOSE);
   if(MA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- getting handle of the iStdDev indicator
   STD_Handle=iStdDev(NULL,0,PeriodNorm,0,MODE_SMA,PRICE_CLOSE);
   if(STD_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iStdDev indicator");

//---- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
   ArraySetAsSeries(IndBuffer,true);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   
   SetIndexBuffer(1,MaBuffer,INDICATOR_DATA);
   ArraySetAsSeries(MaBuffer,true);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,iN+ma_periods);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   
   SetIndexBuffer(2,ArrowUp,INDICATOR_DATA);
   ArraySetAsSeries(ArrowUp,true);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetInteger(2, PLOT_ARROW, 233);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 30);
   
   SetIndexBuffer(3,ArrowDn,INDICATOR_DATA);
   ArraySetAsSeries(ArrowDn,true);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);  
   PlotIndexSetInteger(3, PLOT_ARROW, 234);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -20); 

//---- set dynamic array as as a buffer for data saving   
   SetIndexBuffer(4,TimeSeriesBuffer,INDICATOR_DATA);
   ArraySetAsSeries(TimeSeriesBuffer,true);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"FullSSA");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);

   //---- end of initialization
   ArrayInitialize(MaBuffer,0.0);  
   ArrayInitialize(IndBuffer,0.0);
   ArrayInitialize(ArrowUp,0.0);
   ArrayInitialize(ArrowDn,0.0);
  }

//+------------------------------------------------------------------+  
//| FullSSA iteration function                                       | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   


    //---- checking for the sufficiency of the number of bars for the calculation
   if(BarsCalculated(MA_Handle)<rates_total
      || BarsCalculated(STD_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);     


      //---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-iN);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,rates_total-iN);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double MA[],STD[];

//---- calculations of the necessary number of copied data and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation 1
   {
      limit=rates_total-1-min_rates_total-ma_periods; // starting index for the calculation of all bars
      for(bar=rates_total-1; bar>limit && !IsStopped(); bar--) IndBuffer[bar]=0.0;
   }
   else
   {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
   }

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);
   if(CopyBuffer(STD_Handle,0,0,to_copy,STD)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(MA,true);
   ArraySetAsSeries(STD,true);
   ArraySetAsSeries(close,true);

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double res=close[bar]-MA[bar];
      if(STD[bar]) TimeSeriesBuffer[bar]=res/(3*STD[bar]);
      else TimeSeriesBuffer[bar]=res/0.1;   
    }
//----
   fastsingular(TimeSeriesBuffer,iN,Lag,NumComps,IndBuffer);
//---- 

double sum=0;
for(bar=iN-ma_periods-1; bar>=0 && !IsStopped(); bar--) {
      sum = 0;
     for(int n =0; n < ma_periods; n++) {
         sum += IndBuffer[bar+n];            
       }
       MaBuffer[bar]=sum/ma_periods;     
  }


  for(int n=iN; n<ArraySize(ArrowUp); n++) {
    ArrowUp[n]=0;
    ArrowDn[n]=0;
  }

  for(bar=0; bar<iN; bar++) {
      ArrowUp[bar]=0;
      ArrowDn[bar]=0;
      if(IndBuffer[bar]>MaBuffer[bar] && IndBuffer[bar+1]<=MaBuffer[bar+1]) {
        ArrowUp[bar]=IndBuffer[bar];
      }
      if(IndBuffer[bar]<MaBuffer[bar] && IndBuffer[bar+1]>=MaBuffer[bar+1]) {
        ArrowDn[bar]=IndBuffer[bar];
      }
  }


   return(rates_total);
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75700

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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