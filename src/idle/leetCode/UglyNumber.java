package idle.leetCode;

public class UglyNumber {

	public static void main(String[] args) {
		System.out.println(isUglyNumber(35));

	}

	public static boolean getPrime(long i) {
		long max = i / 2 + 1;
		for (long n = 2; n < max; n++) {
			if (i % n == 0) {
				return false;
			}
		}
		return true;
	}
	
	public static boolean isUglyNumber(long number){
		if (number <= 0 )
			return false;
		if (number == 1)
			return true;
		long max = number / 2 + 1;
		for (long n = 2; n < max; n++){
			if ( number % n == 0 && getPrime(n) && n != 2 && n != 3 && n != 5)
				return false;
		}
		return true;
	}
	
	// better solution
	public boolean isUgly(long num) {
        if(num <= 0)   
            return false;  
        if(num == 1) {  
            return true;  
        }  
        if(num % 5 == 0) {  
            return isUgly(num / 5);  
        } else if(num % 3 == 0) {  
            return isUgly(num / 3);  
        } else if(num % 2 == 0) {  
            return isUgly(num / 2);  
        } else {  
            return false;  
        }  
    }

}
