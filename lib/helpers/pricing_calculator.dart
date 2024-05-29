class TPricingCalculator {
  /// Calculate Price based on tax and shipping
  static double calculateTotalPrice(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;

    double shippingCost = getShippingCost(location);

    double totalPrice = productPrice + taxAmount + shippingCost;
    return totalPrice;
  }

  /// Calculate shipping cost
  static String calculateShippingCost(double productPrice, String location) {
    double shippingCost = getShippingCost(location);
    return shippingCost.toStringAsFixed(2);
  }

  /// Calculate tax
  static String calculateTax(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;
    return taxAmount.toStringAsFixed(2);
  }

  // Mock functions to get tax rate and shipping cost (Replace with actual implementation)
  static double getTaxRateForLocation(String location) {
    // Example implementation, replace with actual logic to get tax rate for the location
    return 0.10; // 10% tax rate
  }

  static double getShippingCost(String location) {
    // Example implementation, replace with actual logic to get shipping cost for the location
    return 5.0; // $5 shipping cost
  }

  /// -- Calculate shipping cost
  static String colculateShippingCost(double productPrice, String location) {
    double shippingCost = getShippingCost(location);
    return shippingCost.toStringAsFixed(2);
  }
  

}
