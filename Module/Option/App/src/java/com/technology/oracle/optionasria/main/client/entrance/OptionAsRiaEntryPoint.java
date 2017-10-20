package com.technology.oracle.optionasria.main.client.entrance;
 
import com.technology.oracle.optionasria.main.client.OptionAsRiaClientFactoryImpl;
import com.technology.jep.jepria.client.entrance.JepEntryPoint;
 
public class OptionAsRiaEntryPoint extends JepEntryPoint {
 
	OptionAsRiaEntryPoint() {
		super(OptionAsRiaClientFactoryImpl.getInstance());
	}
}
