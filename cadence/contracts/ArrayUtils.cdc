// Copied from https://github.com/bluesign/flow-utils/blob/dnz/cadence/contracts/ArrayUtils.cdc with minor adjustments

pub contract ArrayUtils {

    
    pub fun rangeFunc(_ start: Int, _ end: Int, _ f : ((Int):Void) ) {
        var current = start
        while current < end{
            f(current)
            current = current + 1
        }
    }

    pub fun range(_ start: Int, _ end: Int): [Int]{
        var res:[Int] = []
        self.rangeFunc(start, end, fun (i:Int){
            res.append(i)
        })
        return res
    }

    pub fun transform(_ array: &[AnyStruct], _ f : ((AnyStruct): AnyStruct)){
        for i in self.range(0, array.length){
            array[i] = f(array[i])
        }
    }

    pub fun iterate(_ array: [AnyStruct], _ f : ((AnyStruct): Bool)){
        for item in array{
            if !f(item){
                break
            }
        }
    }

    pub fun map(_ array: [AnyStruct], _ f : ((AnyStruct): AnyStruct)) : [AnyStruct] {
        var res : [AnyStruct] = []
        for item in array{
            res.append(f(item))
        }
        return res
    }

    pub fun mapStrings(_ array: [String], _ f: ((String) : String) ) : [String] {
        var res : [String] = []
        for item in array{
            res.append(f(item))
        }
        return res
    }

    pub fun reduce(_ array: [AnyStruct], _ initial: AnyStruct, _ f : ((AnyStruct, AnyStruct): AnyStruct)) : AnyStruct{
        var res: AnyStruct = f(initial, array[0])
        for i in self.range(1, array.length){
            res =  f(res, array[i])
        }
        return res
    }

   
    //heap sort 
    //TODO: @bluesign: we need to add some generic comparators
    pub fun comparatorUInt64(a:AnyStruct, b:AnyStruct, _ reverse:Bool):Bool{
      if reverse {
        return (a as! UInt64)<(b as! UInt64)
      }else{
        return (a as! UInt64)>(b as! UInt64)
      }
    }

    priv fun heapify(_ arr: &[AnyStruct], _ n:Int, _ i:Int, _ comparator: ((AnyStruct, AnyStruct, Bool): Bool), _ reverse:Bool) {
      var largest = i;
      var left = 2 * i + 1;
      var right = 2 * i + 2;

      if (left < n && comparator(arr[left], arr[largest], reverse)){
        largest = left
      }

      if (right < n && comparator(arr[right], arr[largest], reverse)){
        largest = right
      }

      if (largest != i) {
        arr[i]<->arr[largest]
        ArrayUtils.heapify(arr, n, largest, comparator, reverse);
      }
    }

    pub fun heapSort(_ arr: &[AnyStruct], _ comparator: ((AnyStruct, AnyStruct, Bool): Bool), _ reverse:Bool ) {
      var n = arr.length

      var i = (n / 2) - 1
      while i>=0{
          ArrayUtils.heapify(arr, n, i,comparator, reverse);
          i=i-1
      }
      
      i = n - 1
      while i>=0{
          arr[0]<->arr[i]
          ArrayUtils.heapify(arr, i, 0, comparator, reverse);
          i=i-1
      }
    }

}
 
