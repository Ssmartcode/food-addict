resource "azurerm_api_management_api_operation_policy" "app_get_restaurant_policy" {
  api_name            = azurerm_api_management_api.foodaddict_api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  operation_id        = "getRestaurant"

  xml_content = file("../policies/getRestaurant.xml")
}

resource "azurerm_api_management_api_operation_policy" "app_post_restaurant_policy" {
  api_name            = azurerm_api_management_api.foodaddict_api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  operation_id        = "postRestaurant"

  xml_content = file("../policies/postRestaurant.xml")
}
