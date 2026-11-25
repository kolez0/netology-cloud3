output "bucket_url" {
  description = "Публичный URL картинки в бакете"
  value       = "https://storage.yandexcloud.net/${yandex_storage_bucket.bucket.bucket}/image.jpg"
}

output "kms_key_id" {
  description = "ID ключа KMS, которым шифруется бакет"
  value       = yandex_kms_symmetric_key.bucket_key.id
}
