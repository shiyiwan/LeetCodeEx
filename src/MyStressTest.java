package com.idle;

public class MyStressTest {
	public static void main(String[] args) {
		int times = 1000;
		MyExecutor myExecutor = new MyExecutor();
		for (int i = 0; i < times; i++) {
			try {
				myExecutor.runInterface(i);
			} catch (Exception e) {
				throw new RuntimeException("ERROR");
			}
		}
	}
}
