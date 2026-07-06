//+------------------------------------------------------------------+
//|                                        Polynomial_Regression.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Yellow
#property indicator_color3 Yellow

extern int Length=50;
extern int Power=2;
extern double Deviation=1;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Regression[], BandUp[], BandDn[];

int init()
  {
   IndicatorShortName("Polynomial regression");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Regression);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BandUp);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BandDn);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   if (Power>9) return;
   int i, ii;
   double sumxvalue[21], sumyvalue[11], constant[11], matrix[11][11];
   ArrayInitialize(sumxvalue,0);
   ArrayInitialize(sumyvalue,0);
   ArrayInitialize(constant,0);
   ArrayInitialize(matrix,0);
   
   int pos=Length-1;
   
   sumxvalue[0]=Length;
   
   int exp;
   double sumx, sumy;
   int k;
   for (exp=1;exp<=2*Power;exp++)
   {
    sumx=0;
    sumy=0;
    for (k=1;k<=Length;k++)
    {
     sumx=sumx+MathPow(k,exp);
     if (exp==1)
     {
      sumy=sumy+iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos-k+1);
     }
     else
     {
      if (exp<=Power+1)
      {
       sumy=sumy+iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos-k+1)*MathPow(k,exp-1);
      }
     }
    }
    sumxvalue[exp]=sumx;
    if (sumy!=0)
    {
     sumyvalue[exp-1]=sumy;
    }
   }
   
   int row, col;
   for (row=0;row<=Power;row++)
   {
    for (col=0;col<=Power;col++)
    {
     matrix[row][col]=sumxvalue[row+col];
    }
   }
   
   int initialRow=1;
   int initialCol=1;
   for (i=1;i<=Power;i++)
   {
    for (row=initialRow;row<=Power;row++)
    {
     sumyvalue[row]=sumyvalue[row]-(matrix[row][i-1]/matrix[i-1][i-1])*sumyvalue[i-1];
     for (col=initialCol;col<=Power;col++)
     {
      matrix[row][col]=matrix[row][col]-(matrix[row][i-1]/matrix[i-1][i-1])*matrix[i-1][col];
     }
    }
    initialCol++;
    initialRow++;
   }
   int j=0;
   for (i=Power;i>=0;i--)
   {
    if (j==0)
    {
     constant[i]=sumyvalue[i]/matrix[i][i];
    }
    else
    {
     double sum=0;
     for (k=j;k>=1;k--)
     {
      sum=sum+constant[i+k]*matrix[i][i+k];
     }
     constant[i]=(sumyvalue[i]-sum)/matrix[i][i];
    }
    j++;
   }
   
   k=1;
   for (i=Length-1;i>=0;i--)
   {
    sum=0;
    for (j=0;j<=Power;j++)
    {
     sum=sum+constant[j]*MathPow(k,j);
    }
    Regression[i]=sum;
    k++;
   }
   Regression[Length]=EMPTY_VALUE;
   
   sum=0;
   for (i=Length-1;i>=0;i--)
   {
    sum=sum+MathPow(iMA(NULL, 0, 1, 0, MODE_SMA, Price, i)-Regression[i],2);
   }
   double variance=MathSqrt(sum/Length);
   for (i=Length-1;i>=0;i--)
   {
    BandUp[i]=Regression[i]+Deviation*variance;
    BandDn[i]=Regression[i]-Deviation*variance;
   }
   BandUp[Length]=EMPTY_VALUE;
   BandDn[Length]=EMPTY_VALUE;

   return(0);
  }

