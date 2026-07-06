//+------------------------------------------------------------------+
//|                                       Logarithmic_Regression.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue

extern int Length=50;
extern double Deviation=1;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Upper[], Lower[], Middle[];

double sumyvalue[4], constant[4], matrix[4][4], sumxvalue[8];

int init()
  {
   IndicatorShortName("Logarithmic Regression");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Middle);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Upper);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Lower);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int exp;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 double sumx, sumy, sum;
 double lnx;
 double variance;
 int row, col;
 double a;
 int k;
 int i;
 ArrayInitialize(sumxvalue,0);
 ArrayInitialize(sumyvalue,0);
 ArrayInitialize(constant,0);
 ArrayInitialize(matrix,0);
  
 sumxvalue[0]=Length;
 for (exp=1;exp<=2;exp++)
 {
  sumx=0;
  sumy=0;
  for (k=1;k<=Length;k++)
  {
   lnx=MathLog(k);
   sumx=sumx+MathPow(lnx,exp);
   if (exp==1)
   {
    sumy=sumy+MathLog(iMA(NULL, 0, 1, 0, MODE_SMA, Price, Length-k));
   }
   else
   {
    sumy=sumy+MathLog(iMA(NULL, 0, 1, 0, MODE_SMA, Price, Length-k))*MathPow(lnx,exp-1);
   }
  }
  sumxvalue[exp]=sumx;
  if (sumy!=0)
  {
   sumyvalue[exp-1]=sumy;
  }
 } 
 
 for (row=0;row<=1;row++)
 {
  for (col=0;col<=1;col++)
  {
   matrix[row][col]=sumxvalue[row+col];
  }
 }
 sumyvalue[1]=sumyvalue[1]-(matrix[1][0]/matrix[0][0])*sumyvalue[0];
 matrix[1][1]=matrix[1][1]-(matrix[1][0]/matrix[0][0])*matrix[0][1];
 
 constant[1]=sumyvalue[1]/matrix[1][1];
 a=(sumyvalue[0]-constant[1]*matrix[0][1])/matrix[0][0];
 constant[0]=MathExp(a);
 
 k=1;
 sum=0;
 for (i=Length-1;i>=0;i--)
 {
  Middle[i]=constant[0]*MathPow(k,constant[1]);
  sum=sum+MathPow(iMA(NULL, 0, 1, 0, MODE_SMA, Price, i)-Middle[i],2);
  k++;
 }
 Middle[Length]=EMPTY_VALUE;
 
 variance=MathSqrt(sum/Length);
 for (i=Length-1;i>=0;i--)
 {
  Upper[i]=Middle[i]+Deviation*variance;
  Lower[i]=Middle[i]-Deviation*variance;
 }
 Upper[Length]=EMPTY_VALUE;
 Lower[Length]=EMPTY_VALUE;
 return(0);
}

