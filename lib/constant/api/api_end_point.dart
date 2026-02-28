class ApiEndPoint {
  //// live
  static const baseUrl = "https://fakestoreapi.com";
  static const imageUrl = "https://fakestoreapi.com";

  //////////////// Auth part /////////////////
  static const login = "/auth/login";
  static const users = "/users";

  //////////// products ///////////////////
  static const products = "/products";
  static const categories = "/products/categories";
  static const productsByCategory = "/products/category"; // /products/category/{category}

  //////////// profile ///////////////////
  static String userProfile(int userId) => "/users/$userId";
}
