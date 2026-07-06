//+------------------------------------------------------------------+
//|                                                     IndArray.mqh |
//|                                 Copyright © 2016-2018, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|     MQL's OOP: Arrayed indicator buffers on overloaded operators |
//|                        https://www.mql5.com/en/blogs/post/680572 |
//+------------------------------------------------------------------+

// helper defines
#define SETTER int
#define GETTER uint


class IndicatorGetter;         // forward declaration, helper class

class Indicator                // main indicator buffer class
{
  private:
    double buffer[];           // indicator buffer
    
    int cursor;                // position in the buffer
    
    IndicatorGetter *instance; // helper object for reading values (optional)
    
  public:
    Indicator(int i)
    {
      SetIndexBuffer(i, buffer);
      ArraySetAsSeries(buffer, true);
      ArrayInitialize(buffer, EMPTY_VALUE);
      instance = new IndicatorGetter(this);
    }
    
    virtual ~Indicator()
    {
      delete instance;
    }

    double operator[](GETTER b)
    {
      return buffer[b];
    }
    
    Indicator *operator[](SETTER b)
    {
      cursor = (int)b;
      return GetPointer(this);
    }
    
    double operator=(double x)
    {
      buffer[cursor] = x;
      return x;
    }
    
    IndicatorGetter *edit() const
    {
      return instance;
    }
    
    double operator+(double x) const
    {
      return buffer[cursor] + x;
    }
    
    double operator-(double x) const
    {
      return buffer[cursor] - x;
    }
    
    double operator*(double x) const
    {
      return buffer[cursor] * x;
    }
    
    double operator/(double x) const
    {
      return buffer[cursor] / x;
    }

    double operator+=(double x)
    {
      buffer[cursor] += x;
      return buffer[cursor];
    }
    
    double operator-=(double x)
    {
      buffer[cursor] -= x;
      return buffer[cursor];
    }
    
    double operator*=(double x)
    {
      buffer[cursor] *= x;
      return buffer[cursor];
    }
    
    double operator/=(double x)
    {
      buffer[cursor] /= x;
      return buffer[cursor];
    }

};

class IndicatorGetter       // helper class to access buffer values directly
{
  private:
    Indicator *owner;
    int cursor;
    
  public:
    IndicatorGetter(Indicator &o)
    {
      owner = GetPointer(o);
    }
    
    double operator[](int b)
    {
      return owner[(GETTER)b];
    }
};

class IndicatorArray
{
  private:
    Indicator *array[];
    
  public:
    IndicatorArray(int n)
    {
      ArrayResize(array, n);
      for(int i = 0; i < n; ++i)
      {
        array[i] = new Indicator(i);
      }
    }
    
    virtual ~IndicatorArray()
    {
      int n = ArraySize(array);
      for(int i = 0; i < n; ++i)
      {
        if(CheckPointer(array[i]) == POINTER_DYNAMIC)
        {
          delete array[i];
        }
      }
      ArrayResize(array, 0);
    }
    
    Indicator *operator[](int n) const
    {
      return array[n];
    }
    
    int size() const
    {
      return ArraySize(array);
    }
};

class IndicatorArrayGetter
{
  private:
    IndicatorGetter *array[];
    
  public:
    IndicatorArrayGetter(){};
    
    IndicatorArrayGetter(const IndicatorArray &a)
    {
      bind(a);
    }
    
    void bind(const IndicatorArray &a)
    {
      int n = a.size();
      ArrayResize(array, n);
      for(int i = 0; i < n; ++i)
      {
        array[i] = a[i].edit();
      }
    }
    
    IndicatorGetter *operator[](int n) const
    {
      return array[n];
    }
    
    virtual ~IndicatorArrayGetter()
    {
      ArrayResize(array, 0);
    }
};

