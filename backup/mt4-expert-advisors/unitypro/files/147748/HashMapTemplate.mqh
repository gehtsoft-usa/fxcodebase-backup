//+------------------------------------------------------------------+
//|                                              HashMapTemplate.mqh |
//|                                      Copyright © 2017, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//|   Helper hash map for Simple EA for testing probability approach |
//|                            https://www.mql5.com/ru/articles/3264 |
//+------------------------------------------------------------------+

template<typename K, typename V>
class HashMapTemplate
{
  private:
    K keys[];
    V values[];
    int count;
    K emptyKey;
    V emptyValue;
    
  protected:
    void add(const K key, const V value)
    {
      ArrayResize(keys, count + 1);
      ArrayResize(values, count + 1);
      keys[count] = key;
      values[count] = value;
      count++;
    }
    
  public:
    HashMapTemplate(): count(0), emptyKey(NULL), emptyValue((V)EMPTY_VALUE){};
    HashMapTemplate(const K nokey, const V empty): count(0), emptyKey(nokey), emptyValue(empty){};
    
    ~HashMapTemplate()
    {
      reset();
    }

    void reset()
    {
      ArrayResize(keys, 0);
      ArrayResize(values, 0);
      count = 0;
    }
    
    int getIndex(K key) const
    {
      for(int i = 0; i < count; i++)
      {
        if(keys[i] == key) return(i);
      }
      return -1;
    }
    
    K getKey(int index) const
    {
      if(index < 0 || index >= count)
      {
        Print(__FUNCSIG__, ": index out of bounds = ", index);
        return NULL;
      }
      return(keys[index]);
    }
    
    
    V operator[](int index) const
    {
      if(index < 0 || index >= count)
      {
        Print(__FUNCSIG__, ": index out of bounds = ", index);
        return(emptyValue);
      }
      return(values[index]);
    }
    
    V operator[](K key) const
    {
      for(int i = 0; i < count; i++)
      {
        if(keys[i] == key) return(values[i]);
      }
      Print(__FUNCSIG__, ": no key=", key);
      return(emptyValue);
    }
    
    void set(const K key, const V value)
    {
      int index = getIndex(key);
      if(index != -1)
      {
        values[index] = value;
      }
      else
      {
        add(key, value);
      }
    }
    
    void inc(const K key, const V value)
    {
      int index = getIndex(key);
      if(index != -1)
      {
        values[index] += value;
      }
      else
      {
        add(key, value);
      }
    }
    
    void remove(const K key)
    {
      int index = getIndex(key);
      if(index != -1)
      {
        keys[index] = emptyKey;
        values[index] = emptyValue;
      }
    }
    
    void purge()
    {
      int write = 0;
      int i = 0;
      while(i < count)
      {
        while(i < count && keys[i] == emptyKey)
        {
          i++;
        }
        
        while(i < count && keys[i] != emptyKey)
        {
          if(write < i)
          {
            values[write] = values[i];
            keys[write] = keys[i];
          }
          i++;
          write++;
        }
      }
      count = write;
      ArrayResize(keys, count);
      ArrayResize(values, count);
    }
    
    int getSize() const
    {
      return(count);
    }

};
