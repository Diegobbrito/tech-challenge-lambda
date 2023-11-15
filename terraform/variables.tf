variable "db_host" {
  description = "Database host"
}
variable "db_name" {
  description = "Database name"
  default     = "lanchonete"
}

variable "db_user" {
  description = "Database User name"
}

variable "db_password" {
  description = "Database password"
}

variable "secret" {
  description = "Jwt secret"
}