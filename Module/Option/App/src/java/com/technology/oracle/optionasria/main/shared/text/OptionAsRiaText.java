package com.technology.oracle.optionasria.main.shared.text;

/**
 * Interface to represent the constants contained in resource bundle:
 * 	'C:/work/workspace/Oracle/Module/Option/Trunk/App/src/java/com/technology/oracle/optionasria/main/shared/text/OptionAsRiaText.properties'.
 */
public interface OptionAsRiaText extends com.google.gwt.i18n.client.Constants {
  
  /**
   * Translated "Option".
   * 
   * @return translated "Option"
   */
  @DefaultStringValue("Option")
  @Key("module.title")
  String module_title();

  /**
   * Translated "Параметр".
   * 
   * @return translated "Параметр"
   */
  @DefaultStringValue("Параметр")
  @Key("submodule.option.title")
  String submodule_option_title();

  /**
   * Translated "Значения Параметра".
   * 
   * @return translated "Значения Параметра"
   */
  @DefaultStringValue("Значения Параметра")
  @Key("submodule.value.title")
  String submodule_value_title();
}
