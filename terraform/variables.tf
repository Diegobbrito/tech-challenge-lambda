variable "DB_HOST" {
  description = "Database host"
}
variable "DB_USER" {
  description = "Database User name"
}
variable "DB_PASSWORD" {
  description = "Database password"
}
variable "SECRET" {
  description = "Jwt secret"
}

variable "db_name" {
  description = "Database name"
  default     = "lanchonete"
}