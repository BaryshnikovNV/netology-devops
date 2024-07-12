# Создание объекта в существующей папке с изображением кошки
resource "yandex_storage_object" "cute-cat-picture" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = local.bucket_name
  key    = "cute-cat-picture.jpg"
  source = "./cute-cat-picture.jpg"
  acl = "public-read"
  depends_on = [yandex_storage_bucket.baryshnikov-nv]
}