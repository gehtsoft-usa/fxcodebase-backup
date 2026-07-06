//+------------------------------------------------------------------+
//|                                  Polynomial_Regression_Slope.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=50;
extern int Power=2;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

double PRS[], PRS_DN[];
double Pr[];
double sumxvalue[], sumyvalue[], constant[], matrix[];

int init()
{
 IndicatorShortName("Polynomial Regression Slope");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,PRS);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,PRS_DN);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Pr);
 
 ArrayResize(sumxvalue, 2*Power+4);
 ArrayResize(sumyvalue, Power+2);
 ArrayResize(constant, Power+2);
 ArrayResize(matrix, (Power+2)*(Power+2));
 
 ArrayInitialize(sumxvalue, 0.);
 ArrayInitialize(sumyvalue, 0.);
 ArrayInitialize(constant, 0.);
 ArrayInitialize(matrix, 0.);

 return(0);
}

int deinit()
{

 return(0);
}

double GetM(int _c, int _r)
{
 return (matrix[_c*(Power+1)+_r]);
}

void SetM(int _c, int _r, double _v)
{
 matrix[_c*(Power+1)+_r]=_v;
 
 return;
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int _pos;
 int _exp, k;
 double sumx, sumy, sum;
 int col, row;
 int initCol, initRow, i, j;
 double Start, End;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
 
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  ArrayInitialize(sumxvalue, 0.);
  ArrayInitialize(sumyvalue, 0.);
  ArrayInitialize(constant, 0.);
  ArrayInitialize(matrix, 0.);
  
  _pos=pos+Length-1;
  
  sumxvalue[0]=Length;
  
  for (_exp=1;_exp<=2*Power;_exp++)
  {
   sumx=0.; sumy=0.;
   for (k=1;k<=Length;k++)
   {
    sumx=sumx+MathPow(k, _exp);
    if (_exp==1)
    {
     sumy=sumy+Pr[_pos-k+1];
    }
    else
    {
     sumy=sumy+Pr[_pos-k+1]*MathPow(k, _exp-1);
    }
   }
   sumxvalue[_exp]=sumx;
   if (sumy!=0.)
   {
    sumyvalue[_exp-1]=sumy;
   }
  }
  
  for (row=0;row<=Power;row++)
  {
   for (col=0;col<=Power;col++)
   {
    SetM(row, col, sumxvalue[row+col]);
   }
  }
  
  initCol=1; initRow=1;
  for(i=1;i<=Power;i++)
  {
   for (row=initRow;row<=Power;row++)
   {
    sumyvalue[row]=sumyvalue[row]-GetM(row, i-1)*sumyvalue[i-1]/GetM(i-1, i-1);
    for (col=initCol;col<=Power;col++)
    {
     SetM(row, col, GetM(row, col)-GetM(row, i-1)*GetM(i-1, col)/GetM(i-1, i-1));
    }
   }
   initCol++;
   initRow++;
  }
  
  j=0;
  for (i=Power;i>=0;i--)
  {
   if (j==0)
   {
    constant[i]=sumyvalue[i]/GetM(i, i);
   }
   else
   {
    sum=0.;
    for (k=j;k>=1;k--)
    {
     sum=sum+constant[i+k]*GetM(i, i+k);
    }
    constant[i]=(sumyvalue[i]-sum)/GetM(i, i);
   }
   j++;
  }
  
  k=1;
  for (i=pos+Length-1;i>=pos;i--)
  {
   sum=0.;
   for (j=0;j<=Power;j++)
   {
    sum=sum+constant[j]*MathPow(k, j);
   }
   if (i==pos+Length-1)
   {
    Start=sum;
   }
   k++;
  }
  End=sum;
  PRS[pos]=(End-Start)/Point;
  
  if (PRS[pos]<PRS[pos+1])
  {
   PRS_DN[pos]=PRS[pos];
  }
  else
  {
   PRS_DN[pos]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

