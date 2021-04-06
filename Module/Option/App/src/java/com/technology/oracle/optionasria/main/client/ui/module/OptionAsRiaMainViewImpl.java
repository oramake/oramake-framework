package com.technology.oracle.optionasria.main.client.ui.module;

import com.technology.jep.jepria.client.ui.main.MainViewImpl;
import com.technology.jep.jepria.client.ui.main.ModuleConfiguration;

import java.util.ArrayList;
import java.util.List;

import static com.technology.oracle.optionasria.main.client.OptionAsRiaClientConstant.*;


public class OptionAsRiaMainViewImpl extends MainViewImpl {

  @Override
  protected List<ModuleConfiguration> getModuleConfigurations() {
    List<ModuleConfiguration> ret = new ArrayList<>();
    ret.add(new ModuleConfiguration(OPTION_MODULE_ID, optionText.submodule_option_title()));
    ret.add(new ModuleConfiguration(VALUE_MODULE_ID,optionText.submodule_value_title()));
    return ret;
  }
}
