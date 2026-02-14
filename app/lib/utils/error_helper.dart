import 'package:grpc/grpc.dart';

/// Extracts a user-friendly error message from any error, including gRPC errors.
String friendlyError(Object error) {
  if (error is GrpcError) {
    // Use the gRPC message if available, otherwise map status codes
    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }
    switch (error.code) {
      case StatusCode.unavailable:
        return 'Service unavailable. Check your connection.';
      case StatusCode.deadlineExceeded:
        return 'Request timed out. Please try again.';
      case StatusCode.permissionDenied:
        return 'Permission denied.';
      case StatusCode.unauthenticated:
        return 'Authentication required.';
      case StatusCode.notFound:
        return 'Resource not found.';
      case StatusCode.alreadyExists:
        return 'Resource already exists.';
      case StatusCode.invalidArgument:
        return 'Invalid input.';
      case StatusCode.internal:
        return 'Internal error. Please try again.';
      default:
        return 'Operation failed (code ${error.code}).';
    }
  }
  return error.toString();
}
