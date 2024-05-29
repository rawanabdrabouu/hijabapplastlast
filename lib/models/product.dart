class Product {
  String id;
  String name;
  String description;
  double price;
  String imageUrl;
  String category;
  int stock;
  double averageRating;
  List<Comment> comments;
  double discount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    this.averageRating = 0.0,
    this.comments = const [],
    this.discount = 0.0, // default to no discount
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'averageRating': averageRating,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'discount': discount,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'averageRating': averageRating,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'discount': discount,
    };
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      imageUrl: map['imageUrl'],
      category: map['category'],
      stock: map['stock'],
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      comments: (map['comments'] as List<dynamic>?)
              ?.map((comment) => Comment.fromMap(Map<String, dynamic>.from(comment)))
              .toList() ??
          [],
      discount: (map['discount'] ?? 0.0).toDouble(),
    );
  }
}

class Comment {
  String userId;
  String userName;
  String text;
  double rating;

  Comment({
    required this.userId,
    required this.userName,
    required this.text,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'rating': rating,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'rating': rating,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'],
      userName: map['userName'],
      text: map['text'],
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }
}
