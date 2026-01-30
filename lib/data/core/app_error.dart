class AppError implements Exception {
  final String? title;
  final int? statusCode;
  final String? message;

  const AppError({
    this.title,
    this.statusCode,
    this.message,
  });

  @override
  String toString() {
    return 'AppError(title: $title, statusCode: $statusCode, message: $message)';
  }
}