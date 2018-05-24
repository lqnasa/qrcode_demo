package com.lee.qrcode.controller;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Proxy;
import java.util.Map;

public class ReflectionAnnotationTest {

	public static void main(String[] args) throws Exception {
		// 获取Bar实例
		Bar bar = new Bar();
		changeAnnotation(bar, "changeVal");

		Field declaredField = bar.getClass().getDeclaredField("value");
		Foo annotation = declaredField.getAnnotation(Foo.class);
		// 获取 foo 的 value 属性值
		String newValue = annotation.value();
		System.out.println("修改之后的注解值：" + newValue);

		Field declaredField2 = Bar.class.getDeclaredField("value");
		Foo annotation2 = declaredField2.getAnnotation(Foo.class);
		System.out.println(annotation2.value());

		new Thread(()->{
			
			// 获取Bar实例
			Bar bar2 = new Bar();
			try {
				changeAnnotation(bar2, "changeVal2");
				Field declaredField_ = bar2.getClass().getDeclaredField("value");
				Foo annotation_ = declaredField_.getAnnotation(Foo.class);
				// 获取 foo 的 value 属性值
				String newValue2 = annotation_.value();
				System.out.println("修改之后的注解值：" + newValue2);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}).start();
		
		
		Thread.sleep(1000);
		
		System.out.println("修改之后的注解值--：" + annotation.value());
	}

	private static void changeAnnotation(Bar bar, String val) throws NoSuchFieldException, IllegalAccessException {
		// 获取Bar的val字段
		Field field = bar.getClass().getDeclaredField("value");
		// 获取val字段上的Foo注解实例
		Foo foo = field.getAnnotation(Foo.class);
		// 获取Foo注解实例的 value 属性值
		String value = foo.value();
		// 打印该值
		System.out.println("修改之前的注解值：" + value);

		System.out.println("------------以下是修改注解的值------------");

		// 获取 foo 这个代理实例所持有的 InvocationHandler
		InvocationHandler invocationHandler = Proxy.getInvocationHandler(foo);
		// 获取 AnnotationInvocationHandler 的 memberValues 字段
		Field declaredField = invocationHandler.getClass().getDeclaredField("memberValues");
		// 因为这个字段事 private final 修饰，所以要打开权限
		declaredField.setAccessible(true);
		// 获取 memberValues
		Map memberValues = (Map) declaredField.get(invocationHandler);
		// 修改 value 属性值
		memberValues.put("value", val);

	}

}