package idle.leetCode;

public class MoveZero {
	public void moveZeroes(int[] nums) {
		int NonZeroPos = 0;
		int zeroPos = 0;
		while (zeroPos < nums.length) {

			if (nums[zeroPos] != 0) {
				if (zeroPos != NonZeroPos) {
					nums[NonZeroPos++] = nums[zeroPos];
					nums[zeroPos] = 0;
				} else
					NonZeroPos++;
			}
			zeroPos++;
		}
	}

	public static void main(String[] args) {
		int[] nums = { 0, 1, 3, 0, 4 };
		new MoveZero().moveZeroes(nums);
		for (int i = 0; i < nums.length; i++)
			System.out.print(nums[i]);

	}
}
