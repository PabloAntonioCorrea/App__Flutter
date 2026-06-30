class ServiceResult<T> {
  final T data;
  final bool fromCache;

  const ServiceResult(this.data, {this.fromCache = false});
}
