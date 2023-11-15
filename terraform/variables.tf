variable "db_host" {
  description = "Database host"
  default     = ""
}
variable "db_name" {
  description = "Database name"
  default     = "lanchonete"
}

variable "db_user" {
  description = "Database User name"
  default     = ""
}

variable "db_password" {
  description = "Database password"
  default     = ""
}

variable "secret" {
  description = "Jwt secret"
  default     = ""
}