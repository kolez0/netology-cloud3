resource "yandex_iam_service_account" "instance_group_sa" {
  name        = "instance-group-sa"
  folder_id   = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "instance_group_sa_roles" {
  for_each = toset([
    "storage.viewer",
    "kms.keys.encrypterDecrypter",
  ])

  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.instance_group_sa.id}"
}

resource "yandex_kms_symmetric_key" "bucket_key" {
  name              = "bucket-encryption-key"
  description       = "KMS key for Object Storage bucket server-side encryption"
  folder_id         = var.folder_id
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}

resource "yandex_storage_bucket" "bucket" {
  bucket     = var.bucket_name
  folder_id  = var.folder_id
  access_key = null 

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

}

resource "yandex_storage_bucket_grant" "public_read" {
  bucket = yandex_storage_bucket.bucket.id

  grant {
    uri         = "http://acs.amazonaws.com/groups/global/AllUsers"
    permissions = ["READ"]
    type        = "Group"
  }

  depends_on = [yandex_storage_bucket.bucket]
}

resource "yandex_storage_object" "image" {
  bucket      = yandex_storage_bucket.bucket.id
  key         = "image.jpg"
  source      = var.image_path
  acl         = "public-read"
  depends_on  = [yandex_storage_bucket.bucket]
}

